import Foundation
import Dispatch
import CoreGraphics

private let accelerationDueToGravity = CGVector(dx: 0, dy: Settings.Physics.signedMagnitudeOfAccelerationDueToGravity)

protocol PhysicsEngineDelegate: AnyObject {
    func notify(changedRigidBody: RigidBody)
}

/// Convention: Just like the GUI, the y axis points downward.
class PhysicsEngine: AbstractPhysicsEngine {
    weak var delegate: PhysicsEngineDelegate?
    var coordinateMapper: PhysicsCoordinateMapper {
        didSet {
            boundary = coordinateMapper.getBoundary()
            neighborFinder.resize(with: coordinateMapper.getBoundingBox(), entities: rigidBodies)
        }
    }
    var boundary: Boundary
    var rigidBodies: AnyContainer<RigidBody>
    var changeableRigidBodies: Set<RigidBody> = []
    var neighborFinder: AnyNeighborFinder<RigidBody>
    var collisionResolver: CollisionResolver
    var bodiesMarkedForDeletion: Set<RigidBody> = []
    var bodiesMarkedForNotification: Set<RigidBody> = []

    var didUpdateCallbacks: [BinaryFunction<RigidBody>] = []
    var didRemoveCallbacks: [UnaryFunction<RigidBody>] = []
    var didFinishAllUpdatesCallbacks: [Runnable] = []
    var didFinishAllUpdatesTempCallbacks: [Runnable] = []

    init<T, S>(
        coordinateMapper: PhysicsCoordinateMapper,
        rigidBodies: T,
        neighborFinder: S,
        collisionResolver: CollisionResolver
    ) where T: Container, T.Element == RigidBody, S: NeighborFinder, S.Element == RigidBody {
        self.coordinateMapper = coordinateMapper
        self.boundary = coordinateMapper.getBoundary()
        self.rigidBodies = AnyContainer(container: rigidBodies)
        self.neighborFinder = AnyNeighborFinder(neighborFinder: neighborFinder)
        self.collisionResolver = collisionResolver

        for rigidBody in rigidBodies {
            neighborFinder.insert(entity: rigidBody)

            if rigidBody.configuration.canTranslate || rigidBody.configuration.canRotate {
                changeableRigidBodies.insert(rigidBody)
            }
        }
    }

    func simulateAll(time dt: Double) {
        calculateWithoutApplyingResults()
        notifyDelegate()
        cleanup()
        applyResults(time: dt)
        runCallbacksAfterAllUpdates()
    }

    func recategorizeRigidBody(_ rigidBody: RigidBody) {
        if rigidBody.configuration.canTranslate || rigidBody.configuration.canRotate {
            changeableRigidBodies.insert(rigidBody)
        } else {
            changeableRigidBodies.remove(rigidBody)
        }
    }
}

// MARK: High level private functions
extension PhysicsEngine {
    func calculateWithoutApplyingResults() {
        for rigidBody in changeableRigidBodies {
            simulate(rigidBody: rigidBody)
        }
    }

    /// Notify of unconfirmed changes.
    func notifyDelegate() {
        guard let delegate = delegate else {
            return
        }

        for rigidBody in bodiesMarkedForNotification {
            delegate.notify(changedRigidBody: rigidBody)
            if rigidBody.instantaneousDelta.shouldDelete {
                bodiesMarkedForDeletion.insert(rigidBody)
            }
        }
    }

    func cleanup() {
        for rigidBody in bodiesMarkedForDeletion {
            remove(rigidBody: rigidBody)
        }
        bodiesMarkedForDeletion.removeAll()
    }

    /// Commit changes.
    func applyResults(time dt: Double) {
        let bodiesToUpdate = changeableRigidBodies.union(bodiesMarkedForNotification)
        for rigidBody in bodiesToUpdate {
            let updatedRigidBody = RigidBody(instance: rigidBody)

            if rigidBody.instantaneousDelta.shouldRegisterCollision {
                updatedRigidBody.miscProperties.consecutiveCollisionCount =
                    rigidBody.miscProperties.consecutiveCollisionCount + 1
            } else {
                updatedRigidBody.miscProperties.consecutiveCollisionCount = 0
            }

            updatedRigidBody.miscProperties.wrapAroundCount.updateWith(
                counterChange: rigidBody.instantaneousDelta.changeToWrapAroundCount
            )

            if let localizedForceEmitter = rigidBody.localizedForceEmitter {
                if localizedForceEmitter.duration < dt {
                    updatedRigidBody.localizedForceEmitter = nil
                } else {
                    updatedRigidBody.localizedForceEmitter?.duration -= dt
                }
            }

            for force in rigidBody.longTermDelta.persistentForces {
                updatedRigidBody.addForce(force)
            }

            if rigidBody.configuration.canTranslate {
                let (newPosition, newLinearVelocity) = rigidBody.getUpdatedLinearData(time: dt)
                updatedRigidBody.center = newPosition
                updatedRigidBody.longTermDelta.linearVelocity = newLinearVelocity
            }

            if rigidBody.configuration.canRotate {
                let (newAngle, newAngularVelocity) = rigidBody.getUpdatedAngularData(time: dt)
                updatedRigidBody.rotation = newAngle
                updatedRigidBody.longTermDelta.angularVelocity = newAngularVelocity
            }

            update(oldRigidBody: rigidBody, with: updatedRigidBody)
        }
        bodiesMarkedForNotification.removeAll()
    }

    func simulate(rigidBody: RigidBody) {
        if rigidBody.configuration.canTranslate {
            resolveBoundaryCollisions(rigidBody: rigidBody)
        }
        resolveRigidBodyCollisions(rigidBody: rigidBody)
        emitLocalizedForce(rigidBody: rigidBody)
    }

    func runCallbacksAfterAllUpdates() {
        for callback in didFinishAllUpdatesCallbacks {
            callback()
        }
        for callback in didFinishAllUpdatesTempCallbacks {
            callback()
        }
        didFinishAllUpdatesTempCallbacks.removeAll()
    }
}

extension PhysicsEngine {
    func remove(by predicate: Predicate<GameEntity>) {
        var toRemove: [RigidBody] = []
        for rigidBody in rigidBodies {
            guard let entity = rigidBody.associatedEntity else {
                continue
            }

            if predicate(entity) {
                toRemove.append(rigidBody)
            }
        }

        for rigidBody in toRemove {
            remove(rigidBody: rigidBody)
        }
    }

    func remove(by predicate: Predicate<RigidBody>) {
        var toRemove: [RigidBody] = []
        for rigidBody in rigidBodies {

            if predicate(rigidBody) {
                toRemove.append(rigidBody)
            }
        }

        for rigidBody in toRemove {
            remove(rigidBody: rigidBody)
        }
    }
}
