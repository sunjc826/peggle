import UIKit
import Combine

private let editModeConcreteOnlyText = "Concrete \u{1f9f1}"
private let editModeOverlappingAllowedText = "Ghost \u{1f47b}"

class DesignerViewModel {
    private var subscriptions: Set<AnyCancellable> = []
    private var paletteViewModel: PaletteViewModel
    private var shapeTransformViewModel: ShapeTransformViewModel

    @Published var previouslyEditedPeg: Peg?
    @Published var pegBeingEdited: Peg?
    @Published var shouldShowShapeTransform = false
    @Published var gameLevel: DesignerGameLevel?

    var selectedPegInPalette: Peg? {
        paletteViewModel.selectedPegInPalette
    }

    var isDeleting: Bool {
        paletteViewModel.isDeleting
    }

    @Published var editModeText: String = editModeConcreteOnlyText

    @Published var canRemoveInconsistentPegs = false

    @Published var actualDisplayDimensions: CGRect?

    private var coordinateMapper: CoordinateMapper? {
        gameLevel?.coordinateMapper
    }

    init(
        paletteViewModel: PaletteViewModel,
        shapeTransformViewModel: ShapeTransformViewModel
    ) {
        self.paletteViewModel = paletteViewModel
        self.shapeTransformViewModel = shapeTransformViewModel
        setupBindings()
    }

    private func setupBindings() {
        $pegBeingEdited.sink { [weak self] pegBeingEdited in
            guard let self = self else {
                return
            }

            self.shouldShowShapeTransform = pegBeingEdited != nil
            self.previouslyEditedPeg = pegBeingEdited
            guard let pegBeingEdited = pegBeingEdited else {
                return
            }
            self.shapeTransformViewModel.updateWith(peg: pegBeingEdited)
        }
        .store(in: &subscriptions)
    }

    func registerCallbacks() {
        gameLevel?.registerIsAcceptingOverlappingPegsDidSetCallback(
            callback: changeEditMode(isAcceptingOverlappingPegs:)
        )
    }

    func setDimensions(designerWidth: Double, designerHeight: Double, gameWidth: Double, gameHeight: Double) {
        let coordinateMapper = CoordinateMapper(
            width: gameWidth,
            height: gameHeight,
            displayWidth: designerWidth,
            displayHeight: designerHeight
        )
        gameLevel = DesignerGameLevel.withDefaultDependencies(coordinateMapper: coordinateMapper)
        actualDisplayDimensions = CGRect(
            x: 0,
            y: 0,
            width: coordinateMapper.displayWidth,
            height: coordinateMapper.displayHeight
        )
    }

    func selectToEdit(viewModel: CoordinateMappablePegViewModel) {
        if pegBeingEdited !== viewModel.peg {
            pegBeingEdited = viewModel.peg
        } else {
            pegBeingEdited = nil
        }
    }

    func deselectPeg() {
        if pegBeingEdited != nil {
            pegBeingEdited = nil
        }
    }

    func changeEditMode(isAcceptingOverlappingPegs: Bool) {
        if !isAcceptingOverlappingPegs {
            gameLevel?.removeInconsistencies()
            editModeText = editModeConcreteOnlyText
        } else {
            editModeText = editModeOverlappingAllowedText
        }

        canRemoveInconsistentPegs = isAcceptingOverlappingPegs
    }

    func createPegAt(displayCoords: CGPoint) {
        guard let selectedPegInPalette = selectedPegInPalette else {
            return
        }

        guard let coordinateMapper = coordinateMapper else {
            return
        }

        deselectPeg()
        let logicalCoords = coordinateMapper.getLogicalCoords(ofDisplayCoords: displayCoords)
        let pegToAdd = selectedPegInPalette.withCenter(center: logicalCoords)
        gameLevel?.addPeg(peg: pegToAdd)
    }

    func removeInconsistencies() {
        deselectPeg()
        gameLevel?.removeInconsistencies()
    }

    func toggleEditMode() {
        deselectPeg()
        gameLevel?.isAcceptingOverlappingPegs.toggle()
    }

    func move(pegViewModel: CoordinateMappablePegViewModel, to displayCoords: CGPoint) {
        guard let coordinateMapper = coordinateMapper else {
            return
        }

        deselectPeg()
        if isDeleting {
            return
        }

        let logicalCoords = coordinateMapper.getLogicalCoords(ofDisplayCoords: displayCoords)
        let oldPeg = pegViewModel.peg
        let translatedPeg = oldPeg.withCenter(center: logicalCoords)
        gameLevel?.updatePeg(old: oldPeg, with: translatedPeg)
    }

    func scale(_ scale: Double) {
        guard let oldPeg = pegBeingEdited else {
            return
        }

        let scaledPeg = oldPeg.withScale(
            scale: scale
        )

        gameLevel?.updatePeg(old: oldPeg, with: scaledPeg)
    }

    func rotate(_ rotation: Double) {
        guard let oldPeg = pegBeingEdited else {
            return
        }

        let rotatedPeg = oldPeg.withRotation(
            rotation: Double(rotation)
        )

        gameLevel?.updatePeg(old: oldPeg, with: rotatedPeg)
    }

    func remove(pegViewModel: CoordinateMappablePegViewModel) {
        deselectPeg()
        gameLevel?.removePeg(peg: pegViewModel.peg)
    }

    func tearDownBeforeTransition() {
        deselectPeg()
        gameLevel?.reset()
    }

    func getShapeTransformViewModel() -> ShapeTransformViewModel {
        shapeTransformViewModel
    }

    func getDesignerPegViewModel(peg: Peg) -> DesignerPegButtonViewModel {
        let vmDesignerPeg = DesignerPegButtonViewModel(peg: peg)
        vmDesignerPeg.delegate = self
        return vmDesignerPeg
    }
}

extension DesignerViewModel: CoordinateMappableViewModelDelegate {
    func getDisplayCoords(of logicalCoords: CGPoint) -> CGPoint {
        guard let coordinateMapper = coordinateMapper else {
            fatalError("should not be nil")
        }

        return coordinateMapper.getDisplayCoords(ofLogicalCoords: logicalCoords)
    }

    func getDisplayVector(of logicalVector: CGVector) -> CGVector {
        guard let coordinateMapper = coordinateMapper else {
            fatalError("should not be nil")
        }

        return coordinateMapper.getDisplayVector(ofLogicalVector: logicalVector)
    }

    func getDisplayLength(of logicalLength: Double) -> Double {
        guard let coordinateMapper = coordinateMapper else {
            fatalError("should not be nil")
        }

        return coordinateMapper.getDisplayLength(ofLogicalLength: logicalLength)
    }
}
