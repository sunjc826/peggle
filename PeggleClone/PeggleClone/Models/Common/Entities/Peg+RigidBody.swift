import Foundation
import CoreGraphics

extension Peg {
    func toRigidBody() -> RigidBody {
        let physicalProperties: PhysicalProperties
        let configuration: ConfigurationForPhysicsEngine
        switch shape {
        case let circle as CircleObject:
            physicalProperties = PhysicalProperties(
                backingShape: circle,
                uniformDensity: Settings.Peg.uniformDensity,
                elasticity: Settings.Peg.elasticity
            )
            configuration = ConfigurationForPhysicsEngine(
                canTranslate: Settings.Peg.canTranslate,
                canRotate: false
            )
        case let polygon as TransformablePolygonObject:
            physicalProperties = PhysicalProperties(
                backingShape: polygon,
                uniformDensity: Settings.Peg.uniformDensity,
                elasticity: Settings.Peg.elasticity
            )
            configuration = ConfigurationForPhysicsEngine(
                canTranslate: Settings.Peg.canTranslate, canRotate: Settings.Peg.Polygonal.canRotate)
        default:
            fatalError(shapeCastingMessage)
        }

        return RigidBody(
            physicalProperties: physicalProperties,
            associatedEntity: self,
            configuration: configuration,
            longTermDelta: LongTermDelta()
        )
    }
}
