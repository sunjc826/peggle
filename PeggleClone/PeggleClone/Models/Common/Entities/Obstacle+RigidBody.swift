import Foundation
import CoreGraphics

extension Obstacle {
    func toRigidBody() -> RigidBodyObject {
        guard let triangle = shape as? TriangleObject else {
            fatalError("unexpected type")
        }

        return RigidBodyObject(
            backingShape: triangle,
            associatedEntity: self,
            canTranslate: Settings.Obstacle.canTranslate,
            canRotate: Settings.Obstacle.canRotate,
            uniformDensity: Settings.Obstacle.uniformDensity,
            elasticity: Settings.Obstacle.elasticity
        )
    }
}
