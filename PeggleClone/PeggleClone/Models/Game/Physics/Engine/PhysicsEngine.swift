import Foundation
import Dispatch
import CoreGraphics

private let signedMagnitudeOfAccelerationDueToGravity = 10.0
private let accelerationDueToGravity = CGVector(dx: 0, dy: signedMagnitudeOfAccelerationDueToGravity)

/// Convention: Just like the GUI, the y axis points downward.
class PhysicsEngine: AbstractPhysicsEngine {
    let coordinateMapper: PhysicsCoordinateMapper
    var boundary: Boundary
    var rigidBodies: AnyContainer<RigidBodyObject>
    var changeableRigidBodies: Set<RigidBodyObject> = []
    var neighborFinder: AnyNeighborFinder<RigidBodyObject>
    var collisionResolver: CollisionResolver
    var bodiesMarkedForDeletion: Set<RigidBodyObject> = []
    var bodiesMarkedForCalculationUpdates: Set<RigidBodyObject> = []

    var didUpdateCallbacks: [CallbackBinaryFunction<RigidBodyObject>] = []
    var didRemoveCallbacks: [CallbackUnaryFunction<RigidBodyObject>] = []
    var didFinishAllUpdatesCallbacks: [CallbackRunnable] = []
    var didFinishAllUpdatesTempCallbacks: [CallbackRunnable] = []

    var globalAcceleration: [CGVector] = []

    init<T, S>(
        coordinateMapper: PhysicsCoordinateMapper,
        boundary: Boundary,
        rigidBodies: T,
        neighborFinder: S,
        collisionResolver: CollisionResolver
    ) where T: Container, T.Element == RigidBodyObject, S: NeighborFinder, S.Element == RigidBodyObject {
        self.coordinateMapper = coordinateMapper
        self.boundary = boundary
        self.rigidBodies = AnyContainer(container: rigidBodies)
        self.neighborFinder = AnyNeighborFinder(neighborFinder: neighborFinder)
        self.collisionResolver = collisionResolver

        for rigidBody in rigidBodies {
            neighborFinder.insert(entity: rigidBody)

            if rigidBody.canTranslate || rigidBody.canRotate {
                changeableRigidBodies.insert(rigidBody)
            }
        }

        setupGlobalAcceleration()
    }

    func setupGlobalAcceleration() {
        globalAcceleration.append(
            coordinateMapper.getLogicalVector(ofPhysicalVector: accelerationDueToGravity)
        )
    }

    func simulateAll(time dt: Double) {
        calculateWithoutApplyingResults()
        cleanup()
        applyResults(time: dt)
        runCallbacksAfterAllUpdates()
    }
}

// MARK: High level private functions
extension PhysicsEngine {
    func calculateWithoutApplyingResults() {
        for rigidBody in changeableRigidBodies {
            simulate(rigidBody: rigidBody)
        }
    }

    func cleanup() {
        for rigidBody in bodiesMarkedForDeletion {
            remove(rigidBody: rigidBody)
        }
        bodiesMarkedForDeletion.removeAll()
    }

    func applyResults(time dt: Double) {
        let bodiesToUpdate = changeableRigidBodies.union(bodiesMarkedForCalculationUpdates)
        for rigidBody in bodiesToUpdate {
            var updatedRigidBody = rigidBody.hasCollidedMostRecently ?
            rigidBody.withConsecutiveCollisionCount(count: rigidBody.consecutiveCollisionCount + 1) :
            rigidBody.withConsecutiveCollisionCount(count: 0)
            
            if rigidBody.hasWrappedAroundMostRecently {
                updatedRigidBody = updatedRigidBody.withWrapAroundCount(count: rigidBody.wrapAroundCount + 1)
            }

            if rigidBody.canTranslate {
                let (newPosition, newLinearVelocity) = rigidBody.getUpdatedLinearData(time: dt)
                updatedRigidBody = updatedRigidBody.withPositionAndLinearVelocity(
                    position: newPosition,
                    linearVelocity: newLinearVelocity
                )
            }

            if rigidBody.canRotate {
                let (newAngle, newAngularVelocity) = rigidBody.getUpdatedAngularData(time: dt)
                updatedRigidBody = updatedRigidBody.withAngleAndAngularVelocity(
                    angle: newAngle, angularVelocity: newAngularVelocity
                )
            }

            update(oldRigidBody: rigidBody, with: updatedRigidBody)
        }
        bodiesMarkedForCalculationUpdates.removeAll()
    }

    func simulate(rigidBody: RigidBodyObject) {
        if rigidBody.canTranslate {
            addGlobalAcceleration(rigidBody: rigidBody)
            resolveBoundaryCollisions(rigidBody: rigidBody)
        }
        resolveRigidBodyCollisions(rigidBody: rigidBody)
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
        var toRemove: [RigidBodyObject] = []
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
        var toRemove: [RigidBodyObject] = []
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

// MARK: CRUD
extension PhysicsEngine {
    func add(rigidBody: RigidBodyObject) {
        addWithoutFurtherProcessing(rigidBody: rigidBody)
    }

    func update(oldRigidBody: RigidBodyObject, with updatedRigidBody: RigidBodyObject) {
        removeWithoutFurtherProcessing(rigidBody: oldRigidBody)
        addWithoutFurtherProcessing(rigidBody: updatedRigidBody)
        for callback in didUpdateCallbacks {
            callback(oldRigidBody, updatedRigidBody)
        }
    }

    func remove(rigidBody: RigidBodyObject) {
        removeWithoutFurtherProcessing(rigidBody: rigidBody)
        for callback in didRemoveCallbacks {
            callback(rigidBody)
        }
    }

    func addWithoutFurtherProcessing(rigidBody: RigidBodyObject) {
        rigidBodies.insert(rigidBody)
        if rigidBody.canTranslate || rigidBody.canRotate {
            changeableRigidBodies.insert(rigidBody)
        }

        neighborFinder.insert(entity: rigidBody)
    }

    func removeWithoutFurtherProcessing(rigidBody: RigidBodyObject) {
        rigidBodies.remove(rigidBody)
        if rigidBody.canTranslate || rigidBody.canRotate {
            changeableRigidBodies.remove(rigidBody)
        }

        neighborFinder.remove(entity: rigidBody)
    }
}

// MARK: Callbacks
extension PhysicsEngine {
    func registerDidUpdateCallback(callback: @escaping CallbackBinaryFunction<RigidBodyObject>) {
        didUpdateCallbacks.append(callback)
    }

    func registerDidRemoveCallback(callback: @escaping CallbackUnaryFunction<RigidBodyObject>) {
        didRemoveCallbacks.append(callback)
    }
    
    func registerDidFinishAllUpdatesCallback(callback: @escaping CallbackRunnable, temp: Bool) {
        if temp {
            didFinishAllUpdatesTempCallbacks.append(callback)
        } else {
            didFinishAllUpdatesCallbacks.append(callback)
        }
    }
}

// MARK: Shared acceleration
extension PhysicsEngine {
    func addGlobalAcceleration(rigidBody: RigidBodyObject) {
        guard rigidBody.canTranslate && rigidBody.isAffectedByGlobalForces else {
            return
        }

        for accel in globalAcceleration {
            rigidBody.addAcceleration(acceleration: accel)
        }
    }
}
