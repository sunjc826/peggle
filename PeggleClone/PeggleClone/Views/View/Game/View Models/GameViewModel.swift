import UIKit
import Combine
import AVFoundation

private let rotationRateSecondsTillTarget = 1.5

class GameViewModel {
    private var subscriptions: Set<AnyCancellable> = []

    var onScreenDisplayDimensionsPublisher: AnyPublisher<CGRect, Never> {
        onScreenDisplayDimensions.eraseToAnyPublisher()
    }

    private let onScreenDisplayDimensions: PassthroughSubject<CGRect, Never> = PassthroughSubject()

    var peggleMaster: PeggleMaster

    var gameEndViewModelPublisher: AnyPublisher<GameEndViewModel, Never> {
        gameEndViewModel.eraseToAnyPublisher()
    }
    var gameEndViewModel: PassthroughSubject<GameEndViewModel, Never> = PassthroughSubject()
    var gameLevel: GameLevel? {
        didSet {
            setupGameLevelBindings()
        }
    }
    var backingDesignerGameLevel: PersistableDesignerGameLevel?
    var coordinateMapper: PhysicsCoordinateMapper? {
        gameLevel?.coordinateMapper
    }

    var cannon: Cannon? {
        gameLevel?.cannon
    }

    var audioEffectPublisher: AnyPublisher<AVAudioPlayer?, Never> {
        audioEffect.eraseToAnyPublisher()
    }
    private var audioEffect: PassthroughSubject<AVAudioPlayer?, Never> = PassthroughSubject()

    init(peggleMaster: PeggleMaster?) {
        self.peggleMaster = peggleMaster ?? GameData.defaultPeggleMaster
    }

    private func setupGameLevelBindings() {
        guard let gameLevel = gameLevel else {
            fatalError("should not be nil")
        }

        gameLevel.$gamePhase
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
            .sink { [weak self] in self?.gameEndViewModel.send($0) }
            .store(in: &subscriptions)

        gameLevel.gameEvents
            .sink { [weak self] gameEvent in
                guard let self = self else {
                    return
                }

                self.addSoundEffect(dueTo: gameEvent)
            }
            .store(in: &subscriptions)
    }

    func addSoundEffect(dueTo gameEvent: GameEvent) {
        switch gameEvent {
        case .nothingHit:
            audioEffect.send(GameData.AudioEffects.ahahaEffect)
        case .gravityLowered:
            break
        case .specialPegHit:
            audioEffect.send(GameData.AudioEffects.wheeEffect)
        case .ballCollision:
            audioEffect.send(GameData.AudioEffects.boingEffect)
        case .ballFallthrough:
            break
        case .ballWrapAround:
            audioEffect.send(GameData.AudioEffects.teleportEffect)
        case .ballMultiply:
            break
        case .ballIntoBucket:
            audioEffect.send(GameData.AudioEffects.pinponEffect)
        }
    }

    func setDimensions(width: Double, height: Double) {
        let coordinateMapper = PhysicsCoordinateMapper(
            onScreenDisplayWidth: width,
            onScreenDisplayHeight: height,
            physicalScale: Settings.Physics.physicalScale
        )

        gameLevel = GameLevel(
            coordinateMapper: coordinateMapper,
            emptyPegsContainer: SetObject<Peg>(),
            peggleMaster: peggleMaster
        )
        let rect = CGRect(
            x: 0,
            y: 0,
            width: coordinateMapper.onScreenDisplayWidth,
            height: coordinateMapper.onScreenDisplayHeight
        )
        onScreenDisplayDimensions.send(
           rect
        )
    }

    func hydrate() {
        guard let gameLevel = gameLevel, let backingDesignerGameLevel = backingDesignerGameLevel else {
            fatalError("should not be nil")
        }

        do {
            try gameLevel.hydrate(with: backingDesignerGameLevel)
            let rect = CGRect(
                x: 0,
                y: 0,
                width: gameLevel.coordinateMapper.onScreenDisplayWidth,
                height: gameLevel.coordinateMapper.onScreenDisplayHeight
            )
            onScreenDisplayDimensions.send(
                rect
            )
        } catch {
            globalLogger.error("\(error)")
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
        let vmGameplayArea = GameplayAreaViewModel(gameLevel: gameLevel, delegate: self)
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

    func getObstacleViewModel(obstacle: Obstacle) -> GameObstacleViewModel {
        let vmGameObstacle = GameObstacleViewModel(obstacle: obstacle)
        vmGameObstacle.delegate = self
        return vmGameObstacle
    }

    func getGameEndViewModel(stats: GameRoundStats) -> GameEndViewModel {
        let vmGameEnd = GameEndViewModel(stats: stats)
        return vmGameEnd
    }
}

extension GameViewModel: CoordinateMappableViewModelDelegate,
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
