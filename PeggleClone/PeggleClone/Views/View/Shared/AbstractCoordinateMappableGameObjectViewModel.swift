import UIKit

private let opaqueAlpha = 1.0
private let translucentAlpha = 0.7

protocol CoordinateMappableViewModelDelegate: AnyObject, CoordinateMappable {}

protocol AbstractCoordinateMappableGameObjectViewModel {
    var delegate: CoordinateMappableViewModelDelegate? { get set }
    var gameObject: EditableGameObject { get }
    var displayCoords: CGPoint { get }
    var displayFrame: CGRect { get }
    var alpha: Double { get }
    var drawableVertices: [CGPoint] { get }
}

extension AbstractCoordinateMappableGameObjectViewModel {
    var displayCoords: CGPoint {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        return delegate.getDisplayCoords(of: gameObject.boundingBox.center)
    }

    var displayFrame: CGRect {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        return CGRect(
            x: 0,
            y: 0,
            width: delegate.getDisplayLength(of: gameObject.boundingBox.width),
            height: delegate.getDisplayLength(of: gameObject.boundingBox.height)
        )
    }

    var alpha: Double {
        gameObject.isConcrete ? opaqueAlpha : translucentAlpha
    }

    private var shapeCenterInView: CGVector {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        let pegCenterRelativeToBoundingBox = CGVector.getPositionVector(of: gameObject.centerRelativeToBoundingBox)
        return delegate.getDisplayVector(of: pegCenterRelativeToBoundingBox)
    }

    var drawableVertices: [CGPoint] {
        guard let polygon = gameObject.shape as? TransformablePolygon else {
            return []
        }

        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        let vertices = polygon.verticesRelativeToOwnCenter.map { point in
            delegate.getDisplayCoords(of: point).translate(
                offset: shapeCenterInView
            )
        }
        return vertices
    }
}
