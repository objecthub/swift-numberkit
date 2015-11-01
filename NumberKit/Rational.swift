//
//  Rational.swift
//  NumberKit
//
//  Created by Matthias Zenger on 04/08/2015.
//  Copyright © 2015 Matthias Zenger. All rights reserved.
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


/// The `RationalType` protocol defines an interface for rational numbers. A rational
/// number is a signed number that can be expressed as the quotient of two integers
/// a and b: a / b. a is called the numerator, b is called the denominator. b must
/// not be zero.
public protocol RationalType: SignedNumberType,
                              IntegerLiteralConvertible,
                              Comparable,
                              Hashable {
  
  /// The integer type on which this rational number is based.
  typealias Integer: SignedIntegerType
  
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
  func compareTo(rhs: Self) -> Int
  
  /// Returns the sum of this rational value and `rhs`.
  func plus(rhs: Self) -> Self
  
  /// Returns the difference between this rational value and `rhs`.
  func minus(rhs: Self) -> Self
  
  /// Multiplies this rational value with `rhs` and returns the result.
  func times(rhs: Self) -> Self
  
  /// Divides this rational value by `rhs` and returns the result.
  func dividedBy(rhs: Self) -> Self
  
  /// Raises this rational value to the power of `exp`.
  func toPowerOf(exp: Integer) -> Self
}

// TODO: make this a static member of `Rational` once this is supported
internal let RATIONAL_SEPARATOR: Character = "/"


