import Foundation
import CoreGraphics

protocol HasBoundingBox {
    var boundingBox: BoundingBox { get }
}

/// Encapsulates the rectangular axis-aligned bounding box (AABB) of a shape.
class BoundingBox: Rectangle {
    var halfWidth: Double
    var halfHeight: Double

    /// The horizontal distance between the center and left extreme.
    var leftWidth: Double {
        centerOfMassOfUnderlyingObject.x - left
    }

    /// The horizontal distance between the center and the right extreme.
    var rightWidth: Double {
        right - centerOfMassOfUnderlyingObject.x
    }

    /// The vertical distance between the center and the top extreme.
    var topHeight: Double {
        centerOfMassOfUnderlyingObject.y - top
    }

    /// The vertical distance between the center and the bottom extreme.
    var bottomHeight: Double {
        bottom - centerOfMassOfUnderlyingObject.y
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

    convenience init(centerOfMassOfUnderlyingObject: CGPoint,
                     leftWidth: Double,
                     rightWidth: Double,
                     topHeight: Double,
                     bottomHeight: Double) {
        // TODO: Reshaping triangle can break orientation
        assert(leftWidth >= 0 && rightWidth >= 0 && topHeight >= 0 && bottomHeight >= 0)
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
        left <= point.x && point.x <= right && top <= point.y && point.y <= bottom
    }

    func contains(boundingBox: BoundingBox) -> Bool {
        left <= boundingBox.left && boundingBox.right <= right && top <= boundingBox.top && boundingBox.bottom <= bottom
    }

    func containsStrictly(point: CGPoint) -> Bool {
        left < point.x && point.x < right && top < point.y && point.y < bottom
    }

    func containsStrictly(boundingBox: BoundingBox) -> Bool {
        left < boundingBox.left && boundingBox.right < right && top < boundingBox.top && boundingBox.bottom < bottom
    }
}
