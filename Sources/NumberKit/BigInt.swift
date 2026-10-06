//
//  BigInt.swift
//  NumberKit
//
//  Created by Matthias Zenger on 12/08/2015.
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
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation


/// Struct `BigInt` implements signed, arbitrary-size integers. `BigInt` values
/// are immutable, i.e. all operations on `BigInt` values return result values.
/// There are no mutable methdos. `BigInt` provides all the signed, integer
/// arithmetic operations from Swift and implements the corresponding protocols.
/// `BigInt` supports `StaticBigInt`literals, i.e. is is possible to use arbitrary
/// length integer literals. String literals containing `BigInt` numbers are still
/// supported for backward compatibility.
///
/// - Note: `BigInt` is internally implemented as a Swift array of UInt32 numbers
///         and a boolean to represent the sign. Due to this overhead, for instance,
///         representing a `UInt64` value as a `BigInt` will result in an object that
///         requires more memory than the corresponding `UInt64` integer. Use enum
///         `Integer` to avoid such overhead.
public struct BigInt: Hashable,
                      Codable,
                      Sendable,
                      CustomStringConvertible,
                      CustomDebugStringConvertible {
  
  // This is an array of `UInt32` words. The lowest significant word comes first in
  // the array.
  private let uwords: ContiguousArray<UInt32>
  
  // `negative` signals whether the number is positive or negative.
  private let negative: Bool
  
  // All internal computations are based on 32-bit words; the base of this representation
  // is therefore `UInt32.max + 1`.
  private static let base: UInt64 = UInt64(UInt32.max) &+ 1
  
  // `hiword` extracts the highest 32-bit value of a `UInt64`.
  private static func hiword(_ num: UInt64) -> UInt32 {
    return UInt32((num >> 32) & 0xffffffff)
  }
  
  // `loword` extracts the lowest 32-bit value of a `UInt64`.
  private static func loword(_ num: UInt64) -> UInt32 {
    return UInt32(num & 0xffffffff)
  }
  
  // `joinwords` combines two words into a `UInt64` value.
  private static func joinwords(_ lword: UInt32, _ hword: UInt32) -> UInt64 {
    return (UInt64(hword) << 32) &+ UInt64(lword)
  }
  
  /// Class `Base` defines a representation and type for the base used in computing
  /// `String` representations of `BigInt` objects.
  ///
  /// - Note: It is currently not possible to define custom `Base` objects. It needs
  ///         to be figured out first what safety checks need to be put in place.
  public final class Base: Sendable {
    public static let bin = BigInt.binBase
    public static let oct = BigInt.octBase
    public static let dec = BigInt.decBase
    public static let hex = BigInt.hexBase
    
    fileprivate let digitSpace: [Character]
    fileprivate let digitMap: [Character: UInt8]
    
    fileprivate init(digitSpace: [Character], digitMap: [Character: UInt8]) {
      self.digitSpace = digitSpace
      self.digitMap = digitMap
    }
    
    fileprivate var radix: Int {
      return self.digitSpace.count
    }
  }
  
  /// Representing base 2 (binary)
  public static let binBase = Base(
    digitSpace: ["0", "1"],
    digitMap: ["0": 0, "1": 1]
  )
  
  /// Representing base 8 (octal)
  public static let octBase = Base(
    digitSpace: ["0", "1", "2", "3", "4", "5", "6", "7"],
    digitMap: ["0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7]
  )
  
  /// Representing base 10 (decimal)
  public static let decBase = Base(
    digitSpace: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"],
    digitMap: ["0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9]
  )
  
  /// Representing base 16 (hex)
  public static let hexBase = Base(
    digitSpace: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"],
    digitMap: ["0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9,
      "A": 10, "B": 11, "C": 12, "D": 13, "E": 14, "F": 15,
      "a": 10, "b": 11, "c": 12, "d": 13, "e": 14, "f": 15]
  )
  
  /// Maps a radix number to the corresponding `Base` object. Only 2, 8, 10, and 16 are
  /// supported.
  public static func base(of radix: Int) -> Base {
    switch radix {
      case 2:
        return BigInt.binBase
      case 8:
        return BigInt.octBase
      case 10:
        return BigInt.decBase
      case 16:
        return BigInt.hexBase
      default:
        preconditionFailure("unsupported base \(radix)")
    }
  }
  
  /// Internal primary constructor. It removes superfluous words and normalizes the
  /// representation of zero.
  internal init(words: ContiguousArray<UInt32>, negative: Bool) {
    var words = words
    while words.count > 1 && words[words.count - 1] == 0 {
      words.removeLast()
    }
    if words.isEmpty {
      words.append(0)
    }
    self.uwords = words
    self.negative = words.count == 1 && words[0] == 0 ? false : negative
  }
  
  /// Internal constructor for words that are known to be normalized (no superfluous
  /// high words, and `negative` is false for zero).
  private init(normalized words: ContiguousArray<UInt32>, negative: Bool) {
    self.uwords = words
    self.negative = negative
  }
  
  /// Internal primary constructor. It removes superfluous words and normalizes the
  /// representation of zero.
  internal init(words: [UInt], negative: Bool) {
    var uwords = ContiguousArray<UInt32>()
    uwords.reserveCapacity(words.count * 2)
    for word in words {
      let myword = UInt64(word)
      uwords.append(BigInt.loword(myword))
      uwords.append(BigInt.hiword(myword))
    }
    self.init(words: uwords, negative: negative)
  }
  
  private static let int64Max = UInt64(Int64.max)
  
  /// Initializes a `BigInt` from the given `UInt64` value
  public init(_ value: UInt64) {
    self.init(words: [BigInt.loword(value), BigInt.hiword(value)], negative: false)
  }
  
  /// Initializes a `BigInt` from the given `Int64` value
  public init(_ value: Int64) {
    let absvalue = value == Int64.min ? BigInt.int64Max + 1 : UInt64(value < 0 ? -value : value)
    self.init(words: [BigInt.loword(absvalue), BigInt.hiword(absvalue)], negative: value < 0)
  }
  
  /// Initializes a `BigInt` from the given `Double` value
  public init(_ value: Double) {
    precondition(value.isFinite, "BigInt cannot represent infinity or NaN")
    if value > -1.0 && value < 1.0 {
      self.init(words: [BigInt.loword(0), BigInt.hiword(0)], negative: value < 0.0)
    } else if value > -Double(UInt64.max) && value < Double(UInt64.max) {
      let absvalue = UInt64(value < 0 ? -value : value)
      self.init(words: [BigInt.loword(absvalue), BigInt.hiword(absvalue)], negative: value < 0.0)
    } else {
      let x = BigInt(UInt64(value.significand * pow(2.0, 63.0)))
      let y = x * BigInt(2).toPower(of: BigInt(value.exponent - 63))
      self.init(words: y.uwords, negative: value < 0.0)
    }
  }
    
  /// Creates a `BigInt` from a sequence of digits for a given base. The first digit in the
  /// array of digits is the least significant one. `negative` is used to indicate negative
  /// `BigInt` numbers.
  public init(digits: [UInt8], negative: Bool = false, base: Base = BigInt.decBase) {
    // Process as many digits as fit into a word at once
    let radix = UInt64(base.radix)
    var chunkDigits = 0
    var chunkRadix: UInt64 = 1
    while chunkRadix * radix <= UInt64(UInt32.max) {
      chunkRadix *= radix
      chunkDigits += 1
    }
    var words = ContiguousArray<UInt32>()
    words.reserveCapacity(digits.count / Swift.max(chunkDigits, 1) + 1)
    var i = 0
    while i < digits.count {
      let end = Swift.min(i + chunkDigits, digits.count)
      var value: UInt64 = 0
      var mult: UInt64 = 1
      while i < end {
        value = value * radix + UInt64(digits[i])
        mult *= radix
        i += 1
      }
      // words = words * mult + value
      var carry = value
      for k in words.indices {
        let x = UInt64(words[k]) * mult + carry
        words[k] = UInt32(truncatingIfNeeded: x)
        carry = x >> 32
      }
      if carry > 0 {
        words.append(UInt32(truncatingIfNeeded: carry))
      }
    }
    self.init(words: words, negative: negative)
  }
  
  /// Creates a `BigInt` from a string containing a number using the given base.
  public init?(from str: String, base: Base = BigInt.decBase) {
    var negative = false
    var i = str.startIndex
    while i < str.endIndex && str[i] == " " {
      i = str.index(after: i)
    }
    if i < str.endIndex {
      if str[i] == "-" {
        negative = true
        i = str.index(after: i)
      } else if str[i] == "+" {
        i = str.index(after: i)
      }
    }
    if i < str.endIndex && str[i] == "0" {
      while i < str.endIndex && str[i] == "0" {
        i = str.index(after: i)
      }
      if i == str.endIndex {
        self.init(0)
        return
      }
    }
    var temp: [UInt8] = []
    while i < str.endIndex {
      if let digit = base.digitMap[str[i]] {
        temp.append(digit)
        i = str.index(after: i)
      } else {
        break
      }
    }
    while i < str.endIndex && str[i] == " " {
      i = str.index(after: i)
    }
    guard i == str.endIndex && !temp.isEmpty else {
      return nil
    }
    self.init(digits: temp, negative: negative, base: base)
  }
  
  /// Initializes a non-negative `BigInt` randomly with a given number of bits using the
  /// provided random number generator.
  public init<R: RandomNumberGenerator>(randomWithMaxBits bitWidth: Int,
                                        using generator: inout R) {
    var words = ContiguousArray<UInt32>()
    let capacity = (bitWidth + UInt32.bitWidth - 1)/UInt32.bitWidth
    if capacity > 2 {
      words.reserveCapacity(capacity)
    }
    var bits = bitWidth
    while bits >= UInt32.bitWidth {
      words.append(generator.next())
      bits -= UInt32.bitWidth
    }
    if bits > 0 {
      let mask: UInt32 = (1 << bits) - 1
      words.append((generator.next() as UInt32) & mask)
    }
    self.init(words: words, negative: false)
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let object = try? container.decode(String.self),
       let bigInt = BigInt(from: object) {
      self = bigInt
    } else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(codingPath: decoder.codingPath,
                              debugDescription: "Invalid BigInt encoding"))
    }
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.description)
  }
  
  /// Converts the `BigInt` object into a string using the given base. `BigInt.decBase` is
  /// used as the default base.
  public func toString(base: Base = BigInt.decBase,
                       groupSep: String? = nil,
                       groupSize: Int = 3,
                       forceSign: Bool = false,
                       plusSign: String = "+",
                       minusSign: String = "-") -> String {
    // Determine base
    let radix = UInt32(base.radix)
    // Shortcut handling of zero
    if self.isZero {
      // In maths, zero does not have a sign, but it appears that when a sign is forced,
      // a "+" is used normally in conjunction with zero.
      return forceSign ? "\(plusSign)0" : "0"
    }
    // Determine the largest power of the radix that fits into a word
    let radixValue = UInt64(radix)
    var chunkRadix: UInt64 = 1
    var chunkDigits = 0
    while chunkRadix * radixValue <= UInt64(UInt32.max) {
      chunkRadix *= radixValue
      chunkDigits += 1
    }
    // Digits are generated starting with the least significant one; the string is
    // reversed at the end.
    let reversedSep = groupSep.map { String($0.reversed()) }
    var res = ""
    res.reserveCapacity(self.uwords.count * 10 + 2)
    var resDigits = 0
    func append(_ word: UInt32, length: Int) {
      var (value, n) = (Int(word), 0)
      while n < length || value > 0 {
        if resDigits > 0 && resDigits % groupSize == 0,
           let sep = reversedSep {
          res.append(sep)
        }
        res.append(base.digitSpace[value % Int(radix)])
        resDigits += 1
        value /= Int(radix)
        n += 1
      }
    }
    var words = self.uwords
    var count = words.count
    while count > 0 {
      var rem: UInt64 = 0
      var i = count - 1
      while i >= 0 {
        let x = (rem << 32) | UInt64(words[i])
        words[i] = UInt32(truncatingIfNeeded: x / chunkRadix)
        rem = x % chunkRadix
        i -= 1
      }
      while count > 0 && words[count - 1] == 0 {
        count -= 1
      }
      append(UInt32(truncatingIfNeeded: rem), length: count > 0 ? chunkDigits : 0)
    }
    if negative {
      res.append(contentsOf: minusSign.reversed())
    } else if forceSign {
      res.append(contentsOf: plusSign.reversed())
    }
    return String(res.reversed())
  }
  
  /// Returns a string representation of this `BigInt` number using base 10.
  public var description: String {
    return toString()
  }
  
  /// Returns a string representation of this `BigInt` number for debugging purposes.
  public var debugDescription: String {
    var res = "{\(uwords.count): \(uwords[0])"
    for i in 1..<uwords.count {
      res += ", \(uwords[i])"
    }
    return res + "}"
  }

  /// Returns the `BigInt` as a `Int64` value if this is possible. If the number is outside
  /// the `Int64` range, the property will contain `nil`.
  public var intValue: Int64? {
    guard uwords.count <= 2 else {
      return nil
    }
    var value: UInt64 = UInt64(uwords[0])
    if uwords.count == 2 {
      value += UInt64(uwords[1]) * BigInt.base
    }
    if negative && value == BigInt.int64Max + 1 {
      return Int64.min
    }
    if value <= BigInt.int64Max {
      return negative ? -Int64(value) : Int64(value)
    }
    return nil
  }
  
  /// Returns the `BigInt` as a `UInt64` value if this is possible. If the number is outside
  /// the `UInt64` range, the property will contain `nil`.
  public var uintValue: UInt64? {
    guard uwords.count <= 2 && !negative else {
      return nil
    }
    var value: UInt64 = UInt64(uwords[0])
    if uwords.count == 2 {
      value += UInt64(uwords[1]) * BigInt.base
    }
    return value
  }
  
  /// Returns the `BigInt` as a `Double` value. This might lead to a significant loss of
  /// precision, but this operation is always possible.
  public var doubleValue: Double {
    var res: Double = 0.0
    for word in uwords.reversed() {
      res = res * Double(BigInt.base) + Double(word)
    }
    return self.negative ? -res : res
  }
  
  /// For hashing values.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(negative)
    for i in 0..<uwords.count {
      hasher.combine(uwords[i])
    }
  }
  
  /// Returns true if this `BigInt` is negative.
  public var isNegative: Bool {
    return negative
  }
  
  /// Returns true if this `BigInt` represents zero.
  public var isZero: Bool {
    return self.uwords.count == 1 && self.uwords[0] == 0
  }
  
  /// Returns true if this `BigInt` represents one.
  public var isOne: Bool {
    return self.uwords.count == 1 && self.uwords[0] == 1 && !self.negative
  }
  
  /// Returns a `BigInt` with swapped sign.
  public var negate: BigInt {
    return BigInt(normalized: uwords, negative: !negative && !self.isZero)
  }
  
  /// Returns the absolute value of this `BigInt`.
  public var abs: BigInt {
    return self.negative ? BigInt(normalized: uwords, negative: false) : self
  }
  
  /// Returns -1 if `self` is less than `rhs`,
  ///          0 if `self` is equals to `rhs`,
  ///         +1 if `self` is greater than `rhs`
  public func compare(to rhs: BigInt) -> Int {
    guard self.negative == rhs.negative else {
      return self.negative ? -1 : 1
    }
    return self.negative ? rhs.compareDigits(with: self) : self.compareDigits(with: rhs)
  }
  
  private func compareDigits(with rhs: BigInt) -> Int {
    guard self.uwords.count == rhs.uwords.count else {
      return self.uwords.count < rhs.uwords.count ? -1 : 1
    }
    for i in 1...self.uwords.count {
      let a = self.uwords[self.uwords.count - i]
      let b = rhs.uwords[self.uwords.count - i]
      if a != b {
        return a < b ? -1 : 1
      }
    }
    return 0
  }
  
  /// Returns the sum of `self` and `rhs` as a `BigInt`.
  public func plus(_ rhs: BigInt) -> BigInt {
    guard !rhs.isZero else {
      return self
    }
    guard self.negative == rhs.negative else {
      return self.minus(rhs.negate)
    }
    let (b1, b2) = self.uwords.count < rhs.uwords.count ? (rhs, self) : (self, rhs)
    var res = ContiguousArray<UInt32>()
    res.reserveCapacity(b1.uwords.count)
    var sum: UInt64 = 0
    for i in 0..<b2.uwords.count {
      sum += UInt64(b1.uwords[i])
      sum += UInt64(b2.uwords[i])
      res.append(BigInt.loword(sum))
      sum = UInt64(BigInt.hiword(sum))
    }
    for i in b2.uwords.count..<b1.uwords.count {
      sum += UInt64(b1.uwords[i])
      res.append(BigInt.loword(sum))
      sum = UInt64(BigInt.hiword(sum))
    }
    if sum > 0 {
      res.append(BigInt.loword(sum))
    }
    return BigInt(words: res, negative: self.negative)
  }
  
  /// Returns the difference between `self` and `rhs` as a `BigInt`.
  public func minus(_ rhs: BigInt) -> BigInt {
    guard !rhs.isZero else {
      return self
    }
    guard self.negative == rhs.negative else {
      return self.plus(rhs.negate)
    }
    let cmp = self.compareDigits(with: rhs)
    guard cmp != 0 else {
      return 0
    }
    let negative = cmp < 0 ? !self.negative : self.negative
    let (b1, b2) = cmp < 0 ? (rhs, self) : (self, rhs)
    var res = ContiguousArray<UInt32>()
    var carry: UInt64 = 0
    for i in 0..<b2.uwords.count {
      if UInt64(b1.uwords[i]) < UInt64(b2.uwords[i]) + carry {
        res.append(UInt32(BigInt.base + UInt64(b1.uwords[i]) - UInt64(b2.uwords[i]) - carry))
        carry = 1
      } else {
        res.append(b1.uwords[i] - b2.uwords[i] - UInt32(carry))
        carry = 0
      }
    }
    for i in b2.uwords.count..<b1.uwords.count {
      if b1.uwords[i] < UInt32(carry) {
        res.append(UInt32.max)
        carry = 1
      } else {
        res.append(b1.uwords[i] - UInt32(carry))
        carry = 0
      }
    }
    return BigInt(words: res, negative: negative)
  }
  
  /// Returns the result of mulitplying `self` with `rhs` as a `BigInt`
  public func times(_ rhs: BigInt) -> BigInt {
    let (b1, b2) = self.uwords.count < rhs.uwords.count ? (rhs, self) : (self, rhs)
    var res = ContiguousArray<UInt32>(repeating: 0, count: b1.uwords.count + b2.uwords.count)
    for i in 0..<b2.uwords.count {
      var sum: UInt64 = 0
      for j in 0..<b1.uwords.count {
        let mult = UInt64(b1.uwords[j]) * UInt64(b2.uwords[i])
        sum += UInt64(res[i + j]) + mult
        res[i + j] = BigInt.loword(sum)
        sum = UInt64(BigInt.hiword(sum))
      }
      res[i + b1.uwords.count] = BigInt.loword(sum)
    }
    return BigInt(words: res, negative: b1.negative != b2.negative)
  }
  
  /// Divides the magnitude `u` by the single word `v` in place. `u` must not be empty and
  /// `v` must not be zero. Returns the remainder; `u` holds the quotient afterwards.
  private static func shortDivide(_ u: inout ContiguousArray<UInt32>, by v: UInt32) -> UInt32 {
    let divisor = UInt64(v)
    var rem: UInt64 = 0
    var i = u.count - 1
    while i >= 0 {
      let x = (rem << 32) | UInt64(u[i])
      u[i] = UInt32(truncatingIfNeeded: x / divisor)
      rem = x % divisor
      i -= 1
    }
    return UInt32(truncatingIfNeeded: rem)
  }
  
  /// Divides magnitude `u` by magnitude `v` (Knuth, TAOCP vol. 2, algorithm D) and returns
  /// quotient and remainder as arrays of words without superfluous leading zeros being
  /// removed. `v` must have at least two words and `u` must have at least as many words
  /// as `v`; the highest word of `v` must not be zero.
  private static func knuthDivide(_ u: ContiguousArray<UInt32>,
                                  _ v: ContiguousArray<UInt32>)
                                  -> (quotient: ContiguousArray<UInt32>,
                                      remainder: ContiguousArray<UInt32>) {
    let n = v.count
    let m = u.count
    // Normalize such that the highest bit of the divisor is set
    let shift = v[n - 1].leadingZeroBitCount
    var vn = ContiguousArray<UInt32>(repeating: 0, count: n)
    var un = ContiguousArray<UInt32>(repeating: 0, count: m + 1)
    if shift == 0 {
      for i in 0..<n {
        vn[i] = v[i]
      }
      for i in 0..<m {
        un[i] = u[i]
      }
    } else {
      let back = UInt32.bitWidth - shift
      var i = n - 1
      while i > 0 {
        vn[i] = (v[i] << shift) | (v[i - 1] >> back)
        i -= 1
      }
      vn[0] = v[0] << shift
      un[m] = u[m - 1] >> back
      i = m - 1
      while i > 0 {
        un[i] = (u[i] << shift) | (u[i - 1] >> back)
        i -= 1
      }
      un[0] = u[0] << shift
    }
    var q = ContiguousArray<UInt32>(repeating: 0, count: m - n + 1)
    let vtop = UInt64(vn[n - 1])
    let vsecond = UInt64(vn[n - 2])
    var j = m - n
    while j >= 0 {
      // Estimate the quotient digit
      let num = (UInt64(un[j + n]) << 32) | UInt64(un[j + n - 1])
      var qhat = num / vtop
      var rhat = num % vtop
      while qhat >= BigInt.base || qhat * vsecond > ((rhat << 32) | UInt64(un[j + n - 2])) {
        qhat -= 1
        rhat += vtop
        if rhat >= BigInt.base {
          break
        }
      }
      // Multiply and subtract
      var borrow: Int64 = 0
      for i in 0..<n {
        let p = qhat * UInt64(vn[i])
        let t = Int64(un[i + j]) - borrow - Int64(p & 0xffffffff)
        un[i + j] = UInt32(truncatingIfNeeded: t)
        borrow = Int64(p >> 32) - (t >> 32)
      }
      let t = Int64(un[j + n]) - borrow
      un[j + n] = UInt32(truncatingIfNeeded: t)
      if t < 0 {
        // The estimate was one too large: add the divisor back
        qhat -= 1
        var carry: UInt64 = 0
        for i in 0..<n {
          let x = UInt64(un[i + j]) + UInt64(vn[i]) + carry
          un[i + j] = UInt32(truncatingIfNeeded: x)
          carry = x >> 32
        }
        un[j + n] = UInt32(truncatingIfNeeded: UInt64(un[j + n]) + carry)
      }
      q[j] = UInt32(truncatingIfNeeded: qhat)
      j -= 1
    }
    // Denormalize the remainder
    var r = ContiguousArray<UInt32>(repeating: 0, count: n)
    if shift == 0 {
      for i in 0..<n {
        r[i] = un[i]
      }
    } else {
      for i in 0..<n {
        r[i] = (un[i] >> shift) | (un[i + 1] << (UInt32.bitWidth - shift))
      }
    }
    return (q, r)
  }
  
  /// Divides `self` by `rhs` and returns the quotient and the remainder as a `BigInt`. The
  /// quotient is truncated towards zero and the remainder has the sign of `self`.
  public func divided(by rhs: BigInt) -> (quotient: BigInt, remainder: BigInt) {
    precondition(!rhs.isZero, "division by zero")
    guard rhs.uwords.count <= self.uwords.count else {
      return (BigInt(0), self)
    }
    let neg = self.negative != rhs.negative
    if rhs.uwords.count == 1 {
      var quotient = self.uwords
      let rem = BigInt.shortDivide(&quotient, by: rhs.uwords[0])
      return (BigInt(words: quotient, negative: neg),
              BigInt(words: [rem], negative: self.negative))
    }
    let (q, r) = BigInt.knuthDivide(self.uwords, rhs.uwords)
    return (BigInt(words: q, negative: neg), BigInt(words: r, negative: self.negative))
  }
  
  /// Raises this `BigInt` value to the power of `exp`.
  public func toPower(of exp: BigInt) -> BigInt {
    precondition(!exp.negative, "toPower(of:) with negative exponent")
    if exp.isZero {
      return BigInt.one
    }
    var radix = self
    var res = BigInt.one
    let last = exp.uwords.count - 1
    for (i, word) in exp.uwords.enumerated() {
      var bits = word
      var n = 0
      while n < UInt32.bitWidth {
        if bits & 1 == 1 {
          res = res * radix
        }
        bits >>= 1
        n += 1
        if i == last && bits == 0 {
          return res
        }
        radix = radix * radix
      }
    }
    return res
  }
  
  /// Computes the square root; this is the largest `BigInt` value `x` such that `x * x` is
  /// at most `self`.
  public var sqrt: BigInt {
    guard !self.negative else {
      preconditionFailure("cannot compute square root of negative number")
    }
    guard !self.isZero && !self.isOne else {
      return self
    }
    // Newton iteration starting with a power of two that is at least as large as the root
    var x = BigInt.one << ((self.lastBitSet + 1) / 2)
    while true {
      let y = (x + self / x) >> 1
      if y >= x {
        return x
      }
      x = y
    }
  }
  
  /// Returns the bitwise negation of this `BigInt` number assuming a representation in
  /// two-complement form.
  public var not: BigInt {
    return self.negate.minus(BigInt.one)
  }
  
  /// Returns true if the most significant bit is set in the number represented by `words`.
  private static func isMostSignificantBitSet(_ words: ContiguousArray<UInt32>) -> Bool {
    return (words.last! & (1 << (UInt32.bitWidth - 1))) != 0
  }
  
  /// Creates a `BigInt` number from a number represented by `words` in two-complement form.
  private static func fromTwoComplement(_ words: inout ContiguousArray<UInt32>) -> BigInt {
    if BigInt.isMostSignificantBitSet(words) {
      var carry = true
      for i in words.indices {
        if carry {
          (words[i], carry) = (~words[i]).addingReportingOverflow(1)
        } else {
          words[i] = ~words[i]
        }
      }
      return BigInt(words: words, negative: true)
    } else {
      return BigInt(words: words, negative: false)
    }
  }
  
  /// Computes the minimum number of words needed for applying bit operations to two
  /// numbers in two-complement representation. `left` and `right` are representing the
  /// magnitude of those two numbers.
  private static func twoComplementSize(_ left: ContiguousArray<UInt32>,
                                        _ right: ContiguousArray<UInt32>) -> Int {
    return Swift.max(left.count + (BigInt.isMostSignificantBitSet(left) ? 1 : 0),
                     right.count + (BigInt.isMostSignificantBitSet(right) ? 1 : 0))
  }
  
  /// Applies the bitwise operation `op` to this value and `rhs` assuming a representation
  /// of the numbers in two-complement form.
  @inline(__always)
  private func bitwise(_ rhs: BigInt, _ op: (UInt32, UInt32) -> UInt32) -> BigInt {
    var (leftcarry, rightcarry) = (true, true)
    let size = BigInt.twoComplementSize(self.uwords, rhs.uwords)
    var res = ContiguousArray<UInt32>()
    res.reserveCapacity(size)
    for i in 0..<size {
      var leftword: UInt32 = i < self.uwords.count ? self.uwords[i] : 0
      if self.negative {
        if leftcarry {
          (leftword, leftcarry) = (~leftword).addingReportingOverflow(1)
        } else {
          leftword = ~leftword
        }
      }
      var rightword: UInt32 = i < rhs.uwords.count ? rhs.uwords[i] : 0
      if rhs.negative {
        if rightcarry {
          (rightword, rightcarry) = (~rightword).addingReportingOverflow(1)
        } else {
          rightword = ~rightword
        }
      }
      res.append(op(leftword, rightword))
    }
    return BigInt.fromTwoComplement(&res)
  }
  
  /// Computes the bitwise `and` between this value and `rhs` assuming a
  /// representation of the numbers in two-complement form.
  public func and(_ rhs: BigInt) -> BigInt {
    return self.bitwise(rhs, &)
  }
  
  /// Computes the bitwise `or` (inclusive or) between this value and `rhs` assuming a
  /// representation of the numbers in two-complement form.
  public func or(_ rhs: BigInt) -> BigInt {
    return self.bitwise(rhs, |)
  }
  
  /// Computes the bitwise `xor` (exclusive or) between this value and `rhs` assuming a
  /// representation of the numbers in two-complement form.
  public func xor(_ rhs: BigInt) -> BigInt {
    return self.bitwise(rhs, ^)
  }
  
  /// Shifts the bits in this `BigInt` to the left if `n` is positive, or to the right
  /// if `n` is negative. This is an arithmetic shift operation.
  public func shift(_ n: Int) -> BigInt {
    if n < 0 {
      return self.shiftRight(-n)
    } else if n > 0 {
      return self.shiftLeft(n)
    } else {
      return self
    }
  }
  
  private func shiftLeft(_ x: Int) -> BigInt {
    let swords = x / UInt32.bitWidth
    let sbits = x % UInt32.bitWidth
    var res = ContiguousArray<UInt32>()
    res.reserveCapacity(Int(self.uwords.count) + swords)
    res.append(contentsOf: repeatElement(0 as UInt32, count: swords))
    var carry: UInt32 = 0
    for word in self.uwords {
      res.append((word << sbits) | carry)
      carry = word >> (UInt32.bitWidth - sbits)
    }
    if carry > 0 {
      res.append(carry)
    }
    return BigInt(words: res, negative: self.negative)
  }
  
  private func shiftRight(_ x: Int) -> BigInt {
    let swords = x / UInt32.bitWidth
    let sbits = x % UInt32.bitWidth
    var res = ContiguousArray<UInt32>()
    res.reserveCapacity(Int(self.uwords.count) - swords)
    var carry: UInt32 = 0
    var i = self.uwords.count - 1
    while i >= swords {
      let word = self.uwords[i]
      res.append((word >> sbits) | carry)
      carry = word << (UInt32.bitWidth - sbits)
      i -= 1
    }
    let x = BigInt(words: ContiguousArray<UInt32>(res.reversed()), negative: self.negative)
    if self.negative {
      // Round towards negative infinity if any non-zero bit was shifted out
      var lost = carry > 0
      var j = 0
      while !lost && j < Swift.min(swords, self.uwords.count) {
        lost = self.uwords[j] != 0
        j += 1
      }
      if lost {
        return x.minus(BigInt.one)
      }
    }
    return x
  }
  
  /// Number of bits used to represent the (unsigned) `BigInt` number.
  public var bitSize: Int {
    return self.uwords.count * UInt32.bitWidth
  }
  
  /// Number of bits set in this `BigInt` number. For negative numbers, `n.bigCount` returns
  /// `~n.not.bigCount`.
  public var bitCount: Int {
    if self.negative {
      return ~self.not.bitCount
    } else {
      var res = 0
      for word in self.uwords {
        res = res &+ bitcount(word)
      }
      return res
    }
  }
  
  /// Returns the first bit that is set in the two-complement form of this number. For zero,
  /// `firstBitSet` will be -1.
  public var firstBitSet: Int {
    guard !self.isZero else {
      return -1
    }
    var i = 0
    var carry = true
    while i < self.uwords.count {
      var word = self.uwords[i]
      if self.negative {
        if carry {
          (word, carry) = (~word).addingReportingOverflow(1)
        } else {
          word = ~word
        }
      }
      if word != 0 {
        return i * UInt32.bitWidth + word.trailingZeroBitCount
      }
      i += 1
    }
    return i * UInt32.bitWidth
  }
  
  /// Returns the last bit that is set in the two-complement form of this number if it is
  /// positive. For negative numbers, the last bit is computed of the negated number. For 0,
  /// this method returns 0.
  public var lastBitSet: Int {
    guard !self.isZero else {
      return 0
    }
    let number = self.negative ? self.not : self
    var i = number.uwords.count - 1
    while i >= 0 && number.uwords[i] == 0 {
      i -= 1
    }
    return i * UInt32.bitWidth + UInt32.bitWidth - number.uwords[i].leadingZeroBitCount
  }
  
  /// Returns true if bit `n` is set
  public func isBitSet(_ n: Int) -> Bool {
    guard !self.isZero else {
      return false
    }
    let nword = n / UInt32.bitWidth
    let nbit = n % UInt32.bitWidth
    guard nword < self.uwords.count else {
      return self.negative
    }
    guard self.negative else {
      return (self.uwords[nword] & (1 << nbit)) != 0
    }
    var i = 0
    var carry = true
    var word: UInt32 = 0
    while i <= nword {
      word = self.uwords[i]
      if self.negative {
        if carry {
          (word, carry) = (~word).addingReportingOverflow(1)
        } else {
          word = ~word
        }
      }
      i += 1
    }
    return (word & (1 << nbit)) != 0
  }
  
  /// Sets `bit` to the given value and returns the result as a new `BigInt` value.
  /// `true` corresponds to 1, `false` corresponds to 0.
  public func set(bit n: Int, to value: Bool) -> BigInt {
    var words = self.uwords
    let nword = n / UInt32.bitWidth
    let nbit = n % UInt32.bitWidth
    var i = words.count
    while i <= nword {
      words.append(0)
      i += 1
    }
    guard self.negative else {
      if value {
        words[nword] |= 1 << nbit
      } else {
        words[nword] &= ~(1 << nbit)
      }
      return BigInt(words: words, negative: false)
    }
    if BigInt.isMostSignificantBitSet(words) {
      words.append(0)
    }
    var carry = true
    for i in words.indices {
      if carry {
        (words[i], carry) = (~words[i]).addingReportingOverflow(1)
      } else {
        words[i] = ~words[i]
      }
    }
    if value {
      words[nword] |= 1 << nbit
    } else {
      words[nword] &= ~(1 << nbit)
    }
    return BigInt.fromTwoComplement(&words)
  }
  
  /// Returns a random non-negative `BigInt` with up to `bitWidth` bits using the random number
  /// generator `generator`.
  public static func random<R: RandomNumberGenerator>(withMaxBits bitWidth: Int,
                                                      using generator: inout R) -> BigInt {
    return BigInt(randomWithMaxBits: bitWidth, using: &generator)
  }
  
  /// Returns a random non-negative `BigInt` with up to `bitWidth` bits using the system
  /// random number generator.
  public static func random(withMaxBits bitWidth: Int) -> BigInt {
    var generator = SystemRandomNumberGenerator()
    return BigInt(randomWithMaxBits: bitWidth, using: &generator)
  }
  
  /// Returns a random non-negative `BigInt` below the given upper bound `bound` using the
  /// random number generator `generator`.
  public static func random<R: RandomNumberGenerator>(below bound: BigInt,
                                                      using generator: inout R) -> BigInt {
    precondition(!bound.isNegative && !bound.isZero, "upper bound must be positive")
    let bitWidth = bound.lastBitSet
    var res = BigInt(randomWithMaxBits: bitWidth, using: &generator)
    while res >= bound {
      res = BigInt(randomWithMaxBits: bitWidth, using: &generator)
    }
    return res
  }
  
  /// Returns a random non-negative `BigInt` below the given upper bound `bound` using
  /// the system random number generator.
  public static func random(below bound: BigInt) -> BigInt {
    var generator = SystemRandomNumberGenerator()
    return BigInt.random(below: bound, using: &generator)
  }
}


