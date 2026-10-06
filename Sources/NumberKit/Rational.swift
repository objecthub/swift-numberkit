//
//  Rational.swift
//  NumberKit
//
//  Created by Matthias Zenger on 04/08/2015.
//  Copyright © 2015-2026 Matthias Zenger. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,x either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

// Arithmetic on `Rational` values based on fixed-width integers traps on overflow. The
// `*ReportingOverflow` methods can be used to detect overflows. The initializer
// `Rational(_:_:)` and the static `gcd` and `lcm` functions ignore overflow; they may
// return incorrect results if the result is not representable.

/// The `RationalNumber` protocol defines an interface for rational numbers. A rational
/// number is a signed number that can be expressed as the quotient of two integers
/// a and b: a / b. a is called the numerator, b is called the denominator. b must
/// not be zero.
public protocol RationalNumber: SignedNumeric,
                                Comparable,
                                Hashable,
                                CustomStringConvertible {

  /// The integer type on which this rational number is based.
  associatedtype Integer: IntegerNumber

  /// The numerator of this rational number.
  var numerator: Integer { get }

  /// The denominator of this rational number.
  var denominator: Integer { get }

  /// Returns the `Rational` as a value of type `Integer` if this is possible. If the number
  /// cannot be expressed as a `Integer`, this property returns `nil`.
  var intValue: Integer? { get }

  /// Returns the `Rational` value as a float value
  var floatValue: Float { get }

  /// Returns the `Rational` value as a double value
  var doubleValue: Double { get }

  /// Is true if the rational value is negative.
  var isNegative: Bool { get }

  /// Is true if the rational value is zero.
  var isZero: Bool { get }

  /// The absolute rational value (without sign).
  var abs: Self { get }

  /// The negated rational value.
  var negate: Self { get }

  /// Returns -1 if `self` is less than `rhs`,
  ///          0 if `self` is equals to `rhs`,
  ///         +1 if `self` is greater than `rhs`
  func compare(to rhs: Self) -> Int

  /// Returns the sum of this rational value and `rhs`.
  func plus(_ rhs: Self) -> Self

  /// Returns the difference between this rational value and `rhs`.
  func minus(_ rhs: Self) -> Self

  /// Multiplies this rational value with `rhs` and returns the result.
  func times(_ rhs: Self) -> Self

  /// Divides this rational value by `rhs` and returns the result.
  func divided(by rhs: Self) -> Self

  /// Raises this rational value to the power of `exp`.
  func toPower(of exp: Integer) -> Self

  /// Adds `rhs` to `self` and reports the result together with a boolean indicating an overflow.
  func addingReportingOverflow(_ rhs: Self) -> (partialValue: Self, overflow: Bool)

  /// Subtracts `rhs` from `self` and reports the result together with a boolean indicating
  /// an overflow.
  func subtractingReportingOverflow(_ rhs: Self) -> (partialValue: Self, overflow: Bool)

  /// Multiplies `rhs` with `self` and reports the result together with a boolean indicating
  /// an overflow.
  func multipliedReportingOverflow(by rhs: Self) -> (partialValue: Self, overflow: Bool)

  /// Divides `self` by `rhs` and reports the result together with a boolean indicating
  /// an overflow.
  func dividedReportingOverflow(by rhs: Self) -> (partialValue: Self, overflow: Bool)

  /// Returns the greatest common denominator for `self` and `y` and a boolean which indicates
  /// whether there was an overflow.
  func gcdReportingOverflow(with y: Self) -> (partialValue: Self, overflow: Bool)

  /// Returns the least common multiplier for `self` and `y` and a boolean which indicates
  /// whether there was an overflow.
  func lcmReportingOverflow(with y: Self) -> (partialValue: Self, overflow: Bool)
}

/// Struct `Rational<T>` implements the `RationalNumber` interface on top of the
/// integer type `T`. `Rational<T>` always represents rational numbers in normalized
/// form such that the greatest common divisor of the numerator and the denominator
/// is always 1. In addition, the sign of the rational number is defined by the
/// numerator. The denominator is always positive.
public struct Rational<T: IntegerNumber>: RationalNumber, CustomStringConvertible {

