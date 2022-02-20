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
    @IBOutlet private var btnToggleAllowScrollResize: UIButton!
    @IBOutlet private var aiLoading: UIActivityIndicatorView!

    var scrollvLayout: DesignerScrollView?
    var vLayout: UIView? {
        scrollvLayout?.vLayout
    }
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
            fatalError("should not be nil")
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
        registerEventHandlers()
    }

    private func setupBindings() {
        bindLoad()
        bindDimensions()
        bindGameObjects()
        bindShapeTransform()
        bindButtons()
        bindScroll()
    }

    private func bindLoad() {
        viewModel?.isLoadingPublisher
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.aiLoading.isHidden = false
                    self?.aiLoading.startAnimating()
                } else {
                    self?.aiLoading.stopAnimating()
                    self?.aiLoading.isHidden = true
                }
            }
            .store(in: &subscriptions)
    }

    func bindDimensions() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.actualDisplayDimensionsPublisher
            .sink { [weak self] actualDisplayDimensions in
                guard let self = self else {
                    return
                }

                if self.scrollvLayout == nil {
                    self.scrollvLayout = DesignerScrollView(frame: actualDisplayDimensions)
                    self.scrollvLayout!.ownDelegate = self
                }

                guard let scrollvLayout = self.scrollvLayout else {
                    fatalError("should not be nil")
                }

                scrollvLayout.center.x = self.view.frame.midX

                for vLetterBox in self.vLetterBoxes {
                    vLetterBox.removeFromSuperview()
                }

                self.vLetterBoxes.removeAll()

                self.addLetterBoxes()
                self.view.addSubview(scrollvLayout)
                self.view.sendSubviewToBack(scrollvLayout)
                self.view.sendSubviewToBack(self.ivBackground)
                scrollvLayout.setNeedsLayout()
                scrollvLayout.setNeedsDisplay()
                self.viewModel?.contentOffsetYBottom = scrollvLayout.frame.height
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

        viewModel.toggleScrollText?
            .sink { [weak self] text in
                self?.btnToggleAllowScrollResize.setTitle(text, for: .normal)
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

    func bindScroll() {
        viewModel?.$contentOffsetYBottom
            .compactMap { $0 }
            .removeDuplicates()
            .sink { [weak self] contentOffsetYBottom in
                guard let self = self,
                      let scrollvLayout = self.scrollvLayout else {
                    return
                }
                let contentOffset = contentOffsetYBottom - scrollvLayout.frame.height
                scrollvLayout.setContentOffset(CGPoint(x: 0, y: contentOffset), animated: false)
            }
            .store(in: &subscriptions)
        viewModel?.displayDimensionsPublisher
            .sink { [weak self] displayDimensions in
                guard let self = self,
                      let vLayout = self.vLayout,
                      let superview = vLayout.superview else {
                    return
                }
                vLayout.frame = displayDimensions
                vLayout.center.x = superview.bounds.midX
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
            action: #selector(btnRemoveInconsistenciesOnTap),
            for: .touchUpInside
        )
        btnChangeEditMode.addTarget(
            self,
            action: #selector(btnEditModeOnTap),
            for: .touchUpInside
        )
        btnToggleAllowScrollResize.addTarget(
            self,
            action: #selector(btnToggleAllowScrollResizeOnTap),
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

    @IBAction private func btnRemoveInconsistenciesOnTap() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.removeInconsistencies()
    }

    @IBAction private func btnEditModeOnTap() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.toggleEditMode()
    }

    @IBAction private func btnToggleAllowScrollResizeOnTap() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.toggleAllowScrollResize()
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
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }
        viewModel.deselectGameObject()
        let subviewsToHide: [UIView?] = [
            lblEditModeHeader,
            lblEditMode,
            btnChangeEditMode,
            btnRemoveInconsistentPegs,
            btnToggleAllowScrollResize
        ]
        subviewsToHide.forEach { $0?.isHidden = true }
    }

    private func showAllNonPegsSubviews() {
        let subviewsToShow: [UIView?] = [
            lblEditModeHeader,
            lblEditMode,
            btnChangeEditMode,
            btnRemoveInconsistentPegs,
            btnToggleAllowScrollResize
        ]
        subviewsToShow.forEach { $0?.isHidden = false }
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
