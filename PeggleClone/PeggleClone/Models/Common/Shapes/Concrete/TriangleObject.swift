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
    convenience init(center: CGPoint) {
        let regularTriangle = RegularPolygonObject(center: center, sides: 3)
        let polarVertices = regularTriangle.polarVerticesRelativeToOwnCenterBeforeTransform
        self.init(
            center: center,
            polarVerticesRelativeToOwnCenterBeforeTransform: TriangleVertices(
                v1: polarVertices[0],
                v2: polarVertices[1],
                v3: polarVertices[2]
            ),
            scale: 1,
            rotation: 0
        )
    }
    
    init(
        center: CGPoint,
        polarVerticesRelativeToOwnCenterBeforeTransform: TriangleVertices,
        scale: Double,
        rotation: Double
    ) {
        super.init(
            center: center,
            polarVerticesRelativeToOwnCenterBeforeTransform: polarVerticesRelativeToOwnCenterBeforeTransform.vertices,
            sides: 3,
            scale: scale,
            rotation: rotation
        )
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        assert(sides == 3)
    }
}
