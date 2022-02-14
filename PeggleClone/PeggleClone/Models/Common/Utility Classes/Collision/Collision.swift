import Foundation
import CoreGraphics
// reference: A bunch of online tutorials and codebases,
// one of which is
// https://github.com/twobitcoder101/FlatPhysics/blob/main/Collisions.cs

let dataWhenNoCollision = CollisionData(
    isColliding: false,
    normalizedNormalOfIntersection: CGVector.zero,
    depthOfIntersectionAlongNormal: 0,
    penetrationPoint: nil
)

/// Handles collision detection and resolution related functionalities
struct Collision {
    struct ProjectionOverlapData {
        let areProjectionsDisjoint: Bool
        let projectionOverlap: Double
        let penetrationPoint: CGPoint?
    }
    static let dataWhenNoProjectionOverlap = ProjectionOverlapData(
        areProjectionsDisjoint: true,
        projectionOverlap: 0,
        penetrationPoint: nil
    )
}

// MARK: Shared helpers
extension Collision {
    func getNormalizedNormalOfEdge(from: CGPoint, to: CGPoint) -> CGVector {
        let edge = CGVector(from: from, to: to)
        let normal = edge.getNormalizedNormal()
        return normal
    }

    /// Returns the vertex from `toVertices` that is the closest to getClosestPoint
    func getClosestPoint(fromVertex: CGPoint, candidates: [CGPoint]) -> CGPoint {
        guard let closestPoint = candidates.min(by: {
            $0.distanceTo(point: fromVertex) > $1.distanceTo(point: fromVertex)
        }) else {
            fatalError("candidates should be non-empty")
        }
        return closestPoint
    }

    func getMinMaxProjection(vertices: [CGPoint], projectingOnto: CGVector)
    -> (minimum: Double, maximum: Double) {
        var minimum = Double.infinity
        var maximum = -Double.infinity

        for vertex in vertices {
            let projection = projectingOnto.getProjectionOntoSelf(vector: CGVector.getPositionVector(of: vertex))
            minimum = min(minimum, projection)
            maximum = max(maximum, projection)
        }
        return (minimum, maximum)
    }

    func getMinMaxProjection(circle: Circle, projectingOnto: CGVector)
    -> (minimum: Double, maximum: Double) {
        let directionWithRadius = projectingOnto.scaleTo(length: circle.radius)

        let firstExtremeOfCircle = CGVector.getPositionVector(of: circle.center.translate(offset: directionWithRadius))
        let secondExtremeOfCircle = CGVector.getPositionVector(
            of: circle.center.translate(offset: directionWithRadius.reverse())
        )

        let firstExtremeOfProjection = projectingOnto.getProjectionOntoSelf(vector: firstExtremeOfCircle)
        let secondExtremeOfProjection = projectingOnto.getProjectionOntoSelf(vector: secondExtremeOfCircle)

        let minimum = min(firstExtremeOfProjection, secondExtremeOfProjection)
        let maximum = max(firstExtremeOfProjection, secondExtremeOfProjection)
        return (minimum, maximum)
    }
}
