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

    var subscriptions: Set<AnyCancellable> = []

    let physicsEngine: AbstractPhysicsEngine
    @Published var coordinateMapper: PhysicsCoordinateMapper
    var playArea: PlayArea
    let cannon: Cannon
    @Published var bucket: Bucket?
    var balls: [Ball] = []
    let pegs: PegContainer
    var obstacles: Set<Obstacle> = []
    var peggleMaster: PeggleMaster
    var special: SpecialType {
        get {
            peggleMaster.special
        }
        set {
            peggleMaster.special = newValue
        }
    }
    var hasHitSpecialPegInLastRound = false

    @Published var numBalls: Int = GameLevel.startingBalls
    @Published var gamePhase: GamePhase = .disabled
    var totalScore: PassthroughSubject<Int, Never> = PassthroughSubject()
    var didAnyBallHitAnyPegInLastRound = false

    var didAddBallCallbacks: [UnaryFunction<Ball>] = []
    var didUpdateBallCallbacks: [BinaryFunction<Ball>] = []
    var didRemoveBallCallbacks: [UnaryFunction<Ball>] = []
    var didAddPegCallbacks: [UnaryFunction<Peg>] = []
    var didUpdatePegCallbacks: [BinaryFunction<Peg>] = []
    var didRemovePegCallbacks: [UnaryFunction<Peg>] = []
    var didAddObstacleCallbacks: [UnaryFunction<Obstacle>] = []
    var didUpdateObstacleCallbacks: [BinaryFunction<Obstacle>] = []
    var didRemoveObstacleCallbacks: [UnaryFunction<Obstacle>] = []
    var didAddBucketCallbacks: [UnaryFunction<Bucket>] = []
    var didUpdateBucketCallbacks: [BinaryFunction<Bucket>] = []
    var didRemoveBucketCallbacks: [UnaryFunction<Bucket>] = []
    var gameDidEndCallbacks: [UnaryFunction<Bool>] = []
    var gameEvents: PassthroughSubject<GameEvent, Never> = PassthroughSubject()

    init<T: Container>(
        coordinateMapper: PhysicsCoordinateMapper,
        emptyPegsContainer: T,
        peggleMaster: PeggleMaster
    ) where T.Element == Peg {
        self.coordinateMapper = coordinateMapper
        let playArea = coordinateMapper.getPlayArea()
        self.playArea = playArea
        assert(emptyPegsContainer.isEmpty)
        self.pegs = PegContainer(pegs: emptyPegsContainer)
        let cannonPosition = CGPoint(x: playArea.boundingBox.center.x, y: 0)
        self.cannon = Cannon(position: cannonPosition)
        self.physicsEngine = PhysicsEngine(
            coordinateMapper: coordinateMapper,
            rigidBodies: SetObject<RigidBody>(),
            neighborFinder: QuadTree(bounds: playArea.boundingBox),
            collisionResolver: Collision()
        )
        self.peggleMaster = peggleMaster
        physicsEngine.delegate = self
        setupBindings()
        setupCallbacks()
    }

    func hydrate(with incomingLevel: PersistableDesignerGameLevel) throws {
        coordinateMapper = PhysicsCoordinateMapper.fromPersistable(
            persistableCoordinateMapper: incomingLevel.coordinateMapper,
            physicsCoordinateMapperConfigurable: coordinateMapper.getPhysicsConfigurable()
        )
        playArea = coordinateMapper.getPlayArea()
        physicsEngine.coordinateMapper = coordinateMapper
        bucket = Bucket(
            position: CGPoint(
                x: playArea.boundingBox.center.x,
                y: playArea.boundingBox.maxY - Settings.Bucket.distanceFromBottomOfPlayArea
            )
        )

        guard let bucket = bucket else {
            fatalError("should not be nil")
        }

        addBucket(bucket: bucket)
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
        case .waitingForNewRound:
            break
        case .gameEnd(stats: _):
            return
        case .disabled:
            return
        }

        switch gamePhase {
        case .beginning, .shootBallWhenReady, .ongoing, .stuck, .cleanup, .waitingForNewRound:
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
        pegs.$pegScores
            .sink { [weak self] in
                self?.totalScore.send($0.values.reduce(0, +))
            }
            .store(in: &subscriptions)
    }
}
