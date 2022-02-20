import Foundation
import CoreGraphics
import Combine

typealias Runnable = () -> Void
typealias UnaryFunction<T> = (T) -> Void
typealias BinaryFunction<T> = (T, T) -> Void

struct HydrationIncompatibleError: Error {
    let message = "Attempting to hydrate with a level bigger than the current allowed size"
}

/// Encapsulates a single level of Peggle.
final class DesignerGameLevel {
    private var setLevelNameCallbacks = [UnaryFunction<String>]()
    private var isAcceptingOverlappingGameObjectsCallbacks = [UnaryFunction<Bool>]()
    private var addGameObjectCallbacks = [UnaryFunction<GameObject>]()
    private var updateGameObjectCallbacks = [BinaryFunction<GameObject>]()
    private var removeGameObjectCallbacks = [UnaryFunction<GameObject>]()
    private var removeAllCallbacks = [Runnable]()

    var isAcceptingOverlappingGameObjects = false {
        didSet {
            for callback in isAcceptingOverlappingGameObjectsCallbacks {
                callback(isAcceptingOverlappingGameObjects)
            }
        }
    }

    let isLoading: PassthroughSubject<Bool, Never> = PassthroughSubject()

    @Published var levelName: String? = "Default level name"
    @Published var coordinateMapper: CoordinateMapper
    var playArea: PlayArea
    private var gameObjects: AnyContainer<GameObject>
    private let neighborFinder: AnyNeighborFinder<GameObject>
    private let collisionDetector: CollisionDetector

    /// - Remark: No game objects should be placed into a `DesignerGameLevel` at initialization.
    /// The injection of a bunch of game objects is always via the `hydrate` method.
    init<T, S>(
        coordinateMapper: CoordinateMapper,
        emptyContainer: T,
        neighborFinder: S,
        collisionDetector: CollisionDetector
    )
    where T: Container, T.Element == GameObject, S: NeighborFinder, S.Element == GameObject {
        self.coordinateMapper = coordinateMapper
        self.playArea = coordinateMapper.getPlayArea()
        assert(emptyContainer.isEmpty)
        self.gameObjects = AnyContainer(container: emptyContainer)
        self.neighborFinder = AnyNeighborFinder(neighborFinder: neighborFinder)
        self.collisionDetector = collisionDetector
        isLoading.send(false)
    }

    /// Updates self with the contents of the incoming level.
    func hydrate(
        with incomingLevel: PersistableDesignerGameLevel
    ) {
        isLoading.send(true)

        levelName = incomingLevel.levelName
        let incomingCoordinateMapper = CoordinateMapper.fromPersistable(
            persistableCoordinateMapper: incomingLevel.coordinateMapper,
            coordinateMapperConfigurable: coordinateMapper.getConfigurable()
        )
        coordinateMapper = incomingCoordinateMapper
        playArea = coordinateMapper.getPlayArea()
        for persistablePeg in incomingLevel.pegs {
            let peg = Peg.fromPersistable(persistablePeg: persistablePeg)
            addGameObject(gameObject: peg)
        }

        for persistableObstacle in incomingLevel.obstacles {
            let obstacle = Obstacle.fromPersistable(persistableObstacle: persistableObstacle)
            addGameObject(gameObject: obstacle)
        }

        isLoading.send(false)
    }

    func registerOnLevelNameDidSetCallback(callback: @escaping UnaryFunction<String>) {
        setLevelNameCallbacks.append(callback)
    }

    func registerIsAcceptingOverlappingGameObjectsDidSetCallback(callback: @escaping UnaryFunction<Bool>) {
        isAcceptingOverlappingGameObjectsCallbacks.append(callback)
    }

    func registerGameObjectDidAddCallback(callback: @escaping UnaryFunction<GameObject>) {
        addGameObjectCallbacks.append(callback)
    }

    func registerGameObjectDidUpdateCallback(callback: @escaping BinaryFunction<GameObject>) {
        updateGameObjectCallbacks.append(callback)
    }

    func registerGameObjectDidRemoveCallback(callback: @escaping UnaryFunction<GameObject>) {
        removeGameObjectCallbacks.append(callback)
    }

    func registerGameObjectDidRemoveAllCallback(callback: @escaping Runnable) {
        removeAllCallbacks.append(callback)
    }

    /// Adds the given `gameObject` into the level and calls the registered callbacks
    /// - Parameter gameObject: GameObject to be added into the level.
    func addGameObject(gameObject: GameObject) {
        addGameObject(gameObject: gameObject, withCallbacks: addGameObjectCallbacks)
    }

