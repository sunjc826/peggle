import Foundation
import CoreGraphics
import Combine

/// A composite of multiple game entities, in the form of left, right, receiver.
/// - Remark: While it is in principle possible to have a rigid body with a composite shape in the physics engine,
/// such an implementation requires major refactoring, and is too complicated for just adding bucket functionality.
class Bucket {
    var leftSide: BucketLeftSide
    var rightSide: BucketRightSide
    var receiver: BucketReceiver

    @Published var position: CGPoint

    var childComponents: [AbstractBucketComponentObject] {
        [leftSide, rightSide, receiver]
    }

    var boundingBox: BoundingBox {

        BoundingBox(
            topLeft: leftSide.boundingBox.topLeft,
            width: rightSide.boundingBox.maxX - leftSide.boundingBox.minX,
            height: leftSide.boundingBox.maxY - leftSide.boundingBox.minY
        )
    }

    init(position: CGPoint) {
        self.leftSide = BucketLeftSide()
        self.rightSide = BucketRightSide()
        self.position = position

        rightSide.shape.center = leftSide.shape.center.translateX(
            dx: Settings.Bucket.distanceApart + Settings.Bucket.thickness
        )

        let rectangle = RectangleObject(
            center: CGPoint.middle(point: leftSide.shape.center, otherPoint: rightSide.shape.center),
            width: Settings.Bucket.distanceApart,
            height: Settings.Bucket.height / 2
        )

        receiver = BucketReceiver(shape: rectangle.getTransformablePolygon())
        leftSide.parent = self
        rightSide.parent = self
        receiver.parent = self
        setPosition(position: position)

    }

    func setPosition(position: CGPoint) {
        let currentPosition: CGPoint = receiver.shape.center
        let translation = CGVector(from: currentPosition, to: position)
        leftSide.shape.center = leftSide.shape.center.translate(offset: translation)
        rightSide.shape.center = rightSide.shape.center.translate(offset: translation)
        receiver.shape.center = receiver.shape.center.translate(offset: translation)
    }

}
