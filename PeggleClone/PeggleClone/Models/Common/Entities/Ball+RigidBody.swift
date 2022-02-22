import Foundation
import CoreGraphics

extension Ball {
    func toRigidBody(logicalEjectionVelocity: CGVector) -> RigidBody {
        let physicalProperties = PhysicalProperties(
            backingShape: getCircle(),
            uniformDensity: Settings.Ball.uniformDensity,
            elasticity: Settings.Ball.elasticity
        )

        let configuration = ConfigurationForPhysicsEngine(
            canTranslate: true,
            canRotate: false,
            leftWallBehavior: .collide,
            rightWallBehavior: .collide,
            topWallBehavior: .collide,
            bottomWallBehavior: .fallThrough
        )

        let longTermDelta = LongTermDelta(
            linearVelocity: logicalEjectionVelocity
        )

        return RigidBody(
            physicalProperties: physicalProperties,
            associatedEntity: self,
            configuration: configuration,
            longTermDelta: longTermDelta
        )
    }
}
