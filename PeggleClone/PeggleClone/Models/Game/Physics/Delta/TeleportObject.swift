import Foundation
import CoreGraphics

enum TeleportType {
    case wallWrapAround
    case wallCollision
    case collision(dueTo: RigidBody)
}

enum TeleportSetting {
    case to(point: CGPoint)
    case by(vector: CGVector)
}

class TeleportObject {
    let teleportType: TeleportType
    let teleportSetting: TeleportSetting
    init(teleportType: TeleportType, teleportSetting: TeleportSetting) {
        self.teleportType = teleportType
        self.teleportSetting = teleportSetting
    }

    func getTeleportLocation(rigidBody: RigidBody) -> CGPoint {
        switch teleportSetting {
        case .to(let point):
            return point
        case .by(let vector):
            return rigidBody.center.translate(offset: vector)
        }
    }
}
