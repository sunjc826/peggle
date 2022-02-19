import Foundation
import CoreGraphics
typealias Predicate<T> = (T) -> Bool
protocol AbstractPhysicsEngine: AnyObject {
    var coordinateMapper: PhysicsCoordinateMapper { get set }
    func predict(for initialObject: RigidBodyObject, intervalSize dt: Double, numberOfIntervals: Int) -> [CGPoint]
    func simulateAll(time dt: Double)
    func remove(by predicate: Predicate<GameEntity>)
    func remove(by predicate: Predicate<RigidBody>)
    func add(rigidBody: RigidBodyObject)
    func update(oldRigidBody: RigidBodyObject, with updatedRigidBody: RigidBodyObject)
    func remove(rigidBody: RigidBodyObject)
    func registerDidUpdateCallback(callback: @escaping BinaryFunction<RigidBodyObject>)
    func registerDidRemoveCallback(callback: @escaping UnaryFunction<RigidBodyObject>)
    func registerDidFinishAllUpdatesCallback(callback: @escaping Runnable, temp: Bool)
}
