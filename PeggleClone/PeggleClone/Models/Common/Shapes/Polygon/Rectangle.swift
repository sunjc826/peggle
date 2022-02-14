import Foundation
import CoreGraphics

protocol Rectangle: TransformablePolygon, CustomDebugStringConvertible {
    var halfWidth: Double { get }

    var halfHeight: Double { get }

}

extension Rectangle {
    var sides: Int {
        4
    }

    var width: Double { halfWidth * 2 }
    var height: Double { halfHeight * 2 }

    var left: Double {
        center.x - halfWidth
    }

    var right: Double {
        center.x + halfWidth
    }

    var top: Double {
        center.y - halfHeight
    }

    var bottom: Double {
        center.y + halfHeight
    }

    var topLeft: CGPoint {
        center.translate(dx: -halfWidth, dy: -halfHeight)
    }

    var topRight: CGPoint {
        center.translate(dx: halfWidth, dy: -halfHeight)
    }

    var bottomLeft: CGPoint {
        center.translate(dx: -halfWidth, dy: halfHeight)
    }

    var bottomRight: CGPoint {
        center.translate(dx: halfWidth, dy: halfHeight)
    }

    var verticesRelativeToOwnCenterBeforeTransform: [CGPoint] {
        [
            CGPoint(x: -halfWidth, y: -halfHeight),
            CGPoint(x: halfWidth, y: -halfHeight),
            CGPoint(x: halfWidth, y: halfHeight),
            CGPoint(x: -halfWidth, y: halfHeight)
        ]
    }

    var polarVerticesRelativeToOwnCenterBeforeTransform: [PolarCoordinate] {
        verticesRelativeToOwnCenterBeforeTransform.map { $0.toPolar() }
    }
}

// MARK: CustomDebugStringConvertible
extension Rectangle {
    var debugDescription: String {
        """
            dimensions: \(width) * \(height)
            x: \(left) - \(right)
            y: \(top) - \(bottom)

            """
    }
}
