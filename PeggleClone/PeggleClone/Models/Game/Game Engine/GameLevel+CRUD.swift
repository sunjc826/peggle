import Foundation
import CoreGraphics

extension GameLevel {
    func addBall(ball: Ball, ejectionVelocity: CGVector) {
        balls.append(ball)
        let rigidBody = ball.toRigidBody(
            logicalEjectionVelocity: ejectionVelocity
        )
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
        physicsEngine.add(rigidBody: peg.toRigidBody())
        for callback in didAddPegCallbacks {
            callback(peg)
        }
    }

    func updatePeg(oldPeg: Peg, with newPeg: Peg) {
        pegs.remove(oldPeg)
        pegs.insert(newPeg)
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
