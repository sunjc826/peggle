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
        viewModel.deselectPeg()
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

        viewModel.$previouslyEditedPeg
            .sink { [weak self] _ in
                guard let self = self, let viewModel = self.viewModel else {
                    return
                }

                if let previouslyEditedPeg = viewModel.previouslyEditedPeg, // get old value
                   let previouslyEditedPegViewModel = self.pegToButtonMap[previouslyEditedPeg]?.viewModel {
                    previouslyEditedPegViewModel.isBeingEdited = false
                }
            }
            .store(in: &subscriptions)

        viewModel.$pegBeingEdited
            .sink { [weak self] pegBeingEdited in
                guard let self = self else {
                    return
                }

                guard let pegBeingEdited = pegBeingEdited,
                      let btnPeg = self.pegToButtonMap[pegBeingEdited] else {
                    return
                }
                let pegViewModel = btnPeg.viewModel
                pegViewModel.isBeingEdited = true
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
        gameLevel.registerPegDidAddCallback(callback: addPegChild(peg:))
        gameLevel.registerPegDidUpdateCallback(callback: updatePegChild(oldPeg:newPeg:))
        gameLevel.registerPegDidRemoveCallback(callback: removePegChild(peg:))
        gameLevel.registerPegDidRemoveAllCallback(callback: clearPegs)
        gameLevel.isAcceptingOverlappingPegs = false
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

        viewModel.createPegAt(displayCoords: sender.location(in: vLayout))
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
    private func addPegChild(peg: Peg) {
        guard let viewModel = viewModel, let vLayout = vLayout else {
            fatalError("should not be nil")
        }
        let pegViewModel = viewModel.getDesignerPegViewModel(peg: peg)
        let pegEntityButton = DesignerPegButton(
            viewModel: pegViewModel,
            delegate: self
        )
        pegEntityButton.translatesAutoresizingMaskIntoConstraints = true
        vLayout.addSubview(pegEntityButton)
        pegToButtonMap[peg] = pegEntityButton
    }

    private func updatePegChild(oldPeg: Peg, newPeg: Peg) {
        guard let pegEntityButton = pegToButtonMap[oldPeg] else {
            fatalError("Peg should be associated with a button")
        }
        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }
        pegToButtonMap[oldPeg] = nil
        pegToButtonMap[newPeg] = pegEntityButton
        pegEntityButton.viewModel = viewModel.getDesignerPegViewModel(peg: newPeg)
        pegEntityButton.setNeedsDisplay()
        viewModel.selectToEdit(viewModel: pegEntityButton.viewModel)
    }

    private func removePegChild(peg: Peg) {
        guard let pegEntityButton = pegToButtonMap[peg] else {
            fatalError("Peg entity should be found in map")
        }

        guard let viewModel = viewModel else {
            fatalError("should not be nil")
        }

        viewModel.deselectPeg()
        pegEntityButton.removeFromSuperview()
        pegToButtonMap[peg] = nil
    }

    private func clearPegs() {
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
            viewModel.gameLevel?.isAcceptingOverlappingPegs = false
        }
        return image
    }
}