  /// The numerator of this rational number. This is a signed integer.
  public let numerator: T

  /// The denominator of this rational number. This integer is always positive.
  public let denominator: T

  /// Sets numerator and denominator without normalization. This function must not be called
  /// outside of the NumberKit framework.
  private init(numerator: T, denominator: T) {
    self.numerator = numerator
    self.denominator = denominator
  }

  /// Creates a rational number from a given numerator and denominator, ignoring overflow;
  /// it creates an incorrect result iff the correct result is not expressible in the given type.
  public init(_ numerator: T, _ denominator: T) {
    precondition(denominator != 0, "rational with zero denominator")
    self = Rational.rationalWithOverflow(numerator, denominator).0 // Ignore overflow
  }

  /// Creates a `Rational` from the given integer value of type `T`
  public init(_ value: T) {
    self.init(numerator: value, denominator: T.one)
  }

  /// Creates a rational number by rationalizing a `Double` value.
  public init(_ value: Double, precision: Double = 1.0e-8) {
    var x = value
    var a = Foundation.floor(x)
    var (h1, k1, h, k) = (T.one, T.zero, T(a), T.one)
    while x - a > precision * k.doubleValue * k.doubleValue {
      x = 1.0/(x - a)
      a = Foundation.floor(x)
      (h1, k1, h, k) = (h, k, h1 + T(a) * h, k1 + T(a) * k)
    }
    self.init(numerator: h, denominator: k)
  }

  /// Create an instance initialized to `value`.
  public init(integerLiteral value: Int64) {
    self.init(T(value))
  }

  public init?<S: BinaryInteger>(exactly source: S) {
    if let numerator = T(exactly: source) {
      self.init(numerator)
    } else {
      return nil
    }
  }

  /// Creates a `Rational` from a string containing a rational number using the base
  /// defined by parameter `radix`. The syntax of the rational number is defined as follows:
  ///
  ///    Rational    = Numerator '/' Denominator
  ///                | SignedInteger
  ///    Numerator   = SignedInteger
  ///    Denominator = SignedInteger
  public init?(from str: String, radix: Int = 10) {
    precondition(radix >= 2 && radix <= 36, "radix between 2 and 36 required")
    // Parse via `BigInt` such that numbers of any size are supported
    func parse(_ text: Substring) -> T? {
      guard let value = BigInt(String(text), radix: radix) else {
        return nil
      }
      return T(exactly: value)
    }
    if let idx = str.firstIndex(of: rationalSeparator) {
      guard let numVal = parse(str[..<idx]),
            let denomVal = parse(str[str.index(after: idx)...]),
            denomVal != 0 else {
        return nil
      }
      self.init(numVal, denomVal)
    } else if let value = parse(str[...]) {
      self.init(value)
    } else {
      return nil
    }
  }

  /// Returns the `Rational` as a value of type `T` if this is possible. If the number
  /// cannot be expressed as a `T`, this property returns `nil`.
  public var intValue: T? {
    guard denominator == T.one else {
      return nil
    }
    return numerator
  }

  /// Returns the `Rational` value as a float value
  public var floatValue: Float {
    return Float(self.doubleValue)
  }

  /// Returns the `Rational` value as a double value
  public var doubleValue: Double {
    let (num, denom) = (self.numerator.doubleValue, self.denominator.doubleValue)
    // Numbers up to 2^53 are represented exactly by `Double`, so the division is correctly
    // rounded. Otherwise, avoid overflows and double rounding by using `BigInt`.
    if Swift.abs(num) <= 9007199254740992.0 && denom <= 9007199254740992.0 {
      return num / denom
    }
    return BigInt.doubleValue(numerator: BigInt(self.numerator),
                              denominator: BigInt(self.denominator))
  }

  /// Returns a string representation of this `Rational<T>` number using base 10.
  public var description: String {
    return self.denominator == 1 || self.numerator == 0 ?
             self.numerator.description :
             self.numerator.description + String(rationalSeparator) + self.denominator.description
  }

