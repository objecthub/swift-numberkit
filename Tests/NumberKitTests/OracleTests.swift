//
//  OracleTests.swift
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

/// Randomized tests comparing `BigInt` and `Integer` against the standard library's
/// `Int128`, which serves as an independent oracle.
@available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
class OracleTests: XCTestCase {

  /// Returns a random `Int128` of at most `bits` bits, biased towards values at word
  /// boundaries and other special values.
  private func random<G: RandomNumberGenerator>(bits: Int, using g: inout G) -> Int128 {
    let limit: Int128 = bits >= 127 ? Int128.max : (Int128(1) << bits) - 1
    let specials: [Int128] = [0, 1, -1, 2, 0xffff_ffff, 0x1_0000_0000, 0x7fff_ffff, 0x8000_0000,
                              0xffff_ffff_ffff_ffff, 0x1_0000_0000_0000_0000]
    var value: Int128
    switch Int.random(in: 0..<8, using: &g) {
      case 0:
        value = specials.randomElement(using: &g)!
      case 1:
        // Values close to a power of two
        let exponent = Int.random(in: 0..<Swift.max(bits, 1), using: &g)
        value = (Int128(1) << exponent) + Int128.random(in: -2...2, using: &g)
      default:
        let high = UInt64.random(in: 0...UInt64.max, using: &g)
        let low = UInt64.random(in: 0...UInt64.max, using: &g)
        value = Int128(truncatingIfNeeded: (UInt128(high) << 64) | UInt128(low))
        let shift = 127 - Int.random(in: 0...Swift.max(bits - 1, 0), using: &g)
        value = value >> shift
    }
    if value > limit {
      value = value % (limit + 1)
    } else if value < -limit {
      value = value % (limit + 1)
    }
    return value
  }

  private func big(_ x: Int128) -> BigInt {
    return BigInt(from: String(x))!
  }

  private func string(_ x: BigInt) -> String {
    return x.description
  }

  func testConversion() {
    var g = SystemRandomNumberGenerator()
    for _ in 0..<2000 {
      let x = random(bits: 127, using: &g)
      XCTAssertEqual(string(big(x)), String(x))
      XCTAssertEqual(string(BigInt(x)), String(x))
      XCTAssertEqual(big(x).doubleValue, Double(x), "\(x)")
      XCTAssertEqual(big(x).toString(base: .hex), String(x, radix: 16).uppercased())
    }
  }

  func testAddSubtract() {
    var g = SystemRandomNumberGenerator()
    for _ in 0..<5000 {
      let (x, y) = (random(bits: 126, using: &g), random(bits: 126, using: &g))
      XCTAssertEqual(string(big(x) + big(y)), String(x + y), "\(x) + \(y)")
      XCTAssertEqual(string(big(x) - big(y)), String(x - y), "\(x) - \(y)")
      XCTAssertEqual(big(x) < big(y), x < y)
      XCTAssertEqual(big(x) == big(y), x == y)
      XCTAssertEqual(big(x).compare(to: big(y)), x < y ? -1 : (x == y ? 0 : 1))
    }
  }

  func testMultiply() {
    var g = SystemRandomNumberGenerator()
    for _ in 0..<5000 {
      let (x, y) = (random(bits: 63, using: &g), random(bits: 63, using: &g))
      XCTAssertEqual(string(big(x) * big(y)), String(x * y), "\(x) * \(y)")
    }
  }

  func testDivideRemainder() {
    var g = SystemRandomNumberGenerator()
    for _ in 0..<10000 {
      let x = random(bits: 127, using: &g)
      let y = random(bits: Int.random(in: 1...127, using: &g), using: &g)
      if y == 0 || (x == Int128.min && y == -1) {
        continue
      }
      let (q, r) = big(x).divided(by: big(y))
      XCTAssertEqual(string(q), String(x / y), "\(x) / \(y)")
      XCTAssertEqual(string(r), String(x % y), "\(x) % \(y)")
    }
  }

