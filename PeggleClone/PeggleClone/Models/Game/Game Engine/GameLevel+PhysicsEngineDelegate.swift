import Foundation
import CoreGraphics

extension GameLevel: PhysicsEngineDelegate {
    func notify(changedRigidBody rigidBody: RigidBody) {
        let physicsEngineReports = rigidBody.physicsEngineReports

        if physicsEngineReports.collisionDetected && !(rigidBody.associatedEntity is Bucket) {
            rigidBody.instantaneousDelta.shouldRegisterCollision = true
        }

        physicsEngineReports.teleports.forEach { resolveTeleport($0, for: rigidBody) }

        physicsEngineReports.forces.forEach { resolveForce($0, for: rigidBody) }

        physicsEngineReports.impulses.forEach { resolveImpulse($0, for: rigidBody) }
    }

    private func resolveTeleport(_ teleport: Teleport, for rigidBody: RigidBody) {
        switch teleport.teleportType {
        case .wallWrapAround:
            rigidBody.instantaneousDelta.changeToWrapAroundCount = .increment
            rigidBody.addTeleport(teleport)
        case .wallCollision:
            rigidBody.addTeleport(teleport)
        case .collision(dueTo: _):
            guard !(rigidBody.associatedEntity is BucketComponent) else {
                return
            }
            rigidBody.addTeleport(teleport)
        }
    }

    private func resolveForce(_ force: Force, for rigidBody: RigidBody) {
        switch force.forceType {
        case .explosion(emitter: _, direction: _):
            switch rigidBody.associatedEntity {
            case is Ball, is Obstacle, is Bucket:
                break
            case is Peg:
                rigidBody.instantaneousDelta.shouldRegisterCollision = true
            default:
                fatalError("unexpected type")
            }
            rigidBody.addForce(force)
        default:
            rigidBody.addForce(force)
        }
    }

    private func resolveImpulse(_ impulse: Impulse, for rigidBody: RigidBody) {
        switch impulse.impulseType {
        case .wallCollision(impulseVector: _):
            switch rigidBody.associatedEntity {
            case let bucketComponent as AbstractBucketComponentObject:
                resolveImpulseForBucket(component: bucketComponent, impulse: impulse)
            default:
                rigidBody.addImpulse(impulse)
            }

        case .collision(impulseVector: _, dueTo: let otherRigidBody):
            guard !(rigidBody.associatedEntity is BucketComponent) else {
                return
            }

            guard !(rigidBody.associatedEntity is Ball
                    && otherRigidBody.associatedEntity is BucketReceiver) else {
                rigidBody.instantaneousDelta.shouldDelete = true
                getFreeBall()
                return
            }

            rigidBody.addImpulse(impulse)
        }
    }

    private func resolveImpulseForBucket(component: AbstractBucketComponentObject, impulse: Impulse) {
        guard let bucket = component.parent else {
            fatalError("should not be nil")
        }

        for component in bucket.childComponents {
            guard let rigidBody = component.rigidBody else {
                fatalError("should not be nil")
            }
            rigidBody.addImpulse(impulse)
        }
    }
}
