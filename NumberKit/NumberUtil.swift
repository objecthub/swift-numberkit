//
//  NumberUtil.swift
//  NumberKit
//
//  Created by Matthias Zenger on 12/08/2015.
//  Copyright © 2015 ObjectHub. All rights reserved.
//


// Provider power function for all integers

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

public func ** <T: IntegerType>(lhs: T, rhs: T) -> T {
  return pow(lhs, rhs)
}

public func **= <T: IntegerType>(inout lhs: T, rhs: T) {
  lhs = pow(lhs, rhs)
}

// Min/max implementation for all integers

public func min<T: IntegerType>(fst: T, _ snd: T) -> T {
  return fst < snd ? fst : snd
}

public func max<T: IntegerType>(fst: T, _ snd: T) -> T {
  return fst > snd ? fst : snd
}
