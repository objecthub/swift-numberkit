//
//  RegressionTests.swift
//  NumberKit
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import XCTest

@testable import NumberKit

/// Regression tests for edge cases: shifts, random numbers, conversions, parsing,
/// hashing and overflow-safe rational comparison.
class RegressionTests: XCTestCase {

  func testShiftRightPastWidth() {
    XCTAssertEqual((BigInt(5) >> 100).description, "0")
    XCTAssertEqual((BigInt(-1) >> 32).description, "-1")
    XCTAssertEqual((BigInt(-1) >> 100).description, "-1")
    XCTAssertEqual((BigInt(0) >> 7).description, "0")
  }

  func testShiftRightNegativeRounding() {
    let x = -(BigInt(1) << 32) - BigInt(1)  // -(2^32 + 1)
    XCTAssertEqual((x >> 32).description, "-2")
    XCTAssertEqual((-(BigInt(1) << 64) >> 64).description, "-1")
    XCTAssertEqual(((-(BigInt(1) << 64) - BigInt(1)) >> 64).description, "-2")
    XCTAssertEqual((BigInt(-7) >> 1).description, "-4")
  }

  func testRandom() {
    for _ in 0..<200 {
      let r = BigInt.random(below: BigInt(10))
      XCTAssert(r >= BigInt(0) && r < BigInt(10))
    }
    XCTAssertEqual(BigInt.random(below: BigInt(1)), BigInt(0))
    XCTAssertEqual(BigInt.random(withMaxBits: 0), BigInt(0))
    XCTAssertEqual(BigInt.random(withMaxBits: 0).description, "0")
  }

  func testFloatingPointConversion() {
    XCTAssertEqual(BigInt(Float(2.5)), BigInt(2))
    XCTAssertEqual(BigInt(-2.5 as Double), BigInt(-2))
    XCTAssertNil(BigInt(exactly: 2.5 as Float))
    XCTAssertEqual(BigInt(exactly: 4.0 as Float), BigInt(4))
  }

  func testParsing() {
    XCTAssertNil(BigInt(from: ""))
    XCTAssertNil(BigInt(from: "-"))
    XCTAssertNil(BigInt(from: "+"))
    XCTAssertEqual(BigInt(from: "0"), BigInt(0))
    XCTAssertEqual(BigInt(from: "-000"), BigInt(0))
    XCTAssertEqual(BigInt(from: "ff", base: BigInt.hexBase), BigInt(255))
    XCTAssertEqual(BigInt(from: "FF", base: BigInt.hexBase), BigInt(255))
  }

  func testHashing() {
    XCTAssertNotEqual(BigInt(5).hashValue, BigInt(-5).hashValue)
    XCTAssertEqual(Integer.bigInt(BigInt(5)), Integer.int(5))
    XCTAssertEqual(Integer.bigInt(BigInt(5)).hashValue, Integer.int(5).hashValue)
  }

  func testRationalCompareOverflow() {
    let big = Int.max
    let a = Rational<Int>(big - 1, big)
    let b = Rational<Int>(big - 2, big - 1)
    XCTAssert(a > b)
    XCTAssert(b < a)
    XCTAssert(a != b)
    XCTAssert(a == a)
    XCTAssert(Rational<Int>(-(big - 1), big) < Rational<Int>(-(big - 2), big - 1))
    XCTAssert(Rational<Int>(-(big - 1), big) < b)
  }

  func testRationalPowerNegative() {
    XCTAssertEqual(Rational<Int>(2, 3).toPower(of: -2), Rational<Int>(9, 4))
    XCTAssertEqual(Rational<Int>(-2, 3).toPower(of: -3), Rational<Int>(-27, 8))
  }
}
