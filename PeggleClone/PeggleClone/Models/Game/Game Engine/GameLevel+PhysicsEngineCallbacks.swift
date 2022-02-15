import Foundation
import CoreGraphics

extension GameLevel {
    func physicsEngineDidUpdate(oldRigidBody: RigidBodyObject, updatedRigidBody: RigidBodyObject) {
        let oldEntity = oldRigidBody.associatedEntity
        let updatedPosition = updatedRigidBody.center
        let updatedRotation = updatedRigidBody.rotation
        let hasCollidedInLastUpdate = oldRigidBody.hasCollidedMostRecently

        switch oldEntity {
        case let oldBall as Ball:
            if updatedRigidBody.consecutiveCollisionCount > GameLevel.consecutiveCollisionThreshold {
                gamePhase = .stuck
            }

            let updatedBall = oldBall
                .withCenter(center: updatedPosition) // ball does not need to rotate
            updatedRigidBody.associatedEntity = updatedBall
            updatedBall.rigidBody = updatedRigidBody
            updateSpookyStatus(oldBall: oldBall, updatedBall: updatedBall)
            updateBall(oldBall: oldBall, with: updatedBall)
        case let oldPeg as Peg:
            var updatedPeg = oldPeg
                .withCenter(center: updatedPosition)
                .withRotation(rotation: updatedRotation)
            if hasCollidedInLastUpdate {
                updatedPeg = updatedPeg.withHasCollided(hasCollided: true)
                if oldPeg.pegType == .special && !oldPeg.hasCollided {
                    physicsEngine.registerDidFinishAllUpdatesCallback(callback: handleHitSpecialPeg, temp: true)
                }
            }

            updatedRigidBody.associatedEntity = updatedPeg
            updatedPeg.rigidBody = updatedRigidBody

            updatePeg(oldPeg: oldPeg, with: updatedPeg)
        default:
            break
        }
    }

    func updateSpookyStatus(oldBall: Ball, updatedBall: Ball) {
        guard let oldRigidBody = oldBall.rigidBody, let updatedRigidBody = updatedBall.rigidBody else {
            fatalError("should not be nil")
        }

        if oldRigidBody.hasWrappedAroundMostRecently {
            guard case .spooky(activeCount: let activeCount) = special else {
                fatalError("should be spooky")
            }
            if activeCount <= updatedRigidBody.wrapAroundCount {
                updatedRigidBody.bottomWallBehavior = .fallThrough
            }
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
        default:
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
