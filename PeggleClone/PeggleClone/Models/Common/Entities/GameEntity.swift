import Foundation
protocol GameEntity: AnyObject {
    var rigidBody: RigidBodyObject? { get }
    
    /// Whether the object can be destroyed by the ball during a game.
    var isDestructible: Bool { get }

    /// Whether the object is allowed to overlap with other objects during a game.
    var isOverlayable: Bool { get }
}
