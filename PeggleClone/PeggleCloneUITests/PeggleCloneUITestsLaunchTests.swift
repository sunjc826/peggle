//
//  PeggleCloneUITestsLaunchTests.swift
//  PeggleCloneUITests
//
//  Created by Jia Cheng on 19/1/22.
//

import XCTest

class PeggleCloneUITestsLaunchTests: XCTestCase {

    // This is autogenerated.
    // swiftlint:disable empty_xctest_method
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }
    // swiftlint:enable empty_xctest_method

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
