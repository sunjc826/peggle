import Foundation
import CoreGraphics

// MARK: Conversions
extension CGPoint {
    /// Converts  a `CGVector` to a `CGPoint` with the same x and y components.
    /// - Parameter vector: Vector to be converted.
    /// - Returns: Point with the same x and y components.
    static func fromVector(vector: CGVector) -> CGPoint {
        CGPoint(x: vector.dx, y: vector.dy)
    }

    /// Converts cartesian coordinates to polar coordinates.
    /// - Returns: Equivalent polar coordinates.
    /// - Warning: Be wary of the case where x and y are both 0.
    func toPolar() -> PolarCoordinate {
        PolarCoordinate(radius: norm, theta: atan2(y, x))
    }
}

// MARK: Transformations
extension CGPoint {
    /// Returns a translated point by the given `x` and `y` offsets.
    func translate(dx: Double, dy: Double) -> CGPoint {
        CGPoint(x: self.x + dx, y: self.y + dy)
    }

    /// Returns a translated point by the given vector offset.
    func translate(offset: CGVector) -> CGPoint {
        translate(dx: offset.dx, dy: offset.dy)
    }

    /// Returns a translated point translated by the same amount in both x and y coordinates by `uniform`.
    func translate(uniform: Double) -> CGPoint {
        translate(dx: uniform, dy: uniform)
    }

    /// Returns a translated point translated by the given amount in the x coordinate.
    func translateX(x: Double) -> CGPoint {
        translate(dx: x, dy: 0)
    }

    /// Returns a translated point translated by the given amount in the y coordinate.
    func translateY(y: Double) -> CGPoint {
        translate(dx: 0, dy: y)
    }

    /// Returns a scaled point scaled by the given `factor` equally in both x and y coordinates about the origin.
    func scaleAboutOrigin(factor: Double) -> CGPoint {
        CGPoint(x: x * factor, y: y * factor)
    }

    /// Returns a scaled point scaled in the x coordinate by `factorX` and in the y coordinate by `factorY`.
    func scaleAboutOrigin(factorX: Double, factorY: Double) -> CGPoint {
        CGPoint(x: x * factorX, y: y * factorY)
    }
}

// MARK: Lengths and distances
extension CGPoint {
    /// Returns the distance of `self` from the origin, equivalently the length of `self`
    /// when viewed as a position vector.
    var norm: Double {
        hypot(x, y)
    }

    /// Calculates the Euclidean distance between the point `self` and the point (`x`,`y`).
    func distanceTo(x: Double, y: Double) -> Double {
        hypot(self.x - x, self.y - y)
    }

    /// Calculates the Euclidean distance between the point `self` and the given `point`.
    func distanceTo(point: CGPoint) -> Double {
        distanceTo(x: point.x, y: point.y)
    }
}

extension CGPoint {
    static func middle(point: CGPoint, otherPoint: CGPoint) -> CGPoint {
        CGPoint(x: point.x + otherPoint.x, y: point.y + otherPoint.y)
    }
}

// MARK: Hashable
extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}
