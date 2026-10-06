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

  func testLargeDecimalConversion() {
    var generator = SystemRandomNumberGenerator()
    // Random numbers well above the divide-and-conquer threshold
    for words in [40, 41, 79, 80, 150, 400] {
      let n = randomNumber(words: words, using: &generator)
      XCTAssertEqual(BigInt(from: n.description), n, "\(words) words")
    }
    // Numbers with long runs of zeros in the middle require padded digit groups
    let ten = BigInt(10)
    for exp in [200, 360, 361, 720, 1000, 2900] {
      let p = ten.toPower(of: BigInt(exp))
      XCTAssertEqual(p.description, "1" + String(repeating: "0", count: exp))
      XCTAssertEqual((p + BigInt(1)).description,
                     "1" + String(repeating: "0", count: exp - 1) + "1")
      XCTAssertEqual((p - BigInt(1)).description, String(repeating: "9", count: exp))
      XCTAssertEqual((-p).description, "-1" + String(repeating: "0", count: exp))
      let mixed = p * p + BigInt(7)
      XCTAssertEqual(mixed.description,
                     "1" + String(repeating: "0", count: 2 * exp - 1) + "7")
    }
    // Digit grouping
    let big = ten.toPower(of: BigInt(1000)) + BigInt(1)
    let grouped = big.toString(groupSep: ",")
    XCTAssertEqual(grouped.filter { $0 != "," }, big.description)
    let parts = grouped.components(separatedBy: ",")
    XCTAssertEqual(parts[0].count, 1001 % 3 == 0 ? 3 : 1001 % 3)
    XCTAssert(parts.dropFirst().allSatisfy { $0.count == 3 })
  }

  func testPowerOfTwoBaseConversion() {
    var generator = SystemRandomNumberGenerator()
    for _ in 0..<100 {
      let n = randomNumber(words: Int.random(in: 1...60, using: &generator), using: &generator)
      for base in [BigInt.binBase, BigInt.octBase, BigInt.hexBase] {
        XCTAssertEqual(BigInt(from: n.toString(base: base), base: base), n)
      }
    }
    XCTAssertEqual((BigInt(1) << 100).toString(base: .oct), "2" + String(repeating: "0", count: 33))
    XCTAssertEqual((BigInt(1) << 100).toString(base: .hex), "1" + String(repeating: "0", count: 25))
  }

  func testRadixConversion() {
    XCTAssertEqual(BigInt("ff", radix: 16), BigInt(255))
    XCTAssertEqual(BigInt("-Zz", radix: 36), BigInt(-1295))
    XCTAssertEqual(BigInt("+101", radix: 2), BigInt(5))
    XCTAssertNil(BigInt("12", radix: 2))
    // Without a radix, the string literal initializer is selected for literals
    XCTAssertNil(LosslessStringConvertibleHelper.make(" 12") as BigInt?)
    XCTAssertNil(LosslessStringConvertibleHelper.make("") as BigInt?)
    XCTAssertNil(LosslessStringConvertibleHelper.make("1_000") as BigInt?)
    XCTAssertNil(LosslessStringConvertibleHelper.make("-") as BigInt?)
    XCTAssertEqual(LosslessStringConvertibleHelper.make("123456789012345678901234567890"),
                   BigInt(from: "123456789012345678901234567890"))
    var generator = SystemRandomNumberGenerator()
    for radix in 2...36 {
      for _ in 0..<20 {
        let n = randomNumber(words: Int.random(in: 1...12, using: &generator), using: &generator)
        let text = n.toString(radix: radix)
        XCTAssertEqual(BigInt(text, radix: radix), n, "radix \(radix)")
        XCTAssertEqual(BigInt(n.toString(radix: radix, uppercase: true), radix: radix), n)
      }
    }
    for value in [Int64.min, -1, 0, 1, 35, 36, 1295, 1296, 4294967296, Int64.max] {
      for radix in 2...36 {
        XCTAssertEqual(BigInt(value).toString(radix: radix), String(value, radix: radix),
                       "\(value) radix \(radix)")
      }
    }
    let x: BigInt = LosslessStringConvertibleHelper.make("-123")!
    XCTAssertEqual(x, BigInt(-123))
  }

  func testDecodingNumbers() throws {
    let decoder = JSONDecoder()
    XCTAssertEqual(try decoder.decode([BigInt].self, from: Data("[42, -7, \"123456789012345678901234567890\"]".utf8)),
                   [BigInt(42), BigInt(-7), BigInt(from: "123456789012345678901234567890")!])
    XCTAssertEqual(try decoder.decode([BigInt].self, from: Data("[18446744073709551615]".utf8)),
                   [BigInt(UInt64.max)])
    XCTAssertThrowsError(try decoder.decode([BigInt].self, from: Data("[\"abc\"]".utf8)))
    XCTAssertThrowsError(try decoder.decode([BigInt].self, from: Data("[true]".utf8)))
  }

  func testNumberTheory() {
    let (g, x, y) = BigInt.extendedGCD(BigInt(240), BigInt(46))
    XCTAssertEqual(g, BigInt(2))
    XCTAssertEqual(BigInt(240) * x + BigInt(46) * y, g)
    var generator = SystemRandomNumberGenerator()
    for _ in 0..<200 {
      let a = randomNumber(words: Int.random(in: 1...5, using: &generator), using: &generator)
      let b = randomNumber(words: Int.random(in: 1...5, using: &generator), using: &generator)
      let (g, x, y) = BigInt.extendedGCD(a, b)
      XCTAssertEqual(a * x + b * y, g)
      XCTAssert(!g.isNegative)
      if !g.isZero {
        XCTAssert((a % g).isZero && (b % g).isZero)
      }
    }
    XCTAssertEqual(BigInt(3).modInverse(BigInt(11)), BigInt(4))
    XCTAssertEqual(BigInt(-3).modInverse(BigInt(11)), BigInt(7))
    XCTAssertNil(BigInt(6).modInverse(BigInt(9)))
    XCTAssertEqual(BigInt(2).modPow(BigInt(10), modulus: BigInt(1000)), BigInt(24))
    XCTAssertEqual(BigInt(2).modPow(BigInt(0), modulus: BigInt(7)), BigInt(1))
    XCTAssertEqual(BigInt(5).modPow(BigInt(3), modulus: BigInt(1)), BigInt(0))
    XCTAssertEqual(BigInt(-2).modPow(BigInt(3), modulus: BigInt(7)), BigInt(6))
    // Fermat: a^(p-1) = 1 mod p for p = 2^127 - 1
    let p = (BigInt(1) << 127) - BigInt(1)
    XCTAssertEqual(BigInt(3).modPow(p - BigInt(1), modulus: p), BigInt(1))
    let inverse = BigInt(123456789).modInverse(p)!
    XCTAssertEqual((inverse * BigInt(123456789)) % p, BigInt(1))
  }

  func testPrimality() {
    let primes = [2, 3, 5, 7, 97, 101, 7919, 104729, 2147483647]
    for prime in primes {
      XCTAssert(BigInt(prime).isProbablePrime(), "\(prime)")
    }
    for composite in [-7, 0, 1, 4, 9, 91, 561, 1105, 1729, 7917, 2147483649] {
      XCTAssertFalse(BigInt(composite).isProbablePrime(), "\(composite)")
    }
    // Compare with trial division for small numbers
    for n in 0..<2000 {
      let isPrime = n >= 2 && !(2..<n).contains { $0 * $0 <= n && n % $0 == 0 }
      XCTAssertEqual(BigInt(n).isProbablePrime(), isPrime, "\(n)")
    }
    XCTAssert(((BigInt(1) << 127) - BigInt(1)).isProbablePrime())    // Mersenne prime
    XCTAssert(((BigInt(1) << 521) - BigInt(1)).isProbablePrime())    // Mersenne prime
    XCTAssertFalse(((BigInt(1) << 128) + BigInt(1)).isProbablePrime())  // 641 * ...
    XCTAssertFalse(((BigInt(1) << 67) - BigInt(1)).isProbablePrime())  // 193707721 * 761838257287
    // Carmichael number and strong pseudoprimes to several bases
    XCTAssertFalse(BigInt(3825123056546413051).isProbablePrime())
    XCTAssertFalse((BigInt(10).toPower(of: BigInt(30)) + BigInt(1)).isProbablePrime())
  }

  func testDoubleConversionRounding() {
    XCTAssertEqual(BigInt(0).doubleValue, 0.0)
    XCTAssertEqual(BigInt(-5).doubleValue, -5.0)
    XCTAssertEqual(BigInt(UInt64.max).doubleValue, Double(UInt64.max))
    XCTAssertEqual(BigInt(Int64.min).doubleValue, Double(Int64.min))
    // 2^53 + 1 is a tie and rounds to even (2^53); 2^53 + 3 rounds up to 2^53 + 4
    XCTAssertEqual(BigInt(9007199254740993).doubleValue, 9007199254740992.0)
    XCTAssertEqual(BigInt(9007199254740995).doubleValue, 9007199254740996.0)
    // A tie that is broken by bits far below the rounding position
    let tie = (BigInt(1) << 100) + (BigInt(1) << 47)  // exactly half way between two doubles
    XCTAssertEqual(tie.doubleValue, 0x1p100)
    XCTAssertEqual((tie + BigInt(1)).doubleValue, 0x1p100 + 0x1p48)
    XCTAssertEqual((-(tie + BigInt(1))).doubleValue, -(0x1p100 + 0x1p48))
    XCTAssertEqual((BigInt(1) << 1000).doubleValue, 0x1p1000)
    XCTAssertEqual((BigInt(1) << 1023).doubleValue, 0x1p1023)
    XCTAssertEqual((BigInt(1) << 1024).doubleValue, Double.infinity)
    XCTAssertEqual((-(BigInt(1) << 1024)).doubleValue, -Double.infinity)
    // The largest double and the first value that rounds up to infinity
    let maxDouble = BigInt(Double.greatestFiniteMagnitude)
    XCTAssertEqual(maxDouble.doubleValue, Double.greatestFiniteMagnitude)
    XCTAssertEqual((maxDouble + BigInt(1)).doubleValue, Double.greatestFiniteMagnitude)
    // Random 64-bit values agree with the correctly rounded hardware conversion
    var generator = SystemRandomNumberGenerator()
    for _ in 0..<1000 {
      let value = UInt64.random(in: 0...UInt64.max, using: &generator)
      XCTAssertEqual(BigInt(value).doubleValue, Double(value))
    }
    // Ratio conversion
    XCTAssertEqual(BigInt.doubleValue(numerator: BigInt(1), denominator: BigInt(3)), 1.0 / 3.0)
    XCTAssertEqual(BigInt.doubleValue(numerator: BigInt(-2), denominator: BigInt(3)), -2.0 / 3.0)
    let huge = BigInt(10).toPower(of: BigInt(400))
    XCTAssertEqual(BigInt.doubleValue(numerator: huge * BigInt(3), denominator: huge * BigInt(4)), 0.75)
    XCTAssertEqual(BigInt.doubleValue(numerator: BigInt(1), denominator: huge), 0.0)
    XCTAssertEqual(BigInt.doubleValue(numerator: huge, denominator: BigInt(1)), Double.infinity)
  }
}

