import Foundation
import CoreGraphics

final class RegularPolygonObject: RegularPolygon, Codable {
    var center: CGPoint
    var radiusBeforeTransform: Double
    var sides: Int
    var scale: Double = 1
    var rotation: Double = 0

    init(center: CGPoint, radiusBeforeTransform: Double, sides: Int, scale: Double = 1, rotation: Double = 0) {
        self.center = center
        self.radiusBeforeTransform = radiusBeforeTransform
        self.sides = sides
        self.scale = scale
        self.rotation = rotation
    }

    convenience init(center: CGPoint, sides: Int) {
        self.init(
            center: center,
            radiusBeforeTransform: Settings.Peg.RegularPolygonalOrCircular.radius,
            sides: sides
        )
    }

    convenience init(instance: RegularPolygonObject) {
        self.init(
            center: instance.center,
            radiusBeforeTransform: instance.radiusBeforeTransform,
            sides: instance.sides,
            scale: instance.scale,
            rotation: instance.rotation
        )
    }
}
