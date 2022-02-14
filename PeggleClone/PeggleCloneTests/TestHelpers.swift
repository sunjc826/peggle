import Foundation
func doubleEqual(_ a: Double, _ b: Double) -> Bool {
    fabs(a - b) < floatingPointAccuracy
}
