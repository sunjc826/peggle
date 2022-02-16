import UIKit

protocol AbstractFillableGameObjectViewModel {
    var gameObject: GameObject { get }
    var frame: CGRect { get }
    var shapeCenterInView: CGVector { get }
    var drawableVertices: [CGPoint] { get }
    func getDrawableVerticesToFill(rect: CGRect) -> [CGPoint]
}

extension AbstractFillableGameObjectViewModel {
    var frame: CGRect {
        CGRect(rectangle: gameObject.boundingBox)
    }

    var shapeCenterInView: CGVector {
        CGVector.getPositionVector(of: gameObject.centerRelativeToBoundingBox)
    }

    var drawableVertices: [CGPoint] {
        guard let polygon = gameObject.shape as? TransformablePolygon else {
            return []
        }

        let vertices = polygon.verticesRelativeToOwnCenter.map { point in
            point.translate(
                offset: shapeCenterInView
            )
        }
        return vertices
    }
    
    func getDrawableVerticesToFill(rect: CGRect) -> [CGPoint] {
        guard let polygon = gameObject.shape as? TransformablePolygon else {
            return []
        }
        let boundingBox = gameObject.boundingBox
        let boundingBoxWidth = boundingBox.width
        let boundingBoxHeight = boundingBox.height
        let centerRelativeToBoundingBox = gameObject.centerRelativeToBoundingBox
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
