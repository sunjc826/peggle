import Foundation
import CoreGraphics

extension PhysicsEngine {
    func resolveBoundaryCollisions(rigidBody: RigidBodyObject) {
        resolveLeftBoundary(rigidBody)
        resolveRightBoundary(rigidBody)
        resolveTopBoundary(rigidBody)
        resolveBottomBoundary(rigidBody)
    }

    func resolveLeftBoundary(_ rigidBody: RigidBodyObject) {
        guard rigidBody.linearVelocity.dx < 0 else {
            return
        }
        switch rigidBody.leftWallBehavior {
        case .collide:
            if rigidBody.boundingBox.minX <= boundary.minX {
                reflectX(rigidBody)
                bodiesMarkedForCalculationUpdates.insert(rigidBody)
            }
        case .fallThrough:
            if rigidBody.boundingBox.maxX <= boundary.minX {
                bodiesMarkedForDeletion.insert(rigidBody)
            }
        case .wrapAround:
            if rigidBody.boundingBox.maxX <= boundary.minX {
                rigidBody.hasWrappedAroundMostRecently = true
                rigidBody.nextTeleportLocation = CGPoint(x: boundary.maxX, y: rigidBody.center.x)
                bodiesMarkedForCalculationUpdates.insert(rigidBody)
            }
        }
    }

    func resolveRightBoundary(_ rigidBody: RigidBodyObject) {
        guard rigidBody.linearVelocity.dx > 0 else {
            return
        }
        switch rigidBody.rightWallBehavior {
        case .collide:
            if rigidBody.boundingBox.maxX >= boundary.maxX {
                reflectX(rigidBody)
                bodiesMarkedForCalculationUpdates.insert(rigidBody)
            }
        case .fallThrough:
            if rigidBody.boundingBox.minX >= boundary.maxX {
                bodiesMarkedForDeletion.insert(rigidBody)
            }
        case .wrapAround:
            if rigidBody.boundingBox.minX >= boundary.maxX {
                rigidBody.hasWrappedAroundMostRecently = true
                rigidBody.nextTeleportLocation = CGPoint(x: boundary.minX, y: rigidBody.center.x)
                bodiesMarkedForCalculationUpdates.insert(rigidBody)
            }
        }
    }

    func resolveTopBoundary(_ rigidBody: RigidBodyObject) {
        guard rigidBody.linearVelocity.dy < 0 else {
            return
        }
        switch rigidBody.topWallBehavior {
        case .collide:
            if rigidBody.boundingBox.minY <= boundary.minY {
                reflectY(rigidBody)
                bodiesMarkedForCalculationUpdates.insert(rigidBody)
            }
        case .fallThrough:
            if rigidBody.boundingBox.maxY <= boundary.minY {
                bodiesMarkedForDeletion.insert(rigidBody)
            }
        case .wrapAround:
            if rigidBody.boundingBox.maxY <= boundary.minY {
                rigidBody.hasWrappedAroundMostRecently = true
                rigidBody.nextTeleportLocation = CGPoint(x: rigidBody.center.x, y: boundary.maxY)
                bodiesMarkedForCalculationUpdates.insert(rigidBody)
            }
        }
    }

    func resolveBottomBoundary(_ rigidBody: RigidBodyObject) {
        guard rigidBody.linearVelocity.dy > 0 else {
            return
        }
        switch rigidBody.bottomWallBehavior {
        case .collide:
            if rigidBody.boundingBox.maxY >= boundary.maxY {
                reflectY(rigidBody)
                bodiesMarkedForCalculationUpdates.insert(rigidBody)
            }
        case .fallThrough:
            if rigidBody.boundingBox.minY >= boundary.maxY {
                bodiesMarkedForDeletion.insert(rigidBody)
            }
        case .wrapAround:
            if rigidBody.boundingBox.minY >= boundary.maxY {
                rigidBody.hasWrappedAroundMostRecently = true
                rigidBody.nextTeleportLocation = CGPoint(x: rigidBody.center.x, y: boundary.minY)
                bodiesMarkedForCalculationUpdates.insert(rigidBody)
            }
        }
    }

    func reflectX(_ rigidBody: RigidBodyObject) {
        let impulse = rigidBody.linearVelocity.restrictX()
            .reverse()
            .scaleBy(factor: (1 + rigidBody.elasticity) * rigidBody.mass)
        rigidBody.addImpulseTowardCenterOfMass(impulse: impulse)
    }

    func reflectY(_ rigidBody: RigidBodyObject) {
        let impulse = rigidBody.linearVelocity.restrictY()
            .reverse()
            .scaleBy(factor: (1 + rigidBody.elasticity) * rigidBody.mass)
        rigidBody.addImpulseTowardCenterOfMass(impulse: impulse)
    }
}
