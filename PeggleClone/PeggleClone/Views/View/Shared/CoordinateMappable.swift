import Foundation
import CoreGraphics

protocol CoordinateMappable {
    func getDisplayCoords(of logicalCoords: CGPoint) -> CGPoint
    func getDisplayVector(of logicalVector: CGVector) -> CGVector
    func getDisplayLength(of logicalLength: Double) -> Double
}
