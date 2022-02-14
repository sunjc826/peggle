import UIKit
import Combine
protocol StorageViewControllerDelegate: AnyObject {
    func transitionLoadLevel()
    func saveLevelAndTransition()
    func resetLevel()
    func saveAndTransitionStartGame()
    func changeLevelName()
}

class StorageViewController: UIViewController {

    @IBOutlet private var btnLoad: UIButton!
    @IBOutlet private var btnSave: UIButton!
    @IBOutlet private var btnReset: UIButton!
    @IBOutlet private var btnStart: UIButton!
    @IBOutlet private var btnLevelName: UIButton!
    weak var delegate: StorageViewControllerDelegate?
    private var subscriptions: Set<AnyCancellable> = []

    var viewModel: StorageViewModel?

    func duringParentViewDidAppear() {
        setupBindings()
        registerEventHandlers()
    }

    private func setupBindings() {
        guard let levelNamePublisher = viewModel?.levelNamePublisher else {
            fatalError("level name publisher should not be nil")
        }

        levelNamePublisher
            .sink { [weak self] text in
                self?.btnLevelName.setTitle(text, for: .normal)
            }
            .store(in: &subscriptions)
    }

    private func registerEventHandlers() {
        btnLoad.addTarget(self, action: #selector(loadButtonOnTap), for: .touchUpInside)
        btnSave.addTarget(self, action: #selector(saveButtonOnTap), for: .touchUpInside)
        btnReset.addTarget(self, action: #selector(resetButtonOnTap), for: .touchUpInside)
        btnStart.addTarget(self, action: #selector(startButtonOnTap), for: .touchUpInside)
        btnLevelName.addTarget(self, action: #selector(levelNameButtonOnTap), for: .touchUpInside)
    }

    @IBAction private func loadButtonOnTap() {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.transitionLoadLevel()
    }

    @IBAction private func saveButtonOnTap() {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.saveLevelAndTransition()
    }

    @IBAction private func resetButtonOnTap() {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.resetLevel()
    }

    @IBAction private func startButtonOnTap() {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.saveAndTransitionStartGame()
    }

    @IBAction private func levelNameButtonOnTap() {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.changeLevelName()
    }

}