extension RegressionTests {

  func testRationalParsing() {
    XCTAssertEqual(Rational<Int>(from: "3/6"), Rational<Int>(1, 2))
    XCTAssertEqual(Rational<Int>(from: "-3/-6"), Rational<Int>(1, 2))
    XCTAssertEqual(Rational<Int>(from: "7/-14"), Rational<Int>(-1, 2))
    XCTAssertEqual(Rational<Int>(from: "ff/10", radix: 16), Rational<Int>(255, 16))
    XCTAssertNil(Rational<Int>(from: "1/0"))
    XCTAssertNil(Rational<Int>(from: "1/"))
    XCTAssertNil(Rational<Int>(from: "/2"))
    XCTAssertNil(Rational<Int>(from: "a/2"))
    XCTAssertNil(Rational<Int>(from: ""))
    XCTAssertNil(Rational<Int8>(from: "200"))
    XCTAssertEqual(Rational<Int8>(from: "-128/2"), Rational<Int8>(-64, 1))
    let huge = "123456789012345678901234567890"
    let r = Rational<BigInt>(from: huge + "/" + "246913578024691357802469135780")
    XCTAssertEqual(r, Rational<BigInt>(BigInt(1), BigInt(2)))
    XCTAssertEqual(Rational<BigInt>(from: huge)?.numerator, BigInt(from: huge))
    XCTAssertNil(Rational<Int>(from: huge))
  }

