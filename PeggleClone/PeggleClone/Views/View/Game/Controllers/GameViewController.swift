import UIKit
import Combine
import AVFoundation

private let segueGameEnd = "segueGameEnd"

class GameViewController: UIViewController, Storyboardable {
    @IBOutlet private var vWithinSafeArea: GameplayAreaView!
    @IBOutlet private var cvGameEnd: UIView!
    var audioPlayers: [AVAudioPlayer?] = Array(
        repeating: nil,
        count: Settings.maximumConcurrentAudioEffects
    )
    var scrollvGame: GameLevelScrollView?
    var vStaticGame: GameplayAreaStaticView?
    var vGame: GameplayAreaDynamicView? {
        scrollvGame?.vGame
    }
    var vcGameEnd: GameEndViewController?
    var vLetterBoxes: [LetterBoxView] = []
    private var displayLink: CADisplayLink?

    var maximumScrollOffset: Double {
        guard let scrollvGame = scrollvGame, let vGame = vGame else {
            fatalError("should not be nil")
        }

        return vGame.frame.height - scrollvGame.frame.height
    }

    var didBackToLevelSelect: (() -> Void)?

    var viewModel: GameViewModel?
    private var subscriptions: Set<AnyCancellable> = []

    var ballToViewMap: [Ball: BallView] = [:]
    var pegToViewMap: [Peg: GamePegView] = [:]
    var obstacleToViewMap: [Obstacle: GameObstacleView] = [:]

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setup()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        displayLink?.invalidate()
    }

    private func setup() {
        setupBindings()
        setupViews()
        setupModels()
        registerEventHandlers()
        guard let vStaticGame = vStaticGame, let vGame = vGame, let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        // view model is shared between static and dynamic views
        let vmGameplayArea = viewModel.getGameplayAreaViewModel()
        vStaticGame.viewModel = vmGameplayArea
        vGame.viewModel = vmGameplayArea
        viewModel.startNewGame()
        startTimer()
    }

    private func startTimer() {
        displayLink = CADisplayLink(target: self, selector: #selector(gameLoop))
        guard let displayLink = displayLink else {
            fatalError("should not be nil")
        }

        displayLink.preferredFramesPerSecond = GameLevel.targetFps
        displayLink.add(to: .current, forMode: .default)
    }

    private func setupBindings() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.gameEndViewModelPublisher
            .sink { [weak self] vmGameEnd in
                guard let self = self else {
                    return
                }

                guard let vcGameEnd = self.vcGameEnd else {
                    fatalError("should not be nil")
                }

                self.displayLink?.invalidate()
                self.displayLink = nil
                vcGameEnd.viewModel = vmGameEnd
                self.cvGameEnd.isHidden = false
            }
            .store(in: &subscriptions)

        viewModel.onScreenDisplayDimensionsPublisher
            .sink { [weak self] onScreenDisplayDimensions in
                guard let self = self else {
                    return
                }

                self.updateDimensions(onScreenDisplayDimensions: onScreenDisplayDimensions)
            }
            .store(in: &subscriptions)

        viewModel.soundEffectPublisher.sink { [weak self] soundEffect in
            guard let self = self else {
                return
            }

            for (index, audioPlayer) in self.audioPlayers.enumerated() {
                if let isPlaying = audioPlayer?.isPlaying, isPlaying {
                    // Do not interrupt the currently played sound.
                    continue
                }

                DispatchQueue.global().async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.audioPlayers[index] = globalAudio.getSoundEffect(for: soundEffect)
                    self.audioPlayers[index]?.play()
                }
                return
            }
        }.store(in: &subscriptions)
    }

    func updateDimensions(onScreenDisplayDimensions: CGRect) {
        if self.vStaticGame == nil && self.scrollvGame == nil {
            self.vStaticGame = GameplayAreaStaticView(frame: onScreenDisplayDimensions)
            self.scrollvGame = GameLevelScrollView(frame: onScreenDisplayDimensions)
        } else {
            self.vStaticGame?.frame = onScreenDisplayDimensions

            self.scrollvGame?.frame = onScreenDisplayDimensions
        }

        guard let vStaticGame = self.vStaticGame, let scrollvGame = self.scrollvGame else {
            fatalError("should not be nil")
        }

        vStaticGame.center.x = self.vWithinSafeArea.frame.midX
        scrollvGame.center.x = self.vWithinSafeArea.frame.midX

        self.vLetterBoxes.forEach { $0.removeFromSuperview() }
        self.vLetterBoxes.removeAll()
        self.addLetterBoxes()
        self.vWithinSafeArea.addSubview(scrollvGame)
        self.vWithinSafeArea.addSubview(vStaticGame)
        scrollvGame.setNeedsLayout()
        scrollvGame.setNeedsDisplay()
        vStaticGame.setNeedsLayout()
        vStaticGame.setNeedsDisplay()
    }

    func addLetterBoxes() {
        guard let scrollvGame = scrollvGame else {
            fatalError("should not be nil")
        }

        let vLetterBoxes = vWithinSafeArea.getLetterBoxes(around: scrollvGame)
        self.vLetterBoxes.append(contentsOf: vLetterBoxes)
        for vLetterBox in self.vLetterBoxes {
            vWithinSafeArea.addSubview(vLetterBox)
            vWithinSafeArea.sendSubviewToBack(vLetterBox)
        }
    }

    @objc func gameLoop(displaylink: CADisplayLink) {
        viewModel?.update()
        vGame?.setNeedsDisplay()
    }

    private func setupModels() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.setDimensions(width: vWithinSafeArea.frame.width, height: vWithinSafeArea.frame.height)

        guard let gameLevel = viewModel.gameLevel else {
            fatalError("should not be nil")
        }

        gameLevel.registerDidAddBallCallback(callback: addBallChild(ball:))
        gameLevel.registerDidUpdateBallCallback(callback: updateBallChild(oldBall:updatedBall:))
        gameLevel.registerDidRemoveBallCallback(callback: removeBallChild(ball:))
        gameLevel.registerDidAddPegCallback(callback: addPegChild(peg:))
        gameLevel.registerDidUpdatePegCallback(callback: updatePegChild(oldPeg:updatedPeg:))
        gameLevel.registerDidRemovePegCallback(callback: removePegChild(peg:))
        gameLevel.registerDidAddObstacleCallback(callback: addObstacleChild(obstacle:))
        gameLevel.registerDidUpdateObstacleCallback(callback: updateObstacleChild(oldObstacle:updatedObstacle:))
        gameLevel.registerDidRemoveObstacleCallback(callback: removeObstacleChild(obstacle:))

        viewModel.hydrate()
    }

    private func registerEventHandlers() {
        guard let vGame = vGame else {
            return
        }
        let grPan = UIPanGestureRecognizer(
            target: self,
            action: #selector(self.onPan(_:))
        )
        vGame.addGestureRecognizer(grPan)
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.onTap(_:))
        )
        tapGestureRecognizer.shouldRequireFailure(of: grPan)
        vGame.addGestureRecognizer(tapGestureRecognizer)
    }

    private func setupViews() {
        cvGameEnd.isHidden = true
    }

    @objc func onTap(_ sender: UITapGestureRecognizer) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.shootBall()
    }

    @objc func onPan(_ sender: UILongPressGestureRecognizer) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        let touchedCoords = sender.location(in: vGame)
        viewModel.rotateCannon(to: touchedCoords)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case segueGameEnd:
            vcGameEnd = segue.destination as? GameEndViewController
            vcGameEnd!.delegate = self
        default:
            return
        }
    }
}

