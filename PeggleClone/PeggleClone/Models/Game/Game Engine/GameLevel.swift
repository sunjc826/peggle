import Foundation
import CoreGraphics
import Combine

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
    var obstacles: Set<Obstacle> = []
    var special: SpecialType

    @Published var numBalls: Int = GameLevel.startingBalls
    @Published var gamePhase: GamePhase = .disabled
    var totalScore: AnyPublisher<Int, Never>?

    var didAddBallCallbacks: [UnaryFunction<Ball>] = []
    var didUpdateBallCallbacks: [BinaryFunction<Ball>] = []
    var didRemoveBallCallbacks: [UnaryFunction<Ball>] = []
    var didAddPegCallbacks: [UnaryFunction<Peg>] = []
    var didUpdatePegCallbacks: [BinaryFunction<Peg>] = []
    var didRemovePegCallbacks: [UnaryFunction<Peg>] = []
    var didAddObstacleCallbacks: [UnaryFunction<Obstacle>] = []
    var didUpdateObstacleCallbacks: [BinaryFunction<Obstacle>] = []
    var didRemoveObstacleCallbacks: [UnaryFunction<Obstacle>] = []
    var gameDidEndCallbacks: [UnaryFunction<Bool>] = []

    init<T: Container>(
        coordinateMapper: PhysicsCoordinateMapper,
        emptyPegsContainer: T,
        special: SpecialType
    ) where T.Element == Peg {
        self.coordinateMapper = coordinateMapper
        self.playArea = coordinateMapper.getPlayArea()
        assert(emptyPegsContainer.isEmpty)
        self.pegs = PegContainer(pegs: emptyPegsContainer)
        let cannonPosition = CGPoint(x: playArea.boundingBox.center.x, y: 0)
        self.cannon = Cannon(position: cannonPosition)
        let boundary = Boundary(playArea: playArea)
        self.physicsEngine = PhysicsEngine(
            coordinateMapper: coordinateMapper,
            boundary: boundary,
            rigidBodies: SetObject<RigidBodyObject>(),
            neighborFinder: QuadTree(bounds: playArea.boundingBox),
            collisionResolver: Collision()
        )
        self.special = special
        setupBindings()
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

        for persistableObstacle in incomingLevel.obstacles {
            let obstacle = Obstacle.fromPersistable(persistableObstacle: persistableObstacle)
            addObstacle(obstacle: obstacle)
        }
    }

    func update() {
        switch gamePhase {
        case .beginning:
            doBeginning()
        case .shootBallWhenReady:
            doShootBallWhenReady()
        case .ongoing:
            doOngoing()
        case .stuck:
            doStuck()
        case .cleanup:
            doCleanUp()
        case .gameEnd(stats: _):
            return
        case .disabled:
            return
        }

        switch gamePhase {
        case .beginning, .shootBallWhenReady, .ongoing, .stuck, .cleanup:
            physicsEngine.simulateAll(time: GameLevel.targetSecondsPerFrame)
        case .gameEnd(stats: _), .disabled:
            return
        }
    }
}

// MARK: Setup
extension GameLevel {
    private func setupCallbacks() {
        physicsEngine.registerDidUpdateCallback(callback: physicsEngineDidUpdate)
        physicsEngine.registerDidRemoveCallback(callback: physicsEngineDidRemove)
    }

    private func setupBindings() {
        totalScore = pegs.$pegScores
            .map { $0.values.reduce(0, +) }
            .eraseToAnyPublisher()
    }
}
