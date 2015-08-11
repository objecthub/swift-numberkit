//
//  NumberUtilTests.swift
//  NumberKit
//
//  Created by Matthias Zenger on 12/08/2015.
//  Copyright © 2015 ObjectHub. All rights reserved.
//

import XCTest
@testable import NumberKit


class NumberUtilTests: XCTestCase {

  func testPow() {
    XCTAssert(pow(1, 1) == 1)
    XCTAssert(pow(1, 9) == 1)
    XCTAssert(pow(7, 3) == 7 * 7 * 7)
    XCTAssert(pow(31, 7) == 31 * 31 * 31 * 31 * 31 * 31 * 31)
    XCTAssert(pow(-5, 2) == 25)
    XCTAssert(pow(-5, 3) == -125)
    XCTAssert(pow(-5, 0) == 1)
    XCTAssert(pow(5, 0) == 1)
  }
  
  func testPowOperator() {
    XCTAssert(1 ** 1 == 1)
    XCTAssert(1 ** 9 == 1)
    XCTAssert(7 ** 3 == 7 * 7 * 7)
    XCTAssert((29 + 2) ** 7 == 31 * 31 * 31 * 31 * 31 * 31 * 31)
    XCTAssert(-5 ** (1 + 1) == 25)
    XCTAssert(-5 ** 3 == -125)
    XCTAssert(-5 ** 0 == 1)
    XCTAssert(5 ** 0 == 1)
  }
  
  func testMinMax() {
    XCTAssert(min(0, 1) == 0)
    XCTAssert(min(1, 0) == 0)
    XCTAssert(min(-1, 0) == -1)
    XCTAssert(min(0, -1) == -1)
    XCTAssert(max(0, 1) == 1)
    XCTAssert(max(1, 0) == 1)
    XCTAssert(max(-1, 0) == 0)
    XCTAssert(max(0, -1) == 0)
  }
}
