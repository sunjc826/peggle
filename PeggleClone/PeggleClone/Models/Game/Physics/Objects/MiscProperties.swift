import Foundation
import CoreGraphics

class MiscProperties {
    var consecutiveCollisionCount: Int
    var wrapAroundCount: Int
    var wrappedAroundInLastUpdate = false
    var collisionLocationInLastUpdate: CGPoint?

    init(consecutiveCollisionCount: Int = 0, wrapAroundCount: Int = 0) {
        self.consecutiveCollisionCount = consecutiveCollisionCount
        self.wrapAroundCount = wrapAroundCount
    }

    convenience init(instance: MiscProperties) {
        self.init(
            consecutiveCollisionCount: instance.consecutiveCollisionCount,
            wrapAroundCount: instance.wrapAroundCount
        )
    }
}
