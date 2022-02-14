import XCTest
@testable import PeggleClone

class ClosedRangeTests: XCTestCase {

    var integerRange: ClosedRange<Int>!
    var doubleRange: ClosedRange<Double>!
    override func setUpWithError() throws {
        try super.setUpWithError()

        integerRange = 3...5
        doubleRange = 2.9...4.8
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        integerRange = nil
        doubleRange = nil
    }

    func testRestrictToRange_withinRange_noChangeInValue() {
        let integerInRange = 4
        let doubleInRange = 3.5

        XCTAssertEqual(integerRange.restrictToRange(integerInRange), integerInRange)
        XCTAssertEqual(doubleRange.restrictToRange(doubleInRange), doubleInRange)
    }

    func testRestrictToRange_aboveUpperBound_valueCappedToUpperBound() {
        let integerAboveUpperBound = 10
        let doubleAboveUpperBound = 9.8

        XCTAssertEqual(integerRange.restrictToRange(integerAboveUpperBound), integerRange.upperBound)
        XCTAssertEqual(doubleRange.restrictToRange(doubleAboveUpperBound), doubleRange.upperBound)
    }

    func testRestrictToRange_belowLowerBound_valueRaisedToLowerBound() {
        let integerBelowLowerBound = -1
        let doubleBelowLowerBound = 0.1

        XCTAssertEqual(integerRange.restrictToRange(integerBelowLowerBound), integerRange.lowerBound)
        XCTAssertEqual(doubleRange.restrictToRange(doubleBelowLowerBound), doubleRange.lowerBound)
    }
}
