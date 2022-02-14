import Foundation
import CoreGraphics

/// Encapsulates a circle, considered to be a degenerate regular polygon.
protocol Circle: RegularShape {}

extension Circle {
    var sides: Int {
        0
    }

    var area: Double {
        Double.pi * pow(radius, 2)
    }

    /// Since a rotating circle is no different from a non rotating circle, the moment of inertia is inconsequential.
    var areaMomentOfInertia: Double {
        1.0
    }

    func contains(point: CGPoint) -> Bool {
        center.distanceTo(point: point) < radius
    }
}

extension Circle {
    var boundingBox: BoundingBox {
        BoundingBox(center: center, width: radius * 2, height: radius * 2)
    }
}

extension Circle {
    func getCircle() -> CircleObject {
        CircleObject(
            center: center,
            radiusBeforeTransform: radiusBeforeTransform,
            scale: scale,
            rotation: rotation
        )
    }
}
