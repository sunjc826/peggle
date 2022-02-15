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
            if rigidBody.boundingBox.left <= boundary.left {
                reflectX(rigidBody)
                bodiesMarkedForCalculationUpdates.insert(rigidBody)
            }
        case .fallThrough:
            if rigidBody.boundingBox.right <= boundary.left {
                bodiesMarkedForDeletion.insert(rigidBody)
            }
        case .wrapAround:
            if rigidBody.boundingBox.right <= boundary.left {
                rigidBody.hasWrappedAroundMostRecently = true
                rigidBody.nextTeleportLocation = CGPoint(x: boundary.right, y: rigidBody.center.x)
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
            if rigidBody.boundingBox.right >= boundary.right {
                reflectX(rigidBody)
                bodiesMarkedForCalculationUpdates.insert(rigidBody)
            }
        case .fallThrough:
            if rigidBody.boundingBox.left >= boundary.right {
                bodiesMarkedForDeletion.insert(rigidBody)
            }
        case .wrapAround:
            if rigidBody.boundingBox.left >= boundary.right {
                rigidBody.hasWrappedAroundMostRecently = true
                rigidBody.nextTeleportLocation = CGPoint(x: boundary.left, y: rigidBody.center.x)
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
            if rigidBody.boundingBox.top <= boundary.top {
                reflectY(rigidBody)
                bodiesMarkedForCalculationUpdates.insert(rigidBody)
            }
        case .fallThrough:
            if rigidBody.boundingBox.bottom <= boundary.top {
                bodiesMarkedForDeletion.insert(rigidBody)
            }
        case .wrapAround:
            if rigidBody.boundingBox.bottom <= boundary.top {
                rigidBody.hasWrappedAroundMostRecently = true
                rigidBody.nextTeleportLocation = CGPoint(x: rigidBody.center.x, y: boundary.bottom)
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
            if rigidBody.boundingBox.bottom >= boundary.bottom {
                reflectY(rigidBody)
                bodiesMarkedForCalculationUpdates.insert(rigidBody)
            }
        case .fallThrough:
            if rigidBody.boundingBox.top >= boundary.bottom {
                bodiesMarkedForDeletion.insert(rigidBody)
            }
        case .wrapAround:
            if rigidBody.boundingBox.top >= boundary.bottom {
                rigidBody.hasWrappedAroundMostRecently = true
                rigidBody.nextTeleportLocation = CGPoint(x: rigidBody.center.x, y: boundary.top)
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
