import Foundation
import CoreGraphics

extension GameLevel {
    func doBeginning() {
        guard gamePhase == .beginning else {
            return
        }
        cannon.updateAngle(time: GameLevel.targetSecondsPerFrame)
    }

    func doShootBallWhenReady() {
        guard gamePhase == .shootBallWhenReady else {
            return
        }

        gamePhase = .ongoing
        shootBall()
    }

    func doOngoing() {
        guard gamePhase == .ongoing else {
            return
        }

        if balls.isEmpty {
            gamePhase = .cleanup
        }
    }

    func doStuck() {
        guard gamePhase == .stuck else {
            return
        }

        removeStuckEntities()
        gamePhase = .ongoing
    }

    func doCleanUp() {
        guard gamePhase == .cleanup else {
            return
        }

        switch special {
        case .moonTourist:
            setRegularGravity()
        case .spooky(activeCount: _):
            special = .spooky(activeCount: 0)
        default:
            break
        }

        cleanupAfterBallDisappears()

        if pegs.compulsoryPegCount == 0 {
            handleGameOver(isWon: true)
        } else if numBalls == 0 {
            handleGameOver(isWon: false)
        } else {
            gamePhase = .waitingForNewRound
            countdownToNewRound()
        }

        if !didAnyBallHitAnyPegInLastRound {
            gameEvents.send(.nothingHit)
        }

        didAnyBallHitAnyPegInLastRound = false
    }

    func doGameEnd() {
        guard case .gameEnd(stats: _) = gamePhase else {
            return
        }
    }
}

// MARK: Lifecycle helpers
extension GameLevel {
    @objc func startNewRound() {
        gamePhase = .beginning
    }

    func getBallPrediction() -> [CGPoint] {
        let (ball, ejectionVelocity) = cannon.shootBall()
        let rigidBody = ball.toRigidBody(logicalEjectionVelocity: ejectionVelocity)
        let gravityType: ForceType = .gravity(
            gravitationalAcceleration: coordinateMapper.getLogicalLength(
                ofPhysicalLength: Settings.Physics.signedMagnitudeOfAccelerationDueToGravity
            )
        )
        let gravity = ForceObject(forceType: gravityType, forcePosition: .center)
        rigidBody.longTermDelta.persistentForces.append(gravity)
        let predictedPositions = physicsEngine.predict(
            for: rigidBody,
            intervalSize: GameLevel.predictionTimeIntervalInSeconds,
            numberOfIntervals: 30
        )

        return predictedPositions
    }

    func wantToShoot() {
        if gamePhase == .beginning {
            gamePhase = .shootBallWhenReady
        }
    }

    func shootBall() {
        numBalls -= 1
        let (ball, ejectionVelocity) = cannon.shootBall()
        addBall(ball: ball, ejectionVelocity: ejectionVelocity)
    }

    func removeStuckEntities() {
        physicsEngine.remove { (rigidBody: RigidBody) in
            !(rigidBody.associatedEntity is Ball) &&
            rigidBody.miscProperties.consecutiveCollisionCount > GameLevel.consecutiveCollisionThreshold
        }
    }

    func cleanupAfterBallDisappears() {
        physicsEngine.remove { (entity: GameEntity) in
            guard let peg = entity as? Peg else {
                return false
            }
            return peg.hasCollided
        }
    }

    func countdownToNewRound() {
        Timer.scheduledTimer(
            timeInterval: 2.0,
            target: self,
            selector: #selector(startNewRound),
            userInfo: nil,
            repeats: false
        )
    }

    func handleGameOver(isWon: Bool) {
        let endOfGameStatistics = GameRoundStats(
            peggleMaster: peggleMaster,
            isWon: isWon,
            score: pegs.pegScores.values.reduce(0, +),
            compulsoryPegsHit: pegs.pegHits[.compulsory]!,
            optionalPegsHit: pegs.pegHits[.optional]!,
            specialPegsHit: pegs.pegHits[.special]!
        )
        clearAll()
        gamePhase = .gameEnd(stats: endOfGameStatistics)
        for callback in gameDidEndCallbacks {
            callback(isWon)
        }
    }

    func clearAll() {
        for ball in balls {
            removeBall(ball: ball)
        }
        for peg in pegs {
            removePeg(peg: peg)
        }
        for obstacle in obstacles {
            removeObstacle(obstacle: obstacle)
        }
    }
}
