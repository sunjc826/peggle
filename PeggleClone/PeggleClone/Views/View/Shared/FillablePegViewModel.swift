import UIKit

/// Represents a peg that fills its outer container, regardless of the underlying dimensions of the peg model.
class FillablePegViewModel: AbstractPegViewModel {
    @Published var peg: Peg

    var frame: CGRect {
        CGRect(rectangle: peg.boundingBox)
    }

    var shapeCenterInView: CGVector {
        CGVector.getPositionVector(of: peg.centerRelativeToBoundingBox)
    }

    var drawableVertices: [CGPoint] {
        guard let polygon = peg.shape as? TransformablePolygon else {
            return []
        }

        let vertices = polygon.verticesRelativeToOwnCenter.map { point in
            point.translate(
                offset: shapeCenterInView
            )
        }
        return vertices
    }

    init(peg: Peg) {
        self.peg = peg
    }

    func getDrawableVerticesToFill(rect: CGRect) -> [CGPoint] {
        guard let polygon = peg.shape as? TransformablePolygon else {
            return []
        }
        let boundingBox = peg.boundingBox
        let boundingBoxWidth = boundingBox.width
        let boundingBoxHeight = boundingBox.height
        let centerRelativeToBoundingBox = peg.centerRelativeToBoundingBox
        let centerRelativeToRect = centerRelativeToBoundingBox.scaleAboutOrigin(
            factorX: rect.width / boundingBoxWidth,
            factorY: rect.height / boundingBoxHeight
        )

        func scalePositionVectorToFitRect(point: CGPoint) -> CGPoint {
            point.scaleAboutOrigin(
                factorX: rect.width / boundingBoxWidth,
                factorY: rect.height / boundingBoxHeight
            )
        }

        func translatePositionVector(point: CGPoint) -> CGPoint {
            point.translate(offset: CGVector.getPositionVector(of: centerRelativeToRect))
        }

        let vertices = polygon.verticesRelativeToOwnCenter.map { point in
            translatePositionVector(point: scalePositionVectorToFitRect(point: point))
        }
        return vertices
    }
}
