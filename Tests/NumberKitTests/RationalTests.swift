//
//  RationalTests.swift
//  NumberKit
//
//  Created by Matthias Zenger on 16/08/2015.
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


class RationalTests: XCTestCase {
  
  func testConstructors() {
    let r0: Rational<Int> = 8
    XCTAssert(r0.numerator == 8 && r0.denominator == 1)
    XCTAssert(r0 == 8)
    let r1: Rational<Int> = 7/2
    XCTAssert(r1.numerator == 7 && r1.denominator == 2)
    XCTAssert(r1.floatValue == 7.0/2.0)
    let r2 = Rational(43, 7)
    XCTAssert(r2.numerator == 43 && r2.denominator == 7)
    let r3 = Rational(19 * 3 * 5 * 7, 2 * 5 * 7)
    XCTAssert(r3.numerator == 19 * 3 && r3.denominator == 2)
    let r4: Rational<Int>? = Rational(from: "172346/254")
    if let r4u = r4 {
      XCTAssertEqual(r4u.numerator, 86173)
      XCTAssertEqual(r4u.denominator, 127)
    } else {
      XCTFail("cannot parse r4 string")
    }
    let r5: Rational<Int>? = Rational(from: "-128/64")
    if let r5u = r5 {
      XCTAssertEqual(r5u.numerator, -2)
      XCTAssertEqual(r5u.denominator, 1)
    } else {
      XCTFail("cannot parse r5 string")
    }
  }
  
  func testPlus() {
    let r1 = Rational(16348, 343).plus(24/7)
    XCTAssertEqual(r1, 17524/343)
    XCTAssert(r1 == Rational(from: "17524/343"))
    XCTAssert(r1 == 17524/343)
    let r2: Rational<Int> = (74433/215).plus(312/15)
    XCTAssert(r2 == 367)
    let r3: Rational<Int> = (458200/50).plus(3440/17)
    XCTAssert(r3 == 159228/17)
    let x = Rational(BigInt(458200)/BigInt(50))
    let r4: Rational<BigInt> = x.plus(Rational(BigInt(3440)/BigInt(17)))
    XCTAssert(r4 == Rational(BigInt(159228)/BigInt(17)))
  }
  
  func testMinus() {
    let r1 = Rational(123, 5).minus(247/10)
    XCTAssertEqual(r1, Rational(1, 10).negate)
    let r2 = Rational(0).minus(72372/30)
    XCTAssertEqual(r2, -Rational(72372, 30))
    let r3 = Rational(98232, 536).minus(123/12)
    XCTAssertEqual(r3, Rational(46369, 268))
  }
  
  func testTimes() {
    let r1 = Rational(4, 8).times(2)
    XCTAssertEqual(r1, 1)
    let r2 = Rational(83987, 12).times(48/42)
    XCTAssertEqual(r2, Rational(83987 * 48, 12 * 42))
    let r3 = Rational(170, 9).times(-17/72)
    XCTAssertEqual(r3, Rational(-170 * 17, 9 * 72))
  }
  
  func testDividedBy() {
    let r1 = Rational(10, -3).divided(by: -31/49)
    XCTAssertEqual(r1, Rational(10 * 49, 3 * 31))
  }
  
  static let allTests = [
    ("testConstructors", testConstructors),
    ("testPlus", testPlus),
    ("testMinus", testMinus),
    ("testTimes", testTimes),
    ("testDividedBy", testDividedBy),
  ]
}
