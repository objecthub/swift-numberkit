//
//  PropertyTests.swift
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

/// Tests of mathematical identities for complex functions, and of the `Hashable` and
/// `Sendable` conformances of all number types.
class PropertyTests: XCTestCase {

  private func assertClose(_ x: Complex<Double>, _ y: Complex<Double>,
                           tolerance: Double = 1e-9, _ message: String = "",
                           line: UInt = #line) {
    let scale = Swift.max(1.0, y.abs)
    XCTAssert((x - y).abs <= tolerance * scale, "\(x) is not close to \(y) \(message)", line: line)
  }

  private func randomComplex(real: Range<Double>, imaginary: Range<Double>) -> Complex<Double> {
    var generator = SystemRandomNumberGenerator()
    return Complex.random(realRange: real, imaginaryRange: imaginary, using: &generator)
  }

  func testKnownComplexValues() {
    assertClose(exp(Complex(0.0, Double.pi)), Complex(-1.0, 0.0))
    assertClose(exp(Complex(0.0, 0.0)), Complex(1.0, 0.0))
    assertClose(log(Complex(1.0, 0.0)), Complex(0.0, 0.0))
    assertClose(log(Complex(-1.0, 0.0)), Complex(0.0, Double.pi))
    assertClose(log(Complex(0.0, 1.0)), Complex(0.0, Double.pi / 2))
    assertClose(sin(Complex(0.0, 1.0)), Complex(0.0, sinh(1.0)))
    assertClose(cos(Complex(0.0, 1.0)), Complex(cosh(1.0), 0.0))
    assertClose(sinh(Complex(0.0, Double.pi / 2)), Complex(0.0, 1.0))
    assertClose(cosh(Complex(0.0, Double.pi)), Complex(-1.0, 0.0))
    assertClose(sin(Complex(Double.pi / 6, 0.0)), Complex(0.5, 0.0))
    assertClose(cos(Complex(Double.pi / 3, 0.0)), Complex(0.5, 0.0))
    assertClose(tan(Complex(Double.pi / 4, 0.0)), Complex(1.0, 0.0))
    assertClose(asin(Complex(1.0, 0.0)), Complex(Double.pi / 2, 0.0))
    assertClose(acos(Complex(1.0, 0.0)), Complex(0.0, 0.0))
    assertClose(acos(Complex(0.0, 0.0)), Complex(Double.pi / 2, 0.0))
    assertClose(atan(Complex(1.0, 0.0)), Complex(Double.pi / 4, 0.0))
    assertClose(asinh(Complex(0.0, 0.0)), Complex(0.0, 0.0))
    assertClose(acosh(Complex(1.0, 0.0)), Complex(0.0, 0.0))
    assertClose(atanh(Complex(0.0, 0.0)), Complex(0.0, 0.0))
    assertClose(Complex(0.0, 1.0).toPower(of: Complex(0.0, 1.0)), Complex(exp(-Double.pi / 2), 0.0))
  }

  func testComplexIdentities() {
    for _ in 0..<300 {
      let z = randomComplex(real: -3.0..<3.0, imaginary: -3.0..<3.0)
      // Pythagorean identities
      assertClose(sin(z) * sin(z) + cos(z) * cos(z), Complex(1.0, 0.0), tolerance: 1e-8, "z = \(z)")
      assertClose(cosh(z) * cosh(z) - sinh(z) * sinh(z), Complex(1.0, 0.0), tolerance: 1e-8, "z = \(z)")
      // Euler's formula and relation between exponential and logarithm
      assertClose(exp(z.i), cos(z) + sin(z).i, tolerance: 1e-8, "z = \(z)")
      assertClose(exp(log(z)), z, "z = \(z)")
      // Quotient identities
      assertClose(tan(z), sin(z) / cos(z), tolerance: 1e-8, "z = \(z)")
      assertClose(tanh(z), sinh(z) / cosh(z), tolerance: 1e-8, "z = \(z)")
      // Hyperbolic functions are related to the trigonometric functions
      assertClose(sinh(z), sin(z.i).i.negate, tolerance: 1e-8, "z = \(z)")
      assertClose(cosh(z), cos(z.i), tolerance: 1e-8, "z = \(z)")
      // Square roots and powers
      assertClose(z.sqrt * z.sqrt, z)
      assertClose(z.toPower(of: Complex(2.0, 0.0)), z * z)
      assertClose(z * z.reciprocal, Complex(1.0, 0.0))
      assertClose(z / z, Complex(1.0, 0.0))
      assertClose(z.conjugate.conjugate, z)
      XCTAssertEqual(z.norm, z.abs)
      XCTAssertEqual((z * z.conjugate).re, z.abs * z.abs, accuracy: 1e-9)
    }
  }

