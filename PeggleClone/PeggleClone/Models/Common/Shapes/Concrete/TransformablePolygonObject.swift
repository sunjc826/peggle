import Foundation
import CoreGraphics

final class TransformablePolygonObject: TransformablePolygon, Codable {
    var scale: Double

    var rotation: Double

    var polarVerticesRelativeToOwnCenterBeforeTransform: [PolarCoordinate]

    var center: CGPoint

    var sides: Int

    init(
        center: CGPoint,
        polarVerticesRelativeToOwnCenterBeforeTransform: [PolarCoordinate],
        sides: Int,
        scale: Double,
        rotation: Double
    ) {
        self.scale = scale
        self.rotation = rotation
        self.polarVerticesRelativeToOwnCenterBeforeTransform = polarVerticesRelativeToOwnCenterBeforeTransform
        self.center = center
        self.sides = sides
    }

    convenience init(instance: TransformablePolygonObject) {
        self.init(
            center: instance.center,
            polarVerticesRelativeToOwnCenterBeforeTransform: instance.polarVerticesRelativeToOwnCenterBeforeTransform,
            sides: instance.sides,
            scale: instance.scale,
            rotation: instance.rotation
        )
    }
}
