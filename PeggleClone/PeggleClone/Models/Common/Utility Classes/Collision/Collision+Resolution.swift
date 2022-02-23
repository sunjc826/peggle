import Foundation
import CoreGraphics

// MARK: Methods for collision resolution
extension Collision: CollisionResolver {
    /// Returns collision info of the given circles.
    func getCollisionData(circle: Circle, otherCircle: Circle) -> CollisionData {
        let distanceOfCenters = circle.center.distanceTo(point: otherCircle.center)
        let sumOfRadius = circle.radius + otherCircle.radius

        if distanceOfCenters >= sumOfRadius {
            return dataWhenNoCollision
        }

        let normal = CGVector(from: circle.center, to: otherCircle.center).normalize()
        let depth = sumOfRadius - distanceOfCenters
        return CollisionData(
            isColliding: true,
            normalizedNormalOfIntersection: normal,
            depthOfIntersectionAlongNormal: depth,
            penetrationPoint: circle.center.translate(offset: normal.scaleTo(length: circle.radius))
        )
    }

    /// Returns collision info between the given `circle` and the given `convexPolygon`.
    func getCollisionData(circle: Circle, convexPolygon: CenteredPolygon) -> CollisionData {
        var normalOfIntersection = CGVector.zero
        var depthOfIntersectionAlongNormal = Double.infinity
        var penetrationPoint: CGPoint?
        let polygonVertices = convexPolygon.vertices
        for i in 0..<convexPolygon.sides {
            let normalOfPolygon = getNormalizedNormalOfEdge(
                from: polygonVertices[i],
                to: polygonVertices[(i + 1) % convexPolygon.sides]
            )

            let projectionData = compareProjections(
                vertexCollection: polygonVertices,
                circle: circle,
                normalAssociatedWithVertexCollection: normalOfPolygon
            )

            if projectionData.areProjectionsDisjoint {
                return dataWhenNoCollision
            }

            if projectionData.projectionOverlap < depthOfIntersectionAlongNormal {
                depthOfIntersectionAlongNormal = projectionData.projectionOverlap
                normalOfIntersection = normalOfPolygon
                penetrationPoint = projectionData.penetrationPoint
            }
        }

        let closestVertexOfPolygonToCircle = getClosestPoint(fromVertex: circle.center, candidates: polygonVertices)
        let particularNormalOfCircle = CGVector(from: circle.center, to: closestVertexOfPolygonToCircle).normalize()
        let projectionData = compareProjections(
            circle: circle,
            vertexCollection: polygonVertices,
            normalOfCircle: particularNormalOfCircle
        )

        if projectionData.areProjectionsDisjoint {
            return dataWhenNoCollision
        }

        if projectionData.projectionOverlap < depthOfIntersectionAlongNormal {
            depthOfIntersectionAlongNormal = projectionData.projectionOverlap
            normalOfIntersection = particularNormalOfCircle
            penetrationPoint = projectionData.penetrationPoint
        }

        let direction = CGVector(from: circle.center, to: convexPolygon.center)
        if CGVector.dotProduct(vector: direction, otherVector: normalOfIntersection) < 0 {
            normalOfIntersection = normalOfIntersection.reverse()
        }

        return CollisionData(
            isColliding: true,
            normalizedNormalOfIntersection: normalOfIntersection,
            depthOfIntersectionAlongNormal: depthOfIntersectionAlongNormal,
            penetrationPoint: penetrationPoint
        )
    }

    /// Returns collision info between the given `convexPolygon` and the given `circle`.
    func getCollisionData(convexPolygon: CenteredPolygon, circle: Circle) -> CollisionData {
        let collisionData = getCollisionData(circle: circle, convexPolygon: convexPolygon)
        return CollisionData(
            isColliding: collisionData.isColliding,
            normalizedNormalOfIntersection: collisionData.normalizedNormalOfIntersection.reverse(),
            depthOfIntersectionAlongNormal: collisionData.depthOfIntersectionAlongNormal,
            penetrationPoint: collisionData.penetrationPoint
        )
    }