  /// Returns the (non-negative) Greatest Common Divisor (GCD) of two `T: IntegerNumber`
  /// values `x` and `y`. Any overflow occurring during the gcd( is ignored.
  @available(*, deprecated, message: "moved to IntegerNumber.gcd")
  public static func gcd(_ x: T, _ y: T) -> T { T.gcd(x, y) }

  /// Compute the (non-negative) Least Common Multiple (LCM) of two `T: IntegerNumber`
  /// values `x` and `y`. Any overflow during the computation is ignored.
  @available(*, deprecated, message: "moved to IntegerNumber.lcm")
  public static func lcm(_ x: T, _ y: T) -> T { T.lcm(x, y) }

  /// Given two rational values `this` and `that`, return the two equivalent (but possibly
  /// not normalized) values `num0 / denom` and `num1 / denom`, where `denom` is the LCM of
  /// the two denominators. In case of overflow, the wrong result may be returned.
  private func commonDenomWith(_ other: Rational<T>) -> (num0: T, num1: T, denom: T) {
    let (num0, num1, denom, _) = Rational.commonDenomWithOverflow(self, other)  // Ignore overflow.
    return (num0, num1, denom)
  }

  /// For hashing values.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(numerator)
    hasher.combine(denominator)
  }

  /// The absolute rational value (without sign).
  public var abs: Rational<T> {
    return self.magnitude
  }

  /// The magnitude of the rational value.
  public var magnitude: Rational<T> {
    return numerator < 0 ? Rational(numerator: -numerator, denominator: denominator) : self
  }

  /// The negated rational value.
  public var negate: Rational<T> {
    return Rational(numerator: -numerator, denominator: denominator)
  }

  /// The reciprocal of this rational value. This value must not be zero.
  public var reciprocal: Rational<T> {
    precondition(numerator != 0, "reciprocal of zero")
    return numerator < 0 ?
        Rational(numerator: -denominator, denominator: -numerator) :
        Rational(numerator: denominator, denominator: numerator)
  }

  /// Returns this rational value rounded to an integer of type `T` using the given rounding
  /// rule. Use `.down` for the floor, `.up` for the ceiling, and `.towardZero` for
  /// truncating the fractional part.
  public func rounded(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> T {
    let quotient = numerator / denominator  // truncated towards zero
    let remainder = numerator % denominator  // has the sign of the numerator
    if remainder == 0 {
      return quotient
    }
    let negative = numerator < 0
    let away = negative ? quotient - 1 : quotient + 1
    switch rule {
      case .towardZero:
        return quotient
      case .awayFromZero:
        return away
      case .down:
        return negative ? away : quotient
      case .up:
        return negative ? quotient : away
      default:
        // Rounding to nearest: compare the distances to the two neighbouring integers
        let distance = negative ? -remainder : remainder
        let complement = denominator - distance
        if distance < complement {
          return quotient
        } else if distance > complement {
          return away
        } else if rule == .toNearestOrEven {
          return quotient.isOdd ? away : quotient
        } else {
          return away
        }
    }
  }

  /// Is true if the rational value is negative.
  public var isNegative: Bool {
    return numerator < 0
  }

  /// Is true if the rational value is zero.
  public var isZero: Bool {
    return numerator == 0
  }

  /// Returns -1 if `self` is less than `rhs`,
  ///          0 if `self` is equals to `rhs`,
  ///         +1 if `self` is greater than `rhs`
  public func compare(to rhs: Rational<T>) -> Int {
    // Both values are normalized, so equal values have identical components.
    if self.numerator == rhs.numerator && self.denominator == rhs.denominator {
      return 0
    }
    if self.denominator == rhs.denominator {
      return self.numerator < rhs.numerator ? -1 : 1
    }
    let (c1, c2, _, overflow) = Rational.commonDenomWithOverflow(self, rhs)
    if !overflow {
      return c1 == c2 ? 0 : (c1 < c2 ? -1 : 1)
    }
    // Overflow-free comparison via continued fraction expansion.
    var (n1, d1, n2, d2) = (self.numerator, self.denominator, rhs.numerator, rhs.denominator)
    while true {
      var (q1, r1) = (n1 / d1, n1 % d1)
      if r1 < 0 {
        q1 = q1 - 1
        r1 = r1 + d1
      }
      var (q2, r2) = (n2 / d2, n2 % d2)
      if r2 < 0 {
        q2 = q2 - 1
        r2 = r2 + d2
      }
      if q1 != q2 {
        return q1 < q2 ? -1 : 1
      } else if r1 == 0 || r2 == 0 {
        return r1 == r2 ? 0 : (r1 == 0 ? -1 : 1)
      }
      // r1/d1 < r2/d2 iff d2/r2 < d1/r1; swapping the operands keeps the direction
      (n1, d1, n2, d2) = (d2, r2, d1, r1)
    }
  }

  /// Returns the sum of this rational value and `rhs`.
  public func plus(_ rhs: Rational<T>) -> Rational<T> {
    let (res, overflow) = self.addingReportingOverflow(rhs)
    precondition(!overflow, "arithmetic overflow")
    return res
  }

  /// Returns the difference between this rational value and `rhs`.
  public func minus(_ rhs: Rational<T>) -> Rational<T> {
    let (res, overflow) = self.subtractingReportingOverflow(rhs)
    precondition(!overflow, "arithmetic overflow")
    return res
  }

  /// Multiplies this rational value with `rhs` and returns the result.
  public func times(_ rhs: Rational<T>) -> Rational<T> {
    if self.numerator == 0 || rhs.numerator == 0 {
      return Rational(numerator: 0, denominator: 1)
    }
    // Reducing crosswise first yields a normalized result, avoids overflows and keeps
    // the numbers smaller.
    let (g1, overflow1) = T.gcdWithOverflow(self.numerator, rhs.denominator)
    let (g2, overflow2) = T.gcdWithOverflow(rhs.numerator, self.denominator)
    guard !overflow1 && !overflow2 else {
      return Rational(self.numerator * rhs.numerator, self.denominator * rhs.denominator)
    }
    return Rational(numerator: (self.numerator / g1) * (rhs.numerator / g2),
                    denominator: (self.denominator / g2) * (rhs.denominator / g1))
  }

  /// Divides this rational value by `rhs` and returns the result.
  public func divided(by rhs: Rational<T>) -> Rational<T> {
    precondition(rhs.numerator != 0, "division by zero")
    let reciprocal = rhs.numerator < 0 ?
        Rational(numerator: -rhs.denominator, denominator: -rhs.numerator) :
        Rational(numerator: rhs.denominator, denominator: rhs.numerator)
    return self.times(reciprocal)
  }

  /// Raises this rational value to the power of `exp`.
  public func toPower(of exp: T) -> Rational<T> {
    precondition(exp >= 0 || numerator != 0, "zero raised to a negative power")
    if (exp < 0) {
      return Rational(denominator.toPower(of: -exp), numerator.toPower(of: -exp))
    } else {
      return Rational(numerator.toPower(of: exp), denominator.toPower(of: exp))
    }
  }

  /// Returns the greatest common denominator (GCD) of the two given rational numbers, ignoring
  /// overflow; it may return an incorrect result if overflow occurs during the computation.
  public static func gcd(_ x: Rational<T>, _ y: Rational<T>) -> Rational<T> {
    return Rational(T.gcd(x.numerator, y.numerator), T.lcm(x.denominator, y.denominator))
  }

  /// Returns the least common multiple (LCM) of the two given rational numbers, ignoring
  /// overflow; it may return an incorrect result if overflow occurs during the computation.
  public static func lcm(_ x: Rational<T>, _ y: Rational<T>) -> Rational<T> {
    let (xn, yn, denom) = x.commonDenomWith(y)
    return Rational(T.lcm(xn, yn), denom)
  }
}

