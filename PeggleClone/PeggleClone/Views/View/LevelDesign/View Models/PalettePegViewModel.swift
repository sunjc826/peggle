import UIKit
import Combine

private let opaqueAlpha = 1.0
private let translucentAlpha = 0.5

protocol PalettePegViewModelDelegate: AnyObject {
    func toggleSelectInPalette(peg: Peg)
}

class PalettePegViewModel: AbstractPegViewModel {
    weak var delegate: PalettePegViewModelDelegate?

    var peg: Peg
    @Published var isSelected = false
    @Published var alpha: Double = translucentAlpha

    private var subscriptions: Set<AnyCancellable> = []

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
        setupBindings()
    }

    private func setupBindings() {
        $isSelected.sink { [weak self] val in
            self?.alpha = val ? opaqueAlpha : translucentAlpha
        }
        .store(in: &subscriptions)
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

    func toggleSelectInPalette() {
        delegate?.toggleSelectInPalette(peg: peg)
    }
}
