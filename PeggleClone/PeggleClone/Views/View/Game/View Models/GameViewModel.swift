import UIKit
import Combine

private let rotationRateSecondsTillTarget = 1.5
private let physicalScale: Double = 100.0

class GameViewModel {
    var gameLevel: GameLevel?
    var backingDesignerGameLevel: PersistableDesignerGameLevel?
    var coordinateMapper: PhysicsCoordinateMapper? {
        gameLevel?.coordinateMapper
    }

    var cannon: Cannon? {
        gameLevel?.cannon
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
            targetDirectionOfCannon.dx, targetDirectionOfCannon.dy
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