/// This extension implements the boilerplate to make `Rational` compatible
/// to the applicable Swift 4 protocols. `Rational` is convertible from Strings and
/// implements basic arithmetic operations which keep track of overflows.
extension Rational: ExpressibleByStringLiteral {

  public init(stringLiteral value: String) {
    if let rat = Rational(from: value) {
      self.init(numerator: rat.numerator, denominator: rat.denominator)
    } else {
      self.init(0)
    }
  }

  public init(extendedGraphemeClusterLiteral value: String) {
    self.init(stringLiteral: value)
  }

  public init(unicodeScalarLiteral value: String) {
    self.init(stringLiteral: value)
  }

  /// Creates a rational number from a given numerator and denominator, along with a Boolean
  /// indicating whether overflow occurred in the operation, iff the correct value is not
  /// representable in the given type.
  public static func rationalWithOverflow(_ numerator: T, _ denominator: T) ->
                                         (value: Rational<T>, overflow: Bool) {
    guard denominator != 0 else {
      return (0, true)
    }
    // Eliminate special cases early that might otherwise report overflow.
    if denominator == 1 {
      return (Rational(numerator), false)
    } else if numerator == 0 {
      return (0, false)
    } else if numerator == denominator {
      return (1, false)
    }
    // Numerator and denominator are now both non-zero.
    let gcd = T.gcd(numerator, denominator) // Safe: numerator != denominator.
    let normalizedNumerator = numerator / gcd // Safe: gcd is positive and divides numerator.
    let normalizedDenominator = denominator / gcd // Safe: gcd is positive and divides denominator.
    // Overflows if numerator == T.min and denominator is odd.
    let (absNumerator, numeratorOverflow) = T.absWithOverflow(normalizedNumerator)
    // Overflows if denominator == T.min and numerator is odd.
    let (absDenominator, denominatorOverflow) = T.absWithOverflow(normalizedDenominator)
    // The rational value `absNumerator / absDenominator` is already normalized.
    let resultNumerator = (numerator > 0) == (denominator > 0) ? absNumerator : -absNumerator
    let resultOverflow = numeratorOverflow || denominatorOverflow
    return (Rational(numerator: resultNumerator, denominator: absDenominator), resultOverflow)
  }

