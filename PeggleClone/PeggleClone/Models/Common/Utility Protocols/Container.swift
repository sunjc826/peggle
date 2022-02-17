import Foundation

protocol Container: Sequence {
    associatedtype Element
    var count: Int { get }
    func contains(_ entity: Element) -> Bool
    func insert(_ entity: Element)
    func makeIterator() -> AnyIterator<Element>
    func remove(_ entity: Element)
    func removeAll()
}

extension Container {
    // Note: This aims to emulate the `isEmpty` property of an inbuilt swift collection
    var isEmpty: Bool {
        // swiftlint:disable empty_count
        count == 0
        // swiftlint:enable empty_count
    }
}

class AnyContainer<Element>: Container {
    private let _contains: (Element) -> Bool
    private let _insert: (Element) -> Void
    private let _makeIterator: () -> AnyIterator<Element>
    private let _remove: (Element) -> Void
    private let _removeAll: () -> Void
    private let _getCount: () -> Int

    var count: Int {
        _getCount()
    }

    init<T: Container>(container: T) where T.Element == Element {
        self._contains = container.contains
        self._insert = container.insert
        self._makeIterator = container.makeIterator
        self._remove = container.remove
        self._removeAll = container.removeAll
        self._getCount = { [container] in
            container.count
        }
    }

    func contains(_ entity: Element) -> Bool {
        _contains(entity)
    }

    func insert(_ entity: Element) {
        _insert(entity)
    }

    func makeIterator() -> AnyIterator<Element> {
        _makeIterator()
    }

    func remove(_ entity: Element) {
        _remove(entity)
    }

    func removeAll() {
        _removeAll()
    }
}

class AnyEncodableContainer<Element>: AnyContainer<Element>, Encodable {
    private let _encode: ((Encoder) throws -> Void)

    init<T: Container>(encodableContainer: T) where T.Element == Element, T: Encodable {
        self._encode = encodableContainer.encode
        super.init(container: encodableContainer)
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

// A reference-type wrapper around struct Set so that it can be placed in AnyContainer
final class SetObject<Element>: Container where Element: Hashable {
    private var backingSet = Set<Element>()

    var count: Int {
        backingSet.count
    }

    init() {}

    init(set: Set<Element>) {
        self.backingSet = set
    }

    func contains(_ entity: Element) -> Bool {
        backingSet.contains(entity)
    }

    func insert(_ entity: Element) {
        backingSet.insert(entity)
    }

    func makeIterator() -> AnyIterator<Element> {
        AnyIterator(backingSet.makeIterator())
    }

    func remove(_ entity: Element) {
        backingSet.remove(entity)
    }

    func removeAll() {
        backingSet.removeAll()
    }
}

extension SetObject: Encodable where Element: Encodable {
    func encode(to encoder: Encoder) throws {
        try backingSet.encode(to: encoder)
    }
}

extension SetObject: Decodable where Element: Decodable {
    convenience init(from decoder: Decoder) throws {
        let set = try Set<Element>(from: decoder)
        self.init(set: set)
    }
}
