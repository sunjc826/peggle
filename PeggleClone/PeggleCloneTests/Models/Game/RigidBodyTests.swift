//
//  RigidBodyTests.swift
//  PeggleCloneTests
//
//  Created by Jia Cheng Sun on 13/2/22.
//

import XCTest
@testable import PeggleClone

class RigidBodyTests: XCTestCase {
    var rigidBody: RigidBody!

    override func setUpWithError() throws {
        try super.setUpWithError()

        let circle = CircleObject(
            center: CGPoint.zero,
            radiusBeforeTransform: 3
        )

        let physicalProperties = PhysicalProperties(
            backingShape: circle,
            uniformDensity: 1.2,
            elasticity: 0.3
        )

        let configuration = ConfigurationForPhysicsEngine(
            canTranslate: true,
            canRotate: true,
            leftWallBehavior: .collide,
            rightWallBehavior: .fallThrough,
            topWallBehavior: .wrapAround,
            bottomWallBehavior: .fallThrough
        )

        let longTermDelta = LongTermDelta(
            linearVelocity: CGVector(dx: 1, dy: 2),
            angularVelocity: 0,
            persistentForces: []
        )

        rigidBody = RigidBody(
            physicalProperties: physicalProperties,
            associatedEntity: nil,
            configuration: configuration,
            longTermDelta: longTermDelta
        )

        rigidBody.instantaneousDelta.force = CGVector(dx: 1, dy: 2)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        rigidBody = nil
    }

    func testInitWithInstance_valuesCopied() {
        let copy = RigidBody(instance: rigidBody)

        XCTAssertEqual(copy.physicalProperties.mass, rigidBody.physicalProperties.mass)
        XCTAssertEqual(copy.physicalProperties.uniformDensity, rigidBody.physicalProperties.uniformDensity)
        XCTAssertEqual(copy.physicalProperties.elasticity, rigidBody.physicalProperties.elasticity)
        XCTAssertEqual(copy.configuration.canTranslate, rigidBody.configuration.canTranslate)
        XCTAssertEqual(copy.configuration.canRotate, rigidBody.configuration.canRotate)
        XCTAssertEqual(copy.configuration.leftWallBehavior, rigidBody.configuration.leftWallBehavior)
        XCTAssertEqual(copy.configuration.rightWallBehavior, rigidBody.configuration.rightWallBehavior)
        XCTAssertEqual(copy.configuration.topWallBehavior, rigidBody.configuration.topWallBehavior)
        XCTAssertEqual(copy.configuration.bottomWallBehavior, rigidBody.configuration.bottomWallBehavior)
        XCTAssertEqual(copy.longTermDelta.linearVelocity, rigidBody.longTermDelta.linearVelocity)
        XCTAssertEqual(copy.longTermDelta.angularVelocity, rigidBody.longTermDelta.angularVelocity)
    }

    func testInitWithInstance_instantaneousValuesNotCopied() {
        let copy = RigidBody(instance: rigidBody)

        XCTAssertNotEqual(copy.instantaneousDelta.force, rigidBody.instantaneousDelta.force)
    }

}
