import Foundation

protocol CollisionDetector {
    /// Checks if 2 circles collide.
    func isColliding(circle: Circle, otherCircle: Circle) -> Bool

    /// Checks if a circle and a convex polygon collide.
    func isColliding(circle: Circle, convexPolygon: Polygon) -> Bool

    /// Checks if 2 convex polygons collide.
    func isColliding(convexPolygon: Polygon, otherConvexPolygon: Polygon) -> Bool
}
