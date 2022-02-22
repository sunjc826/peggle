import Foundation
import CoreGraphics

extension Bucket {
    func getRigidBodies(initialVelocity: CGVector) -> [RigidBody] {
        let leftRigidBody = leftSide.toRigidBody(initialVelocity: initialVelocity)
        leftSide.rigidBody = leftRigidBody
        let rightRigidBody = rightSide.toRigidBody(initialVelocity: initialVelocity)
        rightSide.rigidBody = rightRigidBody
        let receiverRigidBody = receiver.toRigidBody(initialVelocity: initialVelocity)
        receiver.rigidBody = receiverRigidBody
        return [
            leftRigidBody,
            rightRigidBody,
            receiverRigidBody
        ]
    }
}

extension BucketLeftSide {
    func toRigidBody(initialVelocity: CGVector) -> RigidBody {
        let physicalProperties = PhysicalProperties(backingShape: shape, uniformDensity: 1, elasticity: 1)
        let configuration = ConfigurationForPhysicsEngine(
            canTranslate: true,
            canRotate: false,
            leftWallBehavior: .collide,
            rightWallBehavior: .collide,
            topWallBehavior: .collide,
            bottomWallBehavior: .collide
        )
        return RigidBody(
            physicalProperties: physicalProperties,
            associatedEntity: self,
            configuration: configuration,
            longTermDelta: LongTermDelta(linearVelocity: initialVelocity)
        )
    }
}

extension BucketRightSide {
    func toRigidBody(initialVelocity: CGVector) -> RigidBody {
        let physicalProperties = PhysicalProperties(backingShape: shape, uniformDensity: 1, elasticity: 1)
        let configuration = ConfigurationForPhysicsEngine(
            canTranslate: true,
            canRotate: false,
            leftWallBehavior: .collide,
            rightWallBehavior: .collide,
            topWallBehavior: .collide,
            bottomWallBehavior: .collide
        )
        return RigidBody(
            physicalProperties: physicalProperties,
            associatedEntity: self,
            configuration: configuration,
            longTermDelta: LongTermDelta(linearVelocity: initialVelocity)
        )
    }
}

extension BucketReceiver {
    func toRigidBody(initialVelocity: CGVector) -> RigidBody {
        let physicalProperties = PhysicalProperties(backingShape: shape, uniformDensity: 1, elasticity: 1)
        let configuration = ConfigurationForPhysicsEngine(
            canTranslate: true,
            canRotate: false,
            leftWallBehavior: .collide,
            rightWallBehavior: .collide,
            topWallBehavior: .collide,
            bottomWallBehavior: .collide
        )
        return RigidBody(
            physicalProperties: physicalProperties,
            associatedEntity: self,
            configuration: configuration,
            longTermDelta: LongTermDelta(linearVelocity: initialVelocity)
        )
    }
}
