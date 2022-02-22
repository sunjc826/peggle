import Foundation
import CoreGraphics

final class RigidBody: HasBoundingBox, Equatable, Hashable {
    var associatedEntity: GameEntity?
    var physicalProperties: PhysicalProperties
    var configuration: ConfigurationForPhysicsEngine
    var physicsEngineReports = PhysicsEngineReports()
    var instantaneousDelta = InstantaneousDelta()
    var longTermDelta: LongTermDelta
    var localizedForceEmitter: LocalizedRadialForceEmitter?
    var miscProperties = MiscProperties()

    var backingShape: TransformableShape {
        physicalProperties.backingShape
    }

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

    init(
        physicalProperties: PhysicalProperties,
        associatedEntity: GameEntity?,
        configuration: ConfigurationForPhysicsEngine,
        longTermDelta: LongTermDelta
    ) {
        self.physicalProperties = physicalProperties
        self.associatedEntity = associatedEntity
        self.configuration = configuration
        self.longTermDelta = longTermDelta
    }

    /// Copies some properties of a given rigid body.
    /// - warning: Only some of the properties are copied,
    convenience init(instance: RigidBody) {
        self.init(
            physicalProperties: PhysicalProperties(instance: instance.physicalProperties),
            associatedEntity: instance.associatedEntity,
            configuration: ConfigurationForPhysicsEngine(instance: instance.configuration),
            longTermDelta: LongTermDelta(instance: instance.longTermDelta)
        )
        if let localizedForceEmitter = instance.localizedForceEmitter {
            self.localizedForceEmitter = LocalizedRadialForceEmitter(instance: localizedForceEmitter)
        }
    }

    static func == (lhs: RigidBody, rhs: RigidBody) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(center)
    }
}