  func testRationalRounding() {
    let cases: [(Rational<Int>, [FloatingPointRoundingRule: Int])] = [
      (Rational(7, 2), [.down: 3, .up: 4, .towardZero: 3, .awayFromZero: 4,
                        .toNearestOrAwayFromZero: 4, .toNearestOrEven: 4]),
      (Rational(5, 2), [.down: 2, .up: 3, .towardZero: 2, .awayFromZero: 3,
                        .toNearestOrAwayFromZero: 3, .toNearestOrEven: 2]),
      (Rational(-5, 2), [.down: -3, .up: -2, .towardZero: -2, .awayFromZero: -3,
                         .toNearestOrAwayFromZero: -3, .toNearestOrEven: -2]),
      (Rational(-7, 3), [.down: -3, .up: -2, .towardZero: -2, .awayFromZero: -3,
                         .toNearestOrAwayFromZero: -2, .toNearestOrEven: -2]),
      (Rational(8, 3), [.down: 2, .up: 3, .towardZero: 2, .awayFromZero: 3,
                        .toNearestOrAwayFromZero: 3, .toNearestOrEven: 3]),
      (Rational(6, 3), [.down: 2, .up: 2, .towardZero: 2, .awayFromZero: 2,
                        .toNearestOrAwayFromZero: 2, .toNearestOrEven: 2]),
      (Rational(0, 5), [.down: 0, .up: 0, .towardZero: 0, .awayFromZero: 0,
                        .toNearestOrAwayFromZero: 0, .toNearestOrEven: 0]),
    ]
    for (value, expected) in cases {
      for (rule, result) in expected {
        XCTAssertEqual(value.rounded(rule), result, "\(value) \(rule)")
      }
    }
    XCTAssertEqual(Rational<Int>(7, 2).rounded(), 4)
    XCTAssertEqual(Rational<Int>(Int.max, 2).rounded(.down), Int.max / 2)
    XCTAssertEqual(Rational<Int>(-Int.max, 2).rounded(.up), -(Int.max / 2))
    XCTAssertEqual(Rational<BigInt>(BigInt(1) << 100, BigInt(3)).rounded(.up),
                   ((BigInt(1) << 100) + BigInt(2)) / BigInt(3))
  }

