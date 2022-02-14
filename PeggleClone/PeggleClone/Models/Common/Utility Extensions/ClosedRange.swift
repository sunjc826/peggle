import Foundation

extension ClosedRange {
    func restrictToRange(_ value: Bound) -> Bound {
        var result = value
        if result < self.lowerBound {
            result = self.lowerBound
        }

        if self.upperBound < result {
            result = self.upperBound
        }

        return result
    }
}
