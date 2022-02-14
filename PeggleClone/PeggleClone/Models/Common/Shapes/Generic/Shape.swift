import Foundation
protocol Shape: AnyObject {
    var area: Double { get }
    var areaMomentOfInertia: Double { get }
    var sides: Int { get }
}
