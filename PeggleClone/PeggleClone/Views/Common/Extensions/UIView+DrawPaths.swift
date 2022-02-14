import UIKit

extension UIView {
    /// Helper function to draw a box outlining the given rect for greater clarity
    /// Especially useful for debugging purposes.
    func drawSurroundingBox(in rect: CGRect) {
        let path = UIBezierPath()
        var point = CGPoint.zero
        path.move(to: point)
        point = point.translateX(x: rect.width)
        path.addLine(to: point)
        point = point.translateY(y: rect.height)
        path.addLine(to: point)
        point = point.translateX(x: -rect.width)
        path.addLine(to: point)
        path.close()
        path.stroke()
    }

    func getCircularPathToFill(_ rect: CGRect) -> UIBezierPath {
        UIBezierPath(ovalIn: rect)
    }

    func getPolygonalPath(_ vertices: [CGPoint]) -> UIBezierPath {
        guard let lastVertex = vertices.last else {
            fatalError("Should have at least one vertex")
        }

        let polygonalPath = UIBezierPath()
        polygonalPath.move(to: lastVertex)
        for vertex in vertices {
            polygonalPath.addLine(to: vertex)
        }
        polygonalPath.close()
        return polygonalPath
    }

    func drawCircleToFill(_ rect: CGRect, withAlpha alpha: Double = 1.0) {
        let circlePath = getCircularPathToFill(rect)
        circlePath.fill(with: .normal, alpha: alpha)
        circlePath.stroke(with: .normal, alpha: alpha)
    }

    func drawPolygonalPath(_ vertices: [CGPoint], withAlpha alpha: Double = 1.0) {
        let polygonalPath = getPolygonalPath(vertices)
        polygonalPath.fill(with: .normal, alpha: alpha)
        polygonalPath.stroke(with: .normal, alpha: alpha)
    }
}