  func testRationalReciprocalAndDouble() {
    XCTAssertEqual(Rational<Int>(2, 3).reciprocal, Rational<Int>(3, 2))
    XCTAssertEqual(Rational<Int>(-2, 3).reciprocal, Rational<Int>(-3, 2))
    XCTAssertEqual(Rational<Int>(5).reciprocal, Rational<Int>(1, 5))
    XCTAssertEqual(Rational<Int>(1, 3).doubleValue, 1.0 / 3.0)
    XCTAssertEqual(Rational<Int>(-22, 7).doubleValue, -22.0 / 7.0)
    let huge = BigInt(10).toPower(of: BigInt(400))
    XCTAssertEqual(Rational<BigInt>(huge * BigInt(3), huge * BigInt(4) + BigInt(1)).doubleValue, 0.75)
    XCTAssertEqual(Rational<BigInt>(huge, huge + BigInt(1)).doubleValue, 1.0)
    XCTAssertEqual(Rational<BigInt>(BigInt(1), huge).doubleValue, 0.0)
    XCTAssertEqual(Rational<BigInt>(huge, BigInt(1)).doubleValue, Double.infinity)
    XCTAssertEqual(Rational<Int>(Int.max, Int.max - 1).doubleValue,
                   Double(Int.max) / Double(Int.max - 1))
  }
}

extension RegressionTests {

  private func assertClose(_ x: Complex<Double>, _ y: Complex<Double>,
                           tolerance: Double = 1e-12, line: UInt = #line) {
    let scale = Swift.max(1.0, y.abs)
    XCTAssert((x - y).abs <= tolerance * scale, "\(x) is not close to \(y)", line: line)
  }

