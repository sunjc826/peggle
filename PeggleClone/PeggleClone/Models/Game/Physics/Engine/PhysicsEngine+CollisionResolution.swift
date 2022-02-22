import Foundation
import CoreGraphics

extension PhysicsEngine {
    func resolveRigidBodyCollisions(rigidBody: RigidBody) {
        let potentialNeighbors = neighborFinder.retrievePotentialNeighbors(for: rigidBody)

        for neighbor in potentialNeighbors {
            let collisionData = getCollisionData(
                rigidBody: rigidBody,
                otherRigidBody: neighbor
            )
            guard collisionData.isColliding else {
                continue
            }

            addCollisionResolutionTeleport(to: rigidBody, dueTo: neighbor, given: collisionData)
            addCollisionResolutionImpulse(to: rigidBody, dueTo: neighbor, given: collisionData)

            rigidBody.physicsEngineReports.collisionDetected = true
            neighbor.physicsEngineReports.collisionDetected = true

            bodiesMarkedForNotification.insert(rigidBody)
            bodiesMarkedForNotification.insert(neighbor)
        }
    }

    func addCollisionResolutionImpulse(
        to rigidBody: RigidBody,
        dueTo otherRigidBody: RigidBody,
        given collisionData: CollisionData
    ) {
        let normalOfIntersection = collisionData.normalizedNormalOfIntersection
        let penetrationPoint = collisionData.penetrationPoint
        let impulseVector: CGVector

        if otherRigidBody.configuration.canTranslate {
            let firstSignedMagnitudeOfTangentialVelocityToNormal =
            normalOfIntersection.getProjectionOntoSelf(vector: rigidBody.longTermDelta.linearVelocity)
            let secondSignedMagnitudeOfTangentialVelocityToNormal =
            normalOfIntersection.getProjectionOntoSelf(vector: otherRigidBody.longTermDelta.linearVelocity)

            let signedMagnitudeOfImpulse = getSignedMagnitudeOfImpulse(
                firstBodySignedSpeed: firstSignedMagnitudeOfTangentialVelocityToNormal,
                secondBodySignedSpeed: secondSignedMagnitudeOfTangentialVelocityToNormal,
                firstBodyInverseMass: rigidBody.physicalProperties.inverseMass,
                secondBodyInverseMass: otherRigidBody.physicalProperties.inverseMass,
                elasticity: rigidBody.physicalProperties.elasticity
            )

            impulseVector = normalOfIntersection.scaleBy(factor: signedMagnitudeOfImpulse)

        } else {
            let signedMagnitudeOfTangentialVelocityToNormal = normalOfIntersection
                .getProjectionOntoSelf(vector: rigidBody.longTermDelta.linearVelocity)
            let signedMagnitudeOfImpulse = getSignedMagnitudeOfImpulseDueToImmobileBody(
                translatingBodySignedSpeed: signedMagnitudeOfTangentialVelocityToNormal,
                translatingBodyMass: rigidBody.physicalProperties.mass,
                elasticity: rigidBody.physicalProperties.elasticity
            )

            impulseVector = normalOfIntersection.scaleBy(factor: signedMagnitudeOfImpulse)
        }

        let impulse: ImpulseObject

        if let presentPenetrationPoint = penetrationPoint {
            impulse = ImpulseObject(
                impulseType: .collision(impulseVector: impulseVector, dueTo: otherRigidBody),
                impulsePosition: .point(presentPenetrationPoint)
            )
        } else {
            impulse = ImpulseObject(
                impulseType: .collision(impulseVector: impulseVector, dueTo: otherRigidBody),
                impulsePosition: .center
            )
        }

        rigidBody.physicsEngineReports.impulses.append(impulse)
    }

    func addCollisionResolutionTeleport(
        to rigidBody: RigidBody,
        dueTo otherRigidBody: RigidBody,
        given collisionData: CollisionData
    ) {
        let normalOfIntersection = collisionData.normalizedNormalOfIntersection
        let depthOfIntersection = collisionData.depthOfIntersectionAlongNormal
        let teleportationVector = normalOfIntersection.reverse().scaleBy(factor: depthOfIntersection)
        let teleport = TeleportObject(
            teleportType: .collision(dueTo: otherRigidBody),
            teleportSetting: .by(vector: teleportationVector)
        )
        rigidBody.physicsEngineReports.teleports.append(teleport)
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
            fatalError("Unexpected type")
        }
    }
}
