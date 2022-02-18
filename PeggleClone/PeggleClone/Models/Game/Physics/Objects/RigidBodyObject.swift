import Foundation
import CoreGraphics

final class RigidBodyObject: RigidBody, HasBoundingBox, Equatable, Hashable {
    var backingShape: TransformableShape
    var associatedEntity: GameEntity?

    var nextTeleportLocation: CGPoint?

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

    var boundingBox: BoundingBox {
        backingShape.boundingBox
    }

    // MARK: Force overrides
    var isAffectedByGlobalForces: Bool

    var canTranslate: Bool

    var canRotate: Bool

    // MARK: Physical properties

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

    // MARK: Wall behavior

    var leftWallBehavior: WallBehavior

    var rightWallBehavior: WallBehavior

    var topWallBehavior: WallBehavior

    var bottomWallBehavior: WallBehavior

    // MARK: Other data

    var hasCollidedMostRecently = false

    var consecutiveCollisionCount: Int = 0

    var hasWrappedAroundMostRecently = false

    var wrapAroundCount: Int = 0

    // MARK: Localized radial forces

    var localizedForceEmitter: LocalizedRadialForceEmitter?

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
        initialVelocity: CGVector = CGVector.zero
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
                elasticity: instance.elasticity
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
                elasticity: instance.elasticity
            )
        default:
            fatalError("Cases should be covered")
        }
        consecutiveCollisionCount = instance.consecutiveCollisionCount
        wrapAroundCount = instance.wrapAroundCount
        linearVelocity = instance.linearVelocity
        angularVelocity = instance.angularVelocity
        localizedForceEmitter = instance.localizedForceEmitter
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
        let copy = RigidBodyObject(instance: self)
        copy.center = position
        copy.linearVelocity = linearVelocity
        return copy
    }

    func withAngleAndAngularVelocity(angle: Double, angularVelocity: Double) -> RigidBodyObject {
        let copy = RigidBodyObject(instance: self)
        copy.rotation = angle.generalizedMod(within: 2 * Double.pi)
        copy.angularVelocity = angularVelocity
        return copy
    }

    func withConsecutiveCollisionCount(count: Int) -> RigidBodyObject {
        let copy = RigidBodyObject(instance: self)
        copy.consecutiveCollisionCount = count
        return copy
    }

    func withWrapAroundCount(count: Int) -> RigidBodyObject {
        let copy = RigidBodyObject(instance: self)
        copy.wrapAroundCount = count
        return copy
    }

    func withLocalizedForceEmitter(emitter: LocalizedRadialForceEmitter) -> RigidBodyObject {
        let copy = RigidBodyObject(instance: self)
        copy.localizedForceEmitter = emitter
        return copy
    }
}
