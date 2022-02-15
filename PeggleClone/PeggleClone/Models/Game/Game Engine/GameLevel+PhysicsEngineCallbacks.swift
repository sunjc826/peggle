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
            
            if updatedRigidBody.hasWrappedAroundMostRecently {
                guard case .spooky(activeCount: let activeCount) = special else {
                    fatalError("should be spooky")
                }
                if activeCount >= updatedRigidBody.wrapAroundCount {
                    updatedRigidBody.bottomWallBehavior = .fallThrough
                }
            }
            
            let updatedBall = ball
                .withCenter(center: updatedPosition) // ball does not need to rotate
            updatedRigidBody.associatedEntity = updatedBall
            updatedBall.rigidBody = updatedRigidBody
            updateBall(oldBall: ball, with: updatedBall)
        case let peg as Peg:
            var updatedPeg = peg
                .withCenter(center: updatedPosition)
                .withRotation(rotation: updatedRotation)
            if hasCollidedInLastUpdate {
                updatedPeg = updatedPeg.withHasCollided(hasCollided: true)
            }
            
            if peg.pegType == .special && !peg.hasCollided {
                physicsEngine.registerDidFinishAllUpdatesCallback(callback: handleHitSpecialPeg, temp: true)
            }
            
            updatedRigidBody.associatedEntity = updatedPeg
            updatedPeg.rigidBody = updatedRigidBody
            
            updatePeg(oldPeg: peg, with: updatedPeg)
        default:
            break
        }
    }
    
    func handleHitSpecialPeg() {
        switch special {
        case .normal:
            return
        case .explosive:
            return
        case .spooky(activeCount: let activeCount):
            assert(balls.count == 1)
            let ball = balls.first
            guard let rigidBody = ball?.rigidBody else {
                fatalError("should not be nil")
            }
            rigidBody.bottomWallBehavior = .wrapAround
            special = .spooky(activeCount: activeCount + 1)
            return
        case .moonTourist:
            return
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
