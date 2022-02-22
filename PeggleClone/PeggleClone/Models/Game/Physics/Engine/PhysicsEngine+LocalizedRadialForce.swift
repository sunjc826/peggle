import Foundation
import CoreGraphics

extension PhysicsEngine {
    func emitLocalizedForce(rigidBody: RigidBody) {
        guard let localizedForceEmitter = rigidBody.localizedForceEmitter else {
            return
        }

        let localizedForceDomain = CircleObject(
            center: rigidBody.center,
            radiusBeforeTransform: localizedForceEmitter.maximumRadius
        )

        let potentialNeighbors = neighborFinder.retrievePotentialNeighbors(
            givenBoundingBox: localizedForceDomain.boundingBox
        )
        // for efficiency, we don't check for exact collisions, instead we simply compare distance of centers
        for neighbor in potentialNeighbors {
            guard neighbor !== rigidBody else {
                continue
            }
            emitLocalizedForce(by: rigidBody, on: neighbor)
        }
    }

    func emitLocalizedForce(by rigidBody: RigidBody, on neighbor: RigidBody) {
        guard let emitter = rigidBody.localizedForceEmitter else {
            return
        }

        let direction = CGVector(from: rigidBody.center, to: neighbor.center)
        let distance = direction.norm
        guard distance <= emitter.maximumRadius else {
            return
        }

        switch emitter.forceType {
        case .explosion:
            let explosiveForce = Force(
                forceType: .explosion(emitter: emitter, direction: direction),
                forcePosition: .center
            )
            neighbor.physicsEngineReports.forces.append(explosiveForce)
        case .attraction:
            let attractiveForce = Force(
                forceType: .attraction(emitter: emitter, direction: direction),
                forcePosition: .center
            )
            neighbor.physicsEngineReports.forces.append(attractiveForce)
        case .replusion:
            let repulsiveForce = Force(
                forceType: .repulsion(emitter: emitter, direction: direction),
                forcePosition: .center
            )
            neighbor.physicsEngineReports.forces.append(repulsiveForce)
        }
        bodiesMarkedForNotification.insert(neighbor)
    }
}
