import Foundation
import CoreGraphics

private let consecutiveCollisionThreshold = 20

final class GameLevel {
    static let targetFps = 60
    static let targetSecondsPerFrame: Double = 1.0 / Double(targetFps)
    static let predictionTimeIntervalInSeconds: Double = targetSecondsPerFrame * 2

    static let cannonZoneHeight: Double = 0.0
    static let pegCatcherZoneHeight: Double = 30.0
    static let startingBalls: Int = 5

    private let physicsEngine: AbstractPhysicsEngine
    let coordinateMapper: PhysicsCoordinateMapper
    let playArea: PlayArea
    let cannon: Cannon
    private var balls: [Ball] = []
    let pegs: PegContainer

    @Published var numBalls: Int = GameLevel.startingBalls
    var gamePhase: GamePhase = .disabled
    @Published var score: Int = 0

    private var didAddBallCallbacks: [CallbackUnaryFunction<Ball>] = []
    private var didUpdateBallCallbacks: [CallbackBinaryFunction<Ball>] = []
    private var didRemoveBallCallbacks: [CallbackUnaryFunction<Ball>] = []

    private var didAddPegCallbacks: [CallbackUnaryFunction<Peg>] = []
    private var didUpdatePegCallbacks: [CallbackBinaryFunction<Peg>] = []
    private var didRemovePegCallbacks: [CallbackUnaryFunction<Peg>] = []

    init<T: Container>(coordinateMapper: PhysicsCoordinateMapper, pegs: T) where T.Element == Peg {
        self.coordinateMapper = coordinateMapper
        self.playArea = coordinateMapper.getPlayArea()
        self.pegs = PegContainer(pegs: pegs)
        let cannonPosition = CGPoint(x: playArea.boundingBox.center.x, y: 0)
        self.cannon = Cannon(position: cannonPosition)
        let rigidBodies = SetObject<RigidBodyObject>()
        for peg in pegs {
            rigidBodies.insert(peg.toRigidBody())
        }
        let boundary = Boundary(playArea: playArea)
        self.physicsEngine = PhysicsEngine(
            coordinateMapper: coordinateMapper,
            boundary: boundary,
            rigidBodies: rigidBodies,
            neighborFinder: QuadTree(bounds: playArea.boundingBox),
            collisionResolver: Collision()
        )
        setupCallbacks()
    }

    func hydrate(with incomingLevel: PersistableDesignerGameLevel) throws {
        let incomingPlayArea = PlayArea.fromPersistable(persistableArea: incomingLevel.playArea)
        if incomingPlayArea != playArea {
            throw HydrationIncompatibleError()
        }

        for persistablePeg in incomingLevel.pegs {
            let peg = Peg.fromPersistable(persistablePeg: persistablePeg)
            addPeg(peg: peg)
        }
    }

    func update() {
        if gamePhase == .ongoing && balls.isEmpty {
            gamePhase = .cleanup
            cleanupAfterBallDisappears()
            Timer.scheduledTimer(
                timeInterval: 2.0,
                target: self,
                selector: #selector(startNewRound),
                userInfo: nil,
                repeats: false
            )
        }

        if gamePhase == .stuck {
            removeStuckEntities()
            gamePhase = .ongoing
        }

        cannon.updateAngle(time: GameLevel.targetSecondsPerFrame)
        if gamePhase == .shootBallWhenReady {
            gamePhase = .ongoing
            shootBall()
        }
        physicsEngine.simulateAll(time: GameLevel.targetSecondsPerFrame)
    }
}

// MARK: Setup
extension GameLevel {
    private func setupCallbacks() {
        physicsEngine.registerDidUpdateCallback(callback: physicsEngineDidUpdate)
        physicsEngine.registerDidRemoveCallback(callback: physicsEngineDidRemove)
    }
}

// MARK: Callback Registration
extension GameLevel {
    func registerDidAddBallCallback(callback: @escaping CallbackUnaryFunction<Ball>) {
        didAddBallCallbacks.append(callback)
    }

    func registerDidUpdateBallCallback(callback: @escaping CallbackBinaryFunction<Ball>) {
        didUpdateBallCallbacks.append(callback)
    }

