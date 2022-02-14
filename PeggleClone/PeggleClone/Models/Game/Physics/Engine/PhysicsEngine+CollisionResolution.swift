import Foundation
import CoreGraphics

extension PhysicsEngine {
    func resolveRigidBodyCollisions(rigidBody: RigidBodyObject) {
        let potentialNeighbors = neighborFinder.retrievePotentialNeighbors(for: rigidBody)

        for neighbor in potentialNeighbors {
            let collisionData = getCollisionData(
                rigidBody: rigidBody,
                otherRigidBody: neighbor
            )
            guard collisionData.isColliding else {
                continue
            }

            setCollisionStatus(to: rigidBody, and: neighbor)
            addCollisionResolutionTeleport(to: rigidBody, dueTo: neighbor, given: collisionData)
            addCollisionResolutionImpulse(to: rigidBody, dueTo: neighbor, given: collisionData)
            bodiesMarkedForCalculationUpdates.insert(rigidBody)
            bodiesMarkedForCalculationUpdates.insert(neighbor)
        }
    }

    func setCollisionStatus(to rigidBody: RigidBodyObject, and otherRigidBody: RigidBodyObject) {
        rigidBody.hasCollidedMostRecently = true
        otherRigidBody.hasCollidedMostRecently = true
    }

    func addCollisionResolutionImpulse(
        to rigidBody: RigidBodyObject,
        dueTo otherRigidBody: RigidBodyObject,
        given collisionData: CollisionData
    ) {
        assert(collisionData.isColliding)

        let normalOfIntersection = collisionData.normalizedNormalOfIntersection
        let penetrationPoint = collisionData.penetrationPoint
        let impulse: CGVector

        if otherRigidBody.canTranslate {
            let firstSignedMagnitudeOfTangentialVelocityToNormal =
                normalOfIntersection.getProjectionOntoSelf(vector: rigidBody.linearVelocity)
            let secondSignedMagnitudeOfTangentialVelocityToNormal =
                normalOfIntersection.getProjectionOntoSelf(vector: otherRigidBody.linearVelocity)

            let signedMagnitudeOfImpulse = getSignedMagnitudeOfImpulse(
                firstBodySignedSpeed: firstSignedMagnitudeOfTangentialVelocityToNormal,
                secondBodySignedSpeed: secondSignedMagnitudeOfTangentialVelocityToNormal,
                firstBodyInverseMass: rigidBody.inverseMass,
                secondBodyInverseMass: otherRigidBody.inverseMass,
                elasticity: rigidBody.elasticity
            )

            impulse = normalOfIntersection.scaleBy(factor: signedMagnitudeOfImpulse)

        } else {
            let signedMagnitudeOfTangentialVelocityToNormal = normalOfIntersection
                .getProjectionOntoSelf(vector: rigidBody.linearVelocity)
            let signedMagnitudeOfImpulse = getSignedMagnitudeOfImpulseDueToImmobileBody(
                translatingBodySignedSpeed: signedMagnitudeOfTangentialVelocityToNormal,
                translatingBodyMass: rigidBody.mass,
                elasticity: rigidBody.elasticity
            )

            impulse = normalOfIntersection.scaleBy(factor: signedMagnitudeOfImpulse)
        }

        guard let presentPenetrationPoint = penetrationPoint else {
            rigidBody.addImpulseTowardCenterOfMass(impulse: impulse)
            return
        }

        rigidBody.addImpulseAtPosition(impulse: impulse, position: presentPenetrationPoint)
    }

    func addCollisionResolutionTeleport(
        to rigidBody: RigidBodyObject,
        dueTo otherRigidBody: RigidBodyObject,
        given collisionData: CollisionData
    ) {
        assert(collisionData.isColliding)

        let normalOfIntersection = collisionData.normalizedNormalOfIntersection
        let depthOfIntersection = collisionData.depthOfIntersectionAlongNormal
        let teleportationVector = normalOfIntersection.reverse().scaleBy(factor: depthOfIntersection)
        rigidBody.teleport(by: teleportationVector)
    }

    func getSignedMagnitudeOfImpulse(
        firstBodySignedSpeed: Double,
        secondBodySignedSpeed: Double,
        firstBodyInverseMass: Double,
        secondBodyInverseMass: Double,
        elasticity: Double
    ) -> Double {
        (1 + elasticity)
        * (secondBodySignedSpeed - firstBodySignedSpeed)
        / (firstBodyInverseMass + secondBodyInverseMass)
    }

    func getSignedMagnitudeOfImpulseDueToImmobileBody(
        translatingBodySignedSpeed: Double,
        translatingBodyMass: Double,
        elasticity: Double
    ) -> Double {
        -(1 + elasticity)
        * translatingBodySignedSpeed
        * translatingBodyMass
    }

    func getCollisionData(rigidBody: RigidBody, otherRigidBody: RigidBody) -> CollisionData {
        switch (rigidBody.backingShape, otherRigidBody.backingShape) {
        case let (circle as Circle, otherCircle as Circle):
            return collisionResolver.getCollisionData(
                circle: circle,
                otherCircle: otherCircle
            )
        case let (circle as Circle, polygon as TransformablePolygon):
            return collisionResolver.getCollisionData(
                circle: circle,
                convexPolygon: polygon
            )
        case let (polygon as TransformablePolygon, circle as Circle):
            return collisionResolver.getCollisionData(
                convexPolygon: polygon,
                circle: circle
            )
        case let (polygon as TransformablePolygon, otherPolygon as TransformablePolygon):
            return collisionResolver.getCollisionData(
                convexPolygon: polygon,
                otherConvexPolygon: otherPolygon
            )
        default:
            fatalError("Cases should be covered")
        }
    }
}
