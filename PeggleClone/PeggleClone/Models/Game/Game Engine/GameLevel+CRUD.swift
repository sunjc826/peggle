import Foundation
import CoreGraphics

extension GameLevel {
    func addBall(ball: Ball, ejectionVelocity: CGVector) {
        balls.append(ball)
        let rigidBody = ball.toRigidBody(
            logicalEjectionVelocity: ejectionVelocity
        )
        ball.rigidBody = rigidBody
        let gravityType: ForceType = .gravity(
            gravitationalAcceleration: coordinateMapper.getLogicalLength(
                ofPhysicalLength: Settings.Physics.signedMagnitudeOfAccelerationDueToGravity
            )
        )
        let gravity = Force(forceType: gravityType, forcePosition: .center)
        rigidBody.longTermDelta.persistentForces.append(gravity)
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
        let restoringForceType: ForceType = .restoring(
            springConstant: Settings.Obstacle.easeOfOscillation.rawValue / obstacle.radiusOfOscillation,
            centerOfOscillation: obstacle.shape.center
        )
        let restoringForce = Force(forceType: restoringForceType, forcePosition: .center)
        rigidBody.longTermDelta.persistentForces.append(restoringForce)
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

    func addBucket(bucket: Bucket) {
        let rigidBodies = bucket.getRigidBodies(
            initialVelocity: CGVector(dx: Settings.Bucket.xVelocity, dy: 0)
        )
        rigidBodies.forEach { physicsEngine.add(rigidBody: $0) }
    }
}
