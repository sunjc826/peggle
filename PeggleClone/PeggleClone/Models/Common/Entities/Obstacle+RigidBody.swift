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
            canTranslate: Settings.Peg.canTranslate,
            canRotate: Settings.Peg.Polygonal.canRotate,
            uniformDensity: Settings.Peg.uniformDensity,
            elasticity: Settings.Peg.elasticity
        )
    }
}
