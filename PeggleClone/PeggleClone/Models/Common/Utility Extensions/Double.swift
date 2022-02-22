import Foundation

extension Double {

    /// A generalization of the modulus operation, usally denoted "A mod B",
    /// between an integer A and a non-zero integer B.
    ///
    /// - Parameter range: The numerical range, [0, range) that the result is to be capped to.
    /// - Returns: A number congruent to the `self` with respect to `range`.
    /// - Warning: `range` must be positive
    func generalizedMod(within range: Double) -> Double {
        assert(range > 0, "range must be positive")
        var val = self
        while val >= range {
            val -= range
        }

        while val < 0 {
            val += range
        }

        assert(0 <= val && val < range)
        return val
    }

    func toRadians() -> Double {
        self / 180 * Double.pi
    }
}
