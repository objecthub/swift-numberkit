//
//  BigInt.swift
//  NumberKit
//
//  Created by Matthias Zenger on 12/08/2015.
//  Copyright © 2015 ObjectHub. All rights reserved.
//

import Darwin


/// Class `BigInt` implements signed, arbitrary-precision integers. `BigInt` objects
/// are immutable, i.e. all operations on `BigInt` objects return result objects.
/// `BigInt` provides all the signed, integer arithmetic operations from Swift and
/// implements the corresponding protocols. To make it easier to define large `BigInt`
/// literals, `String` objects can be used for representing such numbers. They get
/// implicitly coerced into `BigInt`
///
/// - Note: `BigInt` is internally implemented as a Swift array of UInt32 numbers
///         and a boolean to represent the sign. Due to this overhead, for instance,
///         representing a `UInt64` value as a `BigInt` will result in an object that
///         requires more memory than the corresponding `UInt64` integer.
public final class BigInt: Hashable,
                           CustomStringConvertible,
                           CustomDebugStringConvertible {
  
  // This is an array of `UInt32` words. The lowest significant word comes first in
  // the array.
  let words: [UInt32]
  
  // `negative` signals whether the number is positive or negative.
  let negative: Bool
  
  // All internal computations are based on 32-bit words; the base of this representation
  // is therefore `UInt32.max + 1`.
  private static let BASE: UInt64 = UInt64(UInt32.max) + 1
  
  // `hiword` extracts the highest 32-bit value of a `UInt64`.
  private static func hiword(num: UInt64) -> UInt32 {
    return UInt32((num >> 32) & 0xffffffff)
  }
  
  // `loword` extracts the lowest 32-bit value of a `UInt64`.
  private static func loword(num: UInt64) -> UInt32 {
    return UInt32(num & 0xffffffff)
  }
  
  // `joinwords` combines two words into a `UInt64` value.
  private static func joinwords(lword: UInt32, _ hword: UInt32) -> UInt64 {
    return (UInt64(hword) << 32) + UInt64(lword)
  }
  
  /// Class `Base` defines a representation and type for the base used in computing
  /// `String` representations of `BigInt` objects.
  ///
  /// - Note: It is currently not possible to define custom `Base` objects. It needs
  ///         to be figured out first what safety checks need to be put in place.
  public final class Base {
    private let digitSpace: [Character]
    private let digitMap: [Character: UInt8]
    private init(digitSpace: [Character], digitMap: [Character: UInt8]) {
      self.digitSpace = digitSpace
      self.digitMap = digitMap
    }
  }
  
  /// Representing base 2 (binary)
  public static let BIN = Base(
    digitSpace: ["0", "1"],
    digitMap: ["0": 0, "1": 1]
  )
  
  /// Representing base 8 (octal)
  public static let OCT = Base(
    digitSpace: ["0", "1", "2", "3", "4", "5", "6", "7"],
    digitMap: ["0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7]
  )
  
  /// Representing base 10 (decimal)
  public static let DEC = Base(
    digitSpace: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"],
    digitMap: ["0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9]
  )
  
  /// Representing base 16 (hex)
  public static let HEX = Base(
    digitSpace: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"],
    digitMap: ["0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9,
      "A": 10, "B": 11, "C": 12, "D": 13, "E": 14, "F": 15]
  )
  
  /// Tries to parse the given string as a `BigInt` number represented with a given
  /// optional base. If parsing fails, `nil` is returned.
  public static func fromString(str: String, base: Base = BigInt.DEC) -> BigInt? {
    var negative = false
    let chars = str.characters
    var i = chars.startIndex
    while i < chars.endIndex && chars[i] == " " {
      i++
    }
    if i < chars.endIndex {
      if chars[i] == "-" {
        negative = true
        i++
      } else if chars[i] == "+" {
        i++
      }
    }
    if i < chars.endIndex && chars[i] == "0" {
      while i < chars.endIndex && chars[i] == "0" {
        i++
      }
      if i == chars.endIndex {
        return BigInt(0)
      }
    }
    var temp: [UInt8] = []
    while i < chars.endIndex {
      if let digit = base.digitMap[chars[i]] {
        temp.append(digit)
        i++
      } else {
        break
      }
    }
    while i < chars.endIndex && chars[i] == " " {
      i++
    }
    guard i == chars.endIndex else {
      return nil
    }
    var words: [UInt32] = []
    var iterate: Bool
    repeat {
      var sum: UInt64 = 0
      var res: [UInt8] = []
      var j = 0
      while j < temp.count && sum < BigInt.BASE {
        sum = sum * 10 + UInt64(temp[j++])
      }
      res.append(UInt8(BigInt.hiword(sum)))
      iterate = BigInt.hiword(sum) > 0
      sum = UInt64(BigInt.loword(sum))
      while j < temp.count {
        sum = sum * 10 + UInt64(temp[j++])
        res.append(UInt8(BigInt.hiword(sum)))
        iterate = true
        sum = UInt64(BigInt.loword(sum))
      }
      words.append(BigInt.loword(sum))
      temp = res
    } while iterate
    return BigInt(words, negative: negative)
  }
  
  /// Converts the `BigInt` object into a string using the given base. `BigInt.DEC` is
  /// used as the default base.
  public func toString(base base: Base = BigInt.DEC) -> String {
    // Determine base
    let b = UInt64(base.digitSpace.count)
    precondition(b > 1 && b <= 36, "illegal base for BigInt string conversion")
    // Shortcut handling of zero
    if isZero {
      return String(base.digitSpace[0])
    }
    // Build representation with base `b` in `str`
    var str: [UInt8] = []
    var word = words[words.count - 1]
    while word > 0 {
      str.append(UInt8(word % UInt32(b)))
      word /= UInt32(b)
    }
    var temp: [UInt8] = []
    if words.count > 1 {
      for i in 2...words.count {
        var carry: UInt64 = 0
        // Multiply `str` with `BASE` and store in `temp`
        temp.removeAll()
        for s in str {
          carry += UInt64(s) * BigInt.BASE
          temp.append(UInt8(carry % b))
          carry /= b
        }
        while carry > 0 {
          temp.append(UInt8(carry % b))
          carry /= b
        }
        // Add `z` to `temp` and store in `str`
        word = words[words.count - i]
        var r = 0
        str.removeAll()
        while r < temp.count || word > 0 {
          if r < temp.count {
            carry += UInt64(temp[r++])
          }
          carry += UInt64(word) % b
          str.append(UInt8(carry % b))
          carry /= b
          word /= UInt32(b)
        }
        if carry > 0 {
          str.append(UInt8(carry % b))
        }
      }
    }
    // Convert representation in `str` into string
    var res = negative ? "-" : ""
    for i in 1...str.count {
      res.append(base.digitSpace[Int(str[str.count-i])])
    }
    return res
  }
  
  // Internal primary constructor. It removes superfluous words and normalizes the
  // representation of zero.
  private init(var _ words: [UInt32], negative: Bool) {
    while words.count > 1 && words[words.count - 1] == 0 {
      words.removeLast()
    }
    self.words = words
    self.negative = words.count == 1 && words[0] == 0 ? false : negative
  }
  
  private static let INT64_MAX = UInt64(Int64.max)
  
  /// Creates a `BigInt` from the given `UInt64` value
  public convenience init(_ value: UInt64) {
    self.init([BigInt.loword(value), BigInt.hiword(value)], negative: false)
  }
  
  /// Creates a `BigInt` from the given `Int64` value
  public convenience init(_ value: Int64) {
    let absvalue = value == Int64.min ? BigInt.INT64_MAX + 1 : UInt64(value < 0 ? -value : value)
    self.init([BigInt.loword(absvalue), BigInt.hiword(absvalue)], negative: value < 0)
  }
  
  /// Creates a `BigInt` from a string containing a number using the given base.
  public convenience init?(_ str: String, base: Base = BigInt.DEC) {
    if let this = BigInt.fromString(str) {
      self.init(this.words, negative: this.negative)
    } else {
      self.init(0)
      return nil
    }
  }
  
  /// Returns the `BigInt` as a `Int64` value if this is possible. If the number is outside
  /// the `Int64` range, the property will contain `nil`.
  public var intValue: Int64? {
    guard words.count <= 2 else {
      return nil
    }
    var value: UInt64 = UInt64(words[0])
    if words.count == 2 {
      value += UInt64(words[1]) * BigInt.BASE
    }
    if negative && value == BigInt.INT64_MAX + 1 {
      return Int64.min
    }
    if value <= BigInt.INT64_MAX {
      return negative ? -Int64(value) : Int64(value)
    }
    return nil
  }
  
  /// Returns the `BigInt` as a `UInt64` value if this is possible. If the number is outside
  /// the `UInt64` range, the property will contain `nil`.
  public var uintValue: UInt64? {
    guard words.count <= 2 && !negative else {
      return nil
    }
    var value: UInt64 = UInt64(words[0])
    if words.count == 2 {
      value += UInt64(words[1]) * BigInt.BASE
    }
    return value
  }
  
  /// Returns a string representation of this `BigInt` number using base 10.
  public var description: String {
    return toString()
  }
  
  /// Returns a string representation of this `BigInt` number for debugging purposes.
  public var debugDescription: String {
    var res = "{\(words.count): \(words[0])"
    for i in 1..<words.count {
      res += ", \(words[i])"
    }
    return res + "}"
  }
  
  /// The hash value of this `BigInt` object.
  public var hashValue: Int {
    var hash: Int = 0
    for i in 0..<words.count {
      hash = (31 &* hash) &+ words[i].hashValue
    }
    return hash
  }
  
  /// Returns true if this `BigInt` is negative.
  public var isNegative: Bool {
    return negative
  }
  
  /// Returns true if this `BigInt` represents zero.
  public var isZero: Bool {
    return words.count == 1 && words[0] == 0
  }
  
  /// Returns a `BigInt` with swapped sign.
  public var negate: BigInt {
    return BigInt(words, negative: !negative)
  }
  
  /// Returns the absolute value of this `BigInt`.
  public var abs: BigInt {
    return BigInt(words, negative: false)
  }
  
  /// Returns -1 if `self` is less than `rhs`,
  ///          0 if `self` is equals to `rhs`,
  ///         +1 if `self` is greater than `rhs`
  public func compareTo(rhs: BigInt) -> Int {
    guard self.negative == rhs.negative else {
      return self.negative ? -1 : 1
    }
    return self.negative ? rhs.compareDigits(self) : compareDigits(rhs)
  }
  
  private func compareDigits(rhs: BigInt) -> Int {
    guard words.count == rhs.words.count else {
      return words.count < rhs.words.count ? -1 : 1
    }
    for i in 1...words.count {
      let a = words[words.count - i]
      let b = rhs.words[words.count - i]
      if a != b {
        return a < b ? -1 : 1
      }
    }
    return 0
  }
  
  /// Returns the sum of `self` and `rhs` as a `BigInt`.
  public func plus(rhs: BigInt) -> BigInt {
    guard self.negative == rhs.negative else {
      return self.minus(rhs.negate)
    }
    let (b1, b2) = self.words.count < rhs.words.count ? (rhs, self) : (self, rhs)
    var res = [UInt32]()
    res.reserveCapacity(b1.words.count)
    var sum: UInt64 = 0
    for i in 0..<b2.words.count {
      sum += UInt64(b1.words[i])
      sum += UInt64(b2.words[i])
      res.append(BigInt.loword(sum))
      sum = UInt64(BigInt.hiword(sum))
    }
    for i in b2.words.count..<b1.words.count {
      sum += UInt64(b1.words[i])
      res.append(BigInt.loword(sum))
      sum = UInt64(BigInt.hiword(sum))
    }
    if sum > 0 {
      res.append(BigInt.loword(sum))
    }
    return BigInt(res, negative: self.negative)
  }
  
  /// Returns the difference between `self` and `rhs` as a `BigInt`.
  public func minus(rhs: BigInt) -> BigInt {
    guard self.negative == rhs.negative else {
      return self.plus(rhs.negate)
    }
    let cmp = compareDigits(rhs)
    guard cmp != 0 else {
      return 0
    }
    let negative = cmp < 0 ? !self.negative : self.negative
    let (b1, b2) = cmp < 0 ? (rhs, self) : (self, rhs)
    var res = [UInt32]()
    var carry: UInt64 = 0
    for i in 0..<b2.words.count {
      if UInt64(b1.words[i]) < UInt64(b2.words[i]) + carry {
        res.append(UInt32(BigInt.BASE + UInt64(b1.words[i]) - UInt64(b2.words[i]) - carry))
        carry = 1
      } else {
        res.append(b1.words[i] - b2.words[i] - UInt32(carry))
        carry = 0
      }
    }
    for i in b2.words.count..<b1.words.count {
      if b1.words[i] < UInt32(carry) {
        res.append(UInt32.max)
        carry = 1
      } else {
        res.append(b1.words[i] - UInt32(carry))
        carry = 0
      }
    }
    return BigInt(res, negative: negative)
  }
  
  /// Returns the result of mulitplying `self` with `rhs` as a `BigInt`
  public func times(rhs: BigInt) -> BigInt {
    let (b1, b2) = self.words.count < rhs.words.count ? (rhs, self) : (self, rhs)
    var res = [UInt32](count: b1.words.count + b2.words.count, repeatedValue: 0)
    for i in 0..<b2.words.count {
      var sum: UInt64 = 0
      for j in 0..<b1.words.count {
        sum += UInt64(res[i + j]) + UInt64(b1.words[j]) * UInt64(b2.words[i])
        res[i + j] = BigInt.loword(sum)
        sum = UInt64(BigInt.hiword(sum))
      }
      res[i + b1.words.count] = BigInt.loword(sum)
    }
    return BigInt(res, negative: b1.negative != b2.negative)
  }
  
  private static func multSub(approx: UInt32, _ divis: [UInt32],
    inout _ rem: [UInt32], _ from: Int) {
      var sum: UInt64 = 0
      var carry: UInt64 = 0
      for j in 0..<divis.count {
        sum += UInt64(divis[j]) * UInt64(approx)
        let x = UInt64(loword(sum)) + carry
        if UInt64(rem[from + j]) < x {
          rem[from + j] = UInt32(BigInt.BASE + UInt64(rem[from + j]) - x)
          carry = 1
        } else {
          rem[from + j] = UInt32(UInt64(rem[from + j]) - x)
          carry = 0
        }
        sum = UInt64(hiword(sum))
      }
  }
  
  private static func subIfPossible(divis: [UInt32], inout _ rem: [UInt32], _ from: Int) -> Bool {
    var i = divis.count
    while i > 0 && divis[i - 1] >= rem[from + i - 1] {
      if divis[i - 1] > rem[from + i - 1] {
        return false
      }
      i--
    }
    var carry: UInt64 = 0
    for j in 0..<divis.count {
      let x = UInt64(divis[j]) + carry
      if UInt64(rem[from + j]) < x {
        rem[from + j] = UInt32(BigInt.BASE + UInt64(rem[from + j]) - x)
        carry = 1
      } else {
        rem[from + j] = UInt32(UInt64(rem[from + j]) - x)
        carry = 0
      }
    }
    return true
  }
  
  /// Divides `self` by `rhs` and returns the result as a `BigInt`.
  public func dividedBy(rhs: BigInt) -> (quotient: BigInt, remainder: BigInt) {
    guard rhs.words.count <= self.words.count else {
      return (BigInt(0), self.abs)
    }
    let neg = self.negative != rhs.negative
    if rhs.words.count == self.words.count {
      let cmp = compareTo(rhs)
      if cmp == 0 {
        return (BigInt(neg ? -1 : 1), BigInt(0))
      } else if cmp < 0 {
        return (BigInt(0), self.abs)
      }
    }
    var rem = [UInt32](self.words)
    rem.append(0)
    var divis = [UInt32](rhs.words)
    divis.append(0)
    var sizediff = self.words.count - rhs.words.count
    let div = UInt64(rhs.words[rhs.words.count - 1]) + 1
    var res = [UInt32](count: sizediff + 1, repeatedValue: 0)
    var divident = rem.count - 2
    repeat {
      var x = BigInt.joinwords(rem[divident], rem[divident + 1])
      var approx = x / div
      res[sizediff] = 0
      while approx > 0 {
        res[sizediff] += UInt32(approx) // Is this cast ok?
        BigInt.multSub(UInt32(approx), divis, &rem, sizediff)
        x = BigInt.joinwords(rem[divident], rem[divident + 1])
        approx = x / div
      }
      if BigInt.subIfPossible(divis, &rem, sizediff) {
        res[sizediff]++
      }
      divident--
      sizediff--
    } while sizediff >= 0
    return (BigInt(res, negative: neg), BigInt(rem, negative: false))
  }
  
  /// Raises this `BigInt` value to the power of `exp`.
  public func toPowerOf(exp: BigInt) -> BigInt {
    return pow(self, exp)
  }
  
  public func and(rhs: BigInt) -> BigInt {
    let size = min(self.words.count, rhs.words.count)
    var res = [UInt32]()
    res.reserveCapacity(size)
    for i in 0..<size {
      res.append(self.words[i] & rhs.words[i])
    }
    return BigInt(res, negative: self.negative && rhs.negative)
  }
  
  public func or(rhs: BigInt) -> BigInt {
    let size = max(self.words.count, rhs.words.count)
    var res = [UInt32]()
    res.reserveCapacity(size)
    for i in 0..<size {
      let fst = i < self.words.count ? self.words[i] : 0
      let snd = i < rhs.words.count ? rhs.words[i] : 0
      res.append(fst | snd)
    }
    return BigInt(res, negative: self.negative || rhs.negative)
  }
  
  public func xor(rhs: BigInt) -> BigInt {
    let size = max(self.words.count, rhs.words.count)
    var res = [UInt32]()
    res.reserveCapacity(size)
    for i in 0..<size {
      let fst = i < self.words.count ? self.words[i] : 0
      let snd = i < rhs.words.count ? rhs.words[i] : 0
      res.append(fst ^ snd)
    }
    return BigInt(res, negative: self.negative || rhs.negative)
  }
  
  public var invert: BigInt {
    var res = [UInt32]()
    res.reserveCapacity(self.words.count)
    for word in self.words {
      res.append(~word)
    }
    return BigInt(res, negative: !self.negative)
  }
}


/// This extension implements all the boilerplate to make `BigInt` compatible
/// to the applicable Swift 2 protocols. `BigInt` is convertible from integer literals,
/// convertible from Strings, it's a signed number, equatable, comparable, and implements
/// all integer arithmetic functions.
extension BigInt: IntegerLiteralConvertible,
                  StringLiteralConvertible,
                  Equatable,
                  IntegerArithmeticType,
                  SignedIntegerType {
  
  public typealias Distance = BigInt
  
  public convenience init(_ value: UInt) {
    self.init(Int64(value))
  }
  
  public convenience init(_ value: UInt8) {
    self.init(Int64(value))
  }
  
  public convenience init(_ value: UInt16) {
    self.init(Int64(value))
  }
  
  public convenience init(_ value: UInt32) {
    self.init(Int64(value))
  }
  
  public convenience init(_ value: Int) {
    self.init(Int64(value))
  }
  
  public convenience init(_ value: Int8) {
    self.init(Int64(value))
  }
  
  public convenience init(_ value: Int16) {
    self.init(Int64(value))
  }
  
  public convenience init(_ value: Int32) {
    self.init(Int64(value))
  }
  
  public convenience init(integerLiteral value: Int64) {
    self.init(value)
  }
  
  public convenience init(_builtinIntegerLiteral value: _MaxBuiltinIntegerType) {
    self.init(Int64(_builtinIntegerLiteral: value))
  }
  
  public convenience init(stringLiteral value: String) {
    if let this = BigInt.fromString(value) {
      self.init(this.words, negative: this.negative)
    } else {
      self.init(0)
    }
  }
  
  public convenience init(
    extendedGraphemeClusterLiteral value: String.ExtendedGraphemeClusterLiteralType) {
      self.init(stringLiteral: String(value))
  }
  
  public convenience init(
    unicodeScalarLiteral value: String.UnicodeScalarLiteralType) {
      self.init(stringLiteral: String(value))
  }
  
  public static func addWithOverflow(lhs: BigInt, _ rhs: BigInt) -> (BigInt, overflow: Bool) {
    return (lhs.plus(rhs), overflow: false)
  }
  
  public static func subtractWithOverflow(lhs: BigInt, _ rhs: BigInt) -> (BigInt, overflow: Bool) {
    return (lhs.minus(rhs), overflow: false)
  }
  
  public static func multiplyWithOverflow(lhs: BigInt, _ rhs: BigInt) -> (BigInt, overflow: Bool) {
    return (lhs.times(rhs), overflow: false)
  }
  
  public static func divideWithOverflow(lhs: BigInt, _ rhs: BigInt) -> (BigInt, overflow: Bool) {
    let res = lhs.dividedBy(rhs)
    return (res.quotient, overflow: false)
  }
  
  public static func remainderWithOverflow(lhs: BigInt, _ rhs: BigInt) -> (BigInt, overflow: Bool) {
    let res = lhs.dividedBy(rhs)
    return (res.remainder, overflow: false)
  }
  
  /// The empty bitset.
  public static var allZeros: BigInt {
    return BigInt(0)
  }
  
  /// Returns this number as an `IntMax` number
  public func toIntMax() -> IntMax {
    if let res = self.intValue {
      return res
    }
    preconditionFailure("`BigInt` value cannot be converted to `IntMax`")
  }
  
  /// This is in preparation for making `BigInt` implement `SignedIntegerType`.
  public func advancedBy(n: BigInt) -> BigInt {
    return self.plus(n)
  }
  
  /// This is in preparation for making `BigInt` implement `SignedIntegerType`.
  public func distanceTo(other: BigInt) -> BigInt {
    return other.minus(self)
  }
  
  /// This is in preparation for making `BigInt` implement `SignedIntegerType`.
  /// Returns the next consecutive value after `self`.
  ///
  /// - Requires: The next value is representable.
  public func successor() -> BigInt {
    return self.plus(1)
  }
  
  /// This is in preparation for making `BigInt` implement `SignedIntegerType`.
  /// Returns the previous consecutive value before `self`.
  ///
  /// - Requires: `self` has a well-defined predecessor.
  public func predecessor() -> BigInt {
    return self.minus(1)
  }
}


/// Returns the sum of `lhs` and `rhs`
///
/// - Note: Without this declaration, the compiler complains that `+` is declared
///         multiple times.
public func +(lhs: BigInt, rhs: BigInt) -> BigInt {
  return lhs.plus(rhs)
}

/// Returns the difference between `lhs` and `rhs`
///
/// - Note: Without this declaration, the compiler complains that `+` is declared
///         multiple times.
public func -(lhs: BigInt, rhs: BigInt) -> BigInt {
  return lhs.minus(rhs)
}

/// Adds `rhs` to `lhs` and stores the result in `lhs`.
///
/// - Note: Without this declaration, the compiler complains that `+` is declared
///         multiple times.
public func +=(inout lhs: BigInt, rhs: BigInt) {
  lhs = lhs.plus(rhs)
}

/// Returns true if `lhs` is less than `rhs`, false otherwise.
public func <(lhs: BigInt, rhs: BigInt) -> Bool {
  return lhs.compareTo(rhs) < 0
}

/// Returns true if `lhs` is less than or equals `rhs`, false otherwise.
public func <=(lhs: BigInt, rhs: BigInt) -> Bool {
  return lhs.compareTo(rhs) <= 0
}

/// Returns true if `lhs` is greater or equals `rhs`, false otherwise.
public func >=(lhs: BigInt, rhs: BigInt) -> Bool {
  return lhs.compareTo(rhs) >= 0
}

/// Returns true if `lhs` is greater than equals `rhs`, false otherwise.
public func >(lhs: BigInt, rhs: BigInt) -> Bool {
  return lhs.compareTo(rhs) > 0
}

/// Returns true if `lhs` is equals `rhs`, false otherwise.
public func ==(lhs: BigInt, rhs: BigInt) -> Bool {
  return lhs.compareTo(rhs) == 0
}

/// Returns true if `lhs` is not equals `rhs`, false otherwise.
public func !=(lhs: BigInt, rhs: BigInt) -> Bool {
  return lhs.compareTo(rhs) != 0
}

/// Negates `self`.
public prefix func -(num: BigInt) -> BigInt {
  return num.negate
}

/// Returns the intersection of bits set in `lhs` and `rhs`.
public func &(lhs: BigInt, rhs: BigInt) -> BigInt {
  return lhs.and(rhs)
}

/// Returns the union of bits set in `lhs` and `rhs`.
public func |(lhs: BigInt, rhs: BigInt) -> BigInt {
  return lhs.or(rhs)
}

/// Returns the bits that are set in exactly one of `lhs` and `rhs`.
public func ^(lhs: BigInt, rhs: BigInt) -> BigInt {
  return lhs.xor(rhs)
}

/// Returns the bitwise inverted BigInt
public prefix func ~(x: BigInt) -> BigInt {
  return x.invert
}

/// Returns the maximum of `fst` and `snd`.
public func max(fst: BigInt, snd: BigInt) -> BigInt {
  return fst.compareTo(snd) >= 0 ? fst : snd
}

/// Returns the minimum of `fst` and `snd`.
public func min(fst: BigInt, snd: BigInt) -> BigInt {
  return fst.compareTo(snd) <= 0 ? fst : snd
}
