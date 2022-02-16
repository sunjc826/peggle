import Foundation
import CoreGraphics

enum GlobalAccelerationType {
    case gravity
    case wind
    case drag
}

class GlobalAcceleration {
    var accelerationType: GlobalAccelerationType
    var accelerationValue: CGVector

    init(accelerationType: GlobalAccelerationType, accelerationValue: CGVector) {
        self.accelerationType = accelerationType
        self.accelerationValue = accelerationValue
    }
}
