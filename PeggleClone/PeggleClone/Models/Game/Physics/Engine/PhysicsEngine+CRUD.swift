import Foundation

extension PhysicsEngine {
    func add(rigidBody: RigidBody) {
        addWithoutFurtherProcessing(rigidBody: rigidBody)
    }

    func update(oldRigidBody: RigidBody, with updatedRigidBody: RigidBody) {
        removeWithoutFurtherProcessing(rigidBody: oldRigidBody)
        addWithoutFurtherProcessing(rigidBody: updatedRigidBody)
        for callback in didUpdateCallbacks {
            callback(oldRigidBody, updatedRigidBody)
        }
    }

    func remove(rigidBody: RigidBody) {
        removeWithoutFurtherProcessing(rigidBody: rigidBody)
        for callback in didRemoveCallbacks {
            callback(rigidBody)
        }
    }

    func addWithoutFurtherProcessing(rigidBody: RigidBody) {
        rigidBodies.insert(rigidBody)
        if rigidBody.configuration.canTranslate || rigidBody.configuration.canRotate {
            changeableRigidBodies.insert(rigidBody)
        }

        neighborFinder.insert(entity: rigidBody)
    }

    func updateWithoutFurtherProcessing(oldRigidBody: RigidBody, with updatedRigidBody: RigidBody) {
        removeWithoutFurtherProcessing(rigidBody: oldRigidBody)
        addWithoutFurtherProcessing(rigidBody: updatedRigidBody)
    }

    func removeWithoutFurtherProcessing(rigidBody: RigidBody) {
        rigidBodies.remove(rigidBody)
        changeableRigidBodies.remove(rigidBody)
        bodiesMarkedForNotification.remove(rigidBody)
        neighborFinder.remove(entity: rigidBody)
    }
}
