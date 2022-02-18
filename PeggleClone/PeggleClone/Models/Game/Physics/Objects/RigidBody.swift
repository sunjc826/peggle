import Foundation
import CoreGraphics

// reference:
// https://www.codeproject.com/Articles/1215961/Making-a-D-Physics-Engine-Mass-Inertia-and-Forces
// https://www.toptal.com/game/video-game-physics-part-i-an-introduction-to-rigid-body-dynamics

protocol RigidBody: TransformableShape {
    var backingShape: TransformableShape { get set }

    var associatedEntity: GameEntity? { get set }

    var nextTeleportLocation: CGPoint? { get set }

    /// Whether a body can actually move as a result of physics, ignores mass.
    var canTranslate: Bool { get set }

    /// Whether a body can actually rotate as a result of physics, ignores mass.
    var canRotate: Bool { get set }

    var mass: Double { get set }

    /// The reciprocal of mass.
    var inverseMass: Double { get }

    var momentOfInertia: Double { get set }

    /// The reciprocal of moment of inertia.
    var inverseMomentOfInertia: Double { get set }

    var hasCollidedMostRecently: Bool { get set }

    var linearVelocity: CGVector { get set }

    var angularVelocity: Double { get set }

    var force: CGVector { get set }

    /// The total impulse is evaluated by taking into account both instantaneous
    /// `force` and `impulseIgnoringForce`.
    var impulseIgnoringForce: CGVector { get set }

    var torque: Double { get set }

    /// The total angular impulse is evaluated by taking into account both
    /// instantaneous `torque` and `angularImpulseIgnoringTorque`.
    var angularImpulseIgnoringTorque: Double { get set }

    var leftWallBehavior: WallBehavior { get }

    var rightWallBehavior: WallBehavior { get }

    var topWallBehavior: WallBehavior { get }

    var bottomWallBehavior: WallBehavior { get }

    /// Number of consecutive physics engine updates for which a collision is detected.
    /// - warning: This is only relevant for translatable or rotatable bodies for efficiency reasons.
    var consecutiveCollisionCount: Int { get set }
}

extension RigidBody {
    var area: Double {
        backingShape.area
    }

    var areaMomentOfInertia: Double {
        backingShape.areaMomentOfInertia
    }

    func teleport(to point: CGPoint) {
        nextTeleportLocation = point
    }

    func teleport(by offset: CGVector) {
        nextTeleportLocation = center.translate(offset: offset)
    }

    func addForceTowardCenterOfMass(force: CGVector) {
        let newForce = force.add(with: force)
        self.force = newForce
    }

    func addTorque(torque: Double) {
        let newTorque = self.torque + torque
        self.torque = newTorque
    }

    func addForceAtPosition(force: CGVector, position: CGPoint) {
        addForceTowardCenterOfMass(force: force)
        addTorque(torque: CGVector.crossProductSignedMagnitude(
            vector: CGVector(from: center, to: position),
            otherVector: force
        ))
    }

    func addAcceleration(acceleration: CGVector) {
        addForceTowardCenterOfMass(force: acceleration.scaleBy(factor: mass))
    }

    func addImpulseTowardCenterOfMass(impulse: CGVector) {
        let newImpulse = impulseIgnoringForce.add(with: impulse)
        impulseIgnoringForce = newImpulse
    }

    func addAngularImpulse(angularImpulse: Double) {
        let newAngularImpulse = self.angularImpulseIgnoringTorque + angularImpulse
        self.angularImpulseIgnoringTorque = newAngularImpulse
    }

    func addImpulseAtPosition(impulse: CGVector, position: CGPoint) {
        addImpulseTowardCenterOfMass(impulse: impulse)
        addAngularImpulse(angularImpulse: CGVector.crossProductSignedMagnitude(
            vector: CGVector(from: center, to: position),
            otherVector: impulse
        ))
    }
}

// MARK: Compute updates
extension RigidBody {
    func getUpdatedLinearData(time dt: Double) -> (newPosition: CGPoint, newLinearVelocity: CGVector) {
        assert(dt >= 0, "Time does not go backward")
        var newPosition = center
        if let unwrappedTeleportLocation = nextTeleportLocation {
            newPosition = unwrappedTeleportLocation
            nextTeleportLocation = nil
        }
        let linearAcceleration = force.scaleBy(factor: inverseMass)
        let deltaLinearVelocityDueToAcceleration = linearAcceleration.scaleBy(factor: dt)
        let deltaLinearVelocityDueToImpulseIgnoringAcceleration = impulseIgnoringForce.scaleBy(factor: inverseMass)

        let deltaLinearVelocity = deltaLinearVelocityDueToAcceleration
            .add(with: deltaLinearVelocityDueToImpulseIgnoringAcceleration)
        let newLinearVelocity = linearVelocity.add(with: deltaLinearVelocity)

        let deltaPosition = newLinearVelocity.scaleBy(factor: dt)
        newPosition = newPosition.translate(offset: deltaPosition)

        return (newPosition, newLinearVelocity)
    }

    func getUpdatedAngularData(time dt: Double) -> (newAngle: Double, newAngularVelocity: Double) {
        assert(dt >= 0, "Time does not go backward")
        let angularAcceleration = torque * inverseMomentOfInertia
        let deltaAngularVelocityDueToAcceleration = angularAcceleration * dt
        let deltaAngularVelocityDueToImpulseIgnoringAcceleration = angularImpulseIgnoringTorque * inverseMomentOfInertia

        let deltaAngularVelocity = deltaAngularVelocityDueToAcceleration +
            deltaAngularVelocityDueToImpulseIgnoringAcceleration
        let newAngularVelocity = angularVelocity + deltaAngularVelocity
        let deltaAngle = newAngularVelocity * dt
        let newAngle = rotation + deltaAngle

        return (newAngle, newAngularVelocity)
    }
}
