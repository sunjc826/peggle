import Foundation
import CoreGraphics

/// The polar counterpart of the cartesian coordinate struct CGPoint.
struct PolarCoordinate: Codable {
    var radius: Double
    var theta: Double
    init (radius: Double, theta: Double) {
        assert(radius >= 0)
        self.radius = radius
        self.theta = theta
    }
}

// MARK: Conversions
extension PolarCoordinate {
    func toCartesian() -> CGPoint {
        CGPoint(x: radius * cos(theta), y: radius * sin(theta))
    }
}

// MARK: Transformations
extension PolarCoordinate {
    /// Returns a polar coordinate scaled by the given factor.
    func scaleBy(factor: Double) -> PolarCoordinate {
        assert(factor >= 0)
        return PolarCoordinate(radius: radius * factor, theta: theta)
    }

    /// Returns a polar coordinates scaled to the given`factor` such that its length equals the given factor.
    func scaleTo(factor: Double) -> PolarCoordinate {
        assert(factor >= 0)
        return PolarCoordinate(radius: factor, theta: theta)
    }

    /// Returns a polar coordinate rotated by the given `angle` in radians.
    func rotate(angle: Double) -> PolarCoordinate {
        let newTheta = (theta + angle).generalizedMod(within: 2 * Double.pi)
        return PolarCoordinate(radius: radius, theta: newTheta)
    }
}

extension PolarCoordinate: Equatable {}
