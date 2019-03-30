//
//  Rational.swift
//  NumberKit
//
//  Created by Matthias Zenger on 04/08/2015.
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
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,x either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation


/// The `RationalNumber` protocol defines an interface for rational numbers. A rational
/// number is a signed number that can be expressed as the quotient of two integers
/// a and b: a / b. a is called the numerator, b is called the denominator. b must
/// not be zero.
public protocol RationalNumber: SignedNumeric,
                                Comparable,
                                Hashable {

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

  /// Creates a rational number from a numerator and a denominator.
  public init(_ numerator: T, _ denominator: T) {
    precondition(denominator != 0, "rational with zero denominator")
    let negative = numerator > 0 && denominator < 0 || numerator < 0 && denominator > 0
    let anum = Swift.abs(numerator)
      // numerator < 0 ? -numerator : numerator
    let adenom = denominator < 0 ? -denominator : denominator
    let div = Rational.gcd(anum, adenom)
    self.numerator = negative ? -(anum / div) : (anum / div)
    self.denominator = adenom / div
  }

  /// Creates a `Rational` from the given integer value of type `T`
  public init(_ value: T) {
    self.init(numerator: value, denominator: T.one)
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
    precondition(radix >= 2, "radix >= 2 required")
    if let idx = str.firstIndex(of: rationalSeparator) {
      if let numVal = Int64(str[..<idx], radix: radix),
         let denomVal = Int64(str[str.index(after: idx)...], radix: radix) {
        self.init(T(numVal), T(denomVal))
      } else {
        return nil
      }
    } else if let value = Int64(str, radix: radix) {
      self.init(T(value))
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
    return self.numerator.doubleValue / self.denominator.doubleValue
  }

  /// Returns a string representation of this `Rational<T>` number using base 10.
  public var description: String {
    return denominator == 1 ?
             self.numerator.description :
             self.numerator.description + String(rationalSeparator) + self.denominator.description
  }
  
  /// Compute the greatest common divisor for `x` and `y`.
  public static func gcd(_ x: T, _ y: T) -> T {
    var (x, y, rest) = (x, y, x % y)
    while rest > 0 {
      x = y
      y = rest
      rest = x % y
    }
    return y
  }

  /// Compute the least common multiplier of `x` and `y`.
  public static func lcm(_ x: T, _ y: T) -> T {
    var abs = x * y
    if abs < 0 {
      abs = -abs
    }
    return abs / Rational.gcd(x, y)
  }

  /// Determine the smallest common denominator between `self` and `other` and return
  /// the corresponding numerators and the common denominator.
  private func commonDenomWith(_ other: Rational<T>) -> (num1: T, num2: T, denom: T) {
    let div = Rational.gcd(self.denominator, other.denominator)
    let t1 = self.denominator / div
    let t2 = other.denominator / div
    return (self.numerator * t2, other.numerator * t1, t1 * t2 * div)
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
    return Rational(numerator < 0 ? -numerator : numerator, denominator)
  }
  
  /// The negated rational value.
  public var negate: Rational<T> {
    return Rational(-numerator, denominator)
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
    let (n1, n2, _) = self.commonDenomWith(rhs)
    return n1 == n2 ? 0 : (n1 < n2 ? -1 : 1)
  }

  /// Returns the sum of this rational value and `rhs`.
  public func plus(_ rhs: Rational<T>) -> Rational<T> {
    let (n1, n2, denom) = self.commonDenomWith(rhs)
    return Rational(n1 + n2, denom)
  }

  /// Returns the difference between this rational value and `rhs`.
  public func minus(_ rhs: Rational<T>) -> Rational<T> {
    let (n1, n2, denom) = self.commonDenomWith(rhs)
    return Rational(n1 - n2, denom)
  }

  /// Multiplies this rational value with `rhs` and returns the result.
  public func times(_ rhs: Rational<T>) -> Rational<T> {
    return Rational(self.numerator * rhs.numerator, self.denominator * rhs.denominator)
  }

  /// Divides this rational value by `rhs` and returns the result.
  public func divided(by rhs: Rational<T>) -> Rational<T> {
    return Rational(self.numerator * rhs.denominator, self.denominator * rhs.numerator)
  }
  
  /// Raises this rational value to the power of `exp`.
  public func toPower(of exp: T) -> Rational<T> {
    if (exp < 0) {
        return Rational(denominator.toPower(of: -exp), numerator.toPower(of: -exp))
    } else {
        return Rational(numerator.toPower(of: exp), denominator.toPower(of: exp))
    }
  }

  /// Returns the greatest common denominator for the two given rational numbers
  public static func gcd(_ x: Rational<T>, _ y: Rational<T>) -> Rational<T> {
    return Rational(Rational.gcd(x.numerator, y.numerator),
                    Rational.lcm(x.denominator, y.denominator))
  }

  /// Returns the least common multiplier for the two given rational numbers
  public static func lcm(_ x: Rational<T>, _ y: Rational<T>) -> Rational<T> {
    let (xn, yn, denom) = x.commonDenomWith(y)
    return Rational(Rational.lcm(xn, yn), denom)
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

  /// Compute absolute number of `num` and return a tuple consisting of the result and a
  /// boolean indicating whether there was an overflow.
  private static func absWithOverflow(_ num: T) -> (value: T, overflow: Bool) {
    return num < 0 ? T(0).subtractingReportingOverflow(num) : (num, false)
  }

  /// Creates a rational number from a numerator and a denominator.
  public static func rationalWithOverflow(_ numerator: T, _ denominator: T)
                                      -> (value: Rational<T>, overflow: Bool) {
    guard denominator != 0 else {
      return (Rational(0), true)
    }
    let negative = numerator > 0 && denominator < 0 || numerator < 0 && denominator > 0
    let (anum, overflow1) = Rational.absWithOverflow(numerator)
    let (adenom, overflow2) = Rational.absWithOverflow(denominator)
    let div = Rational.gcd(anum, adenom)
    let (n, overflow3) = anum.dividedReportingOverflow(by: div)
    let (numer, overflow4) = negative ? T(0).subtractingReportingOverflow(n) : (n, false)
    let (denom, overflow5) = adenom.dividedReportingOverflow(by: div)
    return (Rational(numerator: numer, denominator: denom),
            overflow1 || overflow2 || overflow3 || overflow4 || overflow5)
  }
  
  /// Compute the smalles common denominator of `this` and `that` and return it together
  /// with the corresponding numerators.
  private static func commonDenomWithOverflow(_ this: Rational<T>, _ that: Rational<T>)
                                              -> (num1: T, num2: T, denom: T, overflow: Bool) {
    let div = Rational.gcd(this.denominator, that.denominator)
    let t1 = this.denominator / div
    let t2 = that.denominator / div
    let (n1, overflow1) = this.numerator.multipliedReportingOverflow(by: t2)
    let (n2, overflow2) = that.numerator.multipliedReportingOverflow(by: t1)
    let (dp, overflow3) = t1.multipliedReportingOverflow(by: t2)
    let (dn, overflow4) = dp.multipliedReportingOverflow(by: div)
    return (n1, n2, dn, overflow1 || overflow2 || overflow3 || overflow4)
  }
  
  /// Compute the greatest common divisor for `x` and `y`.
  public static func gcdWithOverflow(_ x: T, _ y: T) -> (T, Bool) {
    var (x, y, (rest, overflow)) = (x, y, x.remainderReportingOverflow(dividingBy: y))
    while rest > 0 {
      x = y
      y = rest
      let (rem, overflow1) = x.remainderReportingOverflow(dividingBy: y)
      rest = rem
      overflow = overflow || overflow1
    }
    return (y, overflow)
  }
  
  /// Compute the least common multiplier of `x` and `y`.
  public static func lcmWithOverflow(_ x: T, _ y: T) -> (T, Bool) {
    let (abs, overflow1) = x.multipliedReportingOverflow(by: y)
    let (gcd, overflow2) = Rational.gcdWithOverflow(x, y)
    return ((abs < 0 ? -abs : abs) / gcd, overflow1 || overflow2)
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
    let (numer, overflow1) = Rational.gcdWithOverflow(self.numerator, y.numerator)
    let (denom, overflow2) = Rational.lcmWithOverflow(self.denominator, y.denominator)
    return (Rational(numer, denom), overflow1 || overflow2)
  }
  
  /// Returns the least common multiplier for `self` and `y` and a boolean which indicates
  /// whether there was an overflow.
  public func lcmReportingOverflow(with y: Rational<T>)
                               -> (partialValue: Rational<T>, overflow: Bool) {
    let (xn, yn, denom, overflow1) = Rational.commonDenomWithOverflow(self, y)
    let (numer, overflow2) = Rational.lcmWithOverflow(xn, yn)
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

// TODO: make this a static member of `Rational` once this is supported
private let rationalSeparator: Character = "/"
