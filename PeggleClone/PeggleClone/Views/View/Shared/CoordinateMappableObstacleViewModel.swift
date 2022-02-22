import Foundation

class CoordinateMappableObstacleViewModel: AbstractObstacleViewModel, AbstractCoordinateMappableGameObjectViewModel {
    weak var delegate: CoordinateMappableViewModelDelegate?

    var gameObject: EditableGameObject {
        obstacle
    }

    var obstacle: Obstacle

    init(obstacle: Obstacle) {
        self.obstacle = obstacle
    }
}
