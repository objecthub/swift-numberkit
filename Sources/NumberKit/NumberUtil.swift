//
//  NumberUtil.swift
//  NumberKit
//
//  Created by Matthias Zenger on 12/08/2015.
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
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


/// Provide power operator for all integers
precedencegroup ExponentiativePrecedence {
  associativity: left
  higherThan: MultiplicationPrecedence
}

infix operator ** : ExponentiativePrecedence
infix operator **= : AssignmentPrecedence

/// Implements power function for all integer types.
public func ** <T: IntegerNumber>(_ lhs: T, _ rhs: T) -> T {
  return lhs.toPower(of: rhs)
}

/// Implements power-assignment function for all integer types.
public func **= <T: IntegerNumber>(_ lhs: inout T, _ rhs: T) {
  lhs = lhs.toPower(of: rhs)
}

/// Implements minimum function for all integer types.
public func min<T: IntegerNumber>(_ fst: T, _ snd: T) -> T {
  return fst < snd ? fst : snd
}

/// Implements maximum function for all integer types.
public func max<T: IntegerNumber>(_ fst: T, _ snd: T) -> T {
  return fst > snd ? fst : snd
}

private let bitCounts: [Int] =
  [0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3,
   4, 4, 5, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4,
   4, 5, 4, 5, 5, 6, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4,
   5, 3, 4, 4, 5, 4, 5, 5, 6, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5,
   4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2,
   3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5,
   5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4,
   5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 3, 4, 4, 5, 4, 5, 5, 6,
   4, 5, 5, 6, 5, 6, 6, 7, 4, 5, 5, 6, 5, 6, 6, 7, 5, 6, 6, 7, 6, 7, 7, 8]

// `bitCount` computes the number of bits set in the given `UInt32` value.
public func bitcount(_ num: UInt32) -> Int {
  var res = bitCounts[Int(num & 0xff)]
  res = res &+ bitCounts[Int((num >> 8) & 0xff)]
  res = res &+ bitCounts[Int((num >> 16) & 0xff)]
  return res &+ bitCounts[Int(num >> 24)]
}

// `bitCount` computes the number of bits set in the given `UInt64` value.
public func bitcount(_ num: UInt64) -> Int {
  return bitcount(UInt32((num >> 32) & 0xffffffff)) + bitcount(UInt32(num & 0xffffffff))
}

// `bitCount` computes the number of bits set in the given `Int32` value.
public func bitcount(_ num: Int32) -> Int {
  return bitcount(UInt32(bitPattern: num))
}

// `bitCount` computes the number of bits set in the given `Int32` value.
public func bitcount(_ num: Int64) -> Int {
  return bitcount(UInt64(bitPattern: num))
}

// `bitCount` computes the number of bits set in the given `UInt` value.
public func bitcount(_ num: UInt) -> Int {
  return bitcount(UInt64(num))
}

// `bitCount` computes the number of bits set in the given `Int` value.
public func bitcount(_ num: Int) -> Int {
  return bitcount(UInt(num))
}
