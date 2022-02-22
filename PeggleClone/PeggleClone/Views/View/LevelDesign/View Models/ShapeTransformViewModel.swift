import UIKit
import Combine

class ShapeTransformViewModel {
    var scaleRange: ClosedRange<Float> = Settings.Peg.Designer.scaleRange
    var rotateRange: ClosedRange<Float> = 0...2 * Float.pi

    var scaleMinValue: Float {
        scaleRange.lowerBound
    }

    var scaleMaxValue: Float {
        scaleRange.upperBound
    }

    var rotateMinValue: Float {
        rotateRange.lowerBound
    }

    var rotateMaxValue: Float {
        rotateRange.upperBound
    }

    @Published var scaleValue: Float = 1
    @Published var rotateValue: Float = 0
    @Published var shouldShowRotate = false

    func updateWith(gameObject: EditableGameObject) {
        scaleValue = Float(gameObject.shape.scale)
        rotateValue = Float(gameObject.shape.rotation)
        shouldShowRotate = !(gameObject.shape is Circle)
    }
}
