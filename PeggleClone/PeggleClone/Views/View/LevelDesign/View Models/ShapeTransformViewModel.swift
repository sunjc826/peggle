import UIKit
import Combine

class ShapeTransformViewModel {
    var scaleRange: ClosedRange<Float> = 0.1...3.0
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

    func updateWith(peg: Peg) {
        scaleValue = Float(peg.shape.scale)
        rotateValue = Float(peg.shape.rotation)
        shouldShowRotate = !(peg.shape is Circle)
    }
}