  func testComplexDivision() {
    assertClose(Complex(3.0, 4.0) / Complex(1.0, 2.0), Complex(2.2, -0.4))
    assertClose(Complex(3.0, 4.0) / Complex(-1.0, 0.5), Complex(3.0, 4.0) * Complex(-1.0, 0.5).reciprocal)
    // Naive formulas overflow or underflow in the intermediate results
    XCTAssertEqual(Complex(1e300, 1e300) / Complex(1e300, 1e300), Complex(1.0, 0.0))
    XCTAssertEqual(Complex(1e-300, 1e-300) / Complex(1e-300, 1e-300), Complex(1.0, 0.0))
    assertClose(Complex(1e300, 1e300).reciprocal, Complex(0.5e-300, -0.5e-300), tolerance: 1e-12)
    XCTAssertEqual(Complex(1.0, 0.0).reciprocal.re, 1.0)
    XCTAssertEqual(Complex(0.0, 2.0).reciprocal, Complex(0.0, -0.5))
    XCTAssert((Complex(1.0, 1.0) / Complex(0.0, 0.0)).isInfinite || (Complex(1.0, 1.0) / Complex(0.0, 0.0)).isNaN)
    XCTAssert(Complex(1.0, 1.0).divided(by: Complex(.infinity, 0.0)).isZero)
  }

  func testComplexSquareRoot() {
    XCTAssertEqual(Complex(-4.0, 0.0).sqrt, Complex(0.0, 2.0))
    XCTAssertEqual(Complex(4.0, 0.0).sqrt, Complex(2.0, 0.0))
    XCTAssertEqual(Complex(3.0, 4.0).sqrt, Complex(2.0, 1.0))
    XCTAssertEqual(Complex(-3.0, 4.0).sqrt, Complex(1.0, 2.0))
    XCTAssertEqual(Complex(-3.0, -4.0).sqrt, Complex(1.0, -2.0))
    XCTAssertEqual(Complex(3.0, -4.0).sqrt, Complex(2.0, -1.0))
    XCTAssertEqual(Complex(0.0, 0.0).sqrt, Complex(0.0, 0.0))
    // No cancellation for small imaginary parts
    let tiny = Complex(-1.0, 1e-20).sqrt
    XCTAssertEqual(tiny.re, 5e-21, accuracy: 1e-30)
    XCTAssertEqual(tiny.im, 1.0, accuracy: 1e-15)
    var generator = SystemRandomNumberGenerator()
    for _ in 0..<500 {
      let z = Complex.random(realRange: -100.0..<100.0, imaginaryRange: -100.0..<100.0, using: &generator)
      let root = z.sqrt
      XCTAssert(root.re >= 0)
      assertClose(root * root, z)
    }
  }

  func testComplexIntegerPowers() {
    XCTAssertEqual(Complex(1.0, 1.0).toPower(of: Complex(2.0, 0.0)), Complex(0.0, 2.0))
    XCTAssertEqual(Complex(1.0, 1.0).toPower(of: Complex(8.0, 0.0)), Complex(16.0, 0.0))
    XCTAssertEqual(Complex(0.0, 1.0).toPower(of: Complex(4.0, 0.0)), Complex(1.0, 0.0))
    XCTAssertEqual(Complex(2.0, 0.0).toPower(of: Complex(-2.0, 0.0)), Complex(0.25, 0.0))
    XCTAssertEqual(Complex(3.0, 4.0).toPower(of: Complex(0.0, 0.0)), Complex(1.0, 0.0))
    XCTAssertEqual(Complex(3.0, 4.0).toPower(of: Complex(1.0, 0.0)), Complex(3.0, 4.0))
    XCTAssertEqual(Complex(0.0, 0.0).toPower(of: Complex(3.0, 0.0)), Complex(0.0, 0.0))
    XCTAssertEqual(Complex(2.0, 0.0).toPower(of: Complex(10.0, 0.0)), Complex(1024.0, 0.0))
    assertClose(Complex(1.0, 2.0).toPower(of: Complex(-3.0, 0.0)), (Complex(1.0, 2.0) * Complex(1.0, 2.0) * Complex(1.0, 2.0)).reciprocal)
    // Non-integral exponents still use the principal branch
    assertClose(Complex(-8.0, 0.0).toPower(of: Complex(1.0 / 3.0, 0.0)), Complex(1.0, 3.0.squareRoot()), tolerance: 1e-12)
    assertClose(Complex(4.0, 0.0).toPower(of: Complex(0.5, 0.0)), Complex(2.0, 0.0))
  }

