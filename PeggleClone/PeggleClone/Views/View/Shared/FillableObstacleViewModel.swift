import UIKit

class FillableObstacleViewModel: AbstractObstacleViewModel, AbstractFillableGameObjectViewModel {
    var gameObject: GameObject {
        obstacle
    }
    
    var obstacle: Obstacle = Obstacle(
        shape: TriangleObject(center: CGPoint.zero),
        radiusOfOscillation: 1,
        isConcrete: true
    )
}
