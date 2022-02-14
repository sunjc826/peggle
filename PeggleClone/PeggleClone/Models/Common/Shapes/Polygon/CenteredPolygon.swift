import Foundation
import CoreGraphics

protocol CenteredPolygon: Polygon, CenteredShape {
    var verticesRelativeToOwnCenter: [CGPoint] { get }
    var polarVerticesRelativeToOwnCenter: [PolarCoordinate] { get }
}

extension CenteredPolygon {
    var verticesRelativeToOwnCenter: [CGPoint] {
        polarVerticesRelativeToOwnCenter.map { $0.toCartesian() }
    }

    var vertices: [CGPoint] {
        verticesRelativeToOwnCenter.map {
            $0.translate(offset: CGVector.getPositionVector(of: center))
        }
    }
}

extension CenteredPolygon {
    var boundingBox: BoundingBox {
        let extrema = verticesRelativeToOwnCenter.getExtrema()
        return BoundingBox(centerOfMassOfUnderlyingObject: center,
                           leftWidth: abs(extrema.minX),
                           rightWidth: extrema.maxX,
                           topHeight: abs(extrema.minY),
                           bottomHeight: extrema.maxY
        )
    }
}