    /// Returns collision info on the given polygons.
    func getCollisionData(convexPolygon: CenteredPolygon, otherConvexPolygon: CenteredPolygon) -> CollisionData {
        var normalOfIntersection = CGVector.zero
        var depthOfIntersectionAlongNormal = Double.infinity
        var penetrationPoint: CGPoint?

        let firstPolygonVertices = convexPolygon.vertices
        let secondPolygonVertices = otherConvexPolygon.vertices
        for i in 0..<convexPolygon.sides {
            let normal = getNormalizedNormalOfEdge(
                from: firstPolygonVertices[i],
                to: firstPolygonVertices[(i + 1) % convexPolygon.sides]
            )
            let projectionData = compareProjections(
                firstVertexCollection: firstPolygonVertices,
                secondVertexCollection: secondPolygonVertices,
                normalAssociatedWithFirstVertexCollection: normal
            )

            if projectionData.areProjectionsDisjoint {
                return dataWhenNoCollision
            }

            if projectionData.projectionOverlap < depthOfIntersectionAlongNormal {
                depthOfIntersectionAlongNormal = projectionData.projectionOverlap
                normalOfIntersection = normal.reverse()
                penetrationPoint = projectionData.penetrationPoint
            }
        }

        for i in 0..<otherConvexPolygon.sides {
            let normal = getNormalizedNormalOfEdge(
                from: secondPolygonVertices[i],
                to: secondPolygonVertices[(i + 1) % otherConvexPolygon.sides]
            )
            let projectionData = compareProjections(
                firstVertexCollection: secondPolygonVertices,
                secondVertexCollection: firstPolygonVertices,
                normalAssociatedWithFirstVertexCollection: normal
            )
            if projectionData.areProjectionsDisjoint {
                return dataWhenNoCollision
            }

            if projectionData.projectionOverlap < depthOfIntersectionAlongNormal {
                depthOfIntersectionAlongNormal = projectionData.projectionOverlap
                normalOfIntersection = normal
                penetrationPoint = projectionData.penetrationPoint
            }
        }

        let direction = CGVector(from: convexPolygon.center, to: otherConvexPolygon.center)
        if CGVector.dotProduct(vector: direction, otherVector: normalOfIntersection) < 0 {
            normalOfIntersection = normalOfIntersection.reverse()
        }

        return CollisionData(
            isColliding: true, normalizedNormalOfIntersection: normalOfIntersection,
            depthOfIntersectionAlongNormal: depthOfIntersectionAlongNormal, penetrationPoint: penetrationPoint
        )
    }
}

// MARK: Helpers for collision resolution
extension Collision {
    struct ProjectionMinMaxData {
        let minimum: Double
        let maximum: Double
        let minimumVertex: CGPoint
    }

    private func getMinMaxProjectionData(vertices: [CGPoint], projectingOnto: CGVector)
    -> ProjectionMinMaxData {
        var minimum = Double.infinity
        var maximum = -Double.infinity
        var minimumVertex = CGPoint.zero

        for vertex in vertices {
            let projection = projectingOnto.getProjectionOntoSelf(vector: CGVector.getPositionVector(of: vertex))
            if projection < minimum {
                minimum = projection
                minimumVertex = vertex
            }
            if projection > maximum {
                maximum = projection
            }
        }
        return ProjectionMinMaxData(
            minimum: minimum,
            maximum: maximum,
            minimumVertex: minimumVertex
        )
    }

