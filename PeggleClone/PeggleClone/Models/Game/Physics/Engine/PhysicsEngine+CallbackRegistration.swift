import Foundation

extension PhysicsEngine {
    func registerDidUpdateCallback(callback: @escaping BinaryFunction<RigidBody>) {
        didUpdateCallbacks.append(callback)
    }

    func registerDidRemoveCallback(callback: @escaping UnaryFunction<RigidBody>) {
        didRemoveCallbacks.append(callback)
    }

    func registerDidFinishAllUpdatesCallback(callback: @escaping Runnable, temp: Bool) {
        if temp {
            didFinishAllUpdatesTempCallbacks.append(callback)
        } else {
            didFinishAllUpdatesCallbacks.append(callback)
        }
    }
}
