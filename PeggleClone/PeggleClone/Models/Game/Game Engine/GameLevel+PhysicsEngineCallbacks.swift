import Foundation
import CoreGraphics

extension GameLevel {
    func physicsEngineDidUpdate(oldRigidBody: RigidBody, updatedRigidBody: RigidBody) {
        let oldEntity = oldRigidBody.associatedEntity
        let updatedPosition = updatedRigidBody.center
        let updatedRotation = updatedRigidBody.rotation

        switch oldEntity {
        case let oldBall as Ball:
            if updatedRigidBody.miscProperties.consecutiveCollisionCount > GameLevel.consecutiveCollisionThreshold {
                gamePhase = .stuck
            }

            if updatedRigidBody.miscProperties.consecutiveCollisionCount == 1 {
                gameEvents.send(.ballCollision)
            }

            let updatedBall = Ball(instance: oldBall)
            updatedBall.center = updatedPosition
            updatedRigidBody.associatedEntity = updatedBall
            updatedBall.rigidBody = updatedRigidBody
            if case .spooky(activeCount: _) = special {
                updateSpookyStatus(oldBall: oldBall, updatedBall: updatedBall)
            }
            updateBall(oldBall: oldBall, with: updatedBall)
        case let oldPeg as Peg:
            let updatedPeg = Peg(instance: oldPeg)
            updatedPeg.shape.center = updatedPosition
            updatedPeg.shape.rotation = updatedRotation
            if updatedRigidBody.miscProperties.consecutiveCollisionCount > 0 {
                updatedPeg.hasCollided = true
                didAnyBallHitAnyPegInLastRound = true
            }

            updatedRigidBody.associatedEntity = updatedPeg
            updatedPeg.rigidBody = updatedRigidBody

            // Is first time collision with special
            if updatedPeg.hasCollided && updatedPeg.pegType == .special && !oldPeg.hasCollided {
                physicsEngine.registerDidFinishAllUpdatesCallback(callback: { [weak self] in
                    guard let self = self else {
                        return
                    }

                    self.handleHitSpecialPeg(oldSpecialPeg: oldPeg, updatedSpecialPeg: updatedPeg)
                }, temp: true)
            }

            updatePeg(oldPeg: oldPeg, with: updatedPeg)
        case let oldObstacle as Obstacle:
            let updatedObstacle = Obstacle(instance: oldObstacle)
            updatedObstacle.shape.center = updatedPosition
            updatedObstacle.shape.rotation = updatedRotation
            updatedRigidBody.associatedEntity = updatedObstacle
            updatedObstacle.rigidBody = updatedRigidBody
            updateObstacle(oldObstacle: oldObstacle, with: updatedObstacle)
        default:
            break
        }
    }

    func updateSpookyStatus(oldBall: Ball, updatedBall: Ball) {
        guard let updatedRigidBody = updatedBall.rigidBody else {
            fatalError("should not be nil")
        }

        guard case .spooky(activeCount: let activeCount) = special else {
            fatalError("should be spooky")
        }

        guard activeCount > 0 else {
            return
        }

        if activeCount <= updatedRigidBody.miscProperties.wrapAroundCount {
            updatedRigidBody.configuration.bottomWallBehavior = .fallThrough
            updatedRigidBody.miscProperties.wrapAroundCount = 0
            special = .spooky(activeCount: 0)
        }
    }

