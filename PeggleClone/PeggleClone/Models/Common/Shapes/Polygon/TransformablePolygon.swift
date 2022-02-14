import Foundation
import CoreGraphics

protocol TransformablePolygon: CenteredPolygon, TransformableShape {
    var polarVerticesRelativeToOwnCenterBeforeTransform: [PolarCoordinate] { get }
}

extension TransformablePolygon {
    var polarVerticesRelativeToOwnCenter: [PolarCoordinate] {
        polarVerticesRelativeToOwnCenterBeforeTransform.map { polarVertex in
            polarVertex.scaleBy(factor: scale).rotate(angle: rotation)
        }
    }

    var verticesRelativeToOwnCenter: [CGPoint] {
        polarVerticesRelativeToOwnCenter.map { polarVertex in
            polarVertex.toCartesian()
        }
    }

    var vertices: [CGPoint] {
        verticesRelativeToOwnCenter.map { vertex in
            vertex.translate(offset: CGVector.getPositionVector(of: center))
        }
    }
}

extension TransformablePolygon {
    func getTransformablePolygon() -> TransformablePolygonObject {
        TransformablePolygonObject(
            center: center,
            polarVerticesRelativeToOwnCenterBeforeTransform: polarVerticesRelativeToOwnCenterBeforeTransform,
            sides: sides,
            scale: scale,
            rotation: rotation
        )
    }
}
