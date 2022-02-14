import Foundation
import CoreGraphics

// MARK: Methods for collision detection
extension Collision: CollisionDetector {
    /// Returns whether the given circles collide.
    func isColliding(circle: Circle, otherCircle: Circle) -> Bool {
        circle.center.distanceTo(point: otherCircle.center) < circle.radius + otherCircle.radius
    }

    /// Returns whether the given `circle` is colliding with the given `convexPolygon`.
    func isColliding(circle: Circle, convexPolygon: Polygon) -> Bool {
        let polygonVertices = convexPolygon.vertices
        assert(convexPolygon.sides == polygonVertices.count)
        for i in 0..<convexPolygon.sides {
            let normalOfPolygon = getNormalizedNormalOfEdge(
                from: polygonVertices[i],
                to: polygonVertices[(i + 1) % convexPolygon.sides]
            )

            let isDisjoint = areProjectionsDisjoint(
                circle: circle,
                vertexCollection: polygonVertices,
                normal: normalOfPolygon
            )
            if isDisjoint {
                return false
            }
        }

        let closestVertexOfPolygonToCircle = getClosestPoint(fromVertex: circle.center, candidates: polygonVertices)
        let particularNormalOfCircle = CGVector(from: circle.center, to: closestVertexOfPolygonToCircle).normalize()
        let isDisjoint = areProjectionsDisjoint(
            circle: circle,
            vertexCollection: polygonVertices,
            normal: particularNormalOfCircle
        )
        if isDisjoint {
            return false
        }

        return true
    }

    /// Returns whether the given polygons collide.
    func isColliding(convexPolygon: Polygon, otherConvexPolygon: Polygon) -> Bool {
        let firstPolygonVertices = convexPolygon.vertices
        let secondPolygonVertices = otherConvexPolygon.vertices
        for i in 0..<convexPolygon.sides {
            let normal = getNormalizedNormalOfEdge(
                from: firstPolygonVertices[i],
                to: firstPolygonVertices[(i + 1) % convexPolygon.sides]
            )
            let isDisjoint = areProjectionsDisjoint(
                firstVertexCollection: firstPolygonVertices,
                secondVertexCollection: secondPolygonVertices,
                normal: normal
            )
            if isDisjoint {
                return false
            }
        }

        for i in 0..<otherConvexPolygon.sides {
            let normal = getNormalizedNormalOfEdge(
                from: secondPolygonVertices[i],
                to: secondPolygonVertices[(i + 1) % otherConvexPolygon.sides]
            )
            let isDisjoint = areProjectionsDisjoint(
                firstVertexCollection: firstPolygonVertices,
                secondVertexCollection: secondPolygonVertices,
                normal: normal
            )
            if isDisjoint {
                return false
            }
        }

        return true
    }
}

// MARK: Helpers for collision detection
extension Collision {
    private func areProjectionsDisjoint(
        firstVertexCollection: [CGPoint],
        secondVertexCollection: [CGPoint],
        normal: CGVector) -> Bool {
        let (firstMin, firstMax) = getMinMaxProjection(vertices: firstVertexCollection, projectingOnto: normal)
        let (secondMin, secondMax) = getMinMaxProjection(vertices: secondVertexCollection, projectingOnto: normal)

        if firstMax <= secondMin || secondMax <= firstMin {
            return true
        }
        return false
    }

    private func areProjectionsDisjoint(
        circle: Circle,
        vertexCollection: [CGPoint],
        normal: CGVector
    ) -> Bool {
        let (firstMin, firstMax) = getMinMaxProjection(vertices: vertexCollection, projectingOnto: normal)
        let (secondMin, secondMax) = getMinMaxProjection(circle: circle, projectingOnto: normal)

        if firstMax <= secondMin || secondMax <= firstMin {
            return true
        }
        return false
    }
}
