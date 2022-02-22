import Foundation
import CoreGraphics

/// A composite of multiple game entities, in the form of left, right, receiver.
/// - Remark: While it is in principle possible to have a rigid body with a composite shape in the physics engine,
/// such an implementation requires major refactoring, and is too complicated for just adding bucket functionality.
class Bucket {
    var left: BucketLeftSide
    var right: BucketRightSide
    var receiver: BucketReceiver

    init(position: CGPoint) {
        self.left = BucketLeftSide()
        self.right = BucketRightSide()

        right.shape.center = left.shape.center.translateX(
            x: Settings.Bucket.distanceApart + Settings.Bucket.thickness
        )

        let rectangle = RectangleObject(
            center: CGPoint.middle(point: left.shape.center, otherPoint: right.shape.center),
            width: Settings.Bucket.distanceApart,
            height: Settings.Bucket.height / 2
        )

        receiver = BucketReceiver(shape: rectangle.getTransformablePolygon())
        left.parent = self
        right.parent = self
        receiver.parent = self
        setPosition(position: position)
    }

    func setPositionX(x: Double) {
        let translation = CGVector(dx: x - receiver.shape.center.x, dy: 0)
        left.shape.center = left.shape.center.translate(offset: translation)
        right.shape.center = right.shape.center.translate(offset: translation)
        receiver.shape.center = receiver.shape.center.translate(offset: translation)
    }

    func setPosition(position: CGPoint) {
        let currentPosition: CGPoint = receiver.shape.center
        let translation = CGVector(from: currentPosition, to: position)
        left.shape.center = left.shape.center.translate(offset: translation)
        right.shape.center = right.shape.center.translate(offset: translation)
        receiver.shape.center = receiver.shape.center.translate(offset: translation)
    }

}

class BucketLeftSide: GameObject {
    weak var parent: Bucket?
    init() {
        let rectangle = RectangleObject(
            center: CGPoint.zero,
            width: Settings.Bucket.thickness,
            height: Settings.Bucket.height
        )
        super.init(shape: rectangle.getTransformablePolygon())
    }
}

class BucketRightSide: GameObject {
    weak var parent: Bucket?
    init() {
        let rectangle = RectangleObject(
            center: CGPoint.zero,
            width: Settings.Bucket.thickness,
            height: Settings.Bucket.height
        )
        super.init(shape: rectangle.getTransformablePolygon())
    }
}

/// Catches the ball.
class BucketReceiver: GameObject {
    weak var parent: Bucket?
    init(shape: TransformablePolygonObject) {
        super.init(shape: shape)
    }
}
