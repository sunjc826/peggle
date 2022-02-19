import Foundation

final class PersistableCoordinateMapper: Codable {
    var logicalWidth: Double
    var logicalHeight: Double
    init(logicalWidth: Double, logicalHeight: Double) {
        self.logicalWidth = logicalWidth
        self.logicalHeight = logicalHeight
    }

    private enum CodingKeys: String, CodingKey {
        case logicalWidth
        case logicalHeight
    }
}
