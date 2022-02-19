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

    @Published var displayHeight: Double?

    var cannonAnglePublisher: AnyPublisher<Double, Never> {
        cannonAngle.eraseToAnyPublisher()
    }
    var cannonAngle: PassthroughSubject<Double, Never> = PassthroughSubject()
    var cannonPositionPublisher: AnyPublisher<CGPoint, Never> {
        cannonPosition.eraseToAnyPublisher()
    }
    var cannonPosition: PassthroughSubject<CGPoint, Never> = PassthroughSubject()
    var ballsLeftPublisher: AnyPublisher<Int, Never> {
        ballsLeft.eraseToAnyPublisher()
    }
    var ballsLeft: PassthroughSubject<Int, Never> = PassthroughSubject()
    var totalScorePublisher: AnyPublisher<Int, Never> {
        totalScore.eraseToAnyPublisher()
    }
    var totalScore: PassthroughSubject<Int, Never> = PassthroughSubject()
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
        gameLevel.totalScore.sink { [weak self] in self?.totalScore.send($0) }.store(in: &subscriptions)
        gameLevel.$playArea.sink { [weak self] playArea in
            guard let self = self, let delegate = self.delegate else {
                fatalError("should not be nil")
            }
            self.displayHeight = delegate.getDisplayLength(of: playArea.height)
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
}

extension GameplayAreaViewModel: CannonLineViewModelDelegate {
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
