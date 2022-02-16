import Foundation
import CoreGraphics
typealias Predicate<T> = (T) -> Bool
protocol AbstractPhysicsEngine {
    func predict(for initialObject: RigidBodyObject, intervalSize dt: Double, numberOfIntervals: Int) -> [CGPoint]
    func simulateAll(time dt: Double)
    func remove(by predicate: Predicate<GameEntity>)
    func remove(by predicate: Predicate<RigidBody>)
    func add(rigidBody: RigidBodyObject)
    func update(oldRigidBody: RigidBodyObject, with updatedRigidBody: RigidBodyObject)
    func remove(rigidBody: RigidBodyObject)
    func registerDidUpdateCallback(callback: @escaping CallbackBinaryFunction<RigidBodyObject>)
    func registerDidRemoveCallback(callback: @escaping CallbackUnaryFunction<RigidBodyObject>)
    func registerDidFinishAllUpdatesCallback(callback: @escaping CallbackRunnable, temp: Bool)
    func setGravity(physicalGravitationalAcceleration: Double)
}
