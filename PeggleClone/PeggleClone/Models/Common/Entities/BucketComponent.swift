import Foundation
import CoreGraphics

protocol BucketComponent: AnyObject {
    var parent: Bucket? { get set }
}

class AbstractBucketComponentObject: GameObject, BucketComponent {
    weak var parent: Bucket?
}

class BucketLeftSide: AbstractBucketComponentObject {
    init() {
        let rectangle = RectangleObject(
            center: CGPoint.zero,
            width: Settings.Bucket.thickness,
            height: Settings.Bucket.height
        )
        super.init(shape: rectangle.getTransformablePolygon())
    }
}

class BucketRightSide: AbstractBucketComponentObject {
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
class BucketReceiver: AbstractBucketComponentObject {
    init(shape: TransformablePolygonObject) {
        super.init(shape: shape)
    }
}
