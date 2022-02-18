import Foundation
import CoreGraphics

extension GameLevel {
    func addBall(ball: Ball, ejectionVelocity: CGVector) {
        balls.append(ball)
        let rigidBody = ball.toRigidBody(
            logicalEjectionVelocity: ejectionVelocity
        )
        ball.rigidBody = rigidBody
        let gravity: Force = .gravity(
            gravitationalAcceleration: coordinateMapper.getLogicalLength(
                ofPhysicalLength: Settings.Physics.signedMagnitudeOfAccelerationDueToGravity
            )
        )
        rigidBody.persistentForces.append(gravity)
        physicsEngine.add(rigidBody: rigidBody)
        for callback in didAddBallCallbacks {
            callback(ball)
        }
    }

    func updateBall(oldBall: Ball, with updatedBall: Ball) {
        balls.removeByIdentity(oldBall)
        balls.append(updatedBall)
        for callback in didUpdateBallCallbacks {
            callback(oldBall, updatedBall)
        }
    }

    func removeBall(ball: Ball) {
        balls.removeByIdentity(ball)
        for callback in didRemoveBallCallbacks {
            callback(ball)
        }
    }

    func addPeg(peg: Peg) {
        pegs.insert(peg)
        let rigidBody = peg.toRigidBody()
        peg.rigidBody = rigidBody
        physicsEngine.add(rigidBody: rigidBody)
        for callback in didAddPegCallbacks {
            callback(peg)
        }
    }

    func updatePeg(oldPeg: Peg, with updatedPeg: Peg) {
        pegs.update(oldPeg: oldPeg, with: updatedPeg)
        for callback in didUpdatePegCallbacks {
            callback(oldPeg, updatedPeg)
        }
    }

    func removePeg(peg: Peg) {
        pegs.remove(peg)
        for callback in didRemovePegCallbacks {
            callback(peg)
        }
    }

    func addObstacle(obstacle: Obstacle) {
        obstacles.insert(obstacle)
        let rigidBody = obstacle.toRigidBody()
        obstacle.rigidBody = rigidBody
        physicsEngine.add(rigidBody: rigidBody)
        for callback in didAddObstacleCallbacks {
            callback(obstacle)
        }
    }

    func updateObstacle(oldObstacle: Obstacle, with updatedObstacle: Obstacle) {
        obstacles.remove(oldObstacle)
        obstacles.insert(updatedObstacle)
        for callback in didUpdateObstacleCallbacks {
            callback(oldObstacle, updatedObstacle)
        }
    }

    func removeObstacle(obstacle: Obstacle) {
        obstacles.remove(obstacle)
        for callback in didRemoveObstacleCallbacks {
            callback(obstacle)
        }
    }

}
