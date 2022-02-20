import Foundation
import CoreGraphics

extension PhysicsEngine {
    func predict(for initialRigidBody: RigidBodyObject, intervalSize dt: Double, numberOfIntervals: Int) -> [CGPoint] {
        var positions: [CGPoint] = []
        var currentRigidBody = RigidBodyObject(instance: initialRigidBody)
        positions.append(currentRigidBody.center)
        for _ in 0..<numberOfIntervals {
            currentRigidBody = predictForSingleInterval(for: currentRigidBody, intervalSize: dt)
            positions.append(currentRigidBody.center)
        }
        return positions
    }

    func predictForSingleInterval(for rigidBody: RigidBodyObject, intervalSize dt: Double) -> RigidBodyObject {
        predictResolvePersistentForces(rigidBody: rigidBody)
        predictResolveBoundaryCollisions(rigidBody: rigidBody)
        predictResolveCollisions(rigidBody: rigidBody)

        let (newPosition, newLinearVelocity) = rigidBody.getUpdatedLinearData(time: dt)

        let updatedRigidBody = rigidBody.withPositionAndLinearVelocity(
            position: newPosition,
            linearVelocity: newLinearVelocity
        )

        return updatedRigidBody
    }

    func predictResolvePersistentForces(rigidBody: RigidBodyObject) {
        for force in rigidBody.persistentForces {
            rigidBody.addAcceleration(acceleration: force.getAccelerationVector(rigidBody: rigidBody))
        }
    }

    func predictResolveBoundaryCollisions(rigidBody: RigidBodyObject) {
        predictResolveLeftBoundary(rigidBody)
        predictResolveRightBoundary(rigidBody)
        predictResolveTopBoundary(rigidBody)
        predictResolveBottomBoundary(rigidBody)
    }

    func predictResolveCollisions(rigidBody: RigidBodyObject) {
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
        }
    }

    func predictResolveLeftBoundary(_ rigidBody: RigidBodyObject) {
        guard rigidBody.linearVelocity.dx < 0 else {
            return
        }
        switch rigidBody.leftWallBehavior {
        case .collide:
            if rigidBody.boundingBox.minX <= boundary.minX {
                reflectX(rigidBody)
            }
        case .fallThrough:
            break
        case .wrapAround:
            if rigidBody.boundingBox.maxX <= boundary.minX {
                rigidBody.nextTeleportLocation = CGPoint(x: boundary.maxX, y: rigidBody.center.x)
            }
        }
    }

    func predictResolveRightBoundary(_ rigidBody: RigidBodyObject) {
        guard rigidBody.linearVelocity.dx > 0 else {
            return
        }
        switch rigidBody.rightWallBehavior {
        case .collide:
            if rigidBody.boundingBox.maxX >= boundary.maxX {
                reflectX(rigidBody)
            }
        case .fallThrough:
            break
        case .wrapAround:
            if rigidBody.boundingBox.minX >= boundary.maxX {
                rigidBody.nextTeleportLocation = CGPoint(x: boundary.minX, y: rigidBody.center.x)
            }
        }
    }

    func predictResolveTopBoundary(_ rigidBody: RigidBodyObject) {
        guard rigidBody.linearVelocity.dy < 0 else {
            return
        }
        switch rigidBody.topWallBehavior {
        case .collide:
            if rigidBody.boundingBox.minY <= boundary.minY {
                reflectY(rigidBody)
            }
        case .fallThrough:
            break
        case .wrapAround:
            if rigidBody.boundingBox.maxY <= boundary.minY {
                rigidBody.nextTeleportLocation = CGPoint(x: rigidBody.center.x, y: boundary.maxY)
            }
        }
    }

    func predictResolveBottomBoundary(_ rigidBody: RigidBodyObject) {
        guard rigidBody.linearVelocity.dy > 0 else {
            return
        }
        switch rigidBody.bottomWallBehavior {
        case .collide:
            if rigidBody.boundingBox.maxY >= boundary.maxY {
                reflectY(rigidBody)
            }
        case .fallThrough:
            break
        case .wrapAround:
            if rigidBody.boundingBox.minY >= boundary.maxY {
                rigidBody.nextTeleportLocation = CGPoint(x: rigidBody.center.x, y: boundary.minY)
            }
        }
    }
}
