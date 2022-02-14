import Foundation
import CoreGraphics

/// Encapsulates a shape that can accept affine transformations restricted to translations, scale and rotation.
/// Translations are to interpreted as the modification of the `center` member field.
protocol TransformableShape: CenteredShape, HasBoundingBox {
    /// Factor by which the shape is scaled to about its center.
    var scale: Double { get set }

    /// Angle (in radians) in which the shape is rotated about its center.
    var rotation: Double { get set }
}
