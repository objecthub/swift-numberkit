//
//  Integer.swift
//  NumberKit
//
//  Created by Matthias Zenger on 11/04/2024.
//  Copyright © 2024 Matthias Zenger. All rights reserved.
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

/// `Integer` implements signed, arbitrary-size integers. As opposed to `BigInt`,
///  the representation of `Integer` numbers falls back to `Int64` when possible,
///  minimizing memory overhead and increasing the performance of arithmetic operations.
///  `Integer` supports `StaticBigInt`literals, i.e. is is possible to use arbitrary
///  length integer literals.
public enum Integer: IntegerNumber,
                     SignedInteger,
                     Hashable,
                     Codable,
                     Sendable,
                     CustomStringConvertible,
                     CustomDebugStringConvertible {
  case int(Int64)
  case bigInt(BigInt)
  
  public static var zero: Integer {
    return .int(0)
  }
  
  public static var one: Integer {
    return .int(1)
  }
  
  public static var two: Integer {
    return .int(2)
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let intNum = try? container.decode(Int64.self) {
      self = .int(intNum)
    } else if let bigIntNum = try? container.decode(BigInt.self) {
      self = .bigInt(bigIntNum)
    } else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(codingPath: decoder.codingPath,
                              debugDescription: "Invalid Integer encoding"))
    }
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
      case .int(let num):
        try container.encode(num)
      case .bigInt(let num):
        try container.encode(num)
    }
  }
  
  public var description: String {
    switch self {
      case .int(let num):
        return num.description
      case .bigInt(let num):
        return num.description
    }
  }
  
  public var debugDescription: String {
    switch self {
      case .int(let num):
        return num.description
      case .bigInt(let num):
        return num.debugDescription
    }
  }
  
  public var isBigInt: Bool {
    guard case .bigInt(_) = self else {
      return false
    }
    return true
  }
  
  public var doubleValue: Double {
    switch self {
      case .int(let num):
        return num.doubleValue
      case .bigInt(let num):
        return num.doubleValue
    }
  }
  
  public var isOdd: Bool {
    switch self {
      case .int(let num):
        return num.isOdd
      case .bigInt(let num):
        return num.isOdd
    }
  }
  
  public init(_ value: Int64) {
    self = .int(value)
  }
  
  public init(_ value: BigInt) {
    if let intNum = value.intValue {
      self = .int(intNum)
    } else {
      self = .bigInt(value)
    }
  }
  
  public init(_ value: Double) {
    let bigIntNum = BigInt(value)
    if let intNum = bigIntNum.intValue {
      self = .int(intNum)
    } else {
      self = .bigInt(bigIntNum)
    }
  }
  
  public init<T: BinaryInteger>(_ source: T) {
    if let value = Int64(exactly: source) {
      self = .int(value)
    } else {
      self = Integer(BigInt(source))
    }
  }
  
  public init?<T: BinaryInteger>(exactly: T) {
    self.init(exactly)
  }
  
  public init<T: BinaryInteger>(clamping: T) {
    self.init(clamping)
  }
  
  public init<T: BinaryInteger>(truncatingIfNeeded: T) {
    self.init(truncatingIfNeeded)
  }
  
  public init<T: BinaryFloatingPoint>(_ source: T) {
    if let intNum = Int64(exactly: source) {
      self = .int(intNum)
    } else if let bigIntNum = BigInt(exactly: source) {
      self = .bigInt(bigIntNum)
    } else {
      self = .int(Int64(source))
    }
  }
  
  public init?<T: BinaryFloatingPoint>(exactly source: T) {
    if let intNum = Int64(exactly: source) {
      self = .int(intNum)
    } else if let bigIntNum = BigInt(exactly: source) {
      self = .bigInt(bigIntNum)
    } else {
      return nil
    }
  }
  
  public var intValue: Int64? {
    switch self {
      case .int(let num):
        return num
      case .bigInt(_):
        return nil
    }
  }
  
  public var bigIntValue: BigInt {
    switch self {
      case .int(let num):
        return BigInt(num)
      case .bigInt(let num):
        return num
    }
  }
  
  public var words: [UInt] {
    switch self {
      case .int(let num):
        return BigInt(num).words
      case .bigInt(let num):
        return num.words
    }
  }
  
  public var magnitude: Integer {
    switch self {
      case .int(let num):
        return Integer(BigInt(num.magnitude))
      case .bigInt(let num):
        return Integer(num.magnitude)
    }
  }
  
  public var bitWidth: Int {
    switch self {
      case .int(let num):
        return num.bitWidth
      case .bigInt(let num):
        return num.bitWidth
    }
  }
  
  public var trailingZeroBitCount: Int {
    switch self {
      case .int(let num):
        return num.trailingZeroBitCount
      case .bigInt(let num):
        return num.trailingZeroBitCount
    }
  }
  
  public var isNegative: Bool {
    switch self {
      case .int(let num):
        return num < 0
      case .bigInt(let num):
        return num.isNegative
    }
  }
  
  public var isZero: Bool {
    switch self {
      case .int(let num):
        return num == 0
      case .bigInt(let num):
        return num.isZero
    }
  }
  
  public var negate: Integer {
    switch self {
      case .int(let num):
        if num == .min {
          return Integer(BigInt(num).negate)
        } else {
          return .int(-num)
        }
      case .bigInt(let num):
        return Integer(BigInt(num).negate)
    }
  }
  
  public var abs: Integer {
    switch self {
      case .int(let num):
        if num == .min {
          return .bigInt(BigInt(num).abs)
        } else {
          return .int(Swift.abs(num))
        }
      case .bigInt(let num):
        return Integer(num.abs)
    }
  }
  
  public func divided(by rhs: Integer) -> (quotient: Integer, remainder: Integer) {
    let (q, r) = self.bigIntValue.divided(by: rhs.bigIntValue)
    return (Integer(q), Integer(r))
  }
  
  public func toPower(of exp: Integer) -> Integer {
    return Integer(self.bigIntValue.toPower(of: exp.bigIntValue))
  }
  
  public var sqrt: Integer {
    return Integer(self.bigIntValue.sqrt)
  }
  
  /// Adds `n` and returns the result.
  public func advanced(by n: Integer) -> Integer {
    return self + n
  }
  
  /// Computes the distance to `other` and returns the result.
  public func distance(to other: Integer) -> Integer {
    return other - self
  }
  
  /// Returns -1 if `self` is less than `rhs`,
  ///          0 if `self` is equals to `rhs`,
  ///         +1 if `self` is greater than `rhs`
  public func compare(to rhs: Integer) -> Int {
    switch self {
      case .int(let lval):
        switch rhs {
          case .int(let rval):
            return lval == rval ? 0 : lval < rval ? -1 : 1
          case .bigInt(let rval):
            return BigInt(lval).compare(to: rval)
        }
      case .bigInt(let lval):
        switch rhs {
          case .int(let rval):
            return lval.compare(to: BigInt(rval))
          case .bigInt(let rval):
            return lval.compare(to: rval)
        }
    }
  }
  
  /// Number of bits used to represent the (unsigned) `Integer` number.
  public var bitSize: Int {
    return self.bigIntValue.bitSize
  }
  
  /// Number of bits set in this `Integer` number. For negative numbers, `n.bigCount` returns
  /// `~n.not.bigCount`.
  public var bitCount: Int {
    return self.bigIntValue.bitCount
  }
  
  /// Returns a random non-negative `Integer` with up to `bitWidth` bits using the random number
  /// generator `generator`.
  public static func random<R: RandomNumberGenerator>(withMaxBits bitWidth: Int,
                                                      using generator: inout R) -> Integer {
    return Integer(BigInt.random(withMaxBits: bitWidth, using: &generator))
  }
  
  /// Returns a random non-negative `Integer` with up to `bitWidth` bits using the system
  /// random number generator.
  public static func random(withMaxBits bitWidth: Int) -> Integer {
    return Integer(BigInt.random(withMaxBits: bitWidth))
  }
  
  /// Returns a random non-negative `Integer` below the given upper bound `bound` using the
  /// random number generator `generator`.
  public static func random<R: RandomNumberGenerator>(below bound: Integer,
                                                      using generator: inout R) -> Integer {
    return Integer(BigInt.random(below: bound.bigIntValue, using: &generator))
  }
  
  /// Returns a random non-negative `Integer` below the given upper bound `bound` using
  /// the system random number generator.
  public static func random(below bound: Integer) -> Integer {
    return Integer(BigInt.random(below: bound.bigIntValue))
  }
  
  public static prefix func -(x: Integer) -> Integer {
    return x.negate
  }
  
  public static prefix func ~(x: Integer) -> Integer {
    switch x {
      case .int(let num):
        return .int(~num)
      case .bigInt(let num):
        return .bigInt(~num)
    }
  }
  
  public static func +(lhs: Integer, rhs: Integer) -> Integer {
    switch lhs {
      case .int(let lval):
        switch rhs {
          case .int(let rval):
            let (res, overflow) = lval.addingReportingOverflow(rval)
            if overflow {
              return .bigInt(BigInt(lval) + BigInt(rval))
            } else {
              return .int(res)
            }
          case .bigInt(let rval):
            return Integer(BigInt(lval) + rval)
        }
      case .bigInt(let lval):
        switch rhs {
          case .int(let rval):
            return Integer(lval + BigInt(rval))
          case .bigInt(let rval):
            return Integer(lval + rval)
        }
    }
  }
  
  public static func -(lhs: Integer, rhs: Integer) -> Integer {
    switch lhs {
      case .int(let lval):
        switch rhs {
          case .int(let rval):
            let (res, overflow) = lval.subtractingReportingOverflow(rval)
            if overflow {
              return Integer(BigInt(lval) - BigInt(rval))
            } else {
              return .int(res)
            }
          case .bigInt(let rval):
            return Integer(BigInt(lval) - rval)
        }
      case .bigInt(let lval):
        switch rhs {
          case .int(let rval):
            return Integer(lval - BigInt(rval))
          case .bigInt(let rval):
            return Integer(lval - rval)
        }
    }
  }
  
  public static func *(lhs: Integer, rhs: Integer) -> Integer {
    switch lhs {
      case .int(let lval):
        switch rhs {
          case .int(let rval):
            let (res, overflow) = lval.multipliedReportingOverflow(by: rval)
            if overflow {
              return Integer(BigInt(lval) * BigInt(rval))
            } else {
              return .int(res)
            }
          case .bigInt(let rval):
            return Integer(BigInt(lval) * rval)
        }
      case .bigInt(let lval):
        switch rhs {
          case .int(let rval):
            return Integer(lval * BigInt(rval))
          case .bigInt(let rval):
            return Integer(lval * rval)
        }
    }
  }
  
  public static func /(lhs: Integer, rhs: Integer) -> Integer {
    switch lhs {
      case .int(let lval):
        switch rhs {
          case .int(let rval):
            let (res, overflow) = lval.dividedReportingOverflow(by: rval)
            if overflow {
              return Integer(BigInt(lval) / BigInt(rval))
            } else {
              return .int(res)
            }
          case .bigInt(let rval):
            return Integer(BigInt(lval) / rval)
        }
      case .bigInt(let lval):
        switch rhs {
          case .int(let rval):
            return Integer(lval / BigInt(rval))
          case .bigInt(let rval):
            return Integer(lval / rval)
        }
    }
  }
  
  public static func %(lhs: Integer, rhs: Integer) -> Integer {
    switch lhs {
      case .int(let lval):
        switch rhs {
          case .int(let rval):
            let (res, overflow) = lval.remainderReportingOverflow(dividingBy: rval)
            if overflow {
              return Integer(BigInt(lval) % BigInt(rval))
            } else {
              return .int(res)
            }
          case .bigInt(let rval):
            return Integer(BigInt(lval) % rval)
        }
      case .bigInt(let lval):
        switch rhs {
          case .int(let rval):
            return Integer(lval % BigInt(rval))
          case .bigInt(let rval):
            return Integer(lval % rval)
        }
    }
  }
  
  public static func &(lhs: Integer, rhs: Integer) -> Integer {
    switch lhs {
      case .int(let lval):
        switch rhs {
          case .int(let rval):
            return .int(lval & rval)
          case .bigInt(let rval):
            return Integer(BigInt(lval) & rval)
        }
      case .bigInt(let lval):
        switch rhs {
          case .int(let rval):
            return Integer(lval & BigInt(rval))
          case .bigInt(let rval):
            return Integer(lval & rval)
        }
    }
  }

  public static func |(lhs: Integer, rhs: Integer) -> Integer {
    switch lhs {
      case .int(let lval):
        switch rhs {
          case .int(let rval):
            return .int(lval | rval)
          case .bigInt(let rval):
            return Integer(BigInt(lval) | rval)
        }
      case .bigInt(let lval):
        switch rhs {
          case .int(let rval):
            return Integer(lval | BigInt(rval))
          case .bigInt(let rval):
            return Integer(lval | rval)
        }
    }
  }

  public static func ^(lhs: Integer, rhs: Integer) -> Integer {
    switch lhs {
      case .int(let lval):
        switch rhs {
          case .int(let rval):
            return .int(lval ^ rval)
          case .bigInt(let rval):
            return Integer(BigInt(lval) ^ rval)
        }
      case .bigInt(let lval):
        switch rhs {
          case .int(let rval):
            return Integer(lval ^ BigInt(rval))
          case .bigInt(let rval):
            return Integer(lval ^ rval)
        }
    }
  }

  public static func << <T: BinaryInteger>(lhs: Integer, rhs: T) -> Integer {
    return Integer(lhs.bigIntValue << rhs)
  }

  public static func >> <T: BinaryInteger>(lhs: Integer, rhs: T) -> Integer {
    return Integer(lhs.bigIntValue >> rhs)
  }

  public static func +=(lhs: inout Integer, rhs: Integer) {
    lhs = lhs + rhs
  }
  
  public static func -=(lhs: inout Integer, rhs: Integer) {
    lhs = lhs - rhs
  }
  
  public static func *=(lhs: inout Integer, rhs: Integer) {
    lhs = lhs * rhs
  }
  
  public static func /=(lhs: inout Integer, rhs: Integer) {
    lhs = lhs / rhs
  }
  
  public static func %= (lhs: inout Integer, rhs: Integer) {
    lhs = lhs % rhs
  }
  
  public static func &= (lhs: inout Integer, rhs: Integer) {
    lhs = lhs & rhs
  }
  
  public static func |= (lhs: inout Integer, rhs: Integer) {
    lhs = lhs | rhs
  }
  
  public static func ^=(lhs: inout Integer, rhs: Integer) {
    lhs = lhs ^ rhs
  }
  
  public static func <<=<T: BinaryInteger>(lhs: inout Integer, rhs: T) {
    lhs = lhs << rhs
  }
  
  public static func >>=<T: BinaryInteger>(lhs: inout Integer, rhs: T) {
    lhs = lhs >> rhs
  }
  
  public static func <(lhs: Integer, rhs: Integer) -> Bool {
    return lhs.compare(to: rhs) < 0
  }

  public static func <=(lhs: Integer, rhs: Integer) -> Bool {
    return lhs.compare(to: rhs) <= 0
  }

  public static func >=(lhs: Integer, rhs: Integer) -> Bool {
    return lhs.compare(to: rhs) >= 0
  }

  public static func >(lhs: Integer, rhs: Integer) -> Bool {
    return lhs.compare(to: rhs) > 0
  }

  public static func ==(lhs: Integer, rhs: Integer) -> Bool {
    return lhs.compare(to: rhs) == 0
  }

  public static func !=(lhs: Integer, rhs: Integer) -> Bool {
    return lhs.compare(to: rhs) != 0
  }
  
  public func addingReportingOverflow(_ rhs: Integer) -> (partialValue: Integer, overflow: Bool) {
    return (self + rhs, false)
  }
  
  public func subtractingReportingOverflow(_ rhs: Integer) -> (partialValue: Integer, overflow: Bool) {
    return (self - rhs, false)
  }
  
  public func multipliedReportingOverflow(by rhs: Integer) -> (partialValue: Integer, overflow: Bool) {
    return (self * rhs, false)
  }
  
  public func dividedReportingOverflow(by rhs: Integer) -> (partialValue: Integer, overflow: Bool) {
    return (self / rhs, false)
  }
  
  public func remainderReportingOverflow(dividingBy rhs: Integer) -> (partialValue: Integer, overflow: Bool) {
    return (self % rhs, false)
  }
}

#if canImport(Swift.StaticBigInt)
extension Integer: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: StaticBigInt) {
    self = Integer(BigInt(integerLiteral: value))
  }
}
#else
extension Integer: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: Int64) {
    self.init(value)
  }
}
#endif

/// Returns the maximum of `fst` and `snd`.
public func max(_ fst: Integer, _ snd: Integer) -> Integer {
  return fst.compare(to: snd) >= 0 ? fst : snd
}

/// Returns the minimum of `fst` and `snd`.
public func min(_ fst: Integer, _ snd: Integer) -> Integer {
  return fst.compare(to: snd) <= 0 ? fst : snd
}
