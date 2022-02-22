import Foundation
import CoreGraphics
class PhysicsEngineReports {
    var teleports: [TeleportObject] = []
    var forces: [ForceObject] = []
    var impulses: [ImpulseObject] = []

    // MARK: Other misc flags

    // Remark: This is important for circular pegs that can't otherwise
    // receive impulses (assuming they are set to non-translatable and non-rotatable).
    // Hence, a boolean flag is needed to capture this collision information instead.
    var collisionDetected = false
}
