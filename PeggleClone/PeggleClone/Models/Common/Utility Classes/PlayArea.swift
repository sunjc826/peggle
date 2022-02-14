import Foundation
import CoreGraphics

/// Encapsulates the rectangular container that the peggle game takes place in.
/// Is responsible for storing the mapping between logical game coordinates and display coordinates.
public final class PlayArea: HasBoundingBox {
    let width: Double
    let height: Double
    let cannonZoneHeight: Double

    init(
        width: Double,
        height: Double,
        cannonZoneHeight: Double
    ) {
        self.width = width
        self.height = height
        self.cannonZoneHeight = cannonZoneHeight
    }

    var boundingBox: BoundingBox {
        BoundingBox(topLeft: CGPoint.zero, width: width, height: height)
    }

    var pegZoneBoundingBox: BoundingBox {
        BoundingBox(topLeft: CGPoint(x: 0, y: cannonZoneHeight),
                    width: width,
                    height: height - cannonZoneHeight)
    }

    /// Returns whether the given `entity` is non-strictly within the PlayArea.
    func containsEntity(entity: HasBoundingBox) -> Bool {
        boundingBox.contains(boundingBox: entity.boundingBox)
    }

    /// Returns whether the given `entity` is non-strictly within the peg zone.
    func pegZoneContainsEntity(entity: HasBoundingBox) -> Bool {
        pegZoneBoundingBox.contains(boundingBox: entity.boundingBox)
    }

    /// Returns whether the given `entity` is strictly within the PlayArea.
    func containsEntityStrictly(entity: HasBoundingBox) -> Bool {
        boundingBox.containsStrictly(boundingBox: entity.boundingBox)
    }

    /// Returns whether the given `entity` is strictly within the peg zone.
    func pegZoneContainsEntityStrictly(entity: HasBoundingBox) -> Bool {
        pegZoneBoundingBox.containsStrictly(boundingBox: entity.boundingBox)
    }
}

extension PlayArea {
    var center: CGPoint {
        boundingBox.center
    }
}

extension PlayArea: Equatable {
    public static func == (lhs: PlayArea, rhs: PlayArea) -> Bool {
        lhs.width == rhs.width && lhs.height == rhs.height
    }
}

extension PlayArea: CustomDebugStringConvertible {
    public var debugDescription: String {
        boundingBox.debugDescription
    }
}

// MARK: Persistable
extension PlayArea {
    func toPersistable() -> PersistablePlayArea {
        PersistablePlayArea(width: width, height: height, cannonZoneHeight: cannonZoneHeight)
    }

    static func fromPersistable(persistableArea: PersistablePlayArea) -> PlayArea {
        PlayArea(
            width: persistableArea.width,
            height: persistableArea.height,
            cannonZoneHeight: persistableArea.cannonZoneHeight
        )
    }
}