  /// Given two rational values `this` and `that`, return the two equivalent (but possibly not
  /// normalized) values `num0 / denom` and `num1 / denom`, where `denom` is the LCM is the two
  /// denominators, together with a Boolean indicating whether overflow occurred during the
  /// computation, iff the result cannot be represented in this type.
  private static func commonDenomWithOverflow(_ this: Rational<T>, _ that: Rational<T>) ->
                                             (num0: T, num1: T, denom: T, overflow: Bool) {
    let (lcmOfDenominators, lcmOverflow) = T.lcmWithOverflow(this.denominator, that.denominator)
    let (num0, num0Overflow) = this.numerator.multipliedReportingOverflow(
      by: lcmOfDenominators / this.denominator)
    let (num1, num1Overflow) = that.numerator.multipliedReportingOverflow(
      by: lcmOfDenominators / that.denominator)
    return (num0, num1, lcmOfDenominators, lcmOverflow || num0Overflow || num1Overflow)
  }

  /// Returns the (non-negative) Greatest Common Divisor (GCD) of two `T: IntegerNumber`
  /// values `x` and `y`, together with a Boolean indicating whether overflow occurred
  /// during the computation, in which case the result may be wrong.
  @available(*, deprecated, message: "moved to IntegerNumber.gcdWithOverflow")
  public static func gcdWithOverflow(_ x: T, _ y: T) -> (T, Bool) {
    return T.gcdWithOverflow(x, y)
  }

  /// Returns the (non-negative) Least Common Multiple (LCM) of two `T: IntegerNumber`
  /// values `x` and `y`, together with a Boolean indicating whether overflow occurred
  /// during the computation, in which case the result may be wrong.
  @available(*, deprecated, message: "moved to IntegerNumber.lcmWithOverflow")
  public static func lcmWithOverflow(_ x: T, _ y: T) -> (T, Bool) {
    return T.lcmWithOverflow(x, y)
  }