/// This extension implements all the boilerplate to make `BigInt` compatible
/// to the applicable Swift 6 numeric protocols. `BigInt` is convertible from integer literals,
/// convertible from Strings, it's a signed number, equatable, comparable, and implements
/// all signed integer arithmetic functions.
extension BigInt: IntegerNumber,
                  SignedInteger,
                  ExpressibleByStringLiteral {
  
  /// This is a signed type
  public static let isSigned: Bool = true
  
  /// Returns the number of bits used to represent this `BigInt` assuming a binary representation
  /// using the two-complement for negative numbers.
  public var bitWidth: Int {
    return self.words.count * UInt.bitWidth
  }
  
  /// Returns the number of trailing zero bits assuming a representation in two-complement form.
  public var trailingZeroBitCount: Int {
    let words = self.words
    var res = 0
    var i = 0
    while i < words.count && words[i] == 0 {
      i += 1
      res += UInt.bitWidth
    }
    return i < words.count ? res + words[i].trailingZeroBitCount : res
  }
  
  /// Returns the number of leading zero bits assuming a representation in two-complement form.
  public var leadingZeroBitCount: Int {
    let words = self.words
    var res = 0
    var i = words.count - 1
    while i >= 0 && words[i] == 0 {
      i -= 1
      res += UInt.bitWidth
    }
    return i >= 0 ? res + words[i].leadingZeroBitCount : res
  }
  
  /// Returns the words in the binary representation of the magnitude of this number in the
  /// format expected by Swift 4, i.e. using the two-complement of the representation for
  /// negative numbers.
  public var words: [UInt] {
    var res = [UInt]()
    res.reserveCapacity((self.uwords.count + 1) / 2)
    var i = 0
    while i < self.uwords.count {
      let current = UInt(self.uwords[i])
      i += 1
      let next = i == self.uwords.count ? 0 : (UInt(self.uwords[i]) << UInt32.bitWidth)
      i += 1
      res.append(current | next)
    }
    res.append(0)
    if self.negative {
      var addOne = true
      for i in res.indices {
        if addOne {
          (res[i], addOne) = (~res[i]).addingReportingOverflow(1)
        } else {
          res[i] = ~res[i]
        }
      }
    }
    return res
  }
  
  /// Returns zero as a `BigInt`.
  public static let zero: BigInt = BigInt(0)
  
  /// Returns one as a `BigInt`.
  public static let one: BigInt = BigInt(1)
  
  /// Returns two as a `BigInt`.
  public static let two: BigInt = BigInt(2)
  
  /// Returns true if this is an odd `BigInt` number.
  public var isOdd: Bool {
    return (self.uwords[0] & 1) == 1
  }
  
  /// Returns the magnitude of this `BigInt`.
  public var magnitude: BigInt {
    return self.abs
  }
  
  /// Generic constructor for all binary integers.
  public init<T: BinaryInteger>(_ source: T) {
    if T.isSigned {
      if let value = Int64(exactly: source) {
        self.init(value)
      } else if source < 0 {
        self.init(words: [UInt]((0 - source).words), negative: true)
      } else {
        self.init(words: [UInt](source.words), negative: false)
      }
    } else {
      if let value = UInt64(exactly: source) {
        self.init(value)
      } else {
        self.init(words: [UInt](source.words), negative: false)
      }
    }
  }
  
  /// Generic constructor for all binary integers.
  public init?<T: BinaryInteger>(exactly: T) {
    self.init(exactly)
  }
  
  /// Generic constructor for all binary integers.
  public init<T: BinaryInteger>(clamping: T) {
    self.init(clamping)
  }
  
  /// Generic constructor for all binary integers.
  public init<T: BinaryInteger>(truncatingIfNeeded: T) {
    self.init(truncatingIfNeeded)
  }
  
  /// Generic constructor for all binary floating point numbers. Fractional parts are
  /// truncated. This crashes for floating point numbers representing infinity or NaN.
  public init<T: BinaryFloatingPoint>(_ source: T) {
    precondition(source.isFinite, "BigInt cannot represent infinity or NaN")
    self.init(exactly: source.rounded(.towardZero))!
  }
  
  /// Generic constructor for all binary floating point numbers.
  public init?<T: BinaryFloatingPoint>(exactly source: T) {
    guard !source.isNaN && source.isFinite else {
      return nil
    }
    if source.isZero {
      self = BigInt.zero
    } else {
      var neg = false
      var value = source
      if source.sign == .minus {
        neg = true
        value = -source
      }
      guard value == value.rounded(.towardZero) else {
        return nil
      }
      let significand = value.significandBitPattern
      let res = (BigInt.one << value.exponent) +
                BigInt(significand) >> (T.significandBitCount - Int(value.exponent))
      self = neg ? -res : res
    }
  }
  
  public init(_ value: UInt) {
    self.init(UInt64(value))
  }
  
  public init(_ value: UInt8) {
    self.init(Int64(value))
  }
  
  public init(_ value: UInt16) {
    self.init(Int64(value))
  }
  
  public init(_ value: UInt32) {
    self.init(Int64(value))
  }
  
  public init(_ value: Int) {
    self.init(Int64(value))
  }
  
  public init(_ value: Int8) {
    self.init(Int64(value))
  }
  
  public init(_ value: Int16) {
    self.init(Int64(value))
  }
  
  public init(_ value: Int32) {
    self.init(Int64(value))
  }
  
  public init(stringLiteral value: String) {
    if let bigInt = BigInt(from: value) {
      self = bigInt
    } else {
      self.init(0)
    }
  }
  
  public init(extendedGraphemeClusterLiteral value: String) {
    self.init(stringLiteral: value)
  }
  
  public init(unicodeScalarLiteral value: String) {
    self.init(stringLiteral: String(value))
  }
  
  public func addingReportingOverflow(_ rhs: BigInt) -> (partialValue: BigInt, overflow: Bool) {
    return (self.plus(rhs), overflow: false)
  }
  
  public func subtractingReportingOverflow(_ rhs: BigInt) -> (partialValue: BigInt,
                                                              overflow: Bool) {
    return (self.minus(rhs), overflow: false)
  }
  
  public func multipliedReportingOverflow(by rhs: BigInt) -> (partialValue: BigInt,
                                                              overflow: Bool) {
    return (self.times(rhs), overflow: false)
  }
  
  public func dividedReportingOverflow(by rhs: BigInt) -> (partialValue: BigInt, overflow: Bool) {
    return (self.divided(by: rhs).quotient, overflow: false)
  }
  
  public func remainderReportingOverflow(dividingBy rhs: BigInt) -> (partialValue: BigInt,
                                                                     overflow: Bool) {
    return (self.divided(by: rhs).remainder, overflow: false)
  }
  
  /// The empty bitset.
  public static var allZeros: BigInt {
    return BigInt(0)
  }
  
  /// Adds `n` and returns the result.
  public func advanced(by n: BigInt) -> BigInt {
    return self.plus(n)
  }
  
  /// Computes the distance to `other` and returns the result.
  public func distance(to other: BigInt) -> BigInt {
    return other.minus(self)
  }
}