  func testComplexParsing() {
    let cases: [(String, Complex<Double>)] = [
      ("3", Complex(3.0, 0.0)), ("-2.5", Complex(-2.5, 0.0)), ("2i", Complex(0.0, 2.0)),
      ("1+2i", Complex(1.0, 2.0)), ("1-2i", Complex(1.0, -2.0)), ("-i", Complex(0.0, -1.0)),
      ("i", Complex(0.0, 1.0)), ("+i", Complex(0.0, 1.0)), ("1+i", Complex(1.0, 1.0)),
      ("2-i", Complex(2.0, -1.0)), ("1e-5+2e3i", Complex(1e-5, 2e3)),
      ("1.5e+3-2.5e-3i", Complex(1500.0, -0.0025)), (" 1 + 2 i ", Complex(1.0, 2.0)),
      ("-1.5-2i", Complex(-1.5, -2.0)), ("-inf", Complex(-Double.infinity, 0.0)),
    ]
    for (text, expected) in cases {
      XCTAssertEqual(Complex<Double>(text), expected, text)
    }
    XCTAssert(Complex<Double>("nan")!.isNaN)
    for text in ["", "i2", "1+2", "abc", "1+i+2i", "1++2i", "--i", "1+2j", "ii"] {
      XCTAssertNil(Complex<Double>(text), text)
    }
    // Round trips with `description`
    var generator = SystemRandomNumberGenerator()
    for _ in 0..<200 {
      let z = Complex.random(realRange: -1e6..<1e6, imaginaryRange: -1e6..<1e6, using: &generator)
      XCTAssertEqual(Complex<Double>(z.description), z)
    }
    for z in [Complex(0.0, 0.0), Complex(1e-300, -1e300), Complex(0.0, -1.0), Complex(-2.5, 0.0)] {
      XCTAssertEqual(Complex<Double>(z.description), z)
    }
    XCTAssertEqual(Complex<Float>("1.5-2i"), Complex<Float>(1.5, -2.0))
  }

  func testComplexNumeric() {
    let values = [Complex(1.0, 1.0), Complex(2.0, -3.0), Complex(-0.5, 0.25)]
    XCTAssertEqual(values.reduce(.zero, +), Complex(2.5, -1.75))
    XCTAssertEqual(values.reduce(.one, *), Complex(1.0, 1.0) * Complex(2.0, -3.0) * Complex(-0.5, 0.25))
    XCTAssertEqual(Complex<Double>(exactly: 5), Complex(5.0, 0.0))
    XCTAssertEqual(Complex<Double>(exactly: -7), Complex(-7.0, 0.0))
    XCTAssertEqual(-Complex(1.0, -2.0), Complex(-1.0, 2.0))
    var z = Complex(1.0, 2.0)
    z.negate()
    XCTAssertEqual(z, Complex(-1.0, -2.0))
    z += Complex(1.0, 1.0)
    z *= Complex(0.0, 1.0)
    XCTAssertEqual(z, Complex(1.0, 0.0))
    XCTAssertEqual(Complex(3.0, -4.0).magnitude, 4.0)
    func generic<N: SignedNumeric>(_ x: N) -> N { return x * x + x }
    XCTAssertEqual(generic(Complex(0.0, 1.0)), Complex(-1.0, 1.0))
  }
}

extension RegressionTests {

