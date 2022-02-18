import UIKit
import Combine

private let editModeConcreteOnlyText = "Concrete \u{1f9f1}"
private let editModeOverlappingAllowedText = "Ghost \u{1f47b}"

class DesignerViewModel {
    private var subscriptions: Set<AnyCancellable> = []
    private var paletteViewModel: PaletteViewModel
    private var shapeTransformViewModel: ShapeTransformViewModel

    @Published var previouslyEditedGameObject: GameObject?
    @Published var gameObjectBeingEdited: GameObject?
    @Published var shouldShowShapeTransform = false
    @Published var gameLevel: DesignerGameLevel?

    var selectedGameObjectInPalette: GameObject? {
        paletteViewModel.selectedGameObject
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
        $gameObjectBeingEdited
            .sink { [weak self] gameObjectBeingEdited in
                guard let self = self else {
                    return
                }
                self.shouldShowShapeTransform = gameObjectBeingEdited != nil
                self.previouslyEditedGameObject = gameObjectBeingEdited
                guard let gameObjectBeingEdited = gameObjectBeingEdited else {
                    return
                }
                self.shapeTransformViewModel.updateWith(gameObject: gameObjectBeingEdited)
            }
            .store(in: &subscriptions)
    }

    func registerCallbacks() {
        gameLevel?.registerIsAcceptingOverlappingGameObjectsDidSetCallback(
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

    func selectToEditAndDeselectIfAlreadyEditing(viewModel: AbstractCoordinateMappableGameObjectViewModel) {
        if gameObjectBeingEdited !== viewModel.gameObject {
            gameObjectBeingEdited = viewModel.gameObject
        } else {
            gameObjectBeingEdited = nil
        }
    }

    func selectToEdit(viewModel: AbstractCoordinateMappableGameObjectViewModel) {
        if gameObjectBeingEdited !== viewModel.gameObject {
            gameObjectBeingEdited = viewModel.gameObject
        }
    }

    func deselectGameObject() {
        if gameObjectBeingEdited != nil {
            gameObjectBeingEdited = nil
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

    func createGameObjectAt(displayCoords: CGPoint) {
        guard let selectedGameObjectInPalette = selectedGameObjectInPalette else {
            return
        }

        guard let coordinateMapper = coordinateMapper else {
            return
        }

        deselectGameObject()
        let logicalCoords = coordinateMapper.getLogicalCoords(ofDisplayCoords: displayCoords)
        let gameObject = selectedGameObjectInPalette.withCenter(center: logicalCoords)
        gameLevel?.addGameObject(gameObject: gameObject)
    }

    func removeInconsistencies() {
        deselectGameObject()
        gameLevel?.removeInconsistencies()
    }

    func toggleEditMode() {
        deselectGameObject()
        gameLevel?.isAcceptingOverlappingGameObjects.toggle()
    }

    func move(viewModel: AbstractCoordinateMappableGameObjectViewModel, to displayCoords: CGPoint) {
        guard let coordinateMapper = coordinateMapper else {
            return
        }

        deselectGameObject()
        if isDeleting {
            return
        }

        let logicalCoords = coordinateMapper.getLogicalCoords(ofDisplayCoords: displayCoords)
        let oldGameObject = viewModel.gameObject
        let translatedGameObject = oldGameObject.withCenter(center: logicalCoords)
        gameLevel?.updateGameObject(old: oldGameObject, with: translatedGameObject)
    }

    func scale(_ scale: Double) {
        guard let oldGameObject = gameObjectBeingEdited else {
            return
        }

        let scaledGameObject = oldGameObject.withScale(
            scale: scale
        )

        gameLevel?.updateGameObject(old: oldGameObject, with: scaledGameObject)
    }

    func rotate(_ rotation: Double) {
        guard let oldGameObject = gameObjectBeingEdited else {
            return
        }

        let rotatedGameObject = oldGameObject.withRotation(
            rotation: Double(rotation)
        )

        gameLevel?.updateGameObject(old: oldGameObject, with: rotatedGameObject)
    }

    func relocateObstacleVertex(
        of viewModel: CoordinateMappableObstacleViewModel,
        at vertexIndex: Int,
        to displayCoords: CGPoint
    ) {
        if isDeleting {
            return
        }

        guard let coordinateMapper = coordinateMapper else {
            return
        }
        let logicalCoords = coordinateMapper.getLogicalCoords(ofDisplayCoords: displayCoords)
        let oldObstacle = viewModel.obstacle
        guard let triangle = oldObstacle.shape as? TriangleObject else {
            fatalError("unexpected type")
        }
        var updatedVertices = triangle.vertices
        updatedVertices[vertexIndex] = logicalCoords

        guard BoundingBox.isOrientationValid(vertices: updatedVertices) else {
            return
        }

        let updatedObstacle = oldObstacle.withVertices(vertices: updatedVertices)

        gameLevel?.updateGameObject(old: oldObstacle, with: updatedObstacle)
    }

    func remove(viewModel: AbstractCoordinateMappableGameObjectViewModel) {
        deselectGameObject()
        gameLevel?.removeGameObject(gameObject: viewModel.gameObject)
    }

    func tearDownBeforeTransition() {
        deselectGameObject()
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

    func getDesignerObstacleViewModel(obstacle: Obstacle) -> DesignerObstacleButtonViewModel {
        let vmDesignerObstacle = DesignerObstacleButtonViewModel(obstacle: obstacle)
        vmDesignerObstacle.delegate = self
        return vmDesignerObstacle
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
