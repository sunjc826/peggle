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
            if case .spooky(activeCount: _) = special {
                updateSpookyStatus(oldBall: oldBall, updatedBall: updatedBall)
            }
            updateBall(oldBall: oldBall, with: updatedBall)
        case let oldPeg as Peg:
            var updatedPeg = oldPeg
                .withCenter(center: updatedPosition)
                .withRotation(rotation: updatedRotation)
            if hasCollidedInLastUpdate {
                updatedPeg = updatedPeg.withHasCollided(hasCollided: true)
            }

            updatedRigidBody.associatedEntity = updatedPeg
            updatedPeg.rigidBody = updatedRigidBody

            // Is first time collision with special
            if hasCollidedInLastUpdate && oldPeg.pegType == .special && !oldPeg.hasCollided {
                physicsEngine.registerDidFinishAllUpdatesCallback(callback: { [weak self] in
                    guard let self = self else {
                        return
                    }

                    self.handleHitSpecialPeg(oldSpecialPeg: oldPeg, updatedSpecialPeg: updatedPeg)
                }, temp: true)
            }

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

    /// - Remark: All modifications of rigid bodies are mutating,
    /// instead of the non-mutating approach taken almost everywhere else.
    func handleHitSpecialPeg(oldSpecialPeg: Peg, updatedSpecialPeg: Peg) {
        guard let updatedPegRigidBody = updatedSpecialPeg.rigidBody else {
            logger.error("cannot find rigid body")
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
            rigidBody.bottomWallBehavior = .wrapAround
            special = .spooky(activeCount: activeCount + 1)
            return
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
            let ball: Ball
            let directionVector: CGVector
            switch updatedSpecialPeg.shape {
            case let circle as Circle:
                let theta = Double.random(in: 0..<2 * Double.pi)
                directionVector = CGVector.fromPoint(
                    point: PolarCoordinate(radius: circle.radius, theta: theta).toCartesian()
                ).normalize()
                print(directionVector)
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
            return
        case .author:
            // TODO
            return
        }
    }

    func setMoonGravity() {
        physicsEngine.setGravity(
            physicalGravitationalAcceleration: Settings.Physics.signedMagnitudeOfAccelerationDueToGravity / 6
        )
    }

    func setRegularGravity() {
        physicsEngine.setGravity(
            physicalGravitationalAcceleration: Settings.Physics.signedMagnitudeOfAccelerationDueToGravity
        )
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
