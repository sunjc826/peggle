import Foundation
import CoreGraphics

final class CenteredPolygonObject: CenteredPolygon, Codable {
    var polarVerticesRelativeToOwnCenter: [PolarCoordinate]

    var center: CGPoint

    var sides: Int

    init(center: CGPoint, polarVerticesRelativeToOwnCenter: [PolarCoordinate], sides: Int) {
        self.center = center
        self.polarVerticesRelativeToOwnCenter = polarVerticesRelativeToOwnCenter
        self.sides = sides
    }

    required convenience init(instance: CenteredPolygonObject) {
        self.init(
            center: instance.center,
            polarVerticesRelativeToOwnCenter: instance.polarVerticesRelativeToOwnCenter,
            sides: instance.sides
        )
    }
}
