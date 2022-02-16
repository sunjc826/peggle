import Foundation
import CoreGraphics

enum LocalizedRadialForceType {
    case replusion
    case attraction
    case explosion // differs from replusion in that affected objects are considered as collided
}

class LocalizedRadialForceEmitter {
    var forceType: LocalizedRadialForceType
    var baseMagnitude: Double // scaled by inverse square distance
    var maximumRadius: Double
    var duration: Double // duration for which force lasts

    init(forceType: LocalizedRadialForceType, baseMagnitude: Double, maximumRadius: Double, duration: Double) {
        self.forceType = forceType
        self.baseMagnitude = baseMagnitude
        self.maximumRadius = maximumRadius
        self.duration = duration
    }

    convenience init(instance: LocalizedRadialForceEmitter) {
        self.init(
            forceType: instance.forceType,
            baseMagnitude: instance.baseMagnitude,
            maximumRadius: instance.maximumRadius,
            duration: instance.duration
        )
    }

    func withDuration(duration: Double) -> LocalizedRadialForceEmitter {
        let copy = LocalizedRadialForceEmitter(instance: self)
        copy.duration = duration
        return copy
    }
}
