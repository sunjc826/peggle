import Foundation
import CoreGraphics

protocol RegularPolygon: RegularShape, TransformablePolygon {}

extension RegularPolygon {
    var polarVerticesRelativeToOwnCenterBeforeTransform: [PolarCoordinate] {
        var polarVertexArr = [PolarCoordinate]()
        for i in 0..<sides {
            let angle = 2 * Double.pi * Double(i) / Double(sides)
            polarVertexArr.append(PolarCoordinate(radius: radiusBeforeTransform, theta: angle))
        }
        return polarVertexArr
    }
}
