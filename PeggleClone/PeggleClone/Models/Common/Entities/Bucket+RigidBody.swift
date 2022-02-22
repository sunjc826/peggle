import Foundation
import CoreGraphics

extension Bucket {
    func getRigidBodies() -> [RigidBody] {
        let leftRigidBody = left.toRigidBody()
        leftRigidBody.associatedEntity = left
        let rightRigidBody = right.toRigidBody()
        rightRigidBody.associatedEntity = right
        let receiverRigidBody = receiver.toRigidBody()
        receiverRigidBody.associatedEntity = receiver
        return [
            leftRigidBody,
            rightRigidBody,
            receiverRigidBody
        ]
    }
}

extension BucketLeftSide {
    func toRigidBody() -> RigidBody {
        let physicalProperties = PhysicalProperties(backingShape: shape, uniformDensity: 1, elasticity: 1)
        let configuration = ConfigurationForPhysicsEngine(canTranslate: true, canRotate: false)
        return RigidBody(
            physicalProperties: physicalProperties,
            associatedEntity: self,
            configuration: configuration,
            longTermDelta: LongTermDelta()
        )
    }
}

extension BucketRightSide {
    func toRigidBody() -> RigidBody {
        let physicalProperties = PhysicalProperties(backingShape: shape, uniformDensity: 1, elasticity: 1)
        let configuration = ConfigurationForPhysicsEngine(canTranslate: true, canRotate: false)
        return RigidBody(
            physicalProperties: physicalProperties,
            associatedEntity: self,
            configuration: configuration,
            longTermDelta: LongTermDelta()
        )
    }
}

extension BucketReceiver {
    func toRigidBody() -> RigidBody {
        let physicalProperties = PhysicalProperties(backingShape: shape, uniformDensity: 1, elasticity: 1)
        let configuration = ConfigurationForPhysicsEngine(canTranslate: true, canRotate: false)
        return RigidBody(
            physicalProperties: physicalProperties,
            associatedEntity: self,
            configuration: configuration,
            longTermDelta: LongTermDelta()
        )
    }
}
