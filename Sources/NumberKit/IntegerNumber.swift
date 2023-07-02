//
//  IntegerNumber.swift
//  NumberKit
//
//  Created by Matthias Zenger on 23/09/2017.
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

import Foundation

/// Protocol `IntegerNumber` is used in combination with struct `Rational<T>`.
/// It defines the functionality needed for a signed integer implementation to
/// build rational numbers on top. The `SignedInteger` protocol from the Swift 4
/// standard library is unfortunately not sufficient as it doesn't provide access
/// to methods reporting overflows explicitly. Furthermore, `BigInt` is not yet
/// compliant with `SignedInteger`.
public protocol IntegerNumber: SignedNumeric,
                               Comparable,
                               Hashable,
                               CustomStringConvertible {
  
  /// Value zero
  static var zero: Self { get }

  /// Value one
  static var one: Self { get }

  /// Value two
  static var two: Self { get }

  /// Division operation.
  ///
  /// - Note: It's inexplicable to me why this operation is missing in `SignedNumeric`.
  static func /(lhs: Self, rhs: Self) -> Self

  /// Division operation.
  ///
  /// - Note: It's inexplicable to me why this operation is missing in `SignedNumeric`.
  static func /=(lhs: inout Self, rhs: Self)

  /// Remainder operation.
  ///
  /// - Note: It's inexplicable to me why this operation is missing in `SignedNumeric`.
  static func %(lhs: Self, rhs: Self) -> Self

  /// Constructs an `IntegerNumber` from an `Int64` value. This constructor might crash if
  /// the value cannot be converted to this type.
  ///
  /// - Note: This is a hack right now.
  init(_ value: Int64)

  /// Constructs an `IntegerNumber` from a `Double` value. This constructor might crash if
  /// the value cannot be converted to this type.
  init(_ value: Double)

  /// Returns the integer as a `Double`.
  var doubleValue: Double { get }

  /// Computes the power of `self` with exponent `exp`.
  func toPower(of exp: Self) -> Self

  /// Returns true if this is an odd number.
  var isOdd: Bool { get }

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

  /// Computes the remainder from dividing `self` by `rhs` and reports the result together
  /// with a boolean indicating an overflow.
  func remainderReportingOverflow(dividingBy rhs: Self) -> (partialValue: Self, overflow: Bool)
}

/// Provide default implementations of this protocol
extension IntegerNumber {
  public func toPower(of exp: Self) -> Self {
    precondition(exp >= 0, "IntegerNumber.toPower(of:) with negative exponent")
    var (expo, radix) = (exp, self)
    var res = Self.one
    while expo != 0 {
      if expo.isOdd {
        res *= radix
      }
      expo /= Self.two
      radix *= radix
    }
    return res
  }

  /// Returns the (non-negative) Greatest Common Divisor (GCD) of `x` and `y`. Any overflow
  /// occurring during the computation is ignored, iff the result cannot be represented in
  /// this type.
  public static func gcd(_ x: Self, _ y: Self) -> Self {
    return gcdWithOverflow(x, y).0
  }

  /// Compute the (non-negative) Least Common Multiple (LCM) of `x` and `y`. Any overflow
  /// occurring during the computation is ignored, iff the result cannot be represented
  /// in this type.
  public static func lcm(_ x: Self, _ y: Self) -> Self {
    return lcmWithOverflow(x, y).0
  }
  
  /// Returns the (non-negative) Greatest Common Divisor (GCD) of `x` and `y`, with a Boolean
  /// indicating whether overflow occurred in the computation, iff the result cannot be
  /// represented in this type.
  public static func gcdWithOverflow(_ x: Self, _ y: Self) -> (Self, Bool) {
    var (x, y, gcdOverflow) = (x, y, false)
    while y != 0 {
      let (remainder, remainderOverflow) = x.remainderReportingOverflow(dividingBy: y)
      (x, y, gcdOverflow) = (y, remainder, gcdOverflow || remainderOverflow)
    }
    let (absGcd, absOverflow) = absWithOverflow(x)
    return (absGcd, gcdOverflow || absOverflow)
  }

  /// Returns the (non-negative) Least Common Multiple (LCM) of `x` and `y`, with a Boolean
  /// indicating whether overflow occurred in the computation, iff the result cannot be
  /// represented in this type.
  public static func lcmWithOverflow(_ x: Self, _ y: Self) -> (Self, Bool) {
    if (x, y) == (0, 0) {
      return (0, false)
    }
    let (gcd, gcdOverflow) = gcdWithOverflow(x, y)
    let (lcm, lcmOverflow) = x.multipliedReportingOverflow(by: y / gcd)
    let (absLcm, absOverflow) = absWithOverflow(lcm)
    return (absLcm, gcdOverflow || lcmOverflow || absOverflow)
  }

  /// Returns the absolute value of `num`, along with a Boolean indicating whether overflow occurred in the operation,
  /// iff the absolute value cannot be represented in this type.
  static func absWithOverflow(_ num: Self) -> (value: Self, overflow: Bool) {
    return num < 0 ? Self.zero.subtractingReportingOverflow(num) : (num, false)
  }
}

/// Provide default implementations of fields needed by this protocol in all the fixed
/// width numeric types.
extension FixedWidthInteger {
  public static var zero: Self {
    return 0
  }

  public static var one: Self {
    return 1
  }

  public static var two: Self {
    return 2
  }

  public var isOdd: Bool {
    return (self & 1) == 1
  }
}

extension Int: IntegerNumber {
  public var doubleValue: Double {
    return Double(self)
  }
}

extension UInt: IntegerNumber {
  public var doubleValue: Double {
    return Double(self)
  }
}

extension Int8: IntegerNumber {
  public var doubleValue: Double {
    return Double(self)
  }
}

extension UInt8: IntegerNumber {
  public var doubleValue: Double {
    return Double(self)
  }
}

extension Int16: IntegerNumber {
  public var doubleValue: Double {
    return Double(self)
  }
}

extension UInt16: IntegerNumber {
  public var doubleValue: Double {
    return Double(self)
  }
}

extension Int32: IntegerNumber {
  public var doubleValue: Double {
    return Double(self)
  }
}

extension UInt32: IntegerNumber {
  public var doubleValue: Double {
    return Double(self)
  }
}

extension Int64: IntegerNumber {
  public var doubleValue: Double {
    return Double(self)
  }
}

extension UInt64: IntegerNumber {
  public var doubleValue: Double {
    return Double(self)
  }
}
