import UIKit

protocol AbstractObstacleViewModel: ShapeDrawable {
    var obstacle: Obstacle { get set }
}

extension AbstractObstacleViewModel {
    var fillColor: UIColor {
        UIColor.brown
    }
    var borderColor: UIColor {
        UIColor.black
    }
}
