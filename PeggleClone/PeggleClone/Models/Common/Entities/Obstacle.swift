import Foundation

// Note: obstacles have not been implemented and is anticipated to be relevant in future
// programming assignments

/// Represents an indestructible object.
final class Obstacle: EditableGameEntity {
    weak var rigidBody: RigidBodyObject?
    let isDestructible = false
    var isOverlayable: Bool
    var isConcrete = true

    init(isOverlayable: Bool = false) {
        self.isOverlayable = isOverlayable
    }
}
