import UIKit
import Combine

private let segueStorage = "segueStorage"
private let seguePalette = "seguePalette"
private let segueDesigner = "segueDesigner"

class DesignerMainViewController: UIViewController, Storyboardable {
    // MARK: Child view controllers
    private var vcPalette: PaletteViewController?
    private var vcStorage: StorageViewController?
    private var vcDesigner: DesignerViewController?

    var viewModel: DesignerMainViewModel?

    var decodedGameLevel: DesignerGameLevel?

    var didLevelSelect: (() -> Void)?
    var didStartGame: ((URL?) -> Void)?
    var didStartOwnView: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let vcPalette = vcPalette,
              let vcDesigner = vcDesigner,
              let vcStorage = vcStorage else {
                  fatalError("should not be nil")
              }
        vcDesigner.duringParentViewDidAppear()
        vcPalette.duringParentViewDidAppear()
        vcStorage.duringParentViewDidAppear()

        didStartOwnView?()
    }
}

extension DesignerMainViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }
        let childViewModels = viewModel.getChildViewModels()
        switch segue.identifier {
        case seguePalette:
            vcPalette = segue.destination as? PaletteViewController
            vcPalette!.viewModel = childViewModels.paletteViewModel
        case segueStorage:
            vcStorage = segue.destination as? StorageViewController
            vcStorage!.delegate = self
            vcStorage!.viewModel = childViewModels.storageViewModel
        case segueDesigner:
            vcDesigner = segue.destination as? DesignerViewController
            vcDesigner!.viewModel = childViewModels.designerViewModel
        default:
            return
        }
    }
}

extension DesignerMainViewController: StorageViewControllerDelegate {
    func transitionLoadLevel() {
        didLevelSelect?()
    }

    func saveLevelAndTransition() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }
        let imageData = captureImageOfLevel()
        do {
            try viewModel.saveLevel(imageData: imageData)
        } catch TransitionError.nameBlank {
            showNameLengthWarning()
        } catch TransitionError.inconsistent {
            attemptingToSegueWithInconsistentLevel()
        } catch {
            globalLogger.error("unexpected error")
        }
        didLevelSelect?()
    }

    private func showNameLengthWarning() {
        let alert = UIAlertController(
            title: "Unable to save",
            message: "Level name must not be blank",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: "Ok", style: .cancel, handler: { _ in })
        )

        present(alert, animated: true, completion: nil)
    }

    func saveAndTransitionStartGame() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        let imageData = captureImageOfLevel()
        var levelURL: URL?
        do {
            levelURL = try viewModel.saveLevel(imageData: imageData, updateDecodedLevel: true)
        } catch TransitionError.nameBlank {
            showNameLengthWarning()
        } catch TransitionError.inconsistent {
            attemptingToSegueWithInconsistentLevel()
        } catch {
            globalLogger.error("unexpected error")
            return
        }

        didStartGame?(levelURL)
    }

    func resetLevel() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }
        viewModel.resetLevel()
    }

    func captureImageOfLevel() -> Data {
        guard let vcDesigner = vcDesigner else {
            fatalError("should not be nil")
        }
        return vcDesigner.imageData
    }

    func attemptingToSegueWithInconsistentLevel() {
        let alert = UIAlertController(
            title: "Unable to proceed",
            message: "Check that all pegs are consistent",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in }))
        alert.addAction(UIAlertAction(
            title: "Remove inconsistencies",
            style: .destructive,
            handler: { [weak self] _ in
                guard let self = self, let viewModel = self.viewModel else {
                    fatalError("should not be nil")
                }
                viewModel.removeInconsistencies()
            })
        )

        present(alert, animated: true, completion: nil)
    }

    func changeLevelName() {
        let alert = UIAlertController(
            title: "Input level name",
            message: nil,
            preferredStyle: .alert
        )
        alert.addTextField { [weak self] textField in
            guard let self = self, let viewModel = self.viewModel else {
                fatalError("should not be nil")
            }
            textField.text = viewModel.levelName
        }

        alert.addAction(
            UIAlertAction(
                title: "Confirm level name",
                style: .default,
                handler: { [weak self, weak alert] _ in
                    guard let self = self, let viewModel = self.viewModel else {
                        fatalError("should not be nil")
                    }
                    let textField = alert?.textFields?[0]
                    viewModel.levelName = textField?.text
                }
            )
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in }))

        present(alert, animated: true, completion: nil)
    }
}
