import Foundation
import CoreGraphics

/// Encapsulates an equiangular and equilateral shape. A circle is considered a degenerate regular shape.
protocol RegularShape: TransformableShape {
    var center: CGPoint { get set }
    var radiusBeforeTransform: Double { get set }
}

extension RegularShape {
    /// The distance between a vertex of the shape and its center.
    /// Also acts as the radius of a circle in the degenerate case.
    var radius: Double {
        radiusBeforeTransform * scale
    }
}