    /// Adds the given `gameObject` into the level and call the callbacks passed as a parameter.
    /// - Parameters:
    ///   - gameObject: GameObject to be added into the level.
    ///   - callbacks: Callbacks to be called on the added `gameObject`.
    ///
    /// - Warning: Only calls the callbacks in the parameter and does not call any registered callbacks.
    func addGameObject(gameObject: GameObject, withCallbacks callbacks: [UnaryFunction<GameObject>]) {
        if gameObjects.contains(gameObject) {
            return
        }
        updateConcreteStatus(gameObject: gameObject)

        guard gameObject.isConcrete || isAcceptingOverlappingGameObjects else {
            return
        }

        gameObjects.insert(gameObject)
        neighborFinder.insert(entity: gameObject)
        for callback in callbacks {
            callback(gameObject)
        }
    }

    /// Updates `oldGameObject` in the level with `updatedGameObject` and calls the registered callbacks.
    /// - Parameters:
    ///   - oldGameObject: GameObject to be updated.
    ///   - updatedGameObject: Updated game object.
    func updateGameObject(old oldGameObject: GameObject, with updatedGameObject: GameObject) {
        updateGameObject(old: oldGameObject, with: updatedGameObject, withDidUpdateCallbacks: updateGameObjectCallbacks)
    }

    /// Updates `oldGameObject` in the level with `updatedGameObject` and calls the callbacks passed as a parameter.
    /// - Parameters:
    ///   - oldGameObject: Game object to be updated.
    ///   - updatedGameObject: Updated game object.
    ///   - callbacks: Callbacks to be called any game objects that are updated.
    ///
    /// - Warning: Only calls the callbacks in the parameter and does not call any registered callbacks.
    func updateGameObject(
        old oldGameObject: GameObject,
        with updatedGameObject: GameObject,
        withDidUpdateCallbacks callbacks: [BinaryFunction<GameObject>]
    ) {
        assert(oldGameObject.shape.sides == updatedGameObject.shape.sides)
        assert(oldGameObject !== updatedGameObject)
        assert(gameObjects.contains(oldGameObject))
        let oldNeighbors = findNeighbors(gameObject: oldGameObject)
        gameObjects.remove(oldGameObject)
        neighborFinder.remove(entity: oldGameObject)

        updateConcreteStatus(gameObject: updatedGameObject)

        guard updatedGameObject.isConcrete || isAcceptingOverlappingGameObjects else {
            gameObjects.insert(oldGameObject)
            neighborFinder.insert(entity: oldGameObject)
            return
        }

        gameObjects.insert(updatedGameObject)
        neighborFinder.insert(entity: updatedGameObject)

        if isAcceptingOverlappingGameObjects {
            for neighbor in oldNeighbors where !neighbor.isConcrete {
                updateConcreteStatus(gameObject: neighbor)
                for callback in callbacks {
                    callback(neighbor, neighbor)
                }
            }
        }

        for callback in updateGameObjectCallbacks {
            callback(oldGameObject, updatedGameObject)
        }
    }

    /// Removes `gameObject` from the level and calls registered callbacks on the removed peg.
    ///
    /// - Parameter gameObject: GameObject to be removed.
    func removeGameObject(gameObject: GameObject) {
        removeGameObject(
            gameObject: gameObject,
            withDidRemoveCallbacks: removeGameObjectCallbacks,
            withDidUpdateCallbacks: updateGameObjectCallbacks
        )
    }

    /// Removes `gameObject` from the level and calls registered callbacks on the removed game object as well as
    /// any other game object that is updated.
    ///
    /// - Parameters:
    ///   - gameObject: GameObject to be removed.
    ///   - didRemoveCallbacks: Callbacks to be called on the removed game object.
    ///   - didUpdateCallbacks: Callbacks to be called on any other game object that is updated.
    /// - Warning: Only calls the callbacks in the parameter and does not call any registered callbacks.
    func removeGameObject(
        gameObject: GameObject,
        withDidRemoveCallbacks didRemoveCallbacks: [UnaryFunction<GameObject>],
        withDidUpdateCallbacks didUpdateCallbacks: [BinaryFunction<GameObject>]
    ) {
        assert(gameObjects.contains(gameObject))
        let oldNeighbors = findNeighbors(gameObject: gameObject)
        gameObjects.remove(gameObject)
        neighborFinder.remove(entity: gameObject)
        for callback in didRemoveCallbacks {
            callback(gameObject)
        }
        for neighbor in oldNeighbors where !neighbor.isConcrete {
            updateConcreteStatus(gameObject: neighbor)
            for callback in didUpdateCallbacks {
                callback(neighbor, neighbor)
            }
        }
    }

    /// Removes all game objects from level and calls registered callbacks on the removed objects.
    func removeAllGameObjects() {
        removeAllGameObjects(withDidRemoveCallbacks: removeAllCallbacks)
    }

