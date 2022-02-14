import Foundation

class PersistablePlayArea: Codable {
    let width: Double
    let height: Double
    let cannonZoneHeight: Double

    init(width: Double, height: Double, cannonZoneHeight: Double) {
        self.width = width
        self.height = height
        self.cannonZoneHeight = cannonZoneHeight
    }

    enum CodingKeys: String, CodingKey {
        case width
        case height
        case cannonZoneHeight
    }
}
