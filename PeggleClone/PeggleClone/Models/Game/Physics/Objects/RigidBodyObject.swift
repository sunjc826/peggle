import Foundation
import CoreGraphics

final class RigidBodyObject: RigidBody, HasBoundingBox, Equatable, Hashable {
    var backingShape: TransformableShape
    var associatedEntity: GameEntity?

    var nextTeleportLocation: CGPoint?

    var isAffectedByGlobalForces: Bool

    var scale: Double {
        get {
            backingShape.scale
        }
        set {
            backingShape.scale = newValue
        }
    }

    var rotation: Double {
        get {
            backingShape.rotation
        }
        set {
            backingShape.rotation = newValue
        }
    }

    var polarVerticesRelativeToOwnCenterBeforeTransform: [PolarCoordinate] {
        switch backingShape {
        case is CircleObject:
            return []
        case let polygon as TransformablePolygonObject:
            return polygon.polarVerticesRelativeToOwnCenterBeforeTransform
        default:
            fatalError(shapeCastingMessage)
        }

    }

    var center: CGPoint {
        get {
            backingShape.center
        }
        set {
            backingShape.center = newValue
        }
    }

    var sides: Int {
        switch backingShape {
        case is CircleObject:
            return 0
        case let polygon as TransformablePolygonObject:
            return polygon.sides
        default:
            fatalError(shapeCastingMessage)
        }
    }

    var canTranslate: Bool

    var canRotate: Bool

    var uniformDensity: Double

    var mass: Double

    var inverseMass: Double

    var momentOfInertia: Double

    var inverseMomentOfInertia: Double

    var linearVelocity = CGVector.zero

    var angularVelocity: Double = 0

    var force = CGVector.zero

    var impulseIgnoringForce = CGVector.zero

    var torque: Double = 0

    var angularImpulseIgnoringTorque: Double = 0

    var elasticity: Double {
        didSet {
            assert(0 <= elasticity && elasticity <= 1)
        }
    }

    var boundingBox: BoundingBox {
        backingShape.boundingBox
    }

    var leftWallBehavior: WallBehavior

    var rightWallBehavior: WallBehavior

    var topWallBehavior: WallBehavior

    var bottomWallBehavior: WallBehavior

    var hasCollidedMostRecently = false

    var consecutiveCollisionCount: Int = 0

    init(
        backingShape: TransformableShape,
        associatedEntity: GameEntity?,
        isAffectedByGlobalForces: Bool,
        canTranslate: Bool,
        canRotate: Bool,
        leftWallBehavior: WallBehavior = .collide,
        rightWallBehavior: WallBehavior = .collide,
        topWallBehavior: WallBehavior = .collide,
        bottomWallBehavior: WallBehavior = .collide,
        uniformDensity: Double = 1,
        elasticity: Double = 0.9,
        initialVelocity: CGVector = CGVector.zero,
        consecutiveCollisionCount: Int = 0
    ) {
        assert(uniformDensity > 0)
        self.backingShape = backingShape
        self.associatedEntity = associatedEntity
        self.isAffectedByGlobalForces = isAffectedByGlobalForces
        self.canTranslate = canTranslate
        self.canRotate = canRotate
        self.leftWallBehavior = leftWallBehavior
        self.rightWallBehavior = rightWallBehavior
        self.topWallBehavior = topWallBehavior
        self.bottomWallBehavior = bottomWallBehavior
        self.uniformDensity = uniformDensity
        self.mass = backingShape.area * uniformDensity
        self.inverseMass = 1 / mass
        self.momentOfInertia = backingShape.areaMomentOfInertia *
            uniformDensity /
            Settings.easeOfRotation.rawValue
        self.inverseMomentOfInertia = 1 / momentOfInertia
        self.elasticity = elasticity
        self.linearVelocity = initialVelocity
        self.consecutiveCollisionCount = consecutiveCollisionCount
    }

