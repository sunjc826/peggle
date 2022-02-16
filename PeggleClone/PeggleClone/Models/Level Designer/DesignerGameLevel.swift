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
    private var isAcceptingOverlappingPegsCallbacks = [UnaryFunction<Bool>]()
    private var addPegCallbacks = [UnaryFunction<Peg>]()
    private var updatePegCallbacks = [BinaryFunction<Peg>]()
    private var removePegCallbacks = [UnaryFunction<Peg>]()
    private var removeAllCallbacks = [Runnable]()

    var isAcceptingOverlappingPegs = false {
        didSet {
            for callback in isAcceptingOverlappingPegsCallbacks {
                callback(isAcceptingOverlappingPegs)
            }
        }
    }

    @Published var levelName: String? = "Default level name"
    let coordinateMapper: CoordinateMapper
    let playArea: PlayArea
    private var pegs: AnyContainer<Peg>
    private let neighborFinder: AnyNeighborFinder<Peg>
    private let collisionDetector: CollisionDetector

    init<T, S>(
        coordinateMapper: CoordinateMapper,
        container: T,
        neighborFinder: S,
        collisionDetector: CollisionDetector
    )
    where T: Container, T.Element == Peg, S: NeighborFinder, S.Element == Peg {
        self.coordinateMapper = coordinateMapper
        self.playArea = coordinateMapper.getPlayArea()
        self.pegs = AnyContainer(container: container)
        self.neighborFinder = AnyNeighborFinder(neighborFinder: neighborFinder)
        self.collisionDetector = collisionDetector
    }

    /// Updates self with the contents of the incoming level.
    func hydrate(with incomingLevel: PersistableDesignerGameLevel) throws {
        let incomingPlayArea = PlayArea.fromPersistable(persistableArea: incomingLevel.playArea)
        if incomingPlayArea != playArea {
            throw HydrationIncompatibleError()
        }
        levelName = incomingLevel.levelName
        for persistablePeg in incomingLevel.pegs {
            let peg = Peg.fromPersistable(persistablePeg: persistablePeg)
            addPeg(peg: peg)
        }
    }

    func registerOnLevelNameDidSetCallback(callback: @escaping UnaryFunction<String>) {
        setLevelNameCallbacks.append(callback)
    }

    func registerIsAcceptingOverlappingPegsDidSetCallback(callback: @escaping UnaryFunction<Bool>) {
        isAcceptingOverlappingPegsCallbacks.append(callback)
    }

    func registerPegDidAddCallback(callback: @escaping UnaryFunction<Peg>) {
        addPegCallbacks.append(callback)
    }

    func registerPegDidUpdateCallback(callback: @escaping BinaryFunction<Peg>) {
        updatePegCallbacks.append(callback)
    }

    func registerPegDidRemoveCallback(callback: @escaping UnaryFunction<Peg>) {
        removePegCallbacks.append(callback)
    }

    func registerPegDidRemoveAllCallback(callback: @escaping Runnable) {
        removeAllCallbacks.append(callback)
    }

    /// Adds the given `peg` into the level and calls the registered callbacks
    /// - Parameter peg: Peg to be added into the level.
    func addPeg(peg: Peg) {
        addPeg(peg: peg, withCallbacks: addPegCallbacks)
    }

    /// Adds the given `peg` into the level and call the callbacks passed as a parameter.
    /// - Parameters:
    ///   - peg: Peg to be added into the level.
    ///   - callbacks: Callbacks to be called on the added peg.
    ///
    /// - Warning: Only calls the callbacks in the parameter and does not call any registered callbacks.
    func addPeg(peg: Peg, withCallbacks callbacks: [UnaryFunction<Peg>]) {
        if pegs.contains(peg) {
            return
        }
        updateConcreteStatus(peg: peg)

        guard peg.isConcrete || isAcceptingOverlappingPegs else {
            return
        }

        pegs.insert(peg)
        neighborFinder.insert(entity: peg)
        for callback in callbacks {
            callback(peg)
        }
    }

    /// Updates `oldPeg` in the level with `updatedPeg` and calls the registered callbacks.
    /// - Parameters:
    ///   - oldPeg: Peg to be updated.
    ///   - updatedPeg: Updated peg.
    func updatePeg(old oldPeg: Peg, with updatedPeg: Peg) {
        updatePeg(old: oldPeg, with: updatedPeg, withDidUpdateCallbacks: updatePegCallbacks)
    }

    /// Updates `oldPeg` in the level with `updatedPeg` and calls the callbacks passed as a parameter.
    /// - Parameters:
    ///   - oldPeg: Peg to be updated.
    ///   - updatedPeg: Updated peg.
    ///   - callbacks: Callbacks to be called any pegs that are updated.
    ///
    /// - Warning: Only calls the callbacks in the parameter and does not call any registered callbacks.
    func updatePeg(old oldPeg: Peg,
                   with updatedPeg: Peg,
                   withDidUpdateCallbacks callbacks: [BinaryFunction<Peg>]
    ) {
        assert(oldPeg.shape.sides == updatedPeg.shape.sides)
        assert(oldPeg !== updatedPeg)
        assert(pegs.contains(oldPeg))
        let oldNeighbors = findNeighbors(peg: oldPeg)
        pegs.remove(oldPeg)
        neighborFinder.remove(entity: oldPeg)

        updateConcreteStatus(peg: updatedPeg)

        guard updatedPeg.isConcrete || isAcceptingOverlappingPegs else {
            pegs.insert(oldPeg)
            neighborFinder.insert(entity: oldPeg)
            return
        }

        pegs.insert(updatedPeg)
        neighborFinder.insert(entity: updatedPeg)

        if isAcceptingOverlappingPegs {
            for neighbor in oldNeighbors where !neighbor.isConcrete {
                updateConcreteStatus(peg: neighbor)
                for callback in callbacks {
                    callback(neighbor, neighbor)
                }
            }
        }

        for callback in updatePegCallbacks {
            callback(oldPeg, updatedPeg)
        }
    }

    /// Removes `peg` from the level and calls registered callbacks on the removed peg.
    ///
    /// - Parameter peg: Peg to be removed.
    func removePeg(peg: Peg) {
        removePeg(peg: peg, withDidRemoveCallbacks: removePegCallbacks, withDidUpdateCallbacks: updatePegCallbacks)
    }

    /// Removes `peg` from the level and calls registered callbacks on the removed peg as well as
    /// any other peg that is updated.
    ///
    /// - Parameters:
    ///   - peg: Peg to be removed.
    ///   - didRemoveCallbacks: Callbacks to be called on the removed peg.
    ///   - didUpdateCallbacks: Callbacks to be called on any other peg that is updated.
    /// - Warning: Only calls the callbacks in the parameter and does not call any registered callbacks.
    func removePeg(peg: Peg,
                   withDidRemoveCallbacks didRemoveCallbacks: [UnaryFunction<Peg>],
                   withDidUpdateCallbacks didUpdateCallbacks: [BinaryFunction<Peg>]) {
        assert(pegs.contains(peg))
        let oldNeighbors = findNeighbors(peg: peg)
        pegs.remove(peg)
        neighborFinder.remove(entity: peg)
        for callback in didRemoveCallbacks {
            callback(peg)
        }
        for neighbor in oldNeighbors where !neighbor.isConcrete {
            updateConcreteStatus(peg: neighbor)
            for callback in didUpdateCallbacks {
                callback(neighbor, neighbor)
            }
        }
    }

    /// Removes all pegs from level and calls registered callbacks on the removed objects.
    func removeAllPegs() {
        removeAllPegs(withDidRemoveCallbacks: removeAllCallbacks)
    }

    /// Removes all pegs from the level and calls callbacks passed in the parameter on the removed objects.
    /// - Parameter callbacks: Callbacks to be called on the removed objects.
    /// - Warning: Only calls the callbacks in the parameter and does not call any registered callbacks.
    func removeAllPegs(withDidRemoveCallbacks callbacks: [Runnable]) {
        pegs.removeAll()
        neighborFinder.removeAll()
        for callback in callbacks {
            callback()
        }
    }

    /// Returns all pegs that collide with the given `peg`.
    private func findNeighbors(peg: Peg) -> [Peg] {
        let potentialNeighbors = neighborFinder.retrievePotentialNeighbors(for: peg)
        var neighbors = [Peg]()
        for potentialNeighbor in potentialNeighbors {
            if isColliding(peg: peg, otherPeg: potentialNeighbor) {
                neighbors.append(potentialNeighbor)
            }
        }
        logger.info("Colliding with \(neighbors.count) neighbors")
        return neighbors
    }

    private func isColliding(peg: Peg, otherPeg: Peg) -> Bool {
        switch (peg.shape, otherPeg.shape) {
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

    /// Updates whether the peg is concrete depending on whether it overlaps with any other concrete peg.
    @discardableResult private func updateConcreteStatus(peg: Peg) -> [Peg] {
        let isContainedInPlayArea = playArea.pegZoneContainsEntity(entity: peg)
        let neighbors = findNeighbors(peg: peg)
        let isOverlappingWithConcreteNeighbor = neighbors.contains(where: { $0.isConcrete })
        peg.isConcrete = isContainedInPlayArea && !isOverlappingWithConcreteNeighbor
        return neighbors
    }
}

// MARK: Defaults
extension DesignerGameLevel {
    static func withDefaultDependencies(coordinateMapper: CoordinateMapper) -> DesignerGameLevel {
        let playArea = coordinateMapper.getPlayArea()
        return DesignerGameLevel(
            coordinateMapper: coordinateMapper,
            container: SetObject<Peg>(),
            neighborFinder: QuadTree<Peg>(bounds: playArea.pegZoneBoundingBox),
            collisionDetector: Collision()
        )
    }
}

extension DesignerGameLevel {
    /// Returns whether all pegs in the level are concrete.
    func isConsistent() -> Bool {
        pegs.allSatisfy { $0.isConcrete }
    }

    /// Removes all non concrete pegs from the level.
    func removeInconsistencies() {
        var pegsToBeRemoved = [Peg]()
        for peg in pegs where !peg.isConcrete {
            pegsToBeRemoved.append(peg)
        }

        for peg in pegsToBeRemoved {
            removePeg(peg: peg)
        }
    }

    /// Clears the game.
    func reset() {
        removeAllPegs()
    }
}

// MARK: Persistable
extension DesignerGameLevel {
    func toPersistable() -> PersistableDesignerGameLevel {
        guard let levelName = levelName else {
            fatalError("should not be nil")
        }
        var persistablePegs: Set<PersistablePeg> = []
        for peg in pegs {
            persistablePegs.insert(peg.toPersistable())
        }
        return PersistableDesignerGameLevel(
            levelName: levelName,
            pegs: persistablePegs,
            playArea: playArea.toPersistable()
        )
    }
}