  /// Add `self` and `rhs` and return a tuple consisting of the result and a boolean which
  /// indicates whether there was an overflow.
  public func addingReportingOverflow(_ rhs: Rational<T>)
                                  -> (partialValue: Rational<T>, overflow: Bool) {
    let (n1, n2, denom, overflow1) = Rational.commonDenomWithOverflow(self, rhs)
    let (numer, overflow2) = n1.addingReportingOverflow(n2)
    let (res, overflow3) = Rational.rationalWithOverflow(numer, denom)
    return (res, overflow1 || overflow2 || overflow3)
  }

  /// Subtract `rhs` from `self` and return a tuple consisting of the result and a boolean which
  /// indicates whether there was an overflow.
  public func subtractingReportingOverflow(_ rhs: Rational<T>)
                                       -> (partialValue: Rational<T>, overflow: Bool) {
    let (n1, n2, denom, overflow1) = Rational.commonDenomWithOverflow(self, rhs)
    let (numer, overflow2) = n1.subtractingReportingOverflow(n2)
    let (res, overflow3) = Rational.rationalWithOverflow(numer, denom)
    return (res, overflow1 || overflow2 || overflow3)
  }

  /// Multiply `self` and `rhs` and return a tuple consisting of the result and a boolean which
  /// indicates whether there was an overflow.
  public func multipliedReportingOverflow(by rhs: Rational<T>)
                                      -> (partialValue: Rational<T>, overflow: Bool) {
    let (numer, overflow1) = self.numerator.multipliedReportingOverflow(by: rhs.numerator)
    let (denom, overflow2) = self.denominator.multipliedReportingOverflow(by: rhs.denominator)
    let (res, overflow3) = Rational.rationalWithOverflow(numer, denom)
    return (res, overflow1 || overflow2 || overflow3)
  }

  /// Divide `lhs` by `rhs` and return a tuple consisting of the result and a boolean which
  /// indicates whether there was an overflow.
  public func dividedReportingOverflow(by rhs: Rational<T>)
                                   -> (partialValue: Rational<T>, overflow: Bool) {
    let (numer, overflow1) = self.numerator.multipliedReportingOverflow(by: rhs.denominator)
    let (denom, overflow2) = self.denominator.multipliedReportingOverflow(by: rhs.numerator)
    let (res, overflow3) = Rational.rationalWithOverflow(numer, denom)
    return (res, overflow1 || overflow2 || overflow3)
  }

  /// Returns the greatest common denominator for `self` and `y` and a boolean which indicates
  /// whether there was an overflow.
  public func gcdReportingOverflow(with y: Rational<T>)
                               -> (partialValue: Rational<T>, overflow: Bool) {
    let (numer, overflow1) = T.gcdWithOverflow(self.numerator, y.numerator)
    let (denom, overflow2) = T.lcmWithOverflow(self.denominator, y.denominator)
    return (Rational(numer, denom), overflow1 || overflow2)
  }

  /// Returns the least common multiplier for `self` and `y` and a boolean which indicates
  /// whether there was an overflow.
  public func lcmReportingOverflow(with y: Rational<T>)
                               -> (partialValue: Rational<T>, overflow: Bool) {
    let (xn, yn, denom, overflow1) = Rational.commonDenomWithOverflow(self, y)
    let (numer, overflow2) = T.lcmWithOverflow(xn, yn)
    return (Rational(numer, denom), overflow1 || overflow2)
  }
}

/// Negates `num`.
public prefix func - <R: RationalNumber>(num: R) -> R {
  return num.negate
}

/// Returns the sum of `lhs` and `rhs`.
public func + <R: RationalNumber>(lhs: R, rhs: R) -> R {
  return lhs.plus(rhs)
}

/// Returns the difference between `lhs` and `rhs`.
public func - <R: RationalNumber>(lhs: R, rhs: R) -> R {
  return lhs.minus(rhs)
}

/// Multiplies `lhs` with `rhs` and returns the result.
public func * <R: RationalNumber>(lhs: R, rhs: R) -> R {
  return lhs.times(rhs)
}