    /// Removes all game objects from the level and calls callbacks passed in the parameter on the removed objects.
    /// - Parameter callbacks: Callbacks to be called on the removed objects.
    /// - Warning: Only calls the callbacks in the parameter and does not call any registered callbacks.
    func removeAllGameObjects(withDidRemoveCallbacks callbacks: [Runnable]) {
        gameObjects.removeAll()
        neighborFinder.removeAll()
        for callback in callbacks {
            callback()
        }
    }

    /// Returns all game objects that collide with the given `gameObject`.
    private func findNeighbors(gameObject: GameObject) -> [GameObject] {
        let potentialNeighbors = neighborFinder.retrievePotentialNeighbors(for: gameObject)
        var neighbors = [GameObject]()
        for potentialNeighbor in potentialNeighbors {
            if isColliding(gameObject: gameObject, otherGameObject: potentialNeighbor) {
                neighbors.append(potentialNeighbor)
            }
        }
        return neighbors
    }

    private func isColliding(gameObject: GameObject, otherGameObject: GameObject) -> Bool {
        switch (gameObject.shape, otherGameObject.shape) {
        case let (circle as Circle, otherCircle as Circle):
            return collisionDetector.isColliding(
                circle: circle,
                otherCircle: otherCircle
            )
        case let (circle as Circle, polygon as TransformablePolygon),
            let (polygon as TransformablePolygon, circle as Circle):
            return collisionDetector.isColliding(
                circle: circle,
                convexPolygon: polygon
            )
        case let (polygon as TransformablePolygon, otherPolygon as TransformablePolygon):
            return collisionDetector.isColliding(
                convexPolygon: polygon,
                otherConvexPolygon: otherPolygon
            )
        default:
            fatalError(shapeCastingMessage)
        }
    }

    /// Updates whether the game object is concrete depending on
    /// whether it overlaps with any other concrete game object.
    @discardableResult private func updateConcreteStatus(gameObject: GameObject) -> [GameObject] {
        let isContainedInPlayArea = playArea.pegZoneContainsEntity(entity: gameObject)
        let neighbors = findNeighbors(gameObject: gameObject)
        let isOverlappingWithConcreteNeighbor = neighbors.contains(where: { $0.isConcrete })
        gameObject.isConcrete = isContainedInPlayArea && !isOverlappingWithConcreteNeighbor
        return neighbors
    }

    func resizeLevelWithoutUpdatingNeighborFinder(updatedHeight: Double) {
        coordinateMapper.logicalHeight = updatedHeight
        playArea = coordinateMapper.getPlayArea()
    }

    func commitResize() {
        let boundingBox = playArea.pegZoneBoundingBox
        isLoading.send(true)
        DispatchQueue.global().async { [weak self] in
            guard let self = self else {
                return
            }
            globalLogger.info("recalculating game objects")
            self.neighborFinder.resize(with: boundingBox, entities: self.gameObjects)
            DispatchQueue.main.async { [weak self] in
                self?.isLoading.send(false)
                globalLogger.info("recalculating done")
            }
        }
    }
}

// MARK: Defaults
extension DesignerGameLevel {
    static func withDefaultDependencies(coordinateMapper: CoordinateMapper) -> DesignerGameLevel {
        let playArea = coordinateMapper.getPlayArea()
        return DesignerGameLevel(
            coordinateMapper: coordinateMapper,
            emptyContainer: SetObject<GameObject>(),
            neighborFinder: QuadTree<GameObject>(bounds: playArea.pegZoneBoundingBox),
            collisionDetector: Collision()
        )
    }
}

extension DesignerGameLevel {
    /// Returns whether all game objects in the level are concrete.
    func isConsistent() -> Bool {
        gameObjects.allSatisfy { $0.isConcrete }
    }

    /// Removes all non concrete game objects from the level.
    func removeInconsistencies() {
        var gameObjectsToBeRemoved = [GameObject]()
        for gameObject in gameObjects where !gameObject.isConcrete {
            gameObjectsToBeRemoved.append(gameObject)
        }

        for gameObject in gameObjectsToBeRemoved {
            removeGameObject(gameObject: gameObject)
        }
    }

    /// Clears the game.
    func reset() {
        removeAllGameObjects()
    }
}

// MARK: Persistable
extension DesignerGameLevel {
    func toPersistable() -> PersistableDesignerGameLevel {
        guard let levelName = levelName else {
            fatalError("should not be nil")
        }
        var persistablePegs: Set<PersistablePeg> = []
        var persistableObstacles: Set<PersistableObstacle> = []

        for gameObject in gameObjects {
            switch gameObject {
            case let peg as Peg:
                persistablePegs.insert(peg.toPersistable())
            case let obstacle as Obstacle:
                persistableObstacles.insert(obstacle.toPersistable())
            default:
                fatalError("unexpected type")
            }
        }

        return PersistableDesignerGameLevel(
            levelName: levelName,
            pegs: persistablePegs,
            obstacles: persistableObstacles,
            coordinateMapper: coordinateMapper.toPersistable()
        )
    }
}
