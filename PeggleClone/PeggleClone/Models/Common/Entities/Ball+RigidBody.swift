import Foundation
import CoreGraphics

extension Ball {
    func toRigidBody(logicalEjectionVelocity: CGVector) -> RigidBodyObject {
        RigidBodyObject(
            backingShape: getCircle(),
            associatedEntity: self,
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
