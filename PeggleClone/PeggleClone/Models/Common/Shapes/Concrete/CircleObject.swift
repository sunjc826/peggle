import Foundation
import CoreGraphics

final class CircleObject: Circle, Codable {
    static var defaultRadius: Double = 0.05
    var center: CGPoint
    var radiusBeforeTransform: Double
    var scale: Double = 1
    var rotation: Double = 0

    init(center: CGPoint, radiusBeforeTransform: Double, scale: Double = 1, rotation: Double = 0) {
        self.center = center
        self.radiusBeforeTransform = radiusBeforeTransform
        self.scale = scale
        self.rotation = rotation
    }

    convenience init() {
        self.init(
            center: CGPoint.zero,
            radiusBeforeTransform: CircleObject.defaultRadius
        )
    }

    convenience init(instance: CircleObject) {
        self.init(
            center: instance.center,
            radiusBeforeTransform: instance.radiusBeforeTransform,
            scale: instance.scale,
            rotation: instance.rotation
        )
    }
}
