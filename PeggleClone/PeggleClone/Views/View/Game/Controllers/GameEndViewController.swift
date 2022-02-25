import UIKit
import Combine

protocol GameEndViewControllerDelegate: AnyObject {
    func restartGame()
    func backToLevelSelect()
}

class GameEndViewController: UIViewController {
    @IBOutlet private var lblGameStatus: UILabel!
    @IBOutlet private var btnRestart: UIButton!
    @IBOutlet private var btnBack: UIButton!
    @IBOutlet private var ivPeggleMaster: UIImageView!

    weak var delegate: GameEndViewControllerDelegate?
    private var subscriptions: Set<AnyCancellable> = []
    var viewModel: GameEndViewModel? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }

            lblGameStatus.text = viewModel.gameStatusText

            guard let audio = viewModel.audio else {
                return
            }

            audio.play()

            viewModel.gameImagePublisher
                .assign(to: \.image, on: ivPeggleMaster)
                .store(in: &subscriptions)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        registerEventHandlers()
    }

    private func registerEventHandlers() {
        btnRestart.addTarget(self, action: #selector(btnRestartOnTap), for: .touchUpInside)
        btnBack.addTarget(self, action: #selector(btnBackOnTap), for: .touchUpInside)
    }

    @IBAction private func btnRestartOnTap() {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.restartGame()
    }

    @IBAction private func btnBackOnTap() {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.backToLevelSelect()
    }

}
