import Foundation
import CoreGraphics

extension Array {
    /// A variant of `init(repeating:count:)`, that fills an array to the given `count` with the result produced
    /// by `repeatingFactory`.
    ///
    /// - Parameters:
    ///   - repeatingFactory: A function producing a certain object of type `Element`.
    ///   - count: The number of times to invoke `repeatingFactory`, so that the array is of size `count`.
    init(repeatingFactory: () -> Element, count: Int) {
        self = []
        for _ in 0..<count {
            self.append(repeatingFactory())
        }
    }
}

extension Array where Element: Equatable {
    mutating func removeAll(_ item: Element) {
        removeAll(where: { $0 == item })
    }
}

extension Array where Element: AnyObject {
    mutating func removeByIdentity(_ item: Element) {
        removeAll(where: { $0 === item })
    }
}

struct PointExtrema {
    let minX: Double
    let maxX: Double
    let minY: Double
    let maxY: Double
}

extension Array where Element == CGPoint {
    /// Returns the minimum and maximum xy values of the points in a non-empty array.
    func getExtrema() -> PointExtrema {
        assert(!isEmpty, "Array cannot be empty")
        var minX = Double.infinity
        var maxX = -Double.infinity
        var minY = Double.infinity
        var maxY = -Double.infinity
        for point in self {
            minX = Swift.min(minX, point.x)
            maxX = Swift.max(maxX, point.x)
            minY = Swift.min(minY, point.y)
            maxY = Swift.max(maxY, point.y)
        }
        return PointExtrema(minX: minX, maxX: maxX, minY: minY, maxY: maxY)
    }
}