    private func getMinMaxProjectionData(circle: Circle, projectingOnto: CGVector)
    -> ProjectionMinMaxData {
        let directionWithRadius = projectingOnto.scaleTo(length: circle.radius)

        let firstExtremeOfCircle = circle.center.translate(offset: directionWithRadius)
        let secondExtremeOfCircle = circle.center.translate(offset: directionWithRadius.reverse()
        )

        let firstExtremeOfProjection = projectingOnto.getProjectionOntoSelf(
            vector: CGVector.getPositionVector(of: firstExtremeOfCircle))
        let secondExtremeOfProjection = projectingOnto.getProjectionOntoSelf(
            vector: CGVector.getPositionVector(of: secondExtremeOfCircle))

        let minimum = min(firstExtremeOfProjection, secondExtremeOfProjection)
        let maximum = max(firstExtremeOfProjection, secondExtremeOfProjection)
        let minimumVertex = firstExtremeOfProjection < secondExtremeOfProjection ?
            firstExtremeOfCircle :
            secondExtremeOfCircle
        return ProjectionMinMaxData(minimum: minimum, maximum: maximum, minimumVertex: minimumVertex)
    }

    private func compareProjections(
        firstVertexCollection: [CGPoint],
        secondVertexCollection: [CGPoint],
        normalAssociatedWithFirstVertexCollection: CGVector
    ) -> ProjectionOverlapData {
        let (firstMin, firstMax) = getMinMaxProjection(
            vertices: firstVertexCollection,
            projectingOnto: normalAssociatedWithFirstVertexCollection
        )
        let projectionDataOfSecondCollection = getMinMaxProjectionData(
            vertices: secondVertexCollection,
            projectingOnto: normalAssociatedWithFirstVertexCollection
        )
        let secondMin = projectionDataOfSecondCollection.minimum
        let secondMax = projectionDataOfSecondCollection.maximum

        if firstMax <= secondMin || secondMax <= firstMin {
            return Collision.dataWhenNoProjectionOverlap
        }

        let projectionOverlap = min(secondMax - firstMin, firstMax - secondMin)
        return ProjectionOverlapData(
            areProjectionsDisjoint: false,
            projectionOverlap: projectionOverlap,
            penetrationPoint: projectionDataOfSecondCollection.minimumVertex
        )
    }

    private func compareProjections(
        circle: Circle,
        vertexCollection: [CGPoint],
        normalOfCircle: CGVector
    ) -> ProjectionOverlapData {
        let (firstMin, firstMax) = getMinMaxProjection(circle: circle, projectingOnto: normalOfCircle)
        let projectionDataOfVertexCollection = getMinMaxProjectionData(
            vertices: vertexCollection,
            projectingOnto: normalOfCircle
        )

        let secondMin = projectionDataOfVertexCollection.minimum
        let secondMax = projectionDataOfVertexCollection.maximum

        if firstMax <= secondMin || secondMax <= firstMin {
            return Collision.dataWhenNoProjectionOverlap
        }

        let projectionOverlap = min(secondMax - firstMin, firstMax - secondMin)
        return ProjectionOverlapData(
            areProjectionsDisjoint: false,
            projectionOverlap: projectionOverlap,
            penetrationPoint: projectionDataOfVertexCollection.minimumVertex
        )
    }

    private func compareProjections(
        vertexCollection: [CGPoint],
        circle: Circle,
        normalAssociatedWithVertexCollection: CGVector
    ) -> ProjectionOverlapData {
        let (firstMin, firstMax) = getMinMaxProjection(
            vertices: vertexCollection,
            projectingOnto: normalAssociatedWithVertexCollection
        )
        let projectionDataOfCircle = getMinMaxProjectionData(
            circle: circle,
            projectingOnto: normalAssociatedWithVertexCollection
        )
        let secondMin = projectionDataOfCircle.minimum
        let secondMax = projectionDataOfCircle.maximum

        if firstMax <= secondMin || secondMax <= firstMin {
            return Collision.dataWhenNoProjectionOverlap
        }

        let projectionOverlap = min(secondMax - firstMin, firstMax - secondMin)

        return ProjectionOverlapData(
            areProjectionsDisjoint: false,
            projectionOverlap: projectionOverlap,
            penetrationPoint: projectionDataOfCircle.minimumVertex
        )
    }
}
