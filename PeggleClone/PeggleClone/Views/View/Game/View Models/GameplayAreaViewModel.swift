import Foundation
import CoreGraphics
import Combine

private let pegs: [Peg] = {
    PegType.allCases.map { pegType in
        Peg(shape: CircleObject(), pegType: pegType, isConcrete: true)
    }
}()

protocol GameplayAreaViewModelDelegate: AnyObject, CoordinateMappable {}

class GameplayAreaViewModel {
    weak var delegate: GameplayAreaViewModelDelegate?
    private var subscriptions: Set<AnyCancellable> = []

    let gameLevel: GameLevel

    @Published var displayDimensions: CGRect?

    var cannonAnglePublisher: AnyPublisher<Double, Never> {
        cannonAngle.compactMap { $0 }.eraseToAnyPublisher()
    }
    private var cannonAngle: CurrentValueSubject<Double?, Never> = CurrentValueSubject(nil)
    var cannonPositionPublisher: AnyPublisher<CGPoint, Never> {
        cannonPosition.compactMap { $0 }.eraseToAnyPublisher()
    }
    private var cannonPosition: CurrentValueSubject<CGPoint?, Never> = CurrentValueSubject(nil)

    var cannonIsShootingPublisher: AnyPublisher<Bool, Never> {
        cannonIsShooting.eraseToAnyPublisher()
    }
    private var cannonIsShooting: PassthroughSubject<Bool, Never> = PassthroughSubject()

    var ballsLeftPublisher: AnyPublisher<Int, Never> {
        ballsLeft.prepend(gameLevel.numBalls).eraseToAnyPublisher()
    }
    var ballsLeft: PassthroughSubject<Int, Never> = PassthroughSubject()
    var activeCountPublisher: AnyPublisher<Int, Never> {
        gameLevel.activeCount.compactMap { $0 }.eraseToAnyPublisher()
    }
    var totalScorePublisher: AnyPublisher<Int, Never> {
        totalScore.prepend(0).eraseToAnyPublisher()
    }
    var totalScore: PassthroughSubject<Int, Never> = PassthroughSubject()

    var explosionEffectAtLocationPublisher: AnyPublisher<ExplosionParticleData, Never> {
        explosionEffectAtLocation.eraseToAnyPublisher()
    }
    private var explosionEffectAtLocation: PassthroughSubject<ExplosionParticleData, Never> = PassthroughSubject()

    var pegStatViewModels: [PegStatViewModel] = []

    init(gameLevel: GameLevel, delegate: GameplayAreaViewModelDelegate) {
        self.gameLevel = gameLevel
        self.delegate = delegate
        setupBindings()
        pegStatViewModels = pegs.map { peg in
            let pegCountPublisher = gameLevel.pegs.$pegCounts.compactMap { pegCount in
                pegCount[peg.pegType]
            }.eraseToAnyPublisher()
            return PegStatViewModel(peg: peg, count: pegCountPublisher)
        }
    }

    private func setupBindings() {
        gameLevel.cannon.$angle.sink { [weak self] in self?.cannonAngle.send($0) }.store(in: &subscriptions)
        gameLevel.cannon.$position
            .sink { [weak self] logicalCannonPosition in
                guard let self = self, let delegate = self.delegate else {
                    return
                }
                self.cannonPosition.send(delegate.getDisplayCoords(of: logicalCannonPosition))
            }
            .store(in: &subscriptions)
        gameLevel.$numBalls.sink { [weak self] in self?.ballsLeft.send($0) }.store(in: &subscriptions)
        gameLevel.totalScore.prepend(0).sink { [weak self] in self?.totalScore.send($0) }.store(in: &subscriptions)
        gameLevel.$coordinateMapper.sink { [weak self] coordinateMapper in
            guard let self = self else {
                fatalError("should not be nil")
            }
            self.displayDimensions = CGRect(
                x: 0,
                y: 0,
                width: coordinateMapper.displayWidth,
                height: coordinateMapper.displayHeight
            )
        }
        .store(in: &subscriptions)
        gameLevel.$gamePhase.sink { [weak self] gamePhase in
            if gamePhase == .shootBallWhenReady {
                self?.cannonIsShooting.send(true)
            } else {
                self?.cannonIsShooting.send(false)
            }
        }
        .store(in: &subscriptions)
        gameLevel.gameEvents.sink { [weak self] gameEvent in
            guard let self = self else {
                return
            }
            switch gameEvent {
            case .specialPegHit(location: let logicalLocation):
                let displayLocation = self.getDisplayCoords(of: logicalLocation)
                self.explosionEffectAtLocation.send(
                    ExplosionParticleData(explosionPoint: displayLocation)
                )
            default:
                break
            }
        }
        .store(in: &subscriptions)
    }
}

extension GameplayAreaViewModel {
    func getCannonLineViewModel() -> CannonLineViewModel {
        let vmCannonLine = CannonLineViewModel()
        vmCannonLine.delegate = self
        return vmCannonLine
    }

    func getBucketViewModel() -> BucketViewModel {
        let vmBucket = BucketViewModel(bucketPublisher: gameLevel.$bucket.eraseToAnyPublisher())
        vmBucket.delegate = self
        return vmBucket
    }
}

extension GameplayAreaViewModel: CannonLineViewModelDelegate, BucketViewModelDelegate {
    func getDisplayCoords(of logicalCoords: CGPoint) -> CGPoint {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }
        return delegate.getDisplayCoords(of: logicalCoords)
    }

    func getDisplayLength(of logicalLength: Double) -> Double {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }
        return delegate.getDisplayLength(of: logicalLength)
    }

    func getDisplayVector(of logicalVector: CGVector) -> CGVector {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }
        return delegate.getDisplayVector(of: logicalVector)
    }
}