/// Struct `Rational<T>` implements the `RationalType` interface on top of the
/// integer type `T`. `Rational<T>` always represents rational numbers in normalized
/// form such that the greatest common divisor of the numerator and the denominator
/// is always 1. In addition, the sign of the rational number is defined by the
/// numerator. The denominator is always positive.
public struct Rational<T: SignedIntegerType>: RationalType,
                                              CustomStringConvertible {
  
  /// The numerator of this rational number. This is a signed integer.
  public let numerator: T
  
  /// The denominator of this rational number. This integer is always positive.
  public let denominator: T
  
  /* Uncomment once static members of generic structs are supported.
  private static let RATIONAL_SEPARATOR: Character = "/"
  
  public static var min: Rational<T> {
  return Rational(T.min, T(1))
  }
  
  public static var max: Rational<T> {
  return Rational(T.max, T(1))
  }
  */
  
  /// Creates a rational number from a numerator and a denominator.
  public init(_ numerator: T, _ denominator: T) {
    precondition(denominator != 0, "rational with zero denominator")
    let negative = numerator > 0 && denominator < 0 || numerator < 0 && denominator > 0
    let anum = numerator < 0 ? -numerator : numerator
    let adenom = denominator < 0 ? -denominator : denominator
    let div = Rational.gcd(anum, adenom)
    self.numerator = negative ? -(anum / div) : (anum / div)
    self.denominator = (denominator < 0 ? -denominator : denominator) / div
  }
  
  /// Creates a `Rational` from the given integer value of type `T`
  public init(_ value: T) {
    self.init(value, T(1))
  }
  
  /// Create an instance initialized to `value`.
  public init(integerLiteral value: T) {
    self.init(value)
  }
  
  /// Creates a `Rational` from a string containing a rational number using the base
  /// defined by parameter `radix`. The syntax of the rational number is defined as follows:
  /// 
  ///    Rational    = Numerator '/' Denominator
  ///                | SignedInteger
  ///    Numerator   = SignedInteger
  ///    Denominator = SignedInteger
  public init?(_ str: String, radix: Int = 10) {
    precondition(radix >= 2, "radix >= 2 required")
    if let idx = str.characters.indexOf(RATIONAL_SEPARATOR) {
      let numStr = str.substringToIndex(idx)
      let denomStr = str.substringFromIndex(idx.successor())
      if let numVal = Int64(numStr, radix: radix), denomVal = Int64(denomStr, radix: radix) {
        self.init(T(numVal.toIntMax()), T(denomVal.toIntMax()))
      } else {
        return nil
      }
    } else if let value = Int64(str, radix: radix) {
      self.init(T(value.toIntMax()))
    } else {
      return nil
    }
  }
  
  /// Returns the `Rational` as a value of type `T` if this is possible. If the number
  /// cannot be expressed as a `T`, this property returns `nil`.
  public var intValue: T? {
    guard denominator == T(1) else {
      return nil
    }
    return numerator
  }
  
  /// Returns the `Rational` value as a float value
  public var floatValue: Float {
    return Float(doubleValue)
  }
  
  /// Returns the `Rational` value as a double value
  public var doubleValue: Double {
    return Double(numerator.toIntMax())/Double(denominator.toIntMax())
  }
  
  /// Returns a string representation of this `Rational<T>` number using base 10.
  public var description: String {
    return denominator == 1 ? numerator.description
      : numerator.description + String(RATIONAL_SEPARATOR) + denominator.description
  }
  
  /// Compute the greatest common divisor for `x` and `y`.
  public static func gcd(var x: T, var _ y: T) -> T {
    var rest = x % y
    while rest > 0 {
      x = y
      y = rest
      rest = x % y
    }
    return y
  }
  
  private func equalizeDenomWith(other: Rational<T>) -> (num1: T, num2: T, denom: T) {
    let div = Rational.gcd(self.denominator, other.denominator)
    let t1 = self.denominator / div
    let t2 = other.denominator / div
    return (self.numerator * t2, other.numerator * t1, t1 * t2 * div)
  }
  
  /// The hash value of this rational value.
  public var hashValue: Int {
    return 31 &* denominator.hashValue &+ numerator.hashValue
  }
  
  /// The absolute rational value (without sign).
  public var abs: Rational<T> {
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
  public func compareTo(rhs: Rational<T>) -> Int {
    let (n1, n2, _) = equalizeDenomWith(rhs)
    return n1 == n2 ? 0 : (n1 < n2 ? -1 : 1)
  }
  
  /// Returns the sum of this rational value and `rhs`.
  public func plus(rhs: Rational<T>) -> Rational<T> {
    let (n1, n2, denom) = equalizeDenomWith(rhs)
    return Rational(n1 + n2, denom)
  }
  
  /// Returns the difference between this rational value and `rhs`.
  public func minus(rhs: Rational<T>) -> Rational<T> {
    let (n1, n2, denom) = equalizeDenomWith(rhs)
    return Rational(n1 - n2, denom)
  }
  
  /// Multiplies this rational value with `rhs` and returns the result.
  public func times(rhs: Rational<T>) -> Rational<T> {
    return Rational(self.numerator * rhs.numerator, self.denominator * rhs.denominator)
  }
  
  /// Divides this rational value by `rhs` and returns the result.
  public func dividedBy(rhs: Rational<T>) -> Rational<T> {
    return Rational(self.numerator * rhs.denominator, self.denominator * rhs.numerator)
  }
  
  /// Raises this rational value to the power of `exp`.
  public func toPowerOf(exp: T) -> Rational<T> {
    return Rational(pow(numerator, exp), pow(denominator, exp))
  }
}


/// Negates `num`.
public prefix func - <R: RationalType>(num: R) -> R {
  return num.negate
}

/// Returns the sum of `lhs` and `rhs`.
public func + <R: RationalType>(lhs: R, rhs: R) -> R {
  return lhs.plus(rhs)
}

/// Returns the difference between `lhs` and `rhs`.
public func - <R: RationalType>(lhs: R, rhs: R) -> R {
  return lhs.minus(rhs)
}

/// Multiplies `lhs` with `rhs` and returns the result.
public func * <R: RationalType>(lhs: R, rhs: R) -> R {
  return lhs.times(rhs)
}

/// Divides `lhs` by `rhs` and returns the result.
public func / <R: RationalType>(lhs: R, rhs: R) -> R {
  return lhs.dividedBy(rhs)
}

/// Divides `lhs` by `rhs` and returns the result.
public func / <T: SignedIntegerType>(lhs: T, rhs: T) -> Rational<T> {
  return Rational(lhs, rhs)
}

/// Raises rational value `lhs` to the power of `exp`.
public func ** <R: RationalType>(lhs: R, exp: R.Integer) -> R {
  return lhs.toPowerOf(exp)
}

/// Assigns `lhs` the sum of `lhs` and `rhs`.
public func += <R: RationalType>(inout lhs: R, rhs: R) {
  lhs = lhs.plus(rhs)
}

/// Assigns `lhs` the difference between `lhs` and `rhs`.
public func -= <R: RationalType>(inout lhs: R, rhs: R) {
  lhs = lhs.minus(rhs)
}

/// Assigns `lhs` the result of multiplying `lhs` with `rhs`.
public func *= <R: RationalType>(inout lhs: R, rhs: R) {
  lhs = lhs.times(rhs)
}

/// Assigns `lhs` the result of dividing `lhs` by `rhs`.
public func /= <R: RationalType>(inout lhs: R, rhs: R) {
  lhs = lhs.dividedBy(rhs)
}

/// Assigns `lhs` the result of raising rational value `lhs` to the power of `exp`.
public func **= <R: RationalType>(inout lhs: R, exp: R.Integer) {
  lhs = lhs.toPowerOf(exp)
}

/// Returns true if `lhs` is less than `rhs`, false otherwise.
public func < <R: RationalType>(lhs: R, rhs: R) -> Bool {
  return lhs.compareTo(rhs) < 0
}

/// Returns true if `lhs` is less than or equals `rhs`, false otherwise.
public func <= <R: RationalType>(lhs: R, rhs: R) -> Bool {
  return lhs.compareTo(rhs) <= 0
}

/// Returns true if `lhs` is greater or equals `rhs`, false otherwise.
public func >= <R: RationalType>(lhs: R, rhs: R) -> Bool {
  return lhs.compareTo(rhs) >= 0
}

/// Returns true if `lhs` is greater than equals `rhs`, false otherwise.
public func > <R: RationalType>(lhs: R, rhs: R) -> Bool {
  return lhs.compareTo(rhs) > 0
}

/// Returns true if `lhs` is equals `rhs`, false otherwise.
public func == <R: RationalType>(lhs: R, rhs: R) -> Bool {
  return lhs.compareTo(rhs) == 0
}

/// Returns true if `lhs` is not equals `rhs`, false otherwise.
public func != <R: RationalType>(lhs: R, rhs: R) -> Bool {
  return lhs.compareTo(rhs) != 0
}
