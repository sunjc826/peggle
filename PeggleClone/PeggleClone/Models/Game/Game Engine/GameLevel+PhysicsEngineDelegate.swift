import Foundation
import CoreGraphics

extension GameLevel: PhysicsEngineDelegate {
    func notify(changedRigidBody rigidBody: RigidBody) {
        let physicsEngineReports = rigidBody.physicsEngineReports

        if physicsEngineReports.collisionDetected {
            rigidBody.instanteneousDelta.shouldRegisterCollision = true
        }

        physicsEngineReports.teleports.forEach { resolveTeleport($0, for: rigidBody) }

        physicsEngineReports.forces.forEach { resolveForce($0, for: rigidBody) }

        physicsEngineReports.impulses.forEach { resolveImpulse($0, for: rigidBody) }
    }

    private func resolveTeleport(_ teleport: TeleportObject, for rigidBody: RigidBody) {
        switch teleport.teleportType {
        case .wallWrapAround:
            rigidBody.instanteneousDelta.changeToWrapAroundCount = .increment
            rigidBody.addTeleport(teleport)
        case .wallCollision:
            rigidBody.addTeleport(teleport)
        case .collision(dueTo: _):
            guard !(rigidBody.associatedEntity is Bucket) else {
                return
            }
            rigidBody.addTeleport(teleport)
        }
    }

    private func resolveForce(_ force: ForceObject, for rigidBody: RigidBody) {
        switch force.forceType {
        case .explosion(emitter: _, direction: _):
            switch rigidBody.associatedEntity {
            case is Ball, is Obstacle, is Bucket:
                break
            case is Peg:
                rigidBody.instanteneousDelta.shouldRegisterCollision = true
            default:
                fatalError("unexpected type")
            }
            rigidBody.addForce(force: force)
        default:
            rigidBody.addForce(force: force)
        }
    }

    private func resolveImpulse(_ impulse: ImpulseObject, for rigidBody: RigidBody) {
        switch impulse.impulseType {
        case .wallCollision(impulseVector: _):
            rigidBody.addImpulseAtPosition(impulse: impulse)
        case .collision(impulseVector: _, dueTo: _):
            guard !(rigidBody.associatedEntity is Bucket) else {
                return
            }

            rigidBody.addImpulseAtPosition(impulse: impulse)
        }
    }
}
