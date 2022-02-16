import Foundation

extension PhysicsEngine {
    func add(rigidBody: RigidBodyObject) {
        addWithoutFurtherProcessing(rigidBody: rigidBody)
    }

    func update(oldRigidBody: RigidBodyObject, with updatedRigidBody: RigidBodyObject) {
        removeWithoutFurtherProcessing(rigidBody: oldRigidBody)
        addWithoutFurtherProcessing(rigidBody: updatedRigidBody)
        for callback in didUpdateCallbacks {
            callback(oldRigidBody, updatedRigidBody)
        }
    }

    func remove(rigidBody: RigidBodyObject) {
        removeWithoutFurtherProcessing(rigidBody: rigidBody)
        for callback in didRemoveCallbacks {
            callback(rigidBody)
        }
    }

    func addWithoutFurtherProcessing(rigidBody: RigidBodyObject) {
        rigidBodies.insert(rigidBody)
        if rigidBody.canTranslate || rigidBody.canRotate {
            changeableRigidBodies.insert(rigidBody)
        }

        neighborFinder.insert(entity: rigidBody)
    }

    func removeWithoutFurtherProcessing(rigidBody: RigidBodyObject) {
        rigidBodies.remove(rigidBody)
        if rigidBody.canTranslate || rigidBody.canRotate {
            changeableRigidBodies.remove(rigidBody)
        }

        neighborFinder.remove(entity: rigidBody)
    }
}
