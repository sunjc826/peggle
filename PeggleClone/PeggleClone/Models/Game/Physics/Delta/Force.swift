import Foundation
import CoreGraphics

enum ForceType {
    case gravity(gravitationalAcceleration: Double)
    case restoring(springConstant: Double, centerOfOscillation: CGPoint)
    case repulsion(emitter: LocalizedRadialForceEmitter, direction: CGVector)
    case attraction(emitter: LocalizedRadialForceEmitter, direction: CGVector)
    case explosion(emitter: LocalizedRadialForceEmitter, direction: CGVector)

    /// Allows adding any type of force/acceleration desired.
    case customForce(forceVector: CGVector)
    case customAcceleration(accelerationVector: CGVector)
}

enum ForcePosition {
    case center
    case point(CGPoint)
}

class Force {
    let forceType: ForceType
    let forcePosition: ForcePosition
    init(forceType: ForceType, forcePosition: ForcePosition) {
        self.forceType = forceType
        self.forcePosition = forcePosition
    }
}

extension Force {
    func getForceVector(rigidBody: RigidBody) -> CGVector {
        switch forceType {
        case .gravity(gravitationalAcceleration: let gravitationalAcceleration):
            return CGVector(dx: 0, dy: rigidBody.physicalProperties.mass * gravitationalAcceleration)
        case let .restoring(
            springConstant: springConstant,
            centerOfOscillation: centerOfOscillation
        ):
            let displacement = CGVector(from: centerOfOscillation, to: rigidBody.center)
            let restoringForce = displacement.reverse().scaleBy(factor: springConstant)
            return restoringForce
        case .customForce(forceVector: let forceVector):
            return forceVector
        case .customAcceleration(accelerationVector: let accelerationVector):
            return accelerationVector.scaleBy(factor: rigidBody.physicalProperties.mass)
        case let .repulsion(emitter: emitter, direction: direction), let
            .explosion(emitter: emitter, direction: direction):
            let distance = direction.norm
            let repulsiveForceVector = direction.scaleBy(factor: emitter.baseMagnitude / (distance * distance))
            return repulsiveForceVector
        case let .attraction(emitter: emitter, direction: direction):
            let distance = direction.norm
            let attractiveForceVector = direction.scaleBy(
                factor: emitter.baseMagnitude / (distance * distance)
            ).reverse()
            return attractiveForceVector
        }
    }
}