    func registerDidRemoveBallCallback(callback: @escaping CallbackUnaryFunction<Ball>) {
        didRemoveBallCallbacks.append(callback)
    }

    func registerDidAddPegCallback(callback: @escaping CallbackUnaryFunction<Peg>) {
        didAddPegCallbacks.append(callback)
    }

    func registerDidUpdatePegCallback(callback: @escaping CallbackBinaryFunction<Peg>) {
        didUpdatePegCallbacks.append(callback)
    }

    func registerDidRemovePegCallback(callback: @escaping CallbackUnaryFunction<Peg>) {
        didRemovePegCallbacks.append(callback)
    }
}

// MARK: CRUD
extension GameLevel {
    private func addBall(ball: Ball, ejectionVelocity: CGVector) {
        balls.append(ball)
        let rigidBody = ball.toRigidBody(
            logicalEjectionVelocity: ejectionVelocity
        )
        physicsEngine.add(rigidBody: rigidBody)
        for callback in didAddBallCallbacks {
            callback(ball)
        }
    }

    private func updateBall(oldBall: Ball, with newBall: Ball) {
        balls.removeByIdentity(oldBall)
        balls.append(newBall)
        for callback in didUpdateBallCallbacks {
            callback(oldBall, newBall)
        }
    }

    private func removeBall(ball: Ball) {
        balls.removeByIdentity(ball)
        for callback in didRemoveBallCallbacks {
            callback(ball)
        }
    }

    private func addPeg(peg: Peg) {
        pegs.insert(peg)
        physicsEngine.add(rigidBody: peg.toRigidBody())
        for callback in didAddPegCallbacks {
            callback(peg)
        }
    }

    private func updatePeg(oldPeg: Peg, with newPeg: Peg) {
        pegs.remove(oldPeg)
        pegs.insert(newPeg)
        for callback in didUpdatePegCallbacks {
            callback(oldPeg, newPeg)
        }
    }

    private func removePeg(peg: Peg) {
        pegs.remove(peg)
        for callback in didRemovePegCallbacks {
            callback(peg)
        }
    }
}

// MARK: Physics Engine Callbacks
extension GameLevel {
    private func physicsEngineDidUpdate(oldRigidBody: RigidBodyObject, updatedRigidBody: RigidBodyObject) {
        let oldEntity = oldRigidBody.associatedEntity
        let updatedPosition = updatedRigidBody.center
        let updatedRotation = updatedRigidBody.rotation
        let hasCollidedInLastUpdate = oldRigidBody.hasCollidedMostRecently

        switch oldEntity {
        case let ball as Ball:
            if updatedRigidBody.consecutiveCollisionCount > consecutiveCollisionThreshold {
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

    private func physicsEngineDidRemove(rigidBody: RigidBodyObject) {
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

// MARK: Game lifecycle methods
extension GameLevel {
    @objc func startNewRound() {
        gamePhase = .beginning
    }

    func getBallPrediction() -> [CGPoint] {
        let (ball, ejectionVelocity) = cannon.shootBall()
        let rigidBody = ball.toRigidBody(logicalEjectionVelocity: ejectionVelocity)
        let predictedPositions = physicsEngine.predict(
            for: rigidBody,
            intervalSize: GameLevel.predictionTimeIntervalInSeconds,
            numberOfIntervals: 20
        )

        return predictedPositions
    }

    func wantToShoot() {
        if gamePhase == .beginning {
            gamePhase = .shootBallWhenReady
        }
    }

    private func shootBall() {
        numBalls -= 1
        let (ball, ejectionVelocity) = cannon.shootBall()
        addBall(ball: ball, ejectionVelocity: ejectionVelocity)
    }

    private func removeStuckEntities() {
        physicsEngine.remove { (rigidBody: RigidBody) in
            !(rigidBody.associatedEntity is Ball) &&
            rigidBody.consecutiveCollisionCount > consecutiveCollisionThreshold
        }
    }

    private func cleanupAfterBallDisappears() {
        physicsEngine.remove { (entity: GameEntity) in
            guard let peg = entity as? Peg else {
                return false
            }

            return peg.hasCollided
        }
    }
}
