import Foundation
import CoreGraphics

extension PhysicsEngine {
    func emitLocalizedForce(rigidBody: RigidBodyObject) {
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
            bodiesMarkedForCalculationUpdates.insert(neighbor)
        }
    }

    func emitLocalizedForce(by rigidBody: RigidBodyObject, on neighbor: RigidBodyObject) {
        guard let localizedForceEmitter = rigidBody.localizedForceEmitter else {
            return
        }

        let direction = CGVector(from: rigidBody.center, to: neighbor.center)
        let distance = direction.norm

        guard distance <= localizedForceEmitter.maximumRadius else {
            return
        }

        let repulsiveForce = direction.scaleBy(factor: localizedForceEmitter.baseMagnitude / (distance * distance))

        switch localizedForceEmitter.forceType {
        case .explosion:
            neighbor.addForceTowardCenterOfMass(force: repulsiveForce)
            neighbor.hasCollidedMostRecently = true
        case .attraction:
            let attractiveForce = repulsiveForce.reverse()
            neighbor.addForceTowardCenterOfMass(force: attractiveForce)
        case .replusion:
            neighbor.addForceTowardCenterOfMass(force: repulsiveForce)
        }
    }
}
