//
//  NumberUtil.swift
//  NumberKit
//
//  Created by Matthias Zenger on 12/08/2015.
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


// Provide power function for all integers

infix operator ** {
  associativity left
  precedence 155
}

infix operator **= {
  associativity right
  precedence 90
  assignment
}

func pow<T: IntegerType>(var base: T, var _ exp: T) -> T {
  precondition(exp >= 0, "pow(base, exp) with negative exp")
  var res: T = 1
  while exp != 0 {
    if (exp & 1) != 0 {
      res *= base
    }
    exp /= 2
    base *= base
  }
  return res
}

/// Implements power function for all integer types.
public func ** <T: IntegerType>(lhs: T, rhs: T) -> T {
  return pow(lhs, rhs)
}

/// Implements power-assignment function for all integer types.
public func **= <T: IntegerType>(inout lhs: T, rhs: T) {
  lhs = pow(lhs, rhs)
}

/// Implements minimum function for all integer types.
public func min<T: IntegerType>(fst: T, _ snd: T) -> T {
  return fst < snd ? fst : snd
}

/// Implements maximum function for all integer types.
public func max<T: IntegerType>(fst: T, _ snd: T) -> T {
  return fst > snd ? fst : snd
}
