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

    var predictiveLinePoints: [CGPoint] {
        guard let delegate = self.delegate else {
            fatalError("should not be nil")
        }
        let logicalLine = gameLevel.getBallPrediction()
        return logicalLine.map { logicalCoords in
            delegate.getDisplayCoords(of: logicalCoords)
        }
    }

    var cannonAngle: AnyPublisher<Double, Never>?
    var cannonPosition: AnyPublisher<CGPoint, Never>?
    var ballsLeft: AnyPublisher<Int, Never>?
    var totalScore: AnyPublisher<Int, Never>?
    var pegStatViewModels: [PegStatViewModel] = []

    var shouldDrawPrediction: Bool {
        gameLevel.gamePhase == .beginning || gameLevel.gamePhase == .shootBallWhenReady
    }

    init(gameLevel: GameLevel) {
        self.gameLevel = gameLevel
        setupBindings()
        pegStatViewModels = pegs.map { peg in
            let pegCountPublisher = gameLevel.pegs.$pegCounts.compactMap { pegCount in
                pegCount[peg.pegType]
            }.eraseToAnyPublisher()
            return PegStatViewModel(peg: peg, count: pegCountPublisher)
        }
    }

    private func setupBindings() {
        cannonAngle = gameLevel.cannon.$angle.eraseToAnyPublisher()

        cannonPosition = gameLevel.cannon.$position
            .map { [weak self] logicalCannonPosition in
                guard let self = self, let delegate = self.delegate else {
                    fatalError("should not be nil")
                }
                return delegate.getDisplayCoords(of: logicalCannonPosition)
            }
            .eraseToAnyPublisher()

        ballsLeft = gameLevel.$numBalls.eraseToAnyPublisher()

        totalScore = gameLevel.totalScore
    }
}
