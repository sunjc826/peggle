import UIKit
import Combine

private let rotationRateSecondsTillTarget = 1.5
private let physicalScale: Double = 100.0

class GameViewModel {
    private var subscriptions: Set<AnyCancellable> = []
    var gameEndViewModelPublisher: AnyPublisher<GameEndViewModel, Never>?
    var gameLevel: GameLevel? {
        didSet {
            setupBindings()
        }
    }
    var backingDesignerGameLevel: PersistableDesignerGameLevel?
    var coordinateMapper: PhysicsCoordinateMapper? {
        gameLevel?.coordinateMapper
    }

    var cannon: Cannon? {
        gameLevel?.cannon
    }

    private func setupBindings() {
        guard let gameLevel = gameLevel else {
            fatalError("should not be nil")
        }

        gameEndViewModelPublisher = gameLevel.$gamePhase
            .map { [weak self] gamePhase -> GameEndViewModel? in
                guard let self = self else {
                    return nil
                }

                guard case .gameEnd(stats: let stats) = gamePhase else {
                    return nil
                }

                let vmGameEnd = self.getGameEndViewModel(stats: stats)

                return vmGameEnd
            }
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    func setDimensions(width: Double, height: Double) {
        guard let backingDesignerGameLevel = backingDesignerGameLevel else {
            fatalError("Game level should be present")
        }

        let coordinateMapper = PhysicsCoordinateMapper(
            playArea: backingDesignerGameLevel.playArea,
            displayWidth: width,
            displayHeight: height,
            physicalScale: physicalScale
        )

        gameLevel = GameLevel(coordinateMapper: coordinateMapper, pegs: SetObject<Peg>())
    }

    func hydrate() {
        guard let gameLevel = gameLevel, let backingDesignerGameLevel = backingDesignerGameLevel else {
            fatalError("should not be nil")
        }

        do {
            try gameLevel.hydrate(with: backingDesignerGameLevel)
        } catch {
            logger.error("\(error)")
        }
    }

    func startNewGame() {
        guard let gameLevel = gameLevel else {
            fatalError("should not be nil")
        }

        gameLevel.startNewRound()
    }

    func update() {
        guard let gameLevel = gameLevel else {
            return
        }
        gameLevel.update()
    }

    func shootBall() {
        guard let gameLevel = gameLevel else {
            return
        }
        gameLevel.wantToShoot()
    }

    func stopRotatingCannon() {
        guard let cannon = cannon else {
            fatalError("should not be nil")
        }

        cannon.rotationRate = 0.0
    }

    func rotateCannon(to displayCoords: CGPoint) {
        guard let cannon = cannon, let coordinateMapper = coordinateMapper else {
            fatalError("should not be nil")
        }

        let logicalCoords = coordinateMapper.getLogicalCoords(ofDisplayCoords: displayCoords)

        let targetDirectionOfCannon = CGVector(
            from: cannon.position, to: logicalCoords
        )

        let targetAngleOfCannon = atan2(
            -targetDirectionOfCannon.dx, targetDirectionOfCannon.dy
        )

        let angleDifference = targetAngleOfCannon - cannon.angle
        cannon.rotationRate = angleDifference / rotationRateSecondsTillTarget
    }

}

// MARK: View model factories
extension GameViewModel {
    func getGameplayAreaViewModel() -> GameplayAreaViewModel {
        guard let gameLevel = gameLevel else {
            fatalError("should not be nil")
        }
        let vmGameplayArea = GameplayAreaViewModel(gameLevel: gameLevel)
        vmGameplayArea.delegate = self
        return vmGameplayArea
    }

    func getBallViewModel(ball: Ball) -> BallViewModel {
        let vmBall = BallViewModel(ball: ball)
        vmBall.delegate = self
        return vmBall
    }

    func getPegViewModel(peg: Peg) -> GamePegViewModel {
        let vmGamePeg = GamePegViewModel(peg: peg)
        vmGamePeg.delegate = self
        return vmGamePeg
    }

    func getGameEndViewModel(stats: GameRoundStats) -> GameEndViewModel {
        let vmGameEnd = GameEndViewModel(stats: stats)
        return vmGameEnd
    }
}

extension GameViewModel: CoordinateMappablePegViewModelDelegate,
                         BallViewModelDelegate,
                         GameplayAreaViewModelDelegate {
    func getDisplayCoords(of logicalCoords: CGPoint) -> CGPoint {
        guard let coordinateMapper = coordinateMapper else {
            fatalError("should not be nil")
        }

        return coordinateMapper.getDisplayCoords(ofLogicalCoords: logicalCoords)
    }

    func getDisplayLength(of logicalLength: Double) -> Double {
        guard let coordinateMapper = coordinateMapper else {
            fatalError("should not be nil")
        }

        return coordinateMapper.getDisplayLength(ofLogicalLength: logicalLength)
    }

    func getDisplayVector(of logicalVector: CGVector) -> CGVector {
        guard let coordinateMapper = coordinateMapper else {
            fatalError("should not be nil")
        }

        return coordinateMapper.getDisplayVector(ofLogicalVector: logicalVector)
    }
}
