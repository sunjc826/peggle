import Foundation

protocol NeighborFinder {
    associatedtype Element where Element: Equatable, Element: HasBoundingBox, Element: AnyObject

    func insert(entity: Element)

    /// Finds all potential entities that may possibly overlap with the given `entity`.
    func retrievePotentialNeighbors(for entity: Element) -> AnySequence<Element>

    func retrievePotentialNeighbors(givenBoundingBox boundingBox: BoundingBox) -> AnySequence<Element>

    func remove(entity: Element)

    func removeAll()
}

// type erased class
final class AnyNeighborFinder<Element>: NeighborFinder
where Element: Equatable, Element: HasBoundingBox, Element: AnyObject {
    private let _insert: (Element) -> Void
    private let _retrievePotentialNeighbors: (Element) -> AnySequence<Element>
    private let _retrievePotentialNeighborsBB: (BoundingBox) -> AnySequence<Element>
    private let _remove: (Element) -> Void
    private let _removeAll: () -> Void

    init<T: NeighborFinder>(neighborFinder: T) where T.Element == Element {
        self._insert = neighborFinder.insert
        self._retrievePotentialNeighbors = neighborFinder.retrievePotentialNeighbors(for:)
        self._retrievePotentialNeighborsBB = neighborFinder.retrievePotentialNeighbors(givenBoundingBox:)
        self._remove = neighborFinder.remove
        self._removeAll = neighborFinder.removeAll
    }

    func insert(entity: Element) {
        _insert(entity)
    }

    func retrievePotentialNeighbors(for entity: Element) -> AnySequence<Element> {
        _retrievePotentialNeighbors(entity)
    }

    func retrievePotentialNeighbors(givenBoundingBox boundingBox: BoundingBox) -> AnySequence<Element> {
        _retrievePotentialNeighborsBB(boundingBox)
    }

    func remove(entity: Element) {
        _remove(entity)
    }

    func removeAll() {
        _removeAll()
    }
}
