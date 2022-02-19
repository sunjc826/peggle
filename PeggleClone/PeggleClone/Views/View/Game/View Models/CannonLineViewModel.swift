import Foundation
import CoreGraphics
import Combine

protocol CannonLineViewModelDelegate: AnyObject, CoordinateMappable {
    var gameLevel: GameLevel { get }
}

class CannonLineViewModel {
    weak var delegate: CannonLineViewModelDelegate? {
        didSet {
            delegate?.gameLevel.$gamePhase.sink { [weak self] gamePhase in
                self?.shouldDrawPrediction = gamePhase == .beginning || gamePhase == .shootBallWhenReady
            }.store(in: &subscriptions)
        }
    }
    var subscriptions: Set<AnyCancellable> = []

    var predictiveLinePoints: [CGPoint] {
        guard let delegate = self.delegate else {
            fatalError("should not be nil")
        }
        let logicalLine = delegate.gameLevel.getBallPrediction()
        return logicalLine.map { logicalCoords in
            delegate.getDisplayCoords(of: logicalCoords)
        }
    }

    @Published var shouldDrawPrediction = true
}
