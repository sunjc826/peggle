import Foundation
import CoreGraphics

final class GameLevel {
    static let targetFps = 60
    static let targetSecondsPerFrame: Double = 1.0 / Double(targetFps)
    static let predictionTimeIntervalInSeconds: Double = targetSecondsPerFrame * 2
    static let consecutiveCollisionThreshold: Int = 20
    static let cannonZoneHeight: Double = 0.0
    static let pegCatcherZoneHeight: Double = 30.0
    static let startingBalls: Int = 5

    let physicsEngine: AbstractPhysicsEngine
    let coordinateMapper: PhysicsCoordinateMapper
    let playArea: PlayArea
    let cannon: Cannon
    var balls: [Ball] = []
    let pegs: PegContainer

    @Published var numBalls: Int = GameLevel.startingBalls
    @Published var gamePhase: GamePhase = .disabled
    @Published var score: Int = 0

    var didAddBallCallbacks: [CallbackUnaryFunction<Ball>] = []
    var didUpdateBallCallbacks: [CallbackBinaryFunction<Ball>] = []
    var didRemoveBallCallbacks: [CallbackUnaryFunction<Ball>] = []
    var didAddPegCallbacks: [CallbackUnaryFunction<Peg>] = []
    var didUpdatePegCallbacks: [CallbackBinaryFunction<Peg>] = []
    var didRemovePegCallbacks: [CallbackUnaryFunction<Peg>] = []
    var gameDidEndCallbacks: [CallbackUnaryFunction<Bool>] = []

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
        doBeginning()
        doShootBallWhenReady()
        doOngoing()
        doStuck()
        doCleanUp()
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