/// Divides `lhs` by `rhs` and returns the result.
public func / <R: RationalNumber>(lhs: R, rhs: R) -> R {
  return lhs.divided(by: rhs)
}

/// Divides `lhs` by `rhs` and returns the result.
public func / <T: SignedInteger>(lhs: T, rhs: T) -> Rational<T> {
  return Rational(lhs, rhs)
}

/// Raises rational value `lhs` to the power of `exp`.
public func ** <R: RationalNumber>(lhs: R, exp: R.Integer) -> R {
  return lhs.toPower(of: exp)
}

/// Assigns `lhs` the sum of `lhs` and `rhs`.
public func += <R: RationalNumber>(lhs: inout R, rhs: R) {
  lhs = lhs.plus(rhs)
}

/// Assigns `lhs` the difference between `lhs` and `rhs`.
public func -= <R: RationalNumber>(lhs: inout R, rhs: R) {
  lhs = lhs.minus(rhs)
}

/// Assigns `lhs` the result of multiplying `lhs` with `rhs`.
public func *= <R: RationalNumber>(lhs: inout R, rhs: R) {
  lhs = lhs.times(rhs)
}

/// Assigns `lhs` the result of dividing `lhs` by `rhs`.
public func /= <R: RationalNumber>(lhs: inout R, rhs: R) {
  lhs = lhs.divided(by: rhs)
}

/// Assigns `lhs` the result of raising rational value `lhs` to the power of `exp`.
public func **= <R: RationalNumber>(lhs: inout R, exp: R.Integer) {
  lhs = lhs.toPower(of: exp)
}

/// Returns the sum of `lhs` and `rhs`.
public func &+ <R: RationalNumber>(lhs: R, rhs: R) -> R {
  return lhs.addingReportingOverflow(rhs).partialValue
}

/// Returns the difference between `lhs` and `rhs`.
public func &- <R: RationalNumber>(lhs: R, rhs: R) -> R {
  return lhs.subtractingReportingOverflow(rhs).partialValue
}

/// Multiplies `lhs` with `rhs` and returns the result.
public func &* <R: RationalNumber>(lhs: R, rhs: R) -> R {
  return lhs.multipliedReportingOverflow(by: rhs).partialValue
}

/// Returns true if `lhs` is less than `rhs`, false otherwise.
public func < <R: RationalNumber>(lhs: R, rhs: R) -> Bool {
  return lhs.compare(to: rhs) < 0
}

/// Returns true if `lhs` is less than or equals `rhs`, false otherwise.
public func <= <R: RationalNumber>(lhs: R, rhs: R) -> Bool {
  return lhs.compare(to: rhs) <= 0
}

/// Returns true if `lhs` is greater or equals `rhs`, false otherwise.
public func >= <R: RationalNumber>(lhs: R, rhs: R) -> Bool {
  return lhs.compare(to: rhs) >= 0
}

/// Returns true if `lhs` is greater than equals `rhs`, false otherwise.
public func > <R: RationalNumber>(lhs: R, rhs: R) -> Bool {
  return lhs.compare(to: rhs) > 0
}

/// Returns true if `lhs` is equals `rhs`, false otherwise.
public func == <R: RationalNumber>(lhs: R, rhs: R) -> Bool {
  return lhs.compare(to: rhs) == 0
}

/// Returns true if `lhs` is not equals `rhs`, false otherwise.
public func != <R: RationalNumber>(lhs: R, rhs: R) -> Bool {
  return lhs.compare(to: rhs) != 0
}

/// This extension implements the logic to make `Rational<T>` codable if `T` is codable.
extension Rational: Codable where T: Codable {

  // Make coding key names explicit to avoid automatic extension.
  enum CodingKeys: String, CodingKey {
      case numerator
      case denominator
  }

}

/// This extension implements the logic to make `Rational<T>` sendable if `T` is sendable.
extension Rational: Sendable where T: Sendable {
}

// TODO: make this a static member of `Rational` once this is supported
private let rationalSeparator: Character = "/"
