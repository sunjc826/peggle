import UIKit
import Combine

class DesignerObstacleButtonViewModel: CoordinateMappableObstacleViewModel {
    @Published var isBeingEdited = false

    var vertices: [CGPoint] {
        guard let triangle = obstacle.shape as? TriangleObject else {
            fatalError("unexpected type")
        }

        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        return triangle.vertices.map {
            delegate.getDisplayCoords(of: $0)
        }
    }
}
