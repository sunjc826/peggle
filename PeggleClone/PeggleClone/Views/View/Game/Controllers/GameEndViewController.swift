import UIKit

protocol GameEndViewControllerDelegate: AnyObject {
    func restartGame()
    func backToLevelSelect()
}

class GameEndViewController: UIViewController {
    @IBOutlet private var lblGameStatus: UILabel!
    @IBOutlet private var btnRestart: UIButton!
    @IBOutlet private var btnBack: UIButton!

    weak var delegate: GameEndViewControllerDelegate?

    var viewModel: GameEndViewModel? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }

            lblGameStatus.text = viewModel.gameStatusText
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
