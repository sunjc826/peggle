import UIKit
import Combine

private let segueShapeTransform = "segueShapeTransform"

/// Controls the placement and relocation of pegs on the canvas.
class DesignerViewController: UIViewController {

    @IBOutlet private var lblEditModeHeader: UILabel!
    @IBOutlet private var btnRemoveInconsistentPegs: UIButton!
    @IBOutlet private var lblEditMode: UILabel!
    @IBOutlet private var btnChangeEditMode: UIButton!
    @IBOutlet private var vShapeTransform: UIView!
    @IBOutlet private var ivBackground: UIImageView!

    var vLayout: UIView?
    var vLetterBoxes: [LetterBoxView] = []
    var vcShapeTransform: ShapeTransformViewController?

    var viewModel: DesignerViewModel?
    var subscriptions: Set<AnyCancellable> = []

    var pegToButtonMap: [Peg: DesignerPegButton] = [:]
    var obstacleToButtonMap: [Obstacle: DesignerObstacleButton] = [:]

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == segueShapeTransform else {
            return
        }

        vcShapeTransform = segue.destination as? ShapeTransformViewController
        guard let vcShapeTransform = vcShapeTransform, let viewModel = viewModel else {
            fatalError("should not be niil")
        }
        vcShapeTransform.viewModel = viewModel.getShapeTransformViewModel()
        vcShapeTransform.delegate = self
    }
}

// MARK: Setup
extension DesignerViewController {
    func duringParentViewDidAppear() {
        setupBindings()
        setupModels()
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }
        viewModel.registerCallbacks()
        registerEventHandlers()
        viewModel.deselectGameObject()
    }

    private func setupBindings() {
        bindDimensions()
        bindGameObjects()
        bindShapeTransform()
        bindButtons()
    }

    func bindDimensions() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.$actualDisplayDimensions
            .compactMap { $0 }
            .sink { [weak self] actualDisplayDimensions in
                guard let self = self else {
                    return
                }

                if self.vLayout == nil {
                    self.vLayout = UIView()
                }

                guard let vLayout = self.vLayout else {
                    fatalError("should not be nil")
                }

                vLayout.frame = actualDisplayDimensions
                vLayout.center.x = self.view.frame.midX

                for vLetterBox in self.vLetterBoxes {
                    vLetterBox.removeFromSuperview()
                }
                self.vLetterBoxes.removeAll()

                self.addLetterBoxes(displayDimensions: actualDisplayDimensions)
                self.view.addSubview(vLayout)
                self.view.sendSubviewToBack(vLayout)
                self.view.sendSubviewToBack(self.ivBackground)
                vLayout.setNeedsLayout()
                vLayout.setNeedsDisplay()
            }
            .store(in: &subscriptions)
    }

    func bindShapeTransform() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.$shouldShowShapeTransform
            .sink { [weak self] shouldShowShapeTransform in
                if shouldShowShapeTransform {
                    self?.showShapeTransformView()
                } else {
                    self?.hideShapeTransformView()
                }
            }
            .store(in: &subscriptions)
    }

    func bindButtons() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.$editModeText
            .sink { [weak self] editModeText in
                self?.lblEditMode.text = editModeText
            }
            .store(in: &subscriptions)

        viewModel.$canRemoveInconsistentPegs
            .sink { [weak self] canRemoveInconsistentPegs in
                self?.btnRemoveInconsistentPegs.isHidden = !canRemoveInconsistentPegs
            }
            .store(in: &subscriptions)
    }

    func bindGameObjects() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.$previouslyEditedGameObject
            .sink { [weak self] _ in
                guard let self = self else {
                    return
                }
                // Note: This uses the fact that @Published broadcasts a new value BEFORE setting it, i.e. willSet.
                self.stopEditingGameObject()
            }
            .store(in: &subscriptions)

        viewModel.$gameObjectBeingEdited
            .sink { [weak self] gameObjectBeingEdited in
                guard let self = self else {
                    return
                }

                self.startEditingGameObject(gameObjectBeingEdited: gameObjectBeingEdited)
            }
            .store(in: &subscriptions)
    }

    private func setupModels() {
        guard let viewModel = viewModel, let parent = parent else {
            fatalError("should not be nil")
        }
        viewModel.setDimensions(
            designerWidth: view.frame.width,
            designerHeight: view.frame.height,
            gameWidth: parent.view.frame.width,
            gameHeight: parent.view.frame.height
        )
        guard let gameLevel = viewModel.gameLevel else {
            fatalError("game level should be present")
        }
        gameLevel.registerGameObjectDidAddCallback(callback: addGameObjectChild(gameObject:))
        gameLevel.registerGameObjectDidUpdateCallback(callback: updateGameObjectChild(oldGameObject:updatedGameObject:))
        gameLevel.registerGameObjectDidRemoveCallback(callback: removeGameObjectChild(gameObject:))
        gameLevel.registerGameObjectDidRemoveAllCallback(callback: clearGameObjects)
        gameLevel.isAcceptingOverlappingGameObjects = false
    }

    private func registerEventHandlers() {
        guard let vLayout = vLayout else {
            fatalError("should not be nil")
        }
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.onTap(_:))
        )
        vLayout.addGestureRecognizer(tapGestureRecognizer)
        btnRemoveInconsistentPegs.addTarget(
            self,
            action: #selector(removeInconsistenciesButtonOnTap),
            for: .touchUpInside
        )
        btnChangeEditMode.addTarget(
            self,
            action: #selector(editModeButtonOnTap),
            for: .touchUpInside
        )
    }
}

// MARK: Event handlers
extension DesignerViewController {
    @objc func onTap(_ sender: UITapGestureRecognizer) {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.createGameObjectAt(displayCoords: sender.location(in: vLayout))
    }

    @IBAction private func removeInconsistenciesButtonOnTap() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.removeInconsistencies()
    }

    @IBAction private func editModeButtonOnTap() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.toggleEditMode()
    }
}

// MARK: View helpers
extension DesignerViewController {
    func hideShapeTransformView() {
        vShapeTransform.isHidden = true
        vShapeTransform.alpha = 0
    }

    func showShapeTransformView() {
        vShapeTransform.isHidden = false
        vShapeTransform.alpha = 1
    }
}

// MARK: Image processing
extension DesignerViewController {
    private func hideAllNonPegsSubviews() {
        lblEditModeHeader.isHidden = true
        lblEditMode.isHidden = true
        btnChangeEditMode.isHidden = true
        btnRemoveInconsistentPegs.isHidden = true

        guard let vcShapeTransform = vcShapeTransform else {
            fatalError("should not be nil")
        }
        vcShapeTransform.view.isHidden = true
    }

    private func showAllNonPegsSubviews() {
        lblEditModeHeader.isHidden = false
        lblEditMode.isHidden = false
        btnChangeEditMode.isHidden = false
        btnRemoveInconsistentPegs.isHidden = false
    }

    var imageData: Data {
        guard let viewModel = viewModel, let vLayout = vLayout else {
            fatalError("should not be nil")
        }

        let renderer = UIGraphicsImageRenderer(bounds: vLayout.bounds)
        let image = renderer.pngData { context in
            hideAllNonPegsSubviews()
            vLayout.layer.render(in: context.cgContext)
            showAllNonPegsSubviews()
            viewModel.gameLevel?.isAcceptingOverlappingGameObjects = false
        }
        return image
    }
}
