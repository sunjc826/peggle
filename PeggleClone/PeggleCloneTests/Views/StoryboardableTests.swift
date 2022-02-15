//
//  StoryboardableTests.swift
//  PeggleCloneTests
//
//  Created by Jia Cheng Sun on 11/2/22.
//

import XCTest
@testable import PeggleClone

class StoryboardableTests: XCTestCase {

    func testDesignerMainViewControllerInstantiate() {
        _ = DesignerMainViewController.instantiate()
    }

    func testLevelSelectViewControllerInstantiate() {
        _ = LevelSelectCollectionViewController.instantiate()
    }

    func testGameViewControllerInstantiate() {
        _ = GameViewController.instantiate()
    }
}
