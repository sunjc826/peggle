import Foundation

class CoordinateMappableObstacleViewModel: AbstractObstacleViewModel, AbstractCoordinateMappableGameObjectViewModel {
    weak var delegate: CoordinateMappableViewModelDelegate?

    var gameObject: GameObject {
        obstacle
    }

    var obstacle: Obstacle

    init(obstacle: Obstacle) {
        self.obstacle = obstacle
    }
}
