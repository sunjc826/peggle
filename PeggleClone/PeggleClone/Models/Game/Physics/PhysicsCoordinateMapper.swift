import Foundation
import CoreGraphics

class PhysicsCoordinateMapper: CoordinateMapper {
    var physicalScalingFactor: Double
    var inversePhysicalScalingFactor: Double

    init(
        aspectRatio: Double,
        displayWidth: Double,
        displayHeight: Double,
        physicalScale: Double
    ) {
        physicalScalingFactor = physicalScale
        inversePhysicalScalingFactor = 1 / physicalScale
        super.init(
            aspectRatio: aspectRatio,
            displayWidth: displayWidth,
            displayHeight: displayHeight
        )
    }

    convenience init(
        width: Double,
        height: Double,
        displayWidth: Double,
        displayHeight: Double,
        physicalScale: Double
    ) {
        self.init(
            aspectRatio: width / height,
            displayWidth: displayWidth,
            displayHeight: displayHeight,
            physicalScale: physicalScale
        )
    }

    func getPhysicalCoords(ofLogicalCoords logicalCoords: CGPoint) -> CGPoint {
        logicalCoords.scaleAboutOrigin(factor: physicalScalingFactor)
    }

    func getLogicalCoords(ofPhysicalCoords physicalCoords: CGPoint) -> CGPoint {
        physicalCoords.scaleAboutOrigin(factor: inversePhysicalScalingFactor)
    }

    func getPhysicalVector(ofLogicalVector logicalVector: CGVector) -> CGVector {
        logicalVector.scaleBy(factor: physicalScalingFactor)
    }

    func getLogicalVector(ofPhysicalVector physicalVector: CGVector) -> CGVector {
        physicalVector.scaleBy(factor: inversePhysicalScalingFactor)
    }
}

extension PhysicsCoordinateMapper {
    convenience init(
        playArea: PersistablePlayArea,
        displayWidth: Double,
        displayHeight: Double,
        physicalScale: Double
    ) {
        self.init(
            width: playArea.width,
            height: playArea.height,
            displayWidth: displayWidth,
            displayHeight: displayHeight,
            physicalScale: physicalScale
        )
    }
}
