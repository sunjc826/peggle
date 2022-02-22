import Foundation
import CoreGraphics
typealias Predicate<T> = (T) -> Bool
protocol AbstractPhysicsEngine: AnyObject {
    var delegate: PhysicsEngineDelegate? { get set }
    var coordinateMapper: PhysicsCoordinateMapper { get set }
    func predict(for initialObject: RigidBody, intervalSize dt: Double, numberOfIntervals: Int) -> [CGPoint]
    func simulateAll(time dt: Double)
    func recategorizeRigidBody(_ rigidBody: RigidBody)
    func remove(by predicate: Predicate<GameEntity>)
    func remove(by predicate: Predicate<RigidBody>)
    func add(rigidBody: RigidBody)
    func update(oldRigidBody: RigidBody, with updatedRigidBody: RigidBody)
    func updateWithoutFurtherProcessing(oldRigidBody: RigidBody, with updatedRigidBody: RigidBody)
    func remove(rigidBody: RigidBody)
    func registerDidUpdateCallback(callback: @escaping BinaryFunction<RigidBody>)
    func registerDidRemoveCallback(callback: @escaping UnaryFunction<RigidBody>)
    func registerDidFinishAllUpdatesCallback(callback: @escaping Runnable, temp: Bool)
}
