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
    private var vcShapeTransform: ShapeTransformViewController?

    var viewModel: DesignerViewModel?
    private var subscriptions: Set<AnyCancellable> = []

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
        bindPegs()
        bindShapeTransform()
        bindButtons()
    }

    private func addLetterBoxes(displayDimensions: CGRect) {
        guard let vLayout = vLayout else {
            fatalError("should not be nil")
        }
        let frameLeft = self.view.frame.minX
        let frameRight = self.view.frame.maxX
        let frameTop = self.view.frame.minY
        let frameBottom = self.view.frame.maxY
        let vLayoutLeft = vLayout.frame.minX
        let vLayoutRight = vLayout.frame.maxX
        let vLayoutTop = vLayout.frame.minY
        let vLayoutBottom = vLayout.frame.maxY
        // letterboxes on left and right
        if displayDimensions.width < self.view.frame.width {
            let vLeftLetterBox = LetterBoxView()
            let vRightLetterBox = LetterBoxView()
            vLeftLetterBox.frame = CGRect(
                x: frameLeft, y: frameTop,
                width: vLayoutLeft - frameLeft,
                height: frameBottom - frameTop
            )
            vRightLetterBox.frame = CGRect(
                x: vLayoutRight, y: frameTop,
                width: frameRight - vLayoutRight,
                height: frameBottom - frameTop
            )
            self.vLetterBoxes.append(vLeftLetterBox)
            self.vLetterBoxes.append(vRightLetterBox)
        }

        // letterboxes on top and bottom
        if displayDimensions.height < self.view.frame.height {
            let vTopLetterBox = LetterBoxView()
            let vBottomLetterBox = LetterBoxView()
            vTopLetterBox.frame = CGRect(
                x: frameLeft, y: frameTop,
                width: frameRight - frameLeft,
                height: vLayoutTop - frameTop
            )
            vBottomLetterBox.frame = CGRect(
                x: frameLeft, y: vLayoutBottom,
                width: frameRight - frameLeft,
                height: frameBottom - vLayoutBottom
            )
            self.vLetterBoxes.append(vTopLetterBox)
            self.vLetterBoxes.append(vBottomLetterBox)
        }

        for vLetterBox in self.vLetterBoxes {
            self.view.addSubview(vLetterBox)
            self.view.sendSubviewToBack(vLetterBox)
        }
    }

    private func bindDimensions() {
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

    private func bindShapeTransform() {
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

    private func bindButtons() {
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

    private func bindPegs() {
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.$previouslyEditedGameObject
            .sink { [weak self] _ in
                guard let self = self, let viewModel = self.viewModel else {
                    return
                }

                guard let previouslyEditedGameObject = viewModel.previouslyEditedGameObject else {
                    return
                }

                switch previouslyEditedGameObject {
                case let peg as Peg:
                    guard let previouslyEditedPegViewModel = self.pegToButtonMap[peg]?.viewModel else {
                        return
                    }
                    previouslyEditedPegViewModel.isBeingEdited = false
                case let obstacle as Obstacle:
                    guard let previouslyEditedObstacleViewModel = self.obstacleToButtonMap[obstacle]?.viewModel else {
                        return
                    }
                    previouslyEditedObstacleViewModel.isBeingEdited = false
                default:
                    return
                }
            }
            .store(in: &subscriptions)

        viewModel.$gameObjectBeingEdited
            .sink { [weak self] gameObjectBeingEdited in
                guard let self = self else {
                    return
                }

                guard let gameObjectBeingEdited = gameObjectBeingEdited else {
                    return
                }
                switch gameObjectBeingEdited {
                case let peg as Peg:
                    guard let vmPeg = self.pegToButtonMap[peg]?.viewModel else {
                        return
                    }
                    vmPeg.isBeingEdited = true
                case let obstacle as Obstacle:
                    guard let vmObstacle = self.obstacleToButtonMap[obstacle]?.viewModel else {
                        return
                    }
                    vmObstacle.isBeingEdited = true
                default:
                    return
                }
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

// MARK: Callbacks
extension DesignerViewController {
    private func addGameObjectChild(gameObject: GameObject) {
        switch gameObject {
        case let peg as Peg:
            addPegChild(peg: peg)
        case let obstacle as Obstacle:
            addObstacleChild(obstacle: obstacle)
        default:
            fatalError("unexpected type")
        }
    }

    private func addObstacleChild(obstacle: Obstacle) {
        guard let viewModel = viewModel, let vLayout = vLayout else {
            fatalError("should not be nil")
        }
        let vmObstacle = viewModel.getDesignerObstacleViewModel(obstacle: obstacle)
        let btnDesignerObstacle = DesignerObstacleButton(
            viewModel: vmObstacle,
            delegate: self
        )
        btnDesignerObstacle.translatesAutoresizingMaskIntoConstraints = true
        vLayout.addSubview(btnDesignerObstacle)
        obstacleToButtonMap[obstacle] = btnDesignerObstacle
    }

    private func addPegChild(peg: Peg) {
        guard let viewModel = viewModel, let vLayout = vLayout else {
            fatalError("should not be nil")
        }
        let vmPeg = viewModel.getDesignerPegViewModel(peg: peg)
        let btnDesignerPeg = DesignerPegButton(
            viewModel: vmPeg,
            delegate: self
        )
        btnDesignerPeg.translatesAutoresizingMaskIntoConstraints = true
        vLayout.addSubview(btnDesignerPeg)
        pegToButtonMap[peg] = btnDesignerPeg
    }

    private func updateGameObjectChild(oldGameObject: GameObject, updatedGameObject: GameObject) {
        switch (oldGameObject, updatedGameObject) {
        case let (oldPeg as Peg, updatedPeg as Peg):
            updatePegChild(oldPeg: oldPeg, updatedPeg: updatedPeg)
        case let (oldObstacle as Obstacle, updatedObstacle as Obstacle):
            updateObstacleChild(oldObstacle: oldObstacle, updatedObstacle: updatedObstacle)
        default:
            fatalError("unexpected type")
        }
    }

    private func updateObstacleChild(oldObstacle: Obstacle, updatedObstacle: Obstacle) {
        guard let btnDesignerObstacle = obstacleToButtonMap[oldObstacle] else {
            fatalError("should not be nil")
        }

        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        obstacleToButtonMap[oldObstacle] = nil
        obstacleToButtonMap[updatedObstacle] = btnDesignerObstacle
        btnDesignerObstacle.viewModel = viewModel.getDesignerObstacleViewModel(obstacle: updatedObstacle)
        viewModel.selectToEdit(viewModel: btnDesignerObstacle.viewModel)
    }

    private func updatePegChild(oldPeg: Peg, updatedPeg: Peg) {
        guard let btnDesignerPeg = pegToButtonMap[oldPeg] else {
            fatalError("Peg should be associated with a button")
        }
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }
        pegToButtonMap[oldPeg] = nil
        pegToButtonMap[updatedPeg] = btnDesignerPeg
        btnDesignerPeg.viewModel = viewModel.getDesignerPegViewModel(peg: updatedPeg)
        viewModel.selectToEdit(viewModel: btnDesignerPeg.viewModel)
    }

    private func removeGameObjectChild(gameObject: GameObject) {
        switch gameObject {
        case let peg as Peg:
            removePegChild(peg: peg)
        case let obstacle as Obstacle:
            removeObstacleChild(obstacle: obstacle)
        default:
            fatalError("unexpected type")
        }
    }

    private func removeObstacleChild(obstacle: Obstacle) {
        guard let btnDesignerObstacle = obstacleToButtonMap[obstacle] else {
            fatalError("should not be nil")
        }

        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.deselectGameObject()
        btnDesignerObstacle.removeFromSuperview()
        obstacleToButtonMap[obstacle] = nil
    }

    private func removePegChild(peg: Peg) {
        guard let btnDesignerPeg = pegToButtonMap[peg] else {
            fatalError("Peg should be found in map")
        }

        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.deselectGameObject()
        btnDesignerPeg.removeFromSuperview()
        pegToButtonMap[peg] = nil
    }

    private func clearGameObjects() {
        pegToButtonMap.values.forEach {
            $0.removeFromSuperview()
        }
        pegToButtonMap.removeAll()
    }
}

// MARK: View helpers
extension DesignerViewController {
    private func hideShapeTransformView() {
        vShapeTransform.isHidden = true
        vShapeTransform.alpha = 0
    }

    private func showShapeTransformView() {
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