extension GameViewController {
    func addBallChild(ball: Ball) {
        guard let vGame = vGame, let viewModel = viewModel else {
            fatalError("should not be nil")
        }
        let vmBall = viewModel.getBallViewModel(ball: ball)
        let vBall = BallView(viewModel: vmBall)
        vBall.delegate = vGame
        vBall.translatesAutoresizingMaskIntoConstraints = true
        vGame.addSubview(vBall)
        ballToViewMap[ball] = vBall
        updateCameraBasedOnLowestBall()
    }

    func updateBallChild(oldBall: Ball, updatedBall: Ball) {
        guard let vBall = ballToViewMap[oldBall] else {
            fatalError("Ball should be associated with a view")
        }
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }
        ballToViewMap[oldBall] = nil
        ballToViewMap[updatedBall] = vBall
        vBall.viewModel = viewModel.getBallViewModel(ball: updatedBall)
        updateCameraBasedOnLowestBall()
    }

    func removeBallChild(ball: Ball) {
        guard let vBall = ballToViewMap[ball] else {
            fatalError("Ball should be found in map")
        }
        vBall.removeFromSuperview()
        ballToViewMap[ball] = nil
        updateCameraBasedOnLowestBall()
    }

    func updateCameraBasedOnLowestBall() {
        guard let scrollvGame = scrollvGame else {
            fatalError("should not be nil")
        }

        let vLowestBall = ballToViewMap.values.max { $0.center.y < $1.center.y }

        guard let lowestYPosition = vLowestBall?.center.y else {
            scrollvGame.setContentOffset(CGPoint.zero, animated: true)
            return
        }

        let contentOffsetY = Double.minimum(
            maximumScrollOffset,
            Double.maximum(0, lowestYPosition - scrollvGame.frame.height / 2)
        )
        scrollvGame.setContentOffset(CGPoint(x: 0, y: contentOffsetY), animated: false)
    }

    func addPegChild(peg: Peg) {
        guard let vGame = vGame, let viewModel = viewModel else {
            fatalError("should not be nil")
        }
        let vmPeg = viewModel.getPegViewModel(peg: peg)
        let vPeg = GamePegView(viewModel: vmPeg)
        vPeg.translatesAutoresizingMaskIntoConstraints = true
        vGame.addSubview(vPeg)
        pegToViewMap[peg] = vPeg
    }

    func updatePegChild(oldPeg: Peg, updatedPeg: Peg) {
        guard let vPeg = pegToViewMap[oldPeg] else {
            fatalError("Peg should be associated with a view")
        }
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }
        pegToViewMap[oldPeg] = nil
        pegToViewMap[updatedPeg] = vPeg
        vPeg.viewModel = viewModel.getPegViewModel(peg: updatedPeg)
    }

    func removePegChild(peg: Peg) {
        guard let vPeg = pegToViewMap[peg] else {
            fatalError("Peg should be found in map")
        }
        vPeg.fadeOut { [weak vPeg] isComplete in
            if isComplete {
                vPeg?.removeFromSuperview()
            }
        }
        pegToViewMap[peg] = nil
    }

    func addObstacleChild(obstacle: Obstacle) {
        guard let vGame = vGame, let viewModel = viewModel else {
            fatalError("should not be nil")
        }
        let vmObstacle = viewModel.getObstacleViewModel(obstacle: obstacle)
        let vObstacle = GameObstacleView(viewModel: vmObstacle)
        vObstacle.translatesAutoresizingMaskIntoConstraints = true
        vGame.addSubview(vObstacle)
        obstacleToViewMap[obstacle] = vObstacle
    }

    func updateObstacleChild(oldObstacle: Obstacle, updatedObstacle: Obstacle) {
        guard let vObstacle = obstacleToViewMap[oldObstacle] else {
            fatalError("Obstacle should be associated with a view")
        }
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }
        obstacleToViewMap[oldObstacle] = nil
        obstacleToViewMap[updatedObstacle] = vObstacle
        vObstacle.viewModel = viewModel.getObstacleViewModel(obstacle: updatedObstacle)
    }

    func removeObstacleChild(obstacle: Obstacle) {
        guard let vObstacle = obstacleToViewMap[obstacle] else {
            fatalError("Obstacle should be found in map")
        }
        vObstacle.fadeOut { [weak vObstacle] isComplete in
            if isComplete {
                vObstacle?.removeFromSuperview()
            }
        }
        obstacleToViewMap[obstacle] = nil
    }
}

extension GameViewController: GameEndViewControllerDelegate {
    func restartGame() {
        setup()
        cvGameEnd.isHidden = true
    }

    func backToLevelSelect() {
        didBackToLevelSelect?()
    }
}
