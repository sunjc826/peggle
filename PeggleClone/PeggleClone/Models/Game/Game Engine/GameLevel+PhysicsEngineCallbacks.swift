import Foundation
import CoreGraphics

extension GameLevel {
    func physicsEngineDidUpdate(oldRigidBody: RigidBodyObject, updatedRigidBody: RigidBodyObject) {
        let oldEntity = oldRigidBody.associatedEntity
        let updatedPosition = updatedRigidBody.center
        let updatedRotation = updatedRigidBody.rotation
        let hasCollidedInLastUpdate = oldRigidBody.hasCollidedMostRecently

        switch oldEntity {
        case let ball as Ball:
            if updatedRigidBody.consecutiveCollisionCount > GameLevel.consecutiveCollisionThreshold {
                gamePhase = .stuck
            }
            let updatedBall = ball
                .withCenter(center: updatedPosition) // ball does not need to rotate
            updatedRigidBody.associatedEntity = updatedBall
            updateBall(oldBall: ball, with: updatedBall)
        case let peg as Peg:
            var updatedPeg = peg
                .withCenter(center: updatedPosition)
                .withRotation(rotation: updatedRotation)
            if hasCollidedInLastUpdate {
                updatedPeg = updatedPeg.withHasCollided(hasCollided: true)
            }
            updatedRigidBody.associatedEntity = updatedPeg
            updatePeg(oldPeg: peg, with: updatedPeg)
        default:
            break
        }
    }

    func physicsEngineDidRemove(rigidBody: RigidBodyObject) {
        let entity = rigidBody.associatedEntity
        switch entity {
        case let ball as Ball:
            removeBall(ball: ball)
        case let peg as Peg:
            removePeg(peg: peg)
        default:
            break
        }
    }
}
