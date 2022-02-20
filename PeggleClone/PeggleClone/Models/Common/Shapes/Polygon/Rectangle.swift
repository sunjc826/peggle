import Foundation
import CoreGraphics

protocol Rectangle: TransformablePolygon, CustomDebugStringConvertible {
    var halfWidth: Double { get }
    var halfHeight: Double { get }
    var width: Double { get }
    var height: Double { get }
}

extension Rectangle {
    var sides: Int {
        4
    }

    var halfWidth: Double {
        width / 2
    }

    var halfHeight: Double {
        height / 2
    }

    var width: Double { halfWidth * 2 }
    var height: Double { halfHeight * 2 }

    var minX: Double {
        center.x - halfWidth
    }

    var maxX: Double {
        center.x + halfWidth
    }

    var minY: Double {
        center.y - halfHeight
    }

    var maxY: Double {
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
            x: \(minX) - \(maxX)
            y: \(minY) - \(maxY)

            """
    }
}
