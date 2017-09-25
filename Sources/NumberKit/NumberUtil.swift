//
//  NumberUtil.swift
//  NumberKit
//
//  Created by Matthias Zenger on 12/08/2015.
//  Copyright © 2015-2017 Matthias Zenger. All rights reserved.
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