    func handleHitSpecialPeg(oldSpecialPeg: Peg, updatedSpecialPeg: Peg) {
        gameEvents.send(.specialPegHit)
        guard let updatedPegRigidBody: RigidBody = updatedSpecialPeg.rigidBody else {
            globalLogger.error("cannot find rigid body")
            return
        }
        switch special {
        case .normal:
            return
        case .spooky(activeCount: let activeCount):
            assert(balls.count == 1)
            let ball = balls.first
            guard let rigidBody = ball?.rigidBody else {
                fatalError("should not be nil")
            }
            rigidBody.configuration.bottomWallBehavior = .wrapAround
            special = .spooky(activeCount: activeCount + 1)
        case .smallBombs:
            updatedPegRigidBody.localizedForceEmitter = LocalizedRadialForceEmitter(
                forceType: .explosion,
                baseMagnitude: Settings.Peg.Special.explosionForceBaseMagnitude,
                maximumRadius: Settings.Peg.Special.explosionRadius,
                duration: GameLevel.targetSecondsPerFrame // Explosion lasts for single frame
            )
        case .moonTourist:
            setMoonGravity()
        case .blackHole:
            updatedPegRigidBody.localizedForceEmitter = LocalizedRadialForceEmitter(
                forceType: .attraction,
                baseMagnitude: Settings.Peg.Special.attractionForceBaseMagnitude,
                maximumRadius: Settings.Peg.Special.attractionRadius,
                duration: Settings.Peg.Special.attractionDuration
            )
        case .iHatePeople:
            updatedPegRigidBody.localizedForceEmitter = LocalizedRadialForceEmitter(
                forceType: .replusion,
                baseMagnitude: Settings.Peg.Special.repulsionForceBaseMagnitude,
                maximumRadius: Settings.Peg.Special.repulsionRadius,
                duration: Settings.Peg.Special.repulsionDuration
            )
        case .multiball:
            addMultiball(updatedSpecialPeg: updatedSpecialPeg)
        case .author:
            // TODO
            return
        }
    }

    func addMultiball(updatedSpecialPeg: Peg) {
        gameEvents.send(.ballMultiply)
        let ball: Ball
        let directionVector: CGVector
        switch updatedSpecialPeg.shape {
        case let circle as Circle:
            let theta = Double.random(in: 0..<2 * Double.pi)
            directionVector = CGVector.fromPoint(
                point: PolarCoordinate(radius: circle.radius, theta: theta).toCartesian()
            ).normalize()
            let offset = directionVector.scaleBy(factor: circle.radius + 0.001)
            let ballPosition = circle.center.translate(offset: offset)
            ball = Ball(center: ballPosition)
        case let polygon as TransformablePolygon:
            let numVertices = polygon.sides
            let vertexIndex = Int.random(in: 0..<numVertices)
            let vertex = polygon.vertices[vertexIndex]
            directionVector = CGVector(from: polygon.center, to: vertex).normalize()
            ball = Ball(center: vertex.translate(offset: directionVector.scaleBy(factor: 0.001)))
        default:
            fatalError(shapeCastingMessage)
        }
        addBall(
            ball: ball,
            ejectionVelocity:
                directionVector.scaleBy(factor: Settings.Peg.Special.multiballEjectionVelocity)
        )
    }

    /// Reduces gravity for all objects affected by gravity, i.e. balls.
    func setMoonGravity() {
        gameEvents.send(.gravityLowered)
        let moonGravityType: ForceType = .gravity(
            gravitationalAcceleration: coordinateMapper.getPhysicalLength(
                ofLogicalLength: Settings.Physics.signedMagnitudeOfAccelerationDueToGravity / 6
            )
        )

        let moonGravity = ForceObject(
            forceType: moonGravityType,
            forcePosition: .center
        )

        for ball in balls {
            ball.rigidBody?.longTermDelta.persistentForces.removeAll(where: {
                guard case .gravity = $0.forceType else {
                    return false
                }
                return true
            })
            ball.rigidBody?.longTermDelta.persistentForces.append(moonGravity)
        }
    }

    func setRegularGravity() {
        let regularGravityType: ForceType = .gravity(
            gravitationalAcceleration: coordinateMapper.getPhysicalLength(
                ofLogicalLength: Settings.Physics.signedMagnitudeOfAccelerationDueToGravity
            )
        )

        let regularGravity = ForceObject(
            forceType: regularGravityType,
            forcePosition: .center
        )

        for ball in balls {
            ball.rigidBody?.longTermDelta.persistentForces.removeAll(where: {
                guard case .gravity = $0.forceType else {
                    return false
                }
                return true
            })
            ball.rigidBody?.longTermDelta.persistentForces.append(regularGravity)
        }
    }

    func physicsEngineDidRemove(rigidBody: RigidBody) {
        let entity = rigidBody.associatedEntity
        switch entity {
        case let ball as Ball:
            gameEvents.send(.ballFallthrough)
            removeBall(ball: ball)
        case let peg as Peg:
            removePeg(peg: peg)
        default:
            break
        }
    }
}
