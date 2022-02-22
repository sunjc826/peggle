import Foundation

class ConfigurationForPhysicsEngine {
    var canTranslate: Bool
    var canRotate: Bool
    var leftWallBehavior: WallBehavior
    var rightWallBehavior: WallBehavior
    var topWallBehavior: WallBehavior
    var bottomWallBehavior: WallBehavior
    init(
        canTranslate: Bool,
        canRotate: Bool,
        leftWallBehavior: WallBehavior = .collide,
        rightWallBehavior: WallBehavior = .collide,
        topWallBehavior: WallBehavior = .collide,
        bottomWallBehavior: WallBehavior = .collide
    ) {
        self.canTranslate = canTranslate
        self.canRotate = canRotate
        self.leftWallBehavior = leftWallBehavior
        self.rightWallBehavior = rightWallBehavior
        self.topWallBehavior = topWallBehavior
        self.bottomWallBehavior = bottomWallBehavior
    }

    convenience init(instance: ConfigurationForPhysicsEngine) {
        self.init(
            canTranslate: instance.canTranslate,
            canRotate: instance.canRotate,
            leftWallBehavior: instance.leftWallBehavior,
            rightWallBehavior: instance.rightWallBehavior,
            topWallBehavior: instance.topWallBehavior,
            bottomWallBehavior: instance.bottomWallBehavior
        )
    }
}