  func testShifts() {
    var g = SystemRandomNumberGenerator()
    for _ in 0..<5000 {
      let x = random(bits: 126, using: &g)
      let n = Int.random(in: 0...126, using: &g)
      XCTAssertEqual(string(big(x) >> n), String(x >> n), "\(x) >> \(n)")
      let small = random(bits: 126 - n, using: &g)
      XCTAssertEqual(string(big(small) << n), String(small << n), "\(small) << \(n)")
    }
  }

  func testBitwise() {
    var g = SystemRandomNumberGenerator()
    for _ in 0..<5000 {
      let (x, y) = (random(bits: 127, using: &g), random(bits: 127, using: &g))
      XCTAssertEqual(string(big(x) & big(y)), String(x & y), "\(x) & \(y)")
      XCTAssertEqual(string(big(x) | big(y)), String(x | y), "\(x) | \(y)")
      XCTAssertEqual(string(big(x) ^ big(y)), String(x ^ y), "\(x) ^ \(y)")
      XCTAssertEqual(string(~big(x)), String(~x), "~\(x)")
      let n = Int.random(in: 0...127, using: &g)
      XCTAssertEqual(big(x).isBitSet(n), (x >> n) & 1 == 1, "bit \(n) of \(x)")
    }
  }

  func testGCD() {
    var g = SystemRandomNumberGenerator()
    for _ in 0..<2000 {
      let (x, y) = (random(bits: 100, using: &g), random(bits: 100, using: &g))
      var (a, b) = (x.magnitude, y.magnitude)
      while b != 0 {
        (a, b) = (b, a % b)
      }
      XCTAssertEqual(string(BigInt.gcd(big(x), big(y))), String(a), "gcd(\(x), \(y))")
    }
  }

  func testIntegerEnum() {
    var g = SystemRandomNumberGenerator()
    for _ in 0..<5000 {
      let (x, y) = (random(bits: 126, using: &g), random(bits: 126, using: &g))
      let (a, b) = (Integer(big(x)), Integer(big(y)))
      XCTAssertEqual((a + b).description, String(x + y))
      XCTAssertEqual((a - b).description, String(x - y))
      if y != 0 {
        XCTAssertEqual((a / b).description, String(x / y), "\(x) / \(y)")
        XCTAssertEqual((a % b).description, String(x % y), "\(x) % \(y)")
      }
      XCTAssertEqual(a < b, x < y)
      XCTAssertEqual(a == b, x == y)
      // Results are always normalized: a value fitting into 64 bits is stored as `.int`
      for value in [a + b, a - b, a & b, a | b, a ^ b] {
        if case .bigInt(let num) = value {
          XCTAssertNil(num.intValue, "\(value) is not normalized")
        }
      }
    }
    var h = SystemRandomNumberGenerator()
    for _ in 0..<3000 {
      let (x, y) = (random(bits: 63, using: &h), random(bits: 63, using: &h))
      let (a, b) = (Integer(big(x)), Integer(big(y)))
      XCTAssertEqual((a * b).description, String(x * y), "\(x) * \(y)")
    }
  }

  func testRationalAgainstOracle() {
    var g = SystemRandomNumberGenerator()
    for _ in 0..<2000 {
      let (a, c) = (random(bits: 40, using: &g), random(bits: 40, using: &g))
      var (b, d) = (random(bits: 40, using: &g), random(bits: 40, using: &g))
      if b == 0 { b = 1 }
      if d == 0 { d = 1 }
      let x = Rational<BigInt>(big(a), big(b))
      let y = Rational<BigInt>(big(c), big(d))
      // Compare by cross multiplication using the oracle
      let lhs = Int128(a) * Int128(d) * (b < 0 ? -1 : 1) * (d < 0 ? -1 : 1)
      let rhs = Int128(c) * Int128(b) * (b < 0 ? -1 : 1) * (d < 0 ? -1 : 1)
      XCTAssertEqual(x.compare(to: y), lhs < rhs ? -1 : (lhs == rhs ? 0 : 1))
      let sum = x + y
      XCTAssert(sum.denominator.compare(to: BigInt.zero) > 0)
      XCTAssertEqual(BigInt.gcd(sum.numerator, sum.denominator), BigInt.one)
      // (x + y) - y == x
      XCTAssertEqual(sum - y, x)
      if !y.isZero {
        XCTAssertEqual((x * y) / y, x)
      }
    }
  }
}
