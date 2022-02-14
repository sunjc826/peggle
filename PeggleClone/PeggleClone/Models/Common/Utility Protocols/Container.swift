import Foundation

protocol Container: Sequence {
    associatedtype Element
    func contains(_ entity: Element) -> Bool
    func insert(_ entity: Element)
    func makeIterator() -> AnyIterator<Element>
    func remove(_ entity: Element)
    func removeAll()
}

class AnyContainer<Element>: Container {
    private let _contains: (Element) -> Bool
    private let _insert: (Element) -> Void
    private let _makeIterator: () -> AnyIterator<Element>
    private let _remove: (Element) -> Void
    private let _removeAll: () -> Void

    init<T: Container>(container: T) where T.Element == Element {
        self._contains = container.contains
        self._insert = container.insert
        self._makeIterator = container.makeIterator
        self._remove = container.remove
        self._removeAll = container.removeAll
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

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }

    init<T: Container>(encodableContainer: T) where T.Element == Element, T: Encodable {
        self._encode = encodableContainer.encode
        super.init(container: encodableContainer)
    }
}

// A reference-type wrapper around struct Set so that it can be placed in AnyContainer
final class SetObject<Element>: Container where Element: Hashable {
    private var set = Set<Element>()

    init() {}

    init(set: Set<Element>) {
        self.set = set
    }

    func contains(_ entity: Element) -> Bool {
        set.contains(entity)
    }

    func insert(_ entity: Element) {
        set.insert(entity)
    }

    func makeIterator() -> AnyIterator<Element> {
        AnyIterator(set.makeIterator())
    }

    func remove(_ entity: Element) {
        set.remove(entity)
    }

    func removeAll() {
        set.removeAll()
    }
}

extension SetObject: Encodable where Element: Encodable {
    func encode(to encoder: Encoder) throws {
        try set.encode(to: encoder)
    }
}

extension SetObject: Decodable where Element: Decodable {
    convenience init(from decoder: Decoder) throws {
        let set = try Set<Element>(from: decoder)
        self.init(set: set)
    }
}