#if canImport(Swift.StaticBigInt)
extension BigInt: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: StaticBigInt) {
    var uwords = ContiguousArray<UInt32>()
    let numWords = (value.bitWidth/UInt.bitWidth) + 1
    for index in 0..<numWords {
      let myword: UInt64 = UInt64(value[index])
      uwords.append(BigInt.loword(myword))
      uwords.append(BigInt.hiword(myword))
    }
    if value.signum() < 0 {
      var subOne = true
      for index in 0..<uwords.count {
        if subOne {
          (uwords[index], subOne) = uwords[index].subtractingReportingOverflow(1)
        }
        uwords[index] = ~uwords[index]
      }
    }
    self.init(words: uwords, negative: value.signum() < 0)
  }
}
#else
extension BigInt: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: Int64) {
    self.init(Int64(value))
  }
}
#endif

/// Returns the sum of `lhs` and `rhs`
public func +(lhs: BigInt, rhs: BigInt) -> BigInt {
  return lhs.plus(rhs)
}

/// Returns the difference between `lhs` and `rhs`
public func -(lhs: BigInt, rhs: BigInt) -> BigInt {
  return lhs.minus(rhs)
}

/// Returns the result of multiplying `lhs` with `rhs`
public func *(lhs: BigInt, rhs: BigInt) -> BigInt {
  return lhs.times(rhs)
}

