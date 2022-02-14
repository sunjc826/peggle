import Foundation
import CoreGraphics

/// Encapsulates a shape centered at a certain point.
protocol CenteredShape: Shape {
    /// Center of mass of shape
    var center: CGPoint { get set }
}
