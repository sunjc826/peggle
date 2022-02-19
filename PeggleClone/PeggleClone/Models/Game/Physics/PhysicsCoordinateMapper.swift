import Foundation
import CoreGraphics

class PhysicsCoordinateMapper: CoordinateMapper {
    var physicalScalingFactor: Double
    var inversePhysicalScalingFactor: Double

    init(
        aspectRatio: Double,
        onScreenDisplayWidth: Double,
        onScreenDisplayHeight: Double,
        physicalScale: Double
    ) {
        physicalScalingFactor = physicalScale
        inversePhysicalScalingFactor = 1 / physicalScale
        super.init(
            aspectRatio: aspectRatio,
            onScreenDisplayWidth: onScreenDisplayWidth,
            onScreenDisplayHeight: onScreenDisplayHeight
        )
    }

    convenience init(
        onScreenDisplayWidth: Double,
        onScreenDisplayHeight: Double,
        physicalScale: Double
    ) {
        self.init(
            aspectRatio: onScreenDisplayWidth / onScreenDisplayHeight,
            onScreenDisplayWidth: onScreenDisplayWidth,
            onScreenDisplayHeight: onScreenDisplayHeight,
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

    func getPhysicalLength(ofLogicalLength logicalLength: Double) -> Double {
        logicalLength * physicalScalingFactor
    }

    func getLogicalLength(ofPhysicalLength physicalLength: Double) -> Double {
        physicalLength * inversePhysicalScalingFactor
    }
}

struct PhysicsCoordinateMapperConfigurable {
    var onScreenDisplayWidth: Double
    var onScreenDisplayHeight: Double
    var physicalScale: Double
}

extension PhysicsCoordinateMapper {
    func getPhysicsConfigurable() -> PhysicsCoordinateMapperConfigurable {
        PhysicsCoordinateMapperConfigurable(
            onScreenDisplayWidth: onScreenDisplayWidth,
            onScreenDisplayHeight: onScreenDisplayHeight,
            physicalScale: physicalScalingFactor)
    }

    static func fromPersistable(
        persistableCoordinateMapper: PersistableCoordinateMapper,
        physicsCoordinateMapperConfigurable: PhysicsCoordinateMapperConfigurable
    ) -> PhysicsCoordinateMapper {
        let coordinateMapper = PhysicsCoordinateMapper(
            aspectRatio: persistableCoordinateMapper.logicalWidth,
            onScreenDisplayWidth: physicsCoordinateMapperConfigurable.onScreenDisplayWidth,
            onScreenDisplayHeight: physicsCoordinateMapperConfigurable.onScreenDisplayHeight,
            physicalScale: physicsCoordinateMapperConfigurable.physicalScale
        )
        coordinateMapper.logicalHeight = persistableCoordinateMapper.logicalHeight
        return coordinateMapper
    }
}
