import Foundation
import CoreGraphics

struct TriangleVertices {
    var v1: PolarCoordinate
    var v2: PolarCoordinate
    var v3: PolarCoordinate

    var vertices: [PolarCoordinate] {
        [v1, v2, v3]
    }
}

class TriangleObject: TransformablePolygonObject {
    init(
        center: CGPoint,
        polarVerticesRelativeToOwnCenterBeforeTransform: [PolarCoordinate],
        scale: Double,
        rotation: Double
    ) {
        assert(polarVerticesRelativeToOwnCenterBeforeTransform.count == 3)
        super.init(
            center: center,
            polarVerticesRelativeToOwnCenterBeforeTransform: polarVerticesRelativeToOwnCenterBeforeTransform,
            sides: 3,
            scale: scale,
            rotation: rotation
        )
    }

    convenience init(center: CGPoint) {
        let regularTriangle = RegularPolygonObject(center: center, sides: 3)
        let polarVertices = regularTriangle.polarVerticesRelativeToOwnCenterBeforeTransform
        self.init(
            center: center,
            polarVerticesRelativeToOwnCenterBeforeTransform: polarVertices,
            scale: 1,
            rotation: 0
        )
    }

    convenience init(instance: TriangleObject) {
        self.init(
            center: instance.center,
            polarVerticesRelativeToOwnCenterBeforeTransform: instance.polarVerticesRelativeToOwnCenterBeforeTransform,
            scale: instance.scale,
            rotation: instance.rotation
        )
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        assert(sides == 3)
    }
}