/// Returns the quotient of `lhs` and `rhs`
public func /(lhs: BigInt, rhs: BigInt) -> BigInt {
  return lhs.divided(by: rhs).quotient
}

/// Returns the remainder of `lhs` when divided by `rhs`
public func %(lhs: BigInt, rhs: BigInt) -> BigInt {
  return lhs.divided(by: rhs).remainder
}

/// Adds `rhs` to `lhs` and stores the result in `lhs`.
public func +=(lhs: inout BigInt, rhs: BigInt) {
  lhs = lhs.plus(rhs)
}

/// Subtracts `rhs` from `lhs` and stores the result in `lhs`.
public func -=(lhs: inout BigInt, rhs: BigInt) {
  lhs = lhs.minus(rhs)
}

/// Multiplies `rhs` and `lhs` and stores the result in `lhs`.
public func *=(lhs: inout BigInt, rhs: BigInt) {
  lhs = lhs.times(rhs)
}

/// Divides `lhs` by `rhs` and stores the result in `lhs`.
public func /=(lhs: inout BigInt, rhs: BigInt) {
  lhs = lhs.divided(by: rhs).quotient
}

/// Computes the remainder of `lhs` when divided by `rhs` and stores the result in `lhs`.
public func %=(lhs: inout BigInt, rhs: BigInt) {
  lhs = lhs % rhs
}

