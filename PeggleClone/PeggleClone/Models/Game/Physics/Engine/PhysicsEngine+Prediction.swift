import Foundation
import CoreGraphics

extension PhysicsEngine {
    func predict(for initialRigidBody: RigidBody, intervalSize dt: Double, numberOfIntervals: Int) -> [CGPoint] {
        var positions: [CGPoint] = []
        var currentRigidBody = RigidBody(instance: initialRigidBody)
        positions.append(currentRigidBody.center)
        for _ in 0..<numberOfIntervals {
            currentRigidBody = predictForSingleInterval(for: currentRigidBody, intervalSize: dt)
            positions.append(currentRigidBody.center)
        }
        return positions
    }

    func predictForSingleInterval(for rigidBody: RigidBody, intervalSize dt: Double) -> RigidBody {
        predictResolveBoundaryCollisions(rigidBody: rigidBody)
        predictResolveCollisions(rigidBody: rigidBody)

        rigidBody.longTermDelta.persistentForces.forEach { rigidBody.addForce($0) }
        rigidBody.physicsEngineReports.teleports.forEach { rigidBody.addTeleport($0) }
        rigidBody.physicsEngineReports.forces.forEach { rigidBody.addForce($0) }
        rigidBody.physicsEngineReports.impulses.forEach { rigidBody.addImpulse($0) }

        let (newPosition, newLinearVelocity) = rigidBody.getUpdatedLinearData(time: dt)

        let updatedRigidBody = RigidBody(instance: rigidBody)
        updatedRigidBody.center = newPosition
        updatedRigidBody.longTermDelta.linearVelocity = newLinearVelocity

        return updatedRigidBody
    }

    func predictResolveBoundaryCollisions(rigidBody: RigidBody) {
        predictResolveLeftBoundary(rigidBody)
        predictResolveRightBoundary(rigidBody)
        predictResolveTopBoundary(rigidBody)
        predictResolveBottomBoundary(rigidBody)
    }

    func predictResolveCollisions(rigidBody: RigidBody) {
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

    func predictResolveLeftBoundary(_ rigidBody: RigidBody) {
        guard rigidBody.longTermDelta.linearVelocity.dx < 0 else {
            return
        }
        switch rigidBody.configuration.leftWallBehavior {
        case .collide:
            if rigidBody.boundingBox.minX <= boundary.minX {
                reflectX(rigidBody)
            }
        case .fallThrough:
            break
        case .wrapAround:
            if rigidBody.boundingBox.maxX <= boundary.minX {
                let teleport = Teleport(
                    teleportType: .wallWrapAround,
                    teleportSetting: .to(point: CGPoint(x: boundary.maxX, y: rigidBody.center.x))
                )
                rigidBody.physicsEngineReports.teleports.append(teleport)
            }
        }
    }

    func predictResolveRightBoundary(_ rigidBody: RigidBody) {
        guard rigidBody.longTermDelta.linearVelocity.dx > 0 else {
            return
        }
        switch rigidBody.configuration.rightWallBehavior {
        case .collide:
            if rigidBody.boundingBox.maxX >= boundary.maxX {
                reflectX(rigidBody)
            }
        case .fallThrough:
            break
        case .wrapAround:
            if rigidBody.boundingBox.minX >= boundary.maxX {
                let teleport = Teleport(
                    teleportType: .wallWrapAround,
                    teleportSetting: .to(point: CGPoint(x: boundary.minX, y: rigidBody.center.x))
                )
                rigidBody.physicsEngineReports.teleports.append(teleport)
            }
        }
    }

    func predictResolveTopBoundary(_ rigidBody: RigidBody) {
        guard rigidBody.longTermDelta.linearVelocity.dy < 0 else {
            return
        }
        switch rigidBody.configuration.topWallBehavior {
        case .collide:
            if rigidBody.boundingBox.minY <= boundary.minY {
                reflectY(rigidBody)
            }
        case .fallThrough:
            break
        case .wrapAround:
            if rigidBody.boundingBox.maxY <= boundary.minY {
                let teleport = Teleport(
                    teleportType: .wallWrapAround,
                    teleportSetting: .to(point: CGPoint(x: rigidBody.center.x, y: boundary.maxY))
                )
                rigidBody.physicsEngineReports.teleports.append(teleport)
            }
        }
    }

    func predictResolveBottomBoundary(_ rigidBody: RigidBody) {
        guard rigidBody.longTermDelta.linearVelocity.dy > 0 else {
            return
        }
        switch rigidBody.configuration.bottomWallBehavior {
        case .collide:
            if rigidBody.boundingBox.maxY >= boundary.maxY {
                reflectY(rigidBody)
            }
        case .fallThrough:
            break
        case .wrapAround:
            if rigidBody.boundingBox.minY >= boundary.maxY {
                let teleport = Teleport(
                    teleportType: .wallWrapAround,
                    teleportSetting: .to(point: CGPoint(x: rigidBody.center.x, y: boundary.minY))
                )
                rigidBody.physicsEngineReports.teleports.append(teleport)
            }
        }
    }
}
