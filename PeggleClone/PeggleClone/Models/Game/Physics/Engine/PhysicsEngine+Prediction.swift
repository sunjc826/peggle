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
            if rigidBody.boundingBox.left <= boundary.left {
                reflectX(rigidBody)
            }
        case .fallThrough:
            break
        case .wrapAround:
            if rigidBody.boundingBox.right <= boundary.left {
                rigidBody.nextTeleportLocation = CGPoint(x: boundary.right, y: rigidBody.center.x)
            }
        }
    }

    func predictResolveRightBoundary(_ rigidBody: RigidBodyObject) {
        guard rigidBody.linearVelocity.dx > 0 else {
            return
        }
        switch rigidBody.rightWallBehavior {
        case .collide:
            if rigidBody.boundingBox.right >= boundary.right {
                reflectX(rigidBody)
            }
        case .fallThrough:
            break
        case .wrapAround:
            if rigidBody.boundingBox.left >= boundary.right {
                rigidBody.nextTeleportLocation = CGPoint(x: boundary.left, y: rigidBody.center.x)
            }
        }
    }

    func predictResolveTopBoundary(_ rigidBody: RigidBodyObject) {
        guard rigidBody.linearVelocity.dy < 0 else {
            return
        }
        switch rigidBody.topWallBehavior {
        case .collide:
            if rigidBody.boundingBox.top <= boundary.top {
                reflectY(rigidBody)
            }
        case .fallThrough:
            break
        case .wrapAround:
            if rigidBody.boundingBox.bottom <= boundary.top {
                rigidBody.nextTeleportLocation = CGPoint(x: rigidBody.center.x, y: boundary.bottom)
            }
        }
    }

    func predictResolveBottomBoundary(_ rigidBody: RigidBodyObject) {
        guard rigidBody.linearVelocity.dy > 0 else {
            return
        }
        switch rigidBody.bottomWallBehavior {
        case .collide:
            if rigidBody.boundingBox.bottom >= boundary.bottom {
                reflectY(rigidBody)
            }
        case .fallThrough:
            break
        case .wrapAround:
            if rigidBody.boundingBox.top >= boundary.bottom {
                rigidBody.nextTeleportLocation = CGPoint(x: rigidBody.center.x, y: boundary.top)
            }
        }
    }
}