/// Returns true if `lhs` is less than `rhs`, false otherwise.
public func <(lhs: BigInt, rhs: BigInt) -> Bool {
  return lhs.compare(to: rhs) < 0
}

/// Returns true if `lhs` is less than or equals `rhs`, false otherwise.
public func <=(lhs: BigInt, rhs: BigInt) -> Bool {
  return lhs.compare(to: rhs) <= 0
}

/// Returns true if `lhs` is greater or equals `rhs`, false otherwise.
public func >=(lhs: BigInt, rhs: BigInt) -> Bool {
  return lhs.compare(to: rhs) >= 0
}

/// Returns true if `lhs` is greater than equals `rhs`, false otherwise.
public func >(lhs: BigInt, rhs: BigInt) -> Bool {
  return lhs.compare(to: rhs) > 0
}

/// Returns true if `lhs` is equals `rhs`, false otherwise.
public func ==(lhs: BigInt, rhs: BigInt) -> Bool {
  return lhs.compare(to: rhs) == 0
}

/// Returns true if `lhs` is not equals `rhs`, false otherwise.
public func !=(lhs: BigInt, rhs: BigInt) -> Bool {
  return lhs.compare(to: rhs) != 0
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

/// Shifts the bits of `lhs` by `rhs` to the left and returns the result.
public func << <T: BinaryInteger>(lhs: BigInt, rhs: T) -> BigInt {
  return lhs.shift(Int(rhs))
}

/// Shifts the bits of `lhs` by `rhs` to the right and returns the result.
public func >> <T: BinaryInteger>(lhs: BigInt, rhs: T) -> BigInt {
  return lhs.shift(-Int(rhs))
}

/// Intersects the bits set in `lhs` and `rhs` and stores the result in `lhs`.
public func &=(lhs: inout BigInt, rhs: BigInt) {
  lhs = lhs & rhs
}

/// Unifies the bits set in `lhs` and `rhs` and stores the result in `lhs`.
public func |=(lhs: inout BigInt, rhs: BigInt) {
  lhs = lhs | rhs
}

/// Computes the bits that are set in exactly one of `lhs` and `rhs` and stores the
/// result in `lhs`.
public func ^=(lhs: inout BigInt, rhs: BigInt) {
  lhs = lhs ^ rhs
}

/// Shifts the bits of `lhs` by `rhs` to the left and stores the result in `lhs`.
public func <<=<T: BinaryInteger>(lhs: inout BigInt, rhs: T) {
  lhs = lhs.shift(Int(rhs))
}

/// Shifts the bits of `lhs` by `rhs` to the right and stores the result in `rhs`.
public func >>=<T: BinaryInteger>(lhs: inout BigInt, rhs: T) {
  lhs = lhs.shift(-Int(rhs))
}

/// Negates `self`.
public prefix func -(num: BigInt) -> BigInt {
  return num.negate
}

/// Returns the bitwise negated BigInt assuming a representation in two-complement form.
public prefix func ~(x: BigInt) -> BigInt {
  return x.not
}

/// Returns the maximum of `fst` and `snd`.
public func max(_ fst: BigInt, _ snd: BigInt) -> BigInt {
  return fst.compare(to: snd) >= 0 ? fst : snd
}

/// Returns the minimum of `fst` and `snd`.
public func min(_ fst: BigInt, _ snd: BigInt) -> BigInt {
  return fst.compare(to: snd) <= 0 ? fst : snd
}
