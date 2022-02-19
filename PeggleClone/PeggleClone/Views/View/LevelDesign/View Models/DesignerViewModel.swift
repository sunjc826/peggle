import UIKit
import Combine

private let editModeConcreteOnlyText = "Concrete \u{1f9f1}"
private let editModeOverlappingAllowedText = "Ghost \u{1f47b}"
private let scrollResizeEnabledText = "Scroll Expansion Enabled"
private let scrollResizeDisabledText = "Scroll Expansion Disabled"

class DesignerViewModel {
    private var subscriptions: Set<AnyCancellable> = []
    private var paletteViewModel: PaletteViewModel
    private var shapeTransformViewModel: ShapeTransformViewModel

    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isLoading.eraseToAnyPublisher()
    }
    private var isLoading: PassthroughSubject<Bool, Never> = PassthroughSubject()

    @Published var previouslyEditedGameObject: GameObject?
    @Published var gameObjectBeingEdited: GameObject?
    @Published var shouldShowShapeTransform = false
    @Published var gameLevel: DesignerGameLevel? {
        didSet {
            registerCallbacks()
            setupGameLevelBindings()
            deselectGameObject()
            isLoading.send(false)
        }
    }

    var selectedGameObjectInPalette: GameObject? {
        paletteViewModel.selectedGameObject
    }

    var isDeleting: Bool {
        paletteViewModel.isDeleting
    }

    @Published var allowScrollResize = false

    var toggleScrollText: AnyPublisher<String, Never>?

    var displayDimensionsPublisher: AnyPublisher<CGRect, Never> {
        displayDimensions.eraseToAnyPublisher()
    }

    private var displayDimensions: PassthroughSubject<CGRect, Never> = PassthroughSubject()

    @Published var contentOffsetYBottom: Double?

    var mimimumContentOffsetYBottom: Double {
        guard let coordinateMapper = coordinateMapper else {
            fatalError("should not be nil")
        }
        return coordinateMapper.onScreenDisplayHeight
    }
    var maximumContentOffsetYBottom: Double {
        guard let coordinateMapper = coordinateMapper else {
            fatalError("should not be nil")
        }
        return coordinateMapper.displayHeight
    }

    @Published var editModeText: String = editModeConcreteOnlyText

    @Published var canRemoveInconsistentPegs = false

    var actualDisplayDimensionsPublisher: AnyPublisher<CGRect, Never> {
        actualDisplayDimensions.eraseToAnyPublisher()
    }

    private let actualDisplayDimensions: PassthroughSubject<CGRect, Never> = PassthroughSubject()

    var coordinateMapper: CoordinateMapper? {
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

        toggleScrollText = $allowScrollResize.map { allowScrollResize in
            allowScrollResize ? scrollResizeEnabledText : scrollResizeDisabledText
        }.eraseToAnyPublisher()
    }

    private func setupGameLevelBindings() {
        guard let gameLevel = gameLevel else {
            return
        }

        gameLevel.isLoading.sink { [weak self] isLoading in
            self?.isLoading.send(isLoading)
        }
        .store(in: &subscriptions)
        gameLevel.$coordinateMapper.sink { [weak self] coordinateMapper in
            guard let self = self else {
                return
            }

            self.displayDimensions.send(
                CGRect(
                    x: 0,
                    y: 0,
                    width: coordinateMapper.displayWidth,
                    height: coordinateMapper.displayHeight
                )
            )
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
            targetDisplayWidth: gameWidth,
            targetDisplayHeight: gameHeight,
            onScreenDisplayWidth: designerWidth,
            onScreenDisplayHeight: designerHeight
        )
        gameLevel = DesignerGameLevel.withDefaultDependencies(coordinateMapper: coordinateMapper)
        actualDisplayDimensions.send(
            CGRect(
                x: 0,
                y: 0,
                width: coordinateMapper.displayWidth,
                height: coordinateMapper.displayHeight
            )
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

    func toggleAllowScrollResize() {
        allowScrollResize.toggle()
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

        let scaledGameObject = oldGameObject.withScale(scale: scale)

        gameLevel?.updateGameObject(old: oldGameObject, with: scaledGameObject)
    }

    func rotate(_ rotation: Double) {
        guard let oldGameObject = gameObjectBeingEdited else {
            return
        }

        let rotatedGameObject = oldGameObject.withRotation(rotation: Double(rotation))

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

    // Remark: Setting oscillation radius would never actually cause any shape overlap
    // with respect to design stage, so it is perfectly possible and safe to just mutate the oscillationRadius
    // property of an obstacle. Additonally, the obstacle can then publish its oscillationRadius
    // with Combine. However, I chose to still do a full update for 2 reasons.
    // 1. There is already a robust update callback system, so minimal extra code is required.
    // 2. There will be multiple forms of data flow, leading to inconsistencies if I added a Publisher to
    // Obstacle. For e.g., most properties will be updated via the usual GameLevel.updateGameObject method
    // but some properties are published. Multiple types of data flow can complicate things quickly.
    //
    // The con of my design choice, of course, is needless update steps, reducing performance.
    func setOscillationRadius(
        of viewModel: CoordinateMappableObstacleViewModel,
        to displayOscillationRadius: Double
    ) {
        guard let coordinateMapper = coordinateMapper else {
            return
        }

        let logicalOscillationRadius = coordinateMapper.getLogicalLength(ofDisplayLength: displayOscillationRadius)
        let oldObstacle = viewModel.obstacle
        let updatedObstacle = oldObstacle.withRadiusOfOscillation(radiusOfOscillation: logicalOscillationRadius)
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

    // Remark: This has some assumptions about the view, so this can be
    // argued to be part of a controller's logic. Even so, on the whole,
    // it seems more logical to place it in the view model.
    func scroll(dy: Double) {
        guard let gameLevel = gameLevel,
              let coordinateMapper = coordinateMapper,
              let contentOffsetYBottom = contentOffsetYBottom else {
            return
        }

        let targetContentOffsetYBottom = Double.maximum(contentOffsetYBottom + dy, mimimumContentOffsetYBottom)

        if targetContentOffsetYBottom <= maximumContentOffsetYBottom {
            self.contentOffsetYBottom = targetContentOffsetYBottom
            return
        }

        guard allowScrollResize else {
            self.contentOffsetYBottom = maximumContentOffsetYBottom
            return
        }

        let updatedDisplayHeight = coordinateMapper.displayHeight + dy
        let updatedLogicalHeight = coordinateMapper.getLogicalLength(ofDisplayLength: updatedDisplayHeight)
        gameLevel.resizeLevelWithoutUpdatingNeighborFinder(updatedHeight: updatedLogicalHeight)
        self.contentOffsetYBottom = updatedDisplayHeight
    }

    func terminateScroll() {
        guard allowScrollResize else {
            return
        }

        gameLevel?.commitResize()
    }
}

// MARK: View model factories
extension DesignerViewModel {
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
