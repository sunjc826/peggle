import UIKit

class FillableObstacleViewModel: AbstractObstacleViewModel, AbstractFillableGameObjectViewModel {
    var gameObject: GameObject {
        obstacle
    }

    var obstacle = Obstacle(
        shape: TriangleObject(center: CGPoint.zero),
        radiusOfOscillation: 0.1,
        isConcrete: true
    )
}
