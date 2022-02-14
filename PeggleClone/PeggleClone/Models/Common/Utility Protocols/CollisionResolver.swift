import Foundation
import CoreGraphics

struct CollisionData {
    /// Whether given shapes are colliding.
    let isColliding: Bool

    /// Normal in which intersection takes place, relative to the first shape.
    /// - warning: By convention, even if the normal belongs to the second shape,
    /// it will be expressed relative to the first shape, for instance, it can be reversed.
    let normalizedNormalOfIntersection: CGVector

    let depthOfIntersectionAlongNormal: Double

    let penetrationPoint: CGPoint?
}

protocol CollisionResolver {
    func getCollisionData(circle: Circle, otherCircle: Circle) -> CollisionData
    func getCollisionData(circle: Circle, convexPolygon: CenteredPolygon) -> CollisionData
    func getCollisionData(convexPolygon: CenteredPolygon, circle: Circle) -> CollisionData
    func getCollisionData(convexPolygon: CenteredPolygon, otherConvexPolygon: CenteredPolygon) -> CollisionData
}
