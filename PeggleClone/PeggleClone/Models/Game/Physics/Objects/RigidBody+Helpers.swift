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

    func addTeleport(_ teleport: TeleportObject) {
        instanteneousDelta.nextTeleportLocation = teleport.getTeleportLocation(rigidBody: self)
    }

    func addTorque(torque: Double) {
        instanteneousDelta.torque += torque
    }

    func addForce(force: ForceObject) {
        let forceVector = force.getForceVector(rigidBody: self)
        instanteneousDelta.force = instanteneousDelta.force.add(with: forceVector)
        switch force.forcePosition {
        case .center:
            break
        case .point(let position):
            addTorque(torque: CGVector.crossProductSignedMagnitude(
                vector: CGVector(from: center, to: position),
                otherVector: forceVector
            ))
        }
    }

    func addAngularImpulse(angularImpulse: Double) {
        instanteneousDelta.angularImpulseIgnoringTorque += angularImpulse
    }

    func addImpulseAtPosition(impulse: ImpulseObject) {
        let impulseVector = impulse.getImpulseVector(rigidBody: self)
        instanteneousDelta.impulseIgnoringForce = instanteneousDelta.impulseIgnoringForce.add(with: impulseVector)

        switch impulse.impulsePosition {
        case .center:
            break
        case .point(let position):
            addAngularImpulse(angularImpulse: CGVector.crossProductSignedMagnitude(
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
        if let unwrappedTeleportLocation = instanteneousDelta.nextTeleportLocation {
            newPosition = unwrappedTeleportLocation
        }
        let linearAcceleration = instanteneousDelta.force.scaleBy(factor: physicalProperties.inverseMass)
        let deltaLinearVelocityDueToAcceleration = linearAcceleration.scaleBy(factor: dt)
        let deltaLinearVelocityDueToImpulseIgnoringAcceleration = instanteneousDelta
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
        let angularAcceleration = instanteneousDelta.torque * physicalProperties.inverseMomentOfInertia
        let deltaAngularVelocityDueToAcceleration = angularAcceleration * dt
        let deltaAngularVelocityDueToImpulseIgnoringAcceleration =
            instanteneousDelta.angularImpulseIgnoringTorque * physicalProperties.inverseMomentOfInertia

        let deltaAngularVelocity = deltaAngularVelocityDueToAcceleration +
            deltaAngularVelocityDueToImpulseIgnoringAcceleration
        let newAngularVelocity = longTermDelta.angularVelocity + deltaAngularVelocity
        let deltaAngle = newAngularVelocity * dt
        let newAngle = rotation + deltaAngle

        return (newAngle, newAngularVelocity)
    }
}
