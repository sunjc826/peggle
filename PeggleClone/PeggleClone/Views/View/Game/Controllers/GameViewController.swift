import UIKit
import Combine

private let segueGameEnd = "segueGameEnd"

class GameViewController: UIViewController, Storyboardable {
    @IBOutlet private var vGame: GameplayAreaView!
    @IBOutlet private var cvGameEnd: UIView!
    private var vcGameEnd: GameEndViewController?
    private var displayLink: CADisplayLink?

    var didBackToLevelSelect: (() -> Void)?

    var viewModel: GameViewModel?
    private var subscriptions: Set<AnyCancellable> = []

    var ballToViewMap: [Ball: BallView] = [:]
    var pegToViewMap: [Peg: GamePegView] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        setupModels()
        registerEventHandlers()
        setupViews()
        setupBindings()

        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        vGame.setup(viewModel: viewModel.getGameplayAreaViewModel())
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

        guard let gameEndViewModelPublisher = viewModel.gameEndViewModelPublisher else {
            fatalError("should not be nil")
        }

        gameEndViewModelPublisher.sink { [weak self] vmGameEnd in
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
    }

    @objc func gameLoop(displaylink: CADisplayLink) {
        viewModel?.update()
        vGame.setNeedsDisplay()
    }

    private func setupModels() {
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

    private func registerEventHandlers() {
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

    private func setupViews() {
        cvGameEnd.isHidden = true
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

extension GameViewController: GameEndViewControllerDelegate {
    func restartGame() {
        setup()
        cvGameEnd.isHidden = true
    }

    func backToLevelSelect() {
        didBackToLevelSelect?()
    }
}
