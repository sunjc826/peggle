import Foundation
import CoreGraphics

// reference:
// https://www.codeproject.com/Articles/1215961/Making-a-D-Physics-Engine-Mass-Inertia-and-Forces
// https://www.toptal.com/game/video-game-physics-part-i-an-introduction-to-rigid-body-dynamics

extension RigidBody {
    var area: Double {
        backingShape.area
    }

    var areaMomentOfInertia: Double {
        backingShape.areaMomentOfInertia
    }

    func addTeleport(_ teleport: Teleport) {
        instantaneousDelta.nextTeleportLocation = teleport.getTeleportLocation(rigidBody: self)
    }

    func addTorque(_ torque: Double) {
        instantaneousDelta.torque += torque
    }

    func addForce(_ force: Force) {
        let forceVector = force.getForceVector(rigidBody: self)
        instantaneousDelta.force = instantaneousDelta.force.add(with: forceVector)
        switch force.forcePosition {
        case .center:
            break
        case .point(let position):
            addTorque(CGVector.crossProductSignedMagnitude(
                vector: CGVector(from: center, to: position),
                otherVector: forceVector
            ))
        }
    }

    func addAngularImpulse(_ angularImpulse: Double) {
        instantaneousDelta.angularImpulseIgnoringTorque += angularImpulse
    }

    func addImpulse(_ impulse: Impulse) {
        let impulseVector = impulse.getImpulseVector(rigidBody: self)
        instantaneousDelta.impulseIgnoringForce = instantaneousDelta.impulseIgnoringForce.add(with: impulseVector)

        switch impulse.impulsePosition {
        case .center:
            break
        case .point(let position):
            addAngularImpulse(CGVector.crossProductSignedMagnitude(
                vector: CGVector(from: center, to: position),
                otherVector: impulseVector
            ))
        }
    }
}

// MARK: Compute updates
extension RigidBody {
    func getUpdatedLinearData(time dt: Double) -> (newPosition: CGPoint, newLinearVelocity: CGVector) {
        assert(dt >= 0, "Time does not go backward")
        var newPosition = center
        if let unwrappedTeleportLocation = instantaneousDelta.nextTeleportLocation {
            newPosition = unwrappedTeleportLocation
        }
        let linearAcceleration = instantaneousDelta.force.scaleBy(factor: physicalProperties.inverseMass)
        let deltaLinearVelocityDueToAcceleration = linearAcceleration.scaleBy(factor: dt)
        let deltaLinearVelocityDueToImpulseIgnoringAcceleration = instantaneousDelta
            .impulseIgnoringForce
            .scaleBy(factor: physicalProperties.inverseMass)

        let deltaLinearVelocity = deltaLinearVelocityDueToAcceleration
            .add(with: deltaLinearVelocityDueToImpulseIgnoringAcceleration)
        let newLinearVelocity = longTermDelta.linearVelocity.add(with: deltaLinearVelocity)

        let deltaPosition = newLinearVelocity.scaleBy(factor: dt)
        newPosition = newPosition.translate(offset: deltaPosition)

        return (newPosition, newLinearVelocity)
    }

    func getUpdatedAngularData(time dt: Double) -> (newAngle: Double, newAngularVelocity: Double) {
        assert(dt >= 0, "Time does not go backward")
        let angularAcceleration = instantaneousDelta.torque * physicalProperties.inverseMomentOfInertia
        let deltaAngularVelocityDueToAcceleration = angularAcceleration * dt
        let deltaAngularVelocityDueToImpulseIgnoringAcceleration =
            instantaneousDelta.angularImpulseIgnoringTorque * physicalProperties.inverseMomentOfInertia

        let deltaAngularVelocity = deltaAngularVelocityDueToAcceleration +
            deltaAngularVelocityDueToImpulseIgnoringAcceleration
        let newAngularVelocity = longTermDelta.angularVelocity + deltaAngularVelocity
        let deltaAngle = newAngularVelocity * dt
        let newAngle = rotation + deltaAngle

        return (newAngle, newAngularVelocity)
    }
}