    /// Copies some properties of a given rigid body.
    /// - warning: Only some of the properties are copied,
    /// in particular the physical properties of acceleration and impulse are not.
    convenience init(instance: RigidBodyObject) {
        switch instance.backingShape {
        case let circle as CircleObject:
            self.init(
                backingShape: CircleObject(instance: circle),
                associatedEntity: instance.associatedEntity,
                isAffectedByGlobalForces: instance.isAffectedByGlobalForces,
                canTranslate: instance.canTranslate,
                canRotate: instance.canRotate,
                leftWallBehavior: instance.leftWallBehavior,
                rightWallBehavior: instance.rightWallBehavior,
                topWallBehavior: instance.topWallBehavior,
                bottomWallBehavior: instance.bottomWallBehavior,
                uniformDensity: instance.uniformDensity,
                elasticity: instance.elasticity,
                consecutiveCollisionCount: instance.consecutiveCollisionCount
            )
        case let polygon as TransformablePolygonObject:
            self.init(
                backingShape: TransformablePolygonObject(instance: polygon),
                associatedEntity: instance.associatedEntity,
                isAffectedByGlobalForces: instance.isAffectedByGlobalForces,
                canTranslate: instance.canTranslate,
                canRotate: instance.canRotate,
                leftWallBehavior: instance.leftWallBehavior,
                rightWallBehavior: instance.rightWallBehavior,
                topWallBehavior: instance.topWallBehavior,
                bottomWallBehavior: instance.bottomWallBehavior,
                uniformDensity: instance.uniformDensity,
                elasticity: instance.elasticity,
                consecutiveCollisionCount: instance.consecutiveCollisionCount
            )
        default:
            fatalError("Cases should be covered")
        }
        linearVelocity = instance.linearVelocity
        angularVelocity = instance.angularVelocity
    }

    static func == (lhs: RigidBodyObject, rhs: RigidBodyObject) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(center)
    }
}

extension RigidBodyObject {
    func withPositionAndLinearVelocity(position: CGPoint, linearVelocity: CGVector) -> RigidBodyObject {
        let rigidBodyCopy = RigidBodyObject(instance: self)
        rigidBodyCopy.center = position
        rigidBodyCopy.linearVelocity = linearVelocity
        return rigidBodyCopy
    }

    func withAngleAndAngularVelocity(angle: Double, angularVelocity: Double) -> RigidBodyObject {
        let rigidBodyCopy = RigidBodyObject(instance: self)
        rigidBodyCopy.rotation = angle.generalizedMod(within: 2 * Double.pi)
        rigidBodyCopy.angularVelocity = angularVelocity
        return rigidBodyCopy
    }

    func withConsecutiveCollisionCount(count: Int) -> RigidBodyObject {
        let rigidBodyCopy = RigidBodyObject(instance: self)
        rigidBodyCopy.consecutiveCollisionCount = count
        return rigidBodyCopy
    }
}

extension Ball {
    func toRigidBody(logicalEjectionVelocity: CGVector) -> RigidBodyObject {
        RigidBodyObject(
            backingShape: getCircle(),
            associatedEntity: self,
            isAffectedByGlobalForces: true,
            canTranslate: true,
            canRotate: false,
            leftWallBehavior: .collide,
            rightWallBehavior: .collide,
            topWallBehavior: .collide,
            bottomWallBehavior: .fallThrough,
            uniformDensity: Settings.Ball.uniformDensity,
            elasticity: Settings.Ball.elasticity,
            initialVelocity: logicalEjectionVelocity
        )
    }
}

extension Peg {
    func toRigidBody() -> RigidBodyObject {
        switch shape {
        case let circle as CircleObject:
            return RigidBodyObject(
                backingShape: circle,
                associatedEntity: self,
                isAffectedByGlobalForces: false,
                canTranslate: Settings.Peg.canTranslate,
                canRotate: false,
                uniformDensity: Settings.Peg.uniformDensity,
                elasticity: Settings.Peg.elasticity
            )

        case let polygon as TransformablePolygonObject:
            return RigidBodyObject(
                backingShape: polygon,
                associatedEntity: self,
                isAffectedByGlobalForces: false,
                canTranslate: Settings.Peg.canTranslate,
                canRotate: Settings.Peg.Polygonal.canRotate,
                uniformDensity: Settings.Peg.uniformDensity,
                elasticity: Settings.Peg.elasticity
            )
        default:
            fatalError(shapeCastingMessage)
        }

    }
}
