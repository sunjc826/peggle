import UIKit
import Combine

private let opaqueAlpha = 1.0
private let translucentAlpha = 0.7

protocol CoordinateMappablePegViewModelDelegate: AnyObject, CoordinateMappable {}

class CoordinateMappablePegViewModel: AbstractPegViewModel {
    weak var delegate: CoordinateMappablePegViewModelDelegate?

    var peg: Peg

    var displayCoords: CGPoint {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        return delegate.getDisplayCoords(of: peg.boundingBox.center)
    }

    var displayFrame: CGRect {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        return CGRect(
            x: 0,
            y: 0,
            width: delegate.getDisplayLength(of: peg.boundingBox.width),
            height: delegate.getDisplayLength(of: peg.boundingBox.height)
        )
    }

    var alpha: Double {
        peg.isConcrete ? opaqueAlpha : translucentAlpha
    }

    private var shapeCenterInView: CGVector {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        let pegCenterRelativeToBoundingBox = CGVector.getPositionVector(of: peg.centerRelativeToBoundingBox)
        return delegate.getDisplayVector(of: pegCenterRelativeToBoundingBox)
    }

    var drawableVertices: [CGPoint] {
        guard let polygon = peg.shape as? TransformablePolygon else {
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

    init(peg: Peg) {
        self.peg = peg
    }
}
