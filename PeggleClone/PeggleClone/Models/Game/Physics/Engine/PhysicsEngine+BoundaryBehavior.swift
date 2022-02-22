import Foundation
import CoreGraphics

extension PhysicsEngine {
    func resolveBoundaryCollisions(rigidBody: RigidBody) {
        resolveLeftBoundary(rigidBody)
        resolveRightBoundary(rigidBody)
        resolveTopBoundary(rigidBody)
        resolveBottomBoundary(rigidBody)
    }

    func resolveLeftBoundary(_ rigidBody: RigidBody) {
        guard rigidBody.longTermDelta.linearVelocity.dx < 0 else {
            return
        }
        switch rigidBody.configuration.leftWallBehavior {
        case .collide:
            if rigidBody.boundingBox.minX <= boundary.minX {
                reflectX(rigidBody)
                bodiesMarkedForNotification.insert(rigidBody)
            }
        case .fallThrough:
            if rigidBody.boundingBox.maxX <= boundary.minX {
                // Remark: Deletion can also be designed as a notification, but for simplicity
                // it will be executed straight away by the physics engine without consulting
                // the game engine.
                bodiesMarkedForDeletion.insert(rigidBody)
            }
        case .wrapAround:
            if rigidBody.boundingBox.maxX <= boundary.minX {
                let teleport = Teleport(
                    teleportType: .wallWrapAround,
                    teleportSetting: .to(point: CGPoint(x: boundary.maxX, y: rigidBody.center.x))
                )
                rigidBody.physicsEngineReports.teleports.append(teleport)
                bodiesMarkedForNotification.insert(rigidBody)
            }
        }
    }

    func resolveRightBoundary(_ rigidBody: RigidBody) {
        guard rigidBody.longTermDelta.linearVelocity.dx > 0 else {
            return
        }
        switch rigidBody.configuration.rightWallBehavior {
        case .collide:
            if rigidBody.boundingBox.maxX >= boundary.maxX {
                reflectX(rigidBody)
                bodiesMarkedForNotification.insert(rigidBody)
            }
        case .fallThrough:
            if rigidBody.boundingBox.minX >= boundary.maxX {
                bodiesMarkedForDeletion.insert(rigidBody)
            }
        case .wrapAround:
            if rigidBody.boundingBox.minX >= boundary.maxX {
                let teleport = Teleport(
                    teleportType: .wallWrapAround,
                    teleportSetting: .to(point: CGPoint(x: boundary.minX, y: rigidBody.center.x))
                )
                rigidBody.physicsEngineReports.teleports.append(teleport)
                bodiesMarkedForNotification.insert(rigidBody)
            }
        }
    }

    func resolveTopBoundary(_ rigidBody: RigidBody) {
        guard rigidBody.longTermDelta.linearVelocity.dy < 0 else {
            return
        }
        switch rigidBody.configuration.topWallBehavior {
        case .collide:
            if rigidBody.boundingBox.minY <= boundary.minY {
                reflectY(rigidBody)
                bodiesMarkedForNotification.insert(rigidBody)
            }
        case .fallThrough:
            if rigidBody.boundingBox.maxY <= boundary.minY {
                bodiesMarkedForDeletion.insert(rigidBody)
            }
        case .wrapAround:
            if rigidBody.boundingBox.maxY <= boundary.minY {
                let teleport = Teleport(
                    teleportType: .wallWrapAround,
                    teleportSetting: .to(point: CGPoint(x: rigidBody.center.x, y: boundary.maxY))
                )
                rigidBody.physicsEngineReports.teleports.append(teleport)
                bodiesMarkedForNotification.insert(rigidBody)
            }
        }
    }

    func resolveBottomBoundary(_ rigidBody: RigidBody) {
        guard rigidBody.longTermDelta.linearVelocity.dy > 0 else {
            return
        }
        switch rigidBody.configuration.bottomWallBehavior {
        case .collide:
            if rigidBody.boundingBox.maxY >= boundary.maxY {
                reflectY(rigidBody)
                bodiesMarkedForNotification.insert(rigidBody)
            }
        case .fallThrough:
            if rigidBody.boundingBox.minY >= boundary.maxY {
                bodiesMarkedForDeletion.insert(rigidBody)
            }
        case .wrapAround:
            if rigidBody.boundingBox.minY >= boundary.maxY {
                let teleport = Teleport(
                    teleportType: .wallWrapAround,
                    teleportSetting: .to(point: CGPoint(x: rigidBody.center.x, y: boundary.minY))
                )
                rigidBody.physicsEngineReports.teleports.append(teleport)
                bodiesMarkedForNotification.insert(rigidBody)
            }
        }
    }

    func reflectX(_ rigidBody: RigidBody) {
        let impulseVector = rigidBody.longTermDelta.linearVelocity.restrictX()
            .reverse()
            .scaleBy(
                factor:
                    (1 + rigidBody.physicalProperties.elasticity)
                    * rigidBody.physicalProperties.mass
            )
        let impulse = Impulse(
            impulseType: .wallCollision(impulseVector: impulseVector),
            impulsePosition: .center)
        rigidBody.physicsEngineReports.impulses.append(impulse)
    }

    func reflectY(_ rigidBody: RigidBody) {
        let impulseVector = rigidBody.longTermDelta.linearVelocity.restrictY()
            .reverse()
            .scaleBy(
                factor:
                    (1 + rigidBody.physicalProperties.elasticity)
                * rigidBody.physicalProperties.mass
            )
        let impulse = Impulse(
            impulseType: .wallCollision(impulseVector: impulseVector),
            impulsePosition: .center
        )
        rigidBody.physicsEngineReports.impulses.append(impulse)
    }
}
