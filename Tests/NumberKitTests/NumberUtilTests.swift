//
//  NumberUtilTests.swift
//  NumberKit
//
//  Created by Matthias Zenger on 12/08/2015.
//  Copyright © 2015-2019 Matthias Zenger. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import XCTest
@testable import NumberKit


class NumberUtilTests: XCTestCase {

  func testPow() {
    XCTAssertEqual(1.toPower(of: 1), 1)
    XCTAssertEqual(1.toPower(of: 9), 1)
    XCTAssertEqual(7.toPower(of: 3), 7 * 7 * 7)
    XCTAssertEqual(31.toPower(of: 7), 27512614111)
    XCTAssertEqual((-5).toPower(of: 2), 25)
    XCTAssertEqual((-5).toPower(of: 3), -125)
    XCTAssertEqual((-5).toPower(of: 0), 1)
    XCTAssertEqual(5.toPower(of: 0), 1)
  }
  
  func testPowOperator() {
    XCTAssertEqual(1 ** 1, 1)
    XCTAssertEqual(1 ** 9, 1)
    XCTAssertEqual(7 ** 3, 7 * 7 * 7)
    let many = 31 * 31 * 31 * 31
    XCTAssertEqual((29 + 2) ** 7, many * 31 * 31 * 31)
    XCTAssertEqual(-5 ** (1 + 1), 25)
    XCTAssertEqual(-5 ** 3, -125)
    XCTAssertEqual(-5 ** 0, 1)
    XCTAssertEqual(5 ** 0, 1)
  }
  
  func testMinMax() {
    XCTAssertEqual(min(0, 1), 0)
    XCTAssertEqual(min(1, 0), 0)
    XCTAssertEqual(min(-1, 0), -1)
    XCTAssertEqual(min(0, -1), -1)
    XCTAssertEqual(max(0, 1), 1)
    XCTAssertEqual(max(1, 0), 1)
    XCTAssertEqual(max(-1, 0), 0)
    XCTAssertEqual(max(0, -1), 0)
  }
  
  static let allTests = [
    ("testPow", testPow),
    ("testPowOperator", testPowOperator),
    ("testMinMax", testMinMax),
  ]
}
