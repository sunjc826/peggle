import Foundation
import CoreGraphics
import Combine

protocol GameplayAreaViewModelDelegate: AnyObject, CoordinateMappable {}

class GameplayAreaViewModel {
    weak var delegate: GameplayAreaViewModelDelegate?

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

    var shouldDrawPrediction: Bool {
        gameLevel.gamePhase == .beginning || gameLevel.gamePhase == .shootBallWhenReady
    }

    init(gameLevel: GameLevel) {
        self.gameLevel = gameLevel
    }
}
