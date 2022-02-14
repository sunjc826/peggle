import Foundation
import CoreGraphics

final class PolygonObject: Polygon, Codable {
    var vertices: [CGPoint]
    var sides: Int

    init(vertices: [CGPoint], sides: Int) {
        self.vertices = vertices
        self.sides = sides
    }

    required convenience init(instance: PolygonObject) {
        self.init(vertices: instance.vertices, sides: instance.sides)
    }
}
