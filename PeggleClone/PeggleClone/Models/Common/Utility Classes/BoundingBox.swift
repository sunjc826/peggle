import Foundation
import CoreGraphics

protocol HasBoundingBox {
    var boundingBox: BoundingBox { get }
}

/// Encapsulates the rectangular axis-aligned bounding box (AABB) of a shape.
class BoundingBox: Rectangle {
    var halfWidth: Double
    var halfHeight: Double

    /// The horizontal distance between the center of mass of underlying object and left extreme.
    var leftWidth: Double {
        centerOfMassOfUnderlyingObject.x - minX
    }

    /// The horizontal distance between the center of mass of underlying object and the right extreme.
    var rightWidth: Double {
        maxX - centerOfMassOfUnderlyingObject.x
    }

    /// The vertical distance between the center of mass of underlying object and the top extreme.
    var topHeight: Double {
        centerOfMassOfUnderlyingObject.y - minY
    }

    /// The vertical distance between the center of mass of underlying object and the bottom extreme.
    var bottomHeight: Double {
        maxY - centerOfMassOfUnderlyingObject.y
    }

    /// Center of mass of bounding box
    var center: CGPoint

    /// Center of mass of the underlying object the bounding box belongs to
    var centerOfMassOfUnderlyingObject: CGPoint

    /// The factor to which the bounding box is scaled.
    var scale: Double {
        get {
            1
        }

        set {
            assertionFailure("Tried to set \(newValue). Operation not relevant to bounding box.")
        }
    }

    /// The angle to which the bounding box is rotated.
    var rotation: Double {
        get {
            0
        }
        set {
            assertionFailure("Tried to set \(newValue). Operation not allowed as bounding box is axis-aligned.")
        }
    }

    init(center: CGPoint, centerOfMassOfUnderlyingObject: CGPoint, width: Double, height: Double) {
        self.center = center
        self.centerOfMassOfUnderlyingObject = centerOfMassOfUnderlyingObject
        self.halfWidth = width / 2
        self.halfHeight = height / 2
    }

    // Remark: In the case of a resizable triangle (i.e. obstacle), centerOfMassOfUnderlyingObject
    // may not correspond with the centroid.
    convenience init(centerOfMassOfUnderlyingObject: CGPoint,
                     leftWidth: Double,
                     rightWidth: Double,
                     topHeight: Double,
                     bottomHeight: Double) {
        let width = leftWidth + rightWidth
        let height = topHeight + bottomHeight
        let centerX = centerOfMassOfUnderlyingObject.x - leftWidth + width / 2
        let centerY = centerOfMassOfUnderlyingObject.y - topHeight + height / 2
        self.init(
            center: CGPoint(x: centerX, y: centerY),
            centerOfMassOfUnderlyingObject: centerOfMassOfUnderlyingObject,
            width: width,
            height: height
        )
    }

    convenience init(center: CGPoint, width: Double, height: Double) {
        self.init(
            center: center,
            centerOfMassOfUnderlyingObject: center,
            width: width,
            height: height
        )
    }

    convenience init(topLeft: CGPoint, width: Double, height: Double) {
        let center = topLeft.translate(offset: CGVector(dx: width / 2, dy: height / 2))
        self.init(center: center, width: width, height: height)
    }

    func contains(point: CGPoint) -> Bool {
        minX <= point.x && point.x <= maxX && minY <= point.y && point.y <= maxY
    }

    func contains(boundingBox: BoundingBox) -> Bool {
        minX <= boundingBox.minX && boundingBox.maxX <= maxX && minY <= boundingBox.minY && boundingBox.maxY <= maxY
    }

    func containsStrictly(point: CGPoint) -> Bool {
        minX < point.x && point.x < maxX && minY < point.y && point.y < maxY
    }

    func containsStrictly(boundingBox: BoundingBox) -> Bool {
        minX < boundingBox.minX && boundingBox.maxX < maxX && minY < boundingBox.minY && boundingBox.maxY < maxY
    }
}

extension BoundingBox {
    static func isOrientationValid(vertices: [CGPoint]) -> Bool {
        let v1 = vertices[0]
        let v2 = vertices[1]
        let v3 = vertices[2]
        return (v2.x - v1.x) * (v3.y - v1.y) - (v3.x - v1.x) * (v2.y - v1.y) > 0
    }
}
