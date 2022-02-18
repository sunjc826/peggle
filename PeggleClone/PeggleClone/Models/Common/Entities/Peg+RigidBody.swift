import Foundation
import CoreGraphics

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
