import Foundation
import CoreGraphics

/// Note: With respect to logical coords, width is aspectRatio, height is some real number >= 1, where
/// 1 represents the size of the viewable area. So, if the level is expanded to be strictly higher than a screen,
/// height will also be strictly greater than 1.
/// aspectRatio == displayWidth / displayHeight == logicalWidth / 1
class CoordinateMapper {
    /// True width divided by true height.
    var aspectRatio: Double
    var logicalWidth: Double {
        aspectRatio
    }
    var logicalHeight: Double = 1
    /// Display dimensions of the viewable area.
    var onScreenDisplayWidth: Double
    var onScreenDisplayHeight: Double

    var displayWidth: Double {
        logicalWidth * scalingFactor
    }
    var displayHeight: Double {
        logicalHeight * scalingFactor
    }
    var scalingFactor: Double
    var inverseScalingFactor: Double

    init(aspectRatio: Double, onScreenDisplayWidth: Double, onScreenDisplayHeight: Double) {
        self.aspectRatio = aspectRatio
        let displayAspectRatio = onScreenDisplayWidth / onScreenDisplayHeight
        let actualDisplayWidth: Double
        let actualDisplayHeight: Double
        if displayAspectRatio < aspectRatio { // vertical letterbox
            actualDisplayWidth = onScreenDisplayWidth
            actualDisplayHeight = onScreenDisplayWidth / aspectRatio
        } else if displayAspectRatio > aspectRatio { // horizontal letterbox
            actualDisplayWidth = aspectRatio * onScreenDisplayHeight
            actualDisplayHeight = onScreenDisplayHeight
        } else { // no letterbox needed
            actualDisplayWidth = onScreenDisplayWidth
            actualDisplayHeight = onScreenDisplayHeight
        }
        self.onScreenDisplayWidth = actualDisplayWidth
        self.onScreenDisplayHeight = actualDisplayHeight
        self.scalingFactor = actualDisplayHeight
        self.inverseScalingFactor = 1 / scalingFactor
    }

    /// - Parameters:
    ///   - targetDisplayWidth: The intended display width of the game when played on this device.
    ///   - targetDisplayHeight: The intended display height of the game when played on this device.
    ///   - onScreenDisplayWidth: The on screen display width of a view in which to render the game.
    ///   - onScreenDisplayHeight: The on screen display height of an arbitrary view in which to render the game.
    /// - Remark: This constructor is used in the designer view.
    /// The target display dimensions are that of the entire screen,
    /// since the game is to take up the entire screen space when played.
    /// However, the designer view has other stuff, like a palette and persistence menu.
    /// As a result, the designer view of the game cannot take up the entire screen.
    /// Hence, onScreenDisplay dimensions give the maximum available screen space with that can hold the level view.
    /// The CoordinateMapper is then responsible for resizing the on screen display dimensions
    /// to fit the target display dimensions. The remaining part of the maximum available screen space unused,
    /// due to differing aspect ratios, can then be letterboxed.
    convenience init(
        targetDisplayWidth: Double,
        targetDisplayHeight: Double,
        onScreenDisplayWidth: Double,
        onScreenDisplayHeight: Double
    ) {
        self.init(
            aspectRatio: targetDisplayWidth / targetDisplayHeight,
            onScreenDisplayWidth: onScreenDisplayWidth,
            onScreenDisplayHeight: onScreenDisplayHeight
        )
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
    func getPlayArea() -> PlayArea {
        PlayArea(
            width: logicalWidth,
            height: logicalHeight,
            cannonZoneHeight: Settings.Cannon.yDistanceFromTopOfPlayArea + Settings.Cannon.height,
            bucketZoneHeight: Settings.Bucket.ydistanceFromBottomOfPlayArea + Settings.Bucket.height
        )
    }
}

struct CoordinateMapperConfigurable {
    var onScreenDisplayWidth: Double
    var onScreenDisplayHeight: Double
}

extension CoordinateMapper {
    func getConfigurable() -> CoordinateMapperConfigurable {
        CoordinateMapperConfigurable(
            onScreenDisplayWidth: onScreenDisplayWidth,
            onScreenDisplayHeight: onScreenDisplayHeight
        )
    }

    func toPersistable() -> PersistableCoordinateMapper {
        PersistableCoordinateMapper(
            logicalWidth: logicalWidth,
            logicalHeight: logicalHeight
        )
    }

    static func fromPersistable(
        persistableCoordinateMapper: PersistableCoordinateMapper,
        coordinateMapperConfigurable: CoordinateMapperConfigurable
    ) -> CoordinateMapper {
        let coordinateMapper = CoordinateMapper(
            aspectRatio: persistableCoordinateMapper.logicalWidth,
            onScreenDisplayWidth: coordinateMapperConfigurable.onScreenDisplayWidth,
            onScreenDisplayHeight: coordinateMapperConfigurable.onScreenDisplayHeight
        )
        coordinateMapper.logicalHeight = persistableCoordinateMapper.logicalHeight
        return coordinateMapper
    }
}
