//
//  RegressionTests.swift
//  NumberKit
//
//  Created by Matthias Zenger on 06/10/2026.
//  Copyright © 2026 Matthias Zenger. All rights reserved.
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

  /// Random number with words biased towards extreme values, which stress the quotient
  /// estimation of long division.
  private func randomNumber<G: RandomNumberGenerator>(words: Int, using g: inout G) -> BigInt {
    let specials: [UInt32] = [0, 1, 0x7fffffff, 0x80000000, 0xffffffff, 0xfffffffe]
    var res = BigInt(0)
    for _ in 0..<words {
      let word = Bool.random(using: &g) ? specials.randomElement(using: &g)! : g.next()
      res = (res << 32) + BigInt(word)
    }
    return Bool.random(using: &g) ? -res : res
  }

  func testDivisionRandomized() {
    var generator = SystemRandomNumberGenerator()
    for _ in 0..<3000 {
      let a = randomNumber(words: Int.random(in: 1...12, using: &generator), using: &generator)
      let b = randomNumber(words: Int.random(in: 1...8, using: &generator), using: &generator)
      if b.isZero {
        continue
      }
      let (q, r) = a.divided(by: b)
      XCTAssertEqual(q * b + r, a, "\(a) / \(b)")
      XCTAssert(r.magnitude < b.magnitude, "\(a) / \(b)")
      XCTAssert(r.isZero || r.isNegative == a.isNegative, "\(a) / \(b)")
    }
  }

  func testDivisionKnownValues() {
    let a = BigInt(from: "340282366920938463463374607431768211455")!  // 2^128 - 1
    let b = BigInt(from: "18446744073709551615")!  // 2^64 - 1
    XCTAssertEqual((a / b).description, "18446744073709551617")
    XCTAssertEqual((a % b).description, "0")
    XCTAssertEqual((a / BigInt(10)).description, "34028236692093846346337460743176821145")
    XCTAssertEqual((a % BigInt(10)).description, "5")
    XCTAssertEqual((BigInt(-7) / BigInt(2)).description, "-3")
    XCTAssertEqual((BigInt(-7) % BigInt(2)).description, "-1")
  }

  func testStringRoundTrip() {
    var generator = SystemRandomNumberGenerator()
    let bases = [BigInt.binBase, BigInt.octBase, BigInt.decBase, BigInt.hexBase]
    for _ in 0..<300 {
      let n = randomNumber(words: Int.random(in: 1...10, using: &generator), using: &generator)
      for base in bases {
        XCTAssertEqual(BigInt(from: n.toString(base: base), base: base), n)
      }
    }
    // Compare with the standard library for 64-bit values
    for value in [Int64.min, -1, 0, 1, 7, 8, 4294967295, 4294967296, Int64.max] {
      XCTAssertEqual(BigInt(value).toString(base: .oct), String(value, radix: 8))
      XCTAssertEqual(BigInt(value).toString(base: .bin), String(value, radix: 2))
      XCTAssertEqual(BigInt(value).toString(base: .hex), String(value, radix: 16).uppercased())
      XCTAssertEqual(BigInt(value).description, String(value))
    }
    XCTAssertEqual(BigInt(1234567890123).toString(groupSep: ",", groupSize: 3), "1,234,567,890,123")
    XCTAssertEqual(BigInt(-123456).toString(groupSep: "_", groupSize: 3, forceSign: true), "-123_456")
    XCTAssertEqual(BigInt(123456).toString(groupSep: "_", groupSize: 3, forceSign: true), "+123_456")
  }

  func testPowerAndSqrt() {
    XCTAssertEqual(BigInt(2).toPower(of: BigInt(100)).description, "1267650600228229401496703205376")
    XCTAssertEqual(BigInt(-3).toPower(of: BigInt(5)), BigInt(-243))
    XCTAssertEqual(BigInt(7).toPower(of: BigInt(0)), BigInt(1))
    XCTAssertEqual(BigInt(0).toPower(of: BigInt(0)), BigInt(1))
    XCTAssertEqual(BigInt(2).toPower(of: BigInt(32)), BigInt(1) << 32)
    XCTAssertEqual(BigInt(2).toPower(of: BigInt(64)), BigInt(1) << 64)
    XCTAssertEqual(BigInt(10).toPower(of: BigInt(40)).sqrt, BigInt(10).toPower(of: BigInt(20)))
    var generator = SystemRandomNumberGenerator()
    for _ in 0..<300 {
      let n = BigInt(randomWithMaxBits: Int.random(in: 1...300, using: &generator), using: &generator)
      let r = n.sqrt
      XCTAssert(r * r <= n && (r + BigInt(1)) * (r + BigInt(1)) > n, "sqrt(\(n))")
    }
  }

  func testFixedWidthPowerNoSpuriousOverflow() {
    XCTAssertEqual(2.toPower(of: 62), 1 << 62)
    XCTAssertEqual(3.toPower(of: 39), 4052555153018976267)
    XCTAssertEqual((-2).toPower(of: 63), Int.min)
  }

  func testBitwiseAgainstInt() {
    let values: [Int] = [0, 1, -1, 5, -5, 255, -256, 123456789, -987654321, Int.max, Int.min]
    for a in values {
      for b in values {
        XCTAssertEqual(BigInt(a) & BigInt(b), BigInt(a & b))
        XCTAssertEqual(BigInt(a) | BigInt(b), BigInt(a | b))
        XCTAssertEqual(BigInt(a) ^ BigInt(b), BigInt(a ^ b))
      }
      XCTAssertEqual(BigInt(a).isOdd, a & 1 == 1)
      XCTAssertEqual(BigInt(a).negate, BigInt(0) - BigInt(a))
      XCTAssertEqual(BigInt(a).abs, a == Int.min ? BigInt(1) << 63 : BigInt(Swift.abs(a)))
    }
  }

  func testIntegerFastPathsAgainstBigInt() {
    let values: [Int64] = [0, 1, -1, 2, -2, 3, 7, -7, 10, 255, 4294967296, -4294967296,
                           3037000499, 3037000500, 9223372036854775807, -9223372036854775807 - 1]
    for a in values {
      for b in values {
        let (x, y) = (Integer(a), Integer(b))
        XCTAssertEqual((x + y).description, (BigInt(a) + BigInt(b)).description)
        XCTAssertEqual((x * y).description, (BigInt(a) * BigInt(b)).description)
        if b != 0 {
          let (q, r) = x.divided(by: y)
          let (bq, br) = BigInt(a).divided(by: BigInt(b))
          XCTAssertEqual(q.description, bq.description, "\(a) / \(b)")
          XCTAssertEqual(r.description, br.description, "\(a) % \(b)")
        }
        if b >= 0 && b <= 70 {
          XCTAssertEqual(x.toPower(of: y).description,
                         BigInt(a).toPower(of: BigInt(b)).description, "\(a) ** \(b)")
        }
      }
      let x = Integer(a)
      XCTAssertEqual(x.magnitude.description, BigInt(a).magnitude.description)
      XCTAssertEqual(x.bitSize, BigInt(a).bitSize)
      XCTAssertEqual(x.bitCount, BigInt(a).bitCount)
      if a >= 0 {
        XCTAssertEqual(x.sqrt.description, BigInt(a).sqrt.description, "sqrt \(a)")
      }
      for n in [0, 1, 5, 31, 32, 62, 63, 64, 65, 100] {
        XCTAssertEqual((x << n).description, (BigInt(a) << n).description, "\(a) << \(n)")
        XCTAssertEqual((x >> n).description, (BigInt(a) >> n).description, "\(a) >> \(n)")
      }
    }
  }

  func testRationalMultiplicationAndDivision() {
    var generator = SystemRandomNumberGenerator()
    for _ in 0..<1000 {
      let a = Int.random(in: -50...50, using: &generator)
      let b = Int.random(in: 1...50, using: &generator)
      let c = Int.random(in: -50...50, using: &generator)
      let d = Int.random(in: 1...50, using: &generator)
      let x = Rational<Int>(a, b)
      let y = Rational<Int>(c, d)
      let product = x * y
      XCTAssertEqual(product, Rational<Int>(a * c, b * d))
      XCTAssert(product.denominator > 0)
      if c != 0 {
        let quotient = x / y
        XCTAssertEqual(quotient, Rational<Int>(a * d, b * c))
        XCTAssert(quotient.denominator > 0)
      }
      XCTAssertEqual(x.compare(to: y), Double(a) / Double(b) < Double(c) / Double(d) ? -1 :
                       (a * d == c * b ? 0 : 1))
    }
    // Crosswise reduction avoids overflow when the result is representable
    let big = Int.max
    XCTAssertEqual(Rational<Int>(big, 3) * Rational<Int>(3, big), Rational<Int>(1, 1))
    XCTAssertEqual(Rational<Int>(big, 3) / Rational<Int>(big, 3), Rational<Int>(1, 1))
  }
}
