import Foundation
import CoreGraphics

/// Note: With respect to logical coords, height is always 1, width is aspectRatio.
/// aspectRatio == displayWidth / displayHeight == logicalWidth / logicalHeight
class CoordinateMapper {
    /// True width divided by true height.
    var aspectRatio: Double
    var displayWidth: Double
    var displayHeight: Double
    var scalingFactor: Double
    var inverseScalingFactor: Double

    init(aspectRatio: Double, displayWidth: Double, displayHeight: Double) {
        self.aspectRatio = aspectRatio
        let displayAspectRatio = displayWidth / displayHeight
        let actualDisplayWidth: Double
        let actualDisplayHeight: Double
        if displayAspectRatio < aspectRatio { // vertical letterbox
            actualDisplayWidth = displayWidth
            actualDisplayHeight = displayWidth / aspectRatio
        } else if displayAspectRatio > aspectRatio { // horizontal letterbox
            actualDisplayWidth = aspectRatio * displayHeight
            actualDisplayHeight = displayHeight
        } else { // no letterbox needed
            actualDisplayWidth = displayWidth
            actualDisplayHeight = displayHeight
        }
        self.displayWidth = actualDisplayWidth
        self.displayHeight = actualDisplayHeight
        self.scalingFactor = actualDisplayHeight
        self.inverseScalingFactor = 1 / scalingFactor
    }

    convenience init(width: Double, height: Double, displayWidth: Double, displayHeight: Double) {
        self.init(aspectRatio: width / height, displayWidth: displayWidth, displayHeight: displayHeight)
    }

    func getDisplayCoords(ofLogicalCoords logicalCoords: CGPoint) -> CGPoint {
        logicalCoords.scaleAboutOrigin(factor: scalingFactor)
    }

    func getLogicalCoords(ofDisplayCoords displayCoords: CGPoint) -> CGPoint {
        displayCoords.scaleAboutOrigin(factor: inverseScalingFactor)
    }

    func getDisplayVector(ofLogicalVector logicalVector: CGVector) -> CGVector {
        logicalVector.scaleBy(factor: scalingFactor)
    }

    func getLogicalVector(ofDisplayVector displayVector: CGVector) -> CGVector {
        displayVector.scaleBy(factor: inverseScalingFactor)
    }

    func getDisplayLength(ofLogicalLength logicalLength: Double) -> Double {
        scalingFactor * logicalLength
    }

    func getLogicalLength(ofDisplayLength displayLength: Double) -> Double {
        displayLength / scalingFactor
    }
}

extension CoordinateMapper {
    convenience init(playArea: PersistablePlayArea, displayWidth: Double, displayHeight: Double) {
        self.init(
            width: playArea.width,
            height: playArea.height,
            displayWidth: displayWidth,
            displayHeight: displayHeight
        )
    }

    func getPlayArea() -> PlayArea {
        PlayArea(width: aspectRatio, height: 1, cannonZoneHeight: GameLevel.cannonZoneHeight)
    }
}
