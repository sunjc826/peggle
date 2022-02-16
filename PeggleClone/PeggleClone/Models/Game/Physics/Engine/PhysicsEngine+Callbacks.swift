import Foundation

extension PhysicsEngine {
    func registerDidUpdateCallback(callback: @escaping BinaryFunction<RigidBodyObject>) {
        didUpdateCallbacks.append(callback)
    }

    func registerDidRemoveCallback(callback: @escaping UnaryFunction<RigidBodyObject>) {
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
