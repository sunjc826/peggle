//
//  RigidBodyTests.swift
//  PeggleCloneTests
//
//  Created by Jia Cheng Sun on 13/2/22.
//

import XCTest
@testable import PeggleClone

class RigidBodyTests: XCTestCase {
    var rigidBody: RigidBodyObject!

    override func setUpWithError() throws {
        try super.setUpWithError()

        let circle = CircleObject(
            center: CGPoint.zero,
            radiusBeforeTransform: 3
        )

        rigidBody = RigidBodyObject(
            backingShape: circle,
            associatedEntity: nil,
            isAffectedByGlobalForces: true,
            canTranslate: true,
            canRotate: true,
            leftWallBehavior: .collide,
            rightWallBehavior: .fallThrough,
            topWallBehavior: .wrapAround,
            bottomWallBehavior: .fallThrough,
            uniformDensity: 1.0,
            elasticity: 1.0,
            initialVelocity: CGVector.zero,
            consecutiveCollisionCount: 0
        )
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        rigidBody = nil
    }

    func testInitWithInstance_valuesCopied() {
        let copy = RigidBodyObject(instance: rigidBody)

        XCTAssert(copy.backingShape is Circle)
        XCTAssertEqual(copy.center, rigidBody.center)
        XCTAssertEqual(copy.linearVelocity, rigidBody.linearVelocity)
        XCTAssertEqual(copy.angularVelocity, rigidBody.angularVelocity)
        XCTAssertEqual(copy.canTranslate, rigidBody.canTranslate)
        XCTAssertEqual(copy.canRotate, rigidBody.canRotate)
        XCTAssertEqual(copy.leftWallBehavior, rigidBody.leftWallBehavior)
        XCTAssertEqual(copy.rightWallBehavior, rigidBody.rightWallBehavior)
        XCTAssertEqual(copy.topWallBehavior, rigidBody.topWallBehavior)
        XCTAssertEqual(copy.bottomWallBehavior, rigidBody.bottomWallBehavior)
        XCTAssertEqual(copy.uniformDensity, rigidBody.uniformDensity)
        XCTAssertEqual(copy.elasticity, rigidBody.elasticity)
        XCTAssertEqual(copy.consecutiveCollisionCount, rigidBody.consecutiveCollisionCount)
    }

    func testWithPositionAndLinearVelocity_valuesChanged() {
        let changedRigidBody = rigidBody.withPositionAndLinearVelocity(
            position: CGPoint(x: 1, y: 2), linearVelocity: CGVector(dx: 0, dy: 2)
        )

        XCTAssertEqual(changedRigidBody.center, CGPoint(x: 1, y: 2))
        XCTAssertEqual(changedRigidBody.linearVelocity, CGVector(dx: 0, dy: 2))
    }

    func testWithAngleAndAngularVelocity_valuesChanged() {
        let changedRigidBody = rigidBody.withAngleAndAngularVelocity(angle: 1, angularVelocity: 0.2)

        XCTAssertEqual(changedRigidBody.rotation, 1)
        XCTAssertEqual(changedRigidBody.angularVelocity, 0.2)
    }

    func testWithConsecutiveCollisionCount_valuesChanged() {
        let changedRigidBody = rigidBody.withConsecutiveCollisionCount(count: 5)

        XCTAssertEqual(changedRigidBody.consecutiveCollisionCount, 5)
    }

}
