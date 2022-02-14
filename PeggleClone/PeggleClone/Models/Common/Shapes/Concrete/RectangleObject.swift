import Foundation
import CoreGraphics

final class RectangleObject: Rectangle, Codable {
    var halfWidth: Double
    var halfHeight: Double
    var center: CGPoint
    var scale: Double = 1
    var rotation: Double = 0

    init(center: CGPoint, halfWidth: Double, halfHeight: Double) {
        self.center = center
        self.halfWidth = halfWidth
        self.halfHeight = halfHeight
    }

    convenience init(center: CGPoint, width: Double, height: Double) {
        self.init(
            center: center,
            halfWidth: width / 2,
            halfHeight: height / 2
        )
    }

    convenience init(instance: RectangleObject) {
        self.init(
            center: instance.center,
            halfWidth: instance.halfWidth,
            halfHeight: instance.halfHeight
        )
    }
 }
