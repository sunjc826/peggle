import Foundation
import CoreGraphics

protocol Polygon: Shape {
    var vertices: [CGPoint] { get }
    var sides: Int { get }
}

extension Polygon {
    var area: Double {
        assert(sides > 2)
        let vertices = vertices
        var area: Double = 0
        for i in 0..<sides {
            let firstVertex = vertices[i]
            let secondVertex = vertices[(i + 1) % sides]
            area += CGVector.crossProductSignedMagnitude(
                vector: CGVector.getPositionVector(of: firstVertex),
                otherVector: CGVector.getPositionVector(of: secondVertex))
        }
        area /= 2
        return area
    }

    var centroid: CGPoint {
        assert(sides > 2)
        var centroid = CGVector.zero
        let vertices = vertices
        for i in 0..<sides {
            let firstVertex = vertices[i]
            let secondVertex = vertices[(i + 1) % sides]
            let crossProductSignedMagnitude = CGVector.crossProductSignedMagnitude(
                vector: CGVector.getPositionVector(of: firstVertex),
                otherVector: CGVector.getPositionVector(of: secondVertex))
            let translation = CGVector(
                dx: firstVertex.x + secondVertex.x,
                dy: firstVertex.y + secondVertex.y
            ).scaleBy(factor: crossProductSignedMagnitude)
            centroid = centroid.translate(offset: translation)
        }
        centroid = centroid.scaleBy(factor: 1 / (6 * area))
        return CGPoint.fromVector(vector: centroid)
    }

    // reference: https://en.wikipedia.org/wiki/Second_moment_of_area#Any_cross_section_defined_as_polygon
    var areaMomentOfInertia: Double {
        let vertices = vertices
        var inertia = 0.0
        for i in 0..<sides {
            let firstVertex = vertices[i]
            let secondVertex = vertices[(i + 1) % sides]
            let crossProductSignedMagnitude = CGVector.crossProductSignedMagnitude(
                vector: CGVector.getPositionVector(of: firstVertex),
                otherVector: CGVector.getPositionVector(of: secondVertex))

            let subSum = firstVertex.x * firstVertex.x +
                firstVertex.x * secondVertex.x +
                secondVertex.x * secondVertex.x +
                firstVertex.y * firstVertex.y +
                firstVertex.y * secondVertex.y +
                secondVertex.y * secondVertex.y

            inertia += subSum * crossProductSignedMagnitude
        }

        inertia /= 12
        return inertia
    }
}

extension Polygon {
    func getPolygon() -> PolygonObject {
        assert(sides > 2)
        return PolygonObject(vertices: vertices, sides: sides)
    }
}
