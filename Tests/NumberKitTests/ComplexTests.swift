//
//  ComplexTests.swift
//  NumberKit
//
//  Created by Matthias Zenger on 16/08/2015.
//  Copyright © 2015-2020 Matthias Zenger. All rights reserved.
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

class ComplexTests: XCTestCase {
  
  func testConstructors() {
    let c1: Complex<Double> = 2.0 + 3.0.i
    XCTAssertEqual(c1, Complex(2.0, 3.0))
    let c2 = -1.0 - 2.0.i
    XCTAssertEqual(c2, Complex(-1.0, -2.0))
    let c3: Complex<Double> = 7
    XCTAssertEqual(c3, Complex(7.0))
  }
  
  func testImaginaryInvariant() {
    let c = 1.0.i
    XCTAssertEqual(c * c, -1)
  }
  
  func testSpecialCases() {
    let c1: Complex<Double> = Complex(.infinity, 12.0)
    XCTAssertTrue(c1.isInfinite)
    XCTAssertFalse(c1.isNaN)
    let c2: Complex<Double> = Complex(.infinity, -7.3)
    XCTAssertEqual(c1, c2)
    let c3: Complex<Double> = Complex(.nan, -1.2)
    XCTAssertTrue(c3.isNaN)
    XCTAssertFalse(c3.isInfinite)
    XCTAssertEqual(c3.im, 0.0)
    let c4: Complex<Double> = Complex(3.4, .nan)
    XCTAssertTrue(c4.isNaN)
    XCTAssertFalse(c4.isInfinite)
    XCTAssertEqual(c4.im, 0.0)
    XCTAssertNotEqual(c3, c4)
    XCTAssertTrue(c4.abs.isNaN)
    let c5: Complex<Double> = Complex(1.234, .infinity)
    XCTAssertTrue(c5.isNaN)
    XCTAssertFalse(c5.isInfinite)
    XCTAssertTrue(c5.magnitude.isNaN)
    let c6: Complex<Double> = .zero
    XCTAssertTrue(c6.reciprocal.isInfinite)
    XCTAssertTrue(c1.reciprocal.isZero)
  }
  
  static let allTests = [
    ("testConstructors", testConstructors),
    ("testImaginaryInvariant", testImaginaryInvariant),
    ("testSpecialCases", testSpecialCases),
  ]
}
