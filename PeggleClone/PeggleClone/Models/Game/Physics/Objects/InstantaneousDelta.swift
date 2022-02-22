import Foundation
import CoreGraphics

class InstantaneousDelta {
    var nextTeleportLocation: CGPoint?
    var force = CGVector.zero
    var impulseIgnoringForce = CGVector.zero
    var torque: Double = 0
    var angularImpulseIgnoringTorque: Double = 0
    var shouldRegisterCollision = false
    var changeToWrapAroundCount: CounterChange = .doNothing
    var shouldDelete = false
}

enum CounterChange {
    case reset
    case increment
    case doNothing
}

extension Int {
    mutating func updateWith(counterChange: CounterChange) {
        switch counterChange {
        case .reset:
            self = 0
        case .increment:
            self += 1
        case .doNothing:
            break
        }
    }
}