  func testComplexInverseFunctions() {
    for _ in 0..<300 {
      // The inverse functions are only the identity in their principal ranges
      let z = randomComplex(real: -1.2..<1.2, imaginary: -1.2..<1.2)
      assertClose(sin(asin(z)), z, tolerance: 1e-8, "z = \(z)")
      assertClose(cos(acos(z)), z, tolerance: 1e-8, "z = \(z)")
      assertClose(tan(atan(z)), z, tolerance: 1e-8, "z = \(z)")
      assertClose(sinh(asinh(z)), z, tolerance: 1e-8, "z = \(z)")
      assertClose(cosh(acosh(z)), z, tolerance: 1e-8, "z = \(z)")
      assertClose(tanh(atanh(z)), z, tolerance: 1e-8, "z = \(z)")
      let w = randomComplex(real: -1.2..<1.2, imaginary: -1.2..<1.2)
      assertClose(asin(sin(w)), w, tolerance: 1e-8, "w = \(w)")
      assertClose(atan(tan(w)), w, tolerance: 1e-8, "w = \(w)")
      assertClose(asinh(sinh(w)), w, tolerance: 1e-8, "w = \(w)")
      assertClose(atanh(tanh(w)), w, tolerance: 1e-8, "w = \(w)")
    }
  }

  func testComplexSpecialValues() {
    XCTAssert(Complex(Double.nan, 1.0).isNaN)
    XCTAssert(Complex(1.0, Double.nan).isNaN)
    XCTAssert((Complex(Double.nan, 0.0) + Complex(1.0, 1.0)).isNaN)
    XCTAssert(Complex(Double.infinity, 0.0).isInfinite)
    XCTAssertEqual(Complex(Double.infinity, 5.0), Complex(Double.infinity, 0.0))
    XCTAssert(exp(Complex(1000.0, 0.0)).isInfinite)
    XCTAssert(exp(Complex(-1000.0, 0.0)).isZero)
    XCTAssertEqual(Complex(0.0, 0.0).reciprocal, Complex.infinity)
    XCTAssertEqual(Complex(Double.infinity, 0.0).reciprocal, Complex.zero)
    XCTAssertEqual(Complex(3.0, 4.0).abs, 5.0)
    XCTAssertEqual(Complex(3.0, 4.0).arg, atan2(4.0, 3.0))
    XCTAssertEqual(Complex(abs: 5.0, arg: 0.0), Complex(5.0, 0.0))
    XCTAssertEqual(Complex(3.0, 4.0).magnitude, 4.0)
    XCTAssertEqual(Complex(3.0, 4.0).norm, 5.0)
  }

  // MARK: Hashable

  private func assertHashing<T: Hashable>(_ values: [T], line: UInt = #line) {
    // All elements of `values` are expected to be equal
    for x in values {
      for y in values {
        XCTAssertEqual(x, y, line: line)
        XCTAssertEqual(x.hashValue, y.hashValue, "\(x) vs \(y)", line: line)
      }
    }
    XCTAssertEqual(Set(values).count, 1, line: line)
  }

  func testBigIntHashing() {
    assertHashing([BigInt(1234567890123), BigInt(from: "1234567890123")!,
                   BigInt("1234567890123", radix: 10)!, BigInt(1234567890123 as Int64),
                   BigInt(1) << 40 + BigInt(1234567890123 - (1 << 40)),
                   BigInt(1234567890124) - BigInt(1), BigInt(UInt64(1234567890123))])
    assertHashing([BigInt(0), BigInt(5) - BigInt(5), BigInt(-0), BigInt(5) >> 10, BigInt(0) << 100,
                   BigInt(-1) + BigInt(1), BigInt(7) % BigInt(7), BigInt(0).negate])
    assertHashing([BigInt(-42), BigInt(42).negate, BigInt(-42 as Int8), BigInt(from: "-42")!])
    let big = BigInt(10).toPower(of: BigInt(50))
    assertHashing([big, BigInt(from: "1" + String(repeating: "0", count: 50))!,
                   (big * BigInt(7)) / BigInt(7), big + BigInt(0), (big << 3) >> 3])
    XCTAssertNotEqual(BigInt(5).hashValue, BigInt(-5).hashValue)
    XCTAssertEqual(Set([BigInt(1), BigInt(2), BigInt(1), BigInt(-1), BigInt(2)]).count, 3)
  }