  func testBigIntegerLiterals() {
    // Values around the boundaries of 32 and 64 bit words
    XCTAssertEqual(("0" as BigInt).description, "0")
    let zero: BigInt = 0
    XCTAssertEqual(zero, BigInt(0))
    XCTAssertEqual(1 as BigInt, BigInt(1))
    XCTAssertEqual(-1 as BigInt, BigInt(-1))
    XCTAssertEqual(4294967295 as BigInt, BigInt(UInt32.max))
    XCTAssertEqual(4294967296 as BigInt, BigInt(1) << 32)
    XCTAssertEqual(-4294967296 as BigInt, -(BigInt(1) << 32))
    XCTAssertEqual(9223372036854775807 as BigInt, BigInt(Int64.max))
    XCTAssertEqual(-9223372036854775808 as BigInt, BigInt(Int64.min))
    XCTAssertEqual(9223372036854775808 as BigInt, BigInt(1) << 63)
    XCTAssertEqual(-9223372036854775809 as BigInt, -(BigInt(1) << 63) - BigInt(1))
    XCTAssertEqual(18446744073709551615 as BigInt, BigInt(UInt64.max))
    XCTAssertEqual(18446744073709551616 as BigInt, BigInt(1) << 64)
    XCTAssertEqual(-18446744073709551616 as BigInt, -(BigInt(1) << 64))
    XCTAssertEqual(-18446744073709551617 as BigInt, -(BigInt(1) << 64) - BigInt(1))
    XCTAssertEqual(340282366920938463463374607431768211455 as BigInt, (BigInt(1) << 128) - BigInt(1))
    XCTAssertEqual(340282366920938463463374607431768211456 as BigInt, BigInt(1) << 128)
    XCTAssertEqual(-340282366920938463463374607431768211456 as BigInt, -(BigInt(1) << 128))
    // Long literals, compared with parsed strings
    let positive: BigInt = 98724897408742085724085724524524524524524522454525245999098037580357603865
    XCTAssertEqual(positive, BigInt(from: "98724897408742085724085724524524524524524522454525245999098037580357603865"))
    let negative: BigInt = -987248974087420857240857245245245245245245224545252459990980375803576038650
    XCTAssertEqual(negative, BigInt(from: "-987248974087420857240857245245245245245245224545252459990980375803576038650"))
    // Other radixes and digit separators
    XCTAssertEqual(0xFFFF_FFFF_FFFF_FFFF_FFFF as BigInt, (BigInt(1) << 80) - BigInt(1))
    XCTAssertEqual(0b1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000 as BigInt, BigInt(1) << 64)
    XCTAssertEqual(0o7777777777777777777777777 as BigInt, (BigInt(1) << 75) - BigInt(1))
    XCTAssertEqual(1_000_000_000_000_000_000_000_000 as BigInt, BigInt(10).toPower(of: BigInt(24)))
    // Literals in arithmetic expressions and generic contexts
    let x: BigInt = 123456789012345678901234567890
    XCTAssertEqual(x + 1, BigInt(from: "123456789012345678901234567891"))
    XCTAssertEqual(x * 2 - 1, BigInt(from: "246913578024691357802469135779"))
    XCTAssertEqual(x % 10, BigInt(0))
    func double<T: ExpressibleByIntegerLiteral & Numeric>(_ value: T) -> T { return value * 2 }
    XCTAssertEqual(double(x), BigInt(from: "246913578024691357802469135780"))
    XCTAssertEqual([1, 2, 3, 400000000000000000000] as [BigInt],
                   [BigInt(1), BigInt(2), BigInt(3), BigInt(from: "400000000000000000000")!])
  }

  func testBigIntegerLiteralsForInteger() {
    let small: Integer = 9223372036854775807
    if case .int(let value) = small {
      XCTAssertEqual(value, Int64.max)
    } else {
      XCTFail("small literals must be stored as native integers")
    }
    let min: Integer = -9223372036854775808
    if case .int(let value) = min {
      XCTAssertEqual(value, Int64.min)
    } else {
      XCTFail("Int64.min must be stored as a native integer")
    }
    let large: Integer = 9223372036854775808
    if case .bigInt(let value) = large {
      XCTAssertEqual(value, BigInt(1) << 63)
    } else {
      XCTFail("large literals must be stored as big integers")
    }
    XCTAssertEqual(-9223372036854775809 as Integer, Integer(Int64.min) - Integer(1))
    XCTAssertEqual(314159265358979323846264338328 as Integer + 1,
                   Integer(BigInt(from: "314159265358979323846264338329")!))
    XCTAssertEqual(0xFFFF_FFFF_FFFF_FFFF_FFFF as Integer, (Integer(1) << 80) - Integer(1))
    XCTAssertEqual(0 as Integer, Integer(0))
  }
}

private enum LosslessStringConvertibleHelper {
  static func make<T: LosslessStringConvertible>(_ text: String) -> T? {
    return T(text)
  }
}
