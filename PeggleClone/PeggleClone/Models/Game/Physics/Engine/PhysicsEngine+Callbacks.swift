import Foundation

extension PhysicsEngine {
    func registerDidUpdateCallback(callback: @escaping CallbackBinaryFunction<RigidBodyObject>) {
        didUpdateCallbacks.append(callback)
    }

    func registerDidRemoveCallback(callback: @escaping CallbackUnaryFunction<RigidBodyObject>) {
        didRemoveCallbacks.append(callback)
    }

    func registerDidFinishAllUpdatesCallback(callback: @escaping CallbackRunnable, temp: Bool) {
        if temp {
            didFinishAllUpdatesTempCallbacks.append(callback)
        } else {
            didFinishAllUpdatesCallbacks.append(callback)
        }
    }
}
