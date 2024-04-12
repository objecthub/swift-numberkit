//
//  Integer.swift
//  NumberKit
//
//  Created by Matthias Zenger on 11/04/2024.
//  Copyright © 2024 ObjectHub. All rights reserved.
//

import Foundation

public enum Integer: IntegerNumber,
                     SignedInteger,
                     Hashable,
                     Codable,
                     Sendable,
                     CustomStringConvertible,
                     CustomDebugStringConvertible,
                     ExpressibleByIntegerLiteral,
                     ExpressibleByStringLiteral {
  case int(Int64)
  case bigInt(BigInt)
  
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
  
  public init(integerLiteral value: Int64) {
    self = .int(value)
  }
  
  public init(stringLiteral value: String) {
    if let num = BigInt(from: value) {
      self = Integer(num)
    } else {
      self = .int(0)
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
  
  public static prefix func -(x: Integer) -> Integer {
    switch x {
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
