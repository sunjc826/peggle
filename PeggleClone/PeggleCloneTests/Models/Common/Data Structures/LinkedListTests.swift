//
//  LinkedListTests.swift
//  PeggleCloneTests
//
//  Created by Jia Cheng on 26/1/22.
//

import XCTest
import PeggleClone

// As the main class of LinkedList was fully copied from
// a reputable source (raywenderlich), I will not write tests
// for methods not written by me.
// Instead, I will test the workings of the extensions I wrote.

class LinkedListTests: XCTestCase {
    class ReferenceObject: Equatable {
        let value: Int
        init(value: Int) {
            self.value = value
        }

        static func == (lhs: LinkedListTests.ReferenceObject, rhs: LinkedListTests.ReferenceObject) -> Bool {
            lhs.value == rhs.value
        }
    }
    var emptyLinkedList = LinkedList<Int>()
    let integerArr = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    var integerLinkedList: LinkedList<Int>!
    var referenceObjectLinkedList: LinkedList<ReferenceObject>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        emptyLinkedList = LinkedList()

        integerLinkedList = LinkedList()
        for val in integerArr {
            integerLinkedList.append(val)
        }

        referenceObjectLinkedList = LinkedList()
        for val in integerArr {
            referenceObjectLinkedList.append(ReferenceObject(value: val))
        }
    }

    func testRemoveByPredicate_emptyLinkedList_removedNothing() {
        let removed = emptyLinkedList.remove { _ in true }
        XCTAssertNil(removed)
    }

    func testRemoveByValue_valueNotPresent_removedNothing() {
        let previousSize = integerLinkedList.count
        integerLinkedList.remove(byValue: 11)
        let currentSize = integerLinkedList.count
        XCTAssertEqual(previousSize, currentSize)
    }

    func testRemoveByValue_valuePresent_success() {
        let previousSize = integerLinkedList.count
        integerLinkedList.remove(byValue: 10)
        let currentSize = integerLinkedList.count
        XCTAssertEqual(previousSize - 1, currentSize)
    }

    func testRemoveByReference_referenceNotPresent_removedNothing() {
        let referenceObject = ReferenceObject(value: 0)
        let previousSize = referenceObjectLinkedList.count
        referenceObjectLinkedList.remove(byIdentity: referenceObject)
        let currentSize = referenceObjectLinkedList.count
        XCTAssertEqual(previousSize, currentSize)
    }

    func testRemoveByReference_referencePresent_success() {
        let objectToAdd = ReferenceObject(value: 0)
        referenceObjectLinkedList.append(objectToAdd)
        let previousSize = referenceObjectLinkedList.count
        referenceObjectLinkedList.remove(byIdentity: objectToAdd)
        let currentSize = referenceObjectLinkedList.count
        XCTAssertEqual(previousSize - 1, currentSize)
    }

    func testIterator_emptyLinkedList() {
        for _ in emptyLinkedList {
            assertionFailure("Should not be reached")
        }
    }

    func testIterator_nonEmptyLinkedList_success() {
        var count = 0
        for (index, val) in integerLinkedList.enumerated() {
            count += 1
            XCTAssertEqual(index, val)
        }
        XCTAssertEqual(count, integerLinkedList.count)
    }
}
