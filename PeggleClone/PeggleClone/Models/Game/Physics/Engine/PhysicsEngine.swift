import Foundation
import Dispatch
import CoreGraphics

private let accelerationDueToGravity = CGVector(dx: 0, dy: Settings.Physics.signedMagnitudeOfAccelerationDueToGravity)

/// Convention: Just like the GUI, the y axis points downward.
class PhysicsEngine: AbstractPhysicsEngine {
    var coordinateMapper: PhysicsCoordinateMapper {
        didSet {
            boundary = coordinateMapper.getBoundary()
            neighborFinder.resize(with: coordinateMapper.getBoundingBox(), entities: rigidBodies)
        }
    }
    var boundary: Boundary
    var rigidBodies: AnyContainer<RigidBodyObject>
    var changeableRigidBodies: Set<RigidBodyObject> = []
    var neighborFinder: AnyNeighborFinder<RigidBodyObject>
    var collisionResolver: CollisionResolver
    var bodiesMarkedForDeletion: Set<RigidBodyObject> = []
    var bodiesMarkedForCalculationUpdates: Set<RigidBodyObject> = []

    var didUpdateCallbacks: [BinaryFunction<RigidBodyObject>] = []
    var didRemoveCallbacks: [UnaryFunction<RigidBodyObject>] = []
    var didFinishAllUpdatesCallbacks: [Runnable] = []
    var didFinishAllUpdatesTempCallbacks: [Runnable] = []

    init<T, S>(
        coordinateMapper: PhysicsCoordinateMapper,
        rigidBodies: T,
        neighborFinder: S,
        collisionResolver: CollisionResolver
    ) where T: Container, T.Element == RigidBodyObject, S: NeighborFinder, S.Element == RigidBodyObject {
        self.coordinateMapper = coordinateMapper
        self.boundary = coordinateMapper.getBoundary()
        self.rigidBodies = AnyContainer(container: rigidBodies)
        self.neighborFinder = AnyNeighborFinder(neighborFinder: neighborFinder)
        self.collisionResolver = collisionResolver

        for rigidBody in rigidBodies {
            neighborFinder.insert(entity: rigidBody)

            if rigidBody.canTranslate || rigidBody.canRotate {
                changeableRigidBodies.insert(rigidBody)
            }
        }
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

            if let localizedForceEmitter = rigidBody.localizedForceEmitter {
                if localizedForceEmitter.duration < dt {
                    updatedRigidBody.localizedForceEmitter = nil
                } else {
                    updatedRigidBody = updatedRigidBody.withLocalizedForceEmitter(
                        emitter: localizedForceEmitter.withDuration(duration: localizedForceEmitter.duration - dt)
                    )
                }
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
        resolvePersistentForces(rigidBody: rigidBody)
        if rigidBody.canTranslate {
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

extension PhysicsEngine {
//    func setGravity(physicalGravitationalAcceleration: Double) {
//        globalAcceleration.first(where: { $0.accelerationType == .gravity })?.accelerationValue = coordinateMapper
//            .getLogicalVector(
//                ofPhysicalVector: CGVector(dx: 0, dy: physicalGravitationalAcceleration)
//            )
//    }

    func resolvePersistentForces(rigidBody: RigidBodyObject) {
        for force in rigidBody.persistentForces {
            let acceleration = force.getAccelerationVector(rigidBody: rigidBody)
            rigidBody.addAcceleration(acceleration: acceleration)
        }
    }
}
