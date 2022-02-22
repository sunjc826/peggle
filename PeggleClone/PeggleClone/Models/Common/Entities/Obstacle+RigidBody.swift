import Foundation
import CoreGraphics

extension Obstacle {
    func toRigidBody() -> RigidBody {
        guard let triangle = shape as? TriangleObject else {
            fatalError("unexpected type")
        }

        let physicalProperties = PhysicalProperties(
            backingShape: triangle,
            uniformDensity: Settings.Obstacle.uniformDensity,
            elasticity: Settings.Obstacle.elasticity
        )

        let configuration = ConfigurationForPhysicsEngine(
            canTranslate: Settings.Obstacle.canTranslate,
            canRotate: Settings.Obstacle.canRotate
        )

        return RigidBody(
            physicalProperties: physicalProperties,
            associatedEntity: self,
            configuration: configuration,
            longTermDelta: LongTermDelta()
        )
    }
}