  func testIntegerHashing() {
    assertHashing([Integer.int(42), Integer.bigInt(BigInt(42)), Integer(BigInt(42)),
                   Integer(40) + Integer(2), Integer(BigInt(from: "42")!), Integer(42 as Int32)])
    let huge = Integer(BigInt(from: "1" + String(repeating: "0", count: 40))!)
    assertHashing([huge, huge * Integer(1), (huge + Integer(1)) - Integer(1)])
    assertHashing([Integer(Int64.min), Integer(BigInt(Int64.min)),
                   Integer(Int64.min + 1) - Integer(1), -(Integer(Int64.max) + Integer(1))])
    XCTAssertEqual(Set([Integer.int(5), Integer.bigInt(BigInt(5)), Integer(10) / Integer(2)]).count, 1)
  }

  func testRationalHashing() {
    assertHashing([Rational<Int>(1, 2), Rational<Int>(2, 4), Rational<Int>(-1, -2),
                   Rational<Int>(50, 100), Rational<Int>(from: "3/6")!, 1 / 2,
                   Rational<Int>(1, 4) + Rational<Int>(1, 4)])
    assertHashing([Rational<Int>(0, 5), Rational<Int>(0, -3), Rational<Int>(0), 0])
    assertHashing([Rational<BigInt>(BigInt(2), BigInt(6)), Rational<BigInt>(BigInt(-1), BigInt(-3)),
                   Rational<BigInt>(BigInt(10).toPower(of: BigInt(30)),
                                    BigInt(3) * BigInt(10).toPower(of: BigInt(30)))])
    XCTAssertNotEqual(Rational<Int>(1, 2).hashValue, Rational<Int>(-1, 2).hashValue)
  }

  func testComplexHashing() {
    assertHashing([Complex(1.0, 2.0), Complex(1.0, 2.0) + Complex(0.0, 0.0), Complex("1+2i")!,
                   Complex(2.0, 4.0) / Complex(2.0, 0.0)])
    assertHashing([Complex(0.0, 0.0), Complex(-0.0, 0.0), Complex(0.0, -0.0), Complex.zero])
    assertHashing([Complex(Double.infinity, 1.0), Complex(Double.infinity, 5.0), Complex.infinity])
    XCTAssertEqual(Set([Complex(1.0, 1.0), Complex(1.0, 1.0), Complex(1.0, -1.0)]).count, 2)
  }

  // MARK: Sendable and Codable

  func testSendable() async {
    func requireSendable<T: Sendable>(_ value: T) -> T { return value }
    let big = requireSendable(BigInt(10).toPower(of: BigInt(30)))
    let integer = requireSendable(Integer(big))
    let rational = requireSendable(Rational<BigInt>(big, BigInt(7)))
    let fixed = requireSendable(Rational<Int>(1, 3))
    let complex = requireSendable(Complex(1.0, 2.0))
    let base = requireSendable(BigInt.hexBase)
    // Use the values concurrently
    async let a = Task { big.toString(base: base) }.value
    async let b = Task { integer * integer }.value
    async let c = Task { rational + rational }.value
    async let d = Task { fixed * fixed }.value
    async let e = Task { complex * complex }.value
    let results = await (a, b, c, d, e)
    XCTAssertEqual(results.0, "C9F2C9CD04674EDEA40000000")
    XCTAssertEqual(results.1, integer * integer)
    XCTAssertEqual(results.2, rational + rational)
    XCTAssertEqual(results.3, Rational<Int>(1, 9))
    XCTAssertEqual(results.4, Complex(-3.0, 4.0))
  }

  func testCodableRoundTrips() throws {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    var generator = SystemRandomNumberGenerator()
    for _ in 0..<50 {
      let n = BigInt(randomWithMaxBits: Int.random(in: 1...300, using: &generator), using: &generator)
      let x = Bool.random() ? n : -n
      XCTAssertEqual(try decoder.decode([BigInt].self, from: try encoder.encode([x])), [x])
      XCTAssertEqual(try decoder.decode([Integer].self, from: try encoder.encode([Integer(x)])), [Integer(x)])
      let r = Rational<BigInt>(x, n + BigInt(1))
      XCTAssertEqual(try decoder.decode(Rational<BigInt>.self, from: try encoder.encode(r)), r)
    }
    let z = Complex(1.5, -2.25)
    XCTAssertEqual(try decoder.decode(Complex<Double>.self, from: try encoder.encode(z)), z)
    let q = Rational<Int>(-7, 21)
    XCTAssertEqual(try decoder.decode(Rational<Int>.self, from: try encoder.encode(q)), q)
  }
}
