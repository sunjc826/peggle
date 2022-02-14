import UIKit

class GameViewController: UIViewController, Storyboardable {
    @IBOutlet private var vGame: GameplayAreaView!

    var viewModel: GameViewModel?

    var ballToViewMap: [Ball: BallView] = [:]
    var pegToViewMap: [Peg: GamePegView] = [:]

    var lag = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupModels()
        registerEventHandlers()
        createDisplayLink()

        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        vGame.viewModel = viewModel.getGameplayAreaViewModel()
        viewModel.startNewGame()
    }

    func createDisplayLink() {
        let displaylink = CADisplayLink(target: self,
                                        selector: #selector(gameLoop))
        displaylink.preferredFramesPerSecond = GameLevel.targetFps
        displaylink.add(to: .current, forMode: .default)
    }

    @objc func gameLoop(displaylink: CADisplayLink) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        lag += displaylink.duration
        while lag >= GameLevel.targetSecondsPerFrame {
            viewModel.update()
            lag -= GameLevel.targetSecondsPerFrame
        }

        render()
    }

    func setupModels() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.setDimensions(width: vGame.frame.width, height: vGame.frame.height)

        guard let gameLevel = viewModel.gameLevel else {
            fatalError("should not be nil")
        }

        gameLevel.registerDidAddBallCallback(callback: addBallChild(ball:))
        gameLevel.registerDidUpdateBallCallback(callback: updateBallChild(oldBall:newBall:))
        gameLevel.registerDidRemoveBallCallback(callback: removeBallChild(ball:))
        gameLevel.registerDidAddPegCallback(callback: addPegChild(peg:))
        gameLevel.registerDidUpdatePegCallback(callback: updatePegChild(oldPeg:newPeg:))
        gameLevel.registerDidRemovePegCallback(callback: removePegChild(peg:))

        viewModel.hydrate()
    }

    func registerEventHandlers() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(self.onLongPress(_:))
        )
        vGame.addGestureRecognizer(longPressGestureRecognizer)
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.onTap(_:))
        )
        tapGestureRecognizer.shouldRequireFailure(of: longPressGestureRecognizer)
        vGame.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func onTap(_ sender: UITapGestureRecognizer) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.shootBall()
    }

    @objc func onLongPress(_ sender: UILongPressGestureRecognizer) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        let touchedCoords = sender.location(in: vGame)
        switch sender.state {
        case .began:
            viewModel.rotateCannon(to: touchedCoords)
        case .changed:
            viewModel.rotateCannon(to: touchedCoords)
        case .ended:
            viewModel.stopRotatingCannon()
        default:
            break
        }
    }

    func render() {
        vGame.setNeedsDisplay()
    }
}

// MARK: Callbacks
extension GameViewController {
    func addBallChild(ball: Ball) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }
        let vmBall = viewModel.getBallViewModel(ball: ball)
        let vBall = BallView(viewModel: vmBall)
        vBall.translatesAutoresizingMaskIntoConstraints = true
        vGame.addSubview(vBall)
        ballToViewMap[ball] = vBall
    }

    func updateBallChild(oldBall: Ball, newBall: Ball) {
        guard let vBall = ballToViewMap[oldBall] else {
            fatalError("Ball should be associated with a view")
        }
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }
        ballToViewMap[oldBall] = nil
        ballToViewMap[newBall] = vBall
        vBall.viewModel = viewModel.getBallViewModel(ball: newBall)
    }

    func removeBallChild(ball: Ball) {
        guard let vBall = ballToViewMap[ball] else {
            fatalError("Ball should be found in map")
        }
        vBall.removeFromSuperview()
        ballToViewMap[ball] = nil
    }

    func addPegChild(peg: Peg) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }
        let vmPeg = viewModel.getPegViewModel(peg: peg)
        let vPeg = GamePegView(viewModel: vmPeg)
        vPeg.translatesAutoresizingMaskIntoConstraints = true
        vGame.addSubview(vPeg)
        pegToViewMap[peg] = vPeg
    }

    func updatePegChild(oldPeg: Peg, newPeg: Peg) {
        guard let vPeg = pegToViewMap[oldPeg] else {
            fatalError("Peg should be associated with a view")
        }
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }
        pegToViewMap[oldPeg] = nil
        pegToViewMap[newPeg] = vPeg
        vPeg.viewModel = viewModel.getPegViewModel(peg: newPeg)
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
}
