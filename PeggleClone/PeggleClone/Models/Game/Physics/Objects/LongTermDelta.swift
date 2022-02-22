import Foundation
import CoreGraphics

class LongTermDelta {
    var linearVelocity: CGVector
    var angularVelocity: Double
    var persistentForces: [ForceObject]

    init(linearVelocity: CGVector = CGVector.zero, angularVelocity: Double = 0, persistentForces: [ForceObject] = []) {
        self.linearVelocity = linearVelocity
        self.angularVelocity = angularVelocity
        self.persistentForces = persistentForces
    }

    convenience init(instance: LongTermDelta) {
        self.init(
            linearVelocity: instance.linearVelocity,
            angularVelocity: instance.angularVelocity,
            persistentForces: instance.persistentForces
        )
    }
}
