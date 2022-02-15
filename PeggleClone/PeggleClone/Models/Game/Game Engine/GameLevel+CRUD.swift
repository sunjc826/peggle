import Foundation
import CoreGraphics

extension GameLevel {
    func addBall(ball: Ball, ejectionVelocity: CGVector) {
        balls.append(ball)
        let rigidBody = ball.toRigidBody(
            logicalEjectionVelocity: ejectionVelocity
        )
        ball.rigidBody = rigidBody
        physicsEngine.add(rigidBody: rigidBody)
        for callback in didAddBallCallbacks {
            callback(ball)
        }
    }

    func updateBall(oldBall: Ball, with newBall: Ball) {
        balls.removeByIdentity(oldBall)
        balls.append(newBall)
        for callback in didUpdateBallCallbacks {
            callback(oldBall, newBall)
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

    func updatePeg(oldPeg: Peg, with newPeg: Peg) {
        pegs.update(oldPeg: oldPeg, with: newPeg)
        for callback in didUpdatePegCallbacks {
            callback(oldPeg, newPeg)
        }
    }

    func removePeg(peg: Peg) {
        pegs.remove(peg)
        for callback in didRemovePegCallbacks {
            callback(peg)
        }
    }
}
