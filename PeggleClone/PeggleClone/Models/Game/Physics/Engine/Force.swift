import Foundation
import CoreGraphics

enum Force {
    case gravity(gravitationalAcceleration: Double)
    case restoring(springConstant: Double, centerOfOscillation: CGPoint)

    /// Allows adding any type of force/acceleration desired.
    case customForce(forceVector: CGVector)
    case customAcceleration(accelerationVector: CGVector)
}

extension Force {
    func getForceVector(rigidBody: RigidBodyObject) -> CGVector {
        switch self {
        case .gravity(gravitationalAcceleration: let gravitationalAcceleration):
            return CGVector(dx: 0, dy: rigidBody.mass * gravitationalAcceleration)
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
            return accelerationVector.scaleBy(factor: rigidBody.mass)
        }
    }

    /// A situational optimization over `getForceVector`, to avoid multiplying by mass.
    func getAccelerationVector(rigidBody: RigidBodyObject) -> CGVector {
        switch self {
        case .gravity(gravitationalAcceleration: let gravitationalAcceleration):
            return CGVector(dx: 0, dy: gravitationalAcceleration)
        case .restoring(
            springConstant: let springConstant,
            centerOfOscillation: let centerOfOscillation
        ):
            let displacement = CGVector(from: centerOfOscillation, to: rigidBody.center)
            let restoringForce = displacement.reverse().scaleBy(factor: springConstant * rigidBody.inverseMass)
            return restoringForce
        case .customForce(forceVector: let forceVector):
            return forceVector.scaleBy(factor: rigidBody.inverseMass)
        case .customAcceleration(accelerationVector: let accelerationVector):
            return accelerationVector
        }
    }
}

extension Force: Equatable {}
