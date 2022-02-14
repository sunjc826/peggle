import Foundation
import CoreGraphics

// MARK: Conversions
extension CGVector {
    init(from: CGPoint, to: CGPoint) {
        self.init(dx: to.x - from.x, dy: to.y - from.y)
    }

    static func fromPoint(point: CGPoint) -> CGVector {
        CGVector(dx: point.x, dy: point.y)
    }

    /// An alias of fromPoint
    static func getPositionVector(of point: CGPoint) -> CGVector {
        fromPoint(point: point)
    }
}

extension CGVector {
    func restrictX() -> CGVector {
        CGVector(dx: dx, dy: 0)
    }

    func restrictY() -> CGVector {
        CGVector(dx: 0, dy: dy)
    }
}

// MARK: Transformations
extension CGVector {
    func translate(x: Double, y: Double) -> CGVector {
        CGVector(dx: self.dx + x, dy: self.dy + y)
    }

    func translate(offset: CGVector) -> CGVector {
        translate(x: offset.dx, y: offset.dy)
    }

    func add(with otherVector: CGVector) -> CGVector {
        translate(offset: otherVector)
    }

    func translate(uniform: Double) -> CGVector {
        translate(x: uniform, y: uniform)
    }

    func translateX(x: Double) -> CGVector {
        translate(x: x, y: 0)
    }

    func translateY(y: Double) -> CGVector {
        translate(x: 0, y: y)
    }

    func scaleBy(factor: Double) -> CGVector {
        CGVector(dx: dx * factor, dy: dy * factor)
    }

    func scaleTo(length: Double) -> CGVector {
        normalize().scaleBy(factor: length)
    }

    func scale(factorX: Double, factorY: Double) -> CGVector {
        CGVector(dx: dx * factorX, dy: dy * factorY)
    }

    func reverse() -> CGVector {
        scaleBy(factor: -1)
    }

    func normalize() -> CGVector {
        assert(norm > 0, "Cannot normalize the zero vector")
        return CGVector(dx: dx / norm, dy: dy / norm)
    }
}

// MARK: Lengths and distances
extension CGVector {
    var norm: Double {
        hypot(dx, dy)
    }
}

// MARK: More vector operations
extension CGVector {
    func getNormal() -> CGVector {
        CGVector(dx: dy, dy: -dx)
    }

    func getNormalizedNormal() -> CGVector {
        getNormal().normalize()
    }

    static func dotProduct(vector: CGVector, otherVector: CGVector) -> Double {
        vector.dx * otherVector.dx + vector.dy * otherVector.dy
    }

    /// Cross product for vectors projected in a 2D plane.
    static func crossProductSignedMagnitude(vector: CGVector, otherVector: CGVector) -> Double {
        vector.dx * otherVector.dy - otherVector.dx * vector.dy
    }

    func getProjectionOntoSelf(vector: CGVector, isNormalized: Bool = true) -> Double {
        let normalizedVector = isNormalized ? self : self.normalize()
        return CGVector.dotProduct(vector: normalizedVector, otherVector: vector)
    }

}
