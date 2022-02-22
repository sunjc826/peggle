import Foundation
import CoreGraphics

enum ImpulseType {
    case wallCollision(impulseVector: CGVector)
    case collision(impulseVector: CGVector, dueTo: RigidBody)
}

class ImpulseObject {
    let impulseType: ImpulseType
    let impulsePosition: ForcePosition
    init(impulseType: ImpulseType, impulsePosition: ForcePosition) {
        self.impulseType = impulseType
        self.impulsePosition = impulsePosition
    }

    func getImpulseVector(rigidBody: RigidBody) -> CGVector {
        switch impulseType {
        case .wallCollision(impulseVector: let impulseVector),
            .collision(impulseVector: let impulseVector, _):
            return impulseVector
        }
    }
}
