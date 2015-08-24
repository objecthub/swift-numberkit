//
//  Complex.swift
//  NumberKit
//
//  Created by Matthias Zenger on 15/08/2015.
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

import Darwin


/// The `ComplexType` protocol defines an interface for complex numbers. A complex
/// number consists of two floating point components: a real part `re` and an imaginary
/// part `im`. It is typically expressed as: re + im * i where i is the imaginary unit.
/// i satisfies the equation i * i = -1.
///
/// - Note: The `ComplexType` protocol abstracts over the floating point type on which
///         the complex type implementation is based on.
protocol ComplexType: Equatable {
  
  /// The floating point number type on which this complex number is based.
  typealias Float: FloatingPointType
  
  /// The real part of the complex number.
  var re: Float { get }
  
  /// The imaginary part of the complex number.
  var im: Float { get }
  
  /// Returns the real part of the complex number if the number has no complex
  /// part, nil otherwise
  var realValue: Float? { get }
  
  /// Returns true if this complex number has no imaginary part.
  var isReal: Bool { get }
  
  /// Returns true if this complex number is zero.
  var isZero: Bool { get }
  
  /// Returns true if either real or imaginary parts are not a number.
  var isNaN: Bool { get }
  
  /// Returns true if either real or imaginary parts are infinite.
  var isInfinite: Bool { get }
  
  /// Returns the absolute value of this complex number.
  var abs: Float { get }
  
  /// Returns the negated complex number.
  var negate: Self { get }
  
  /// Multiplies `self` by i.
  var i: Self { get }
  
  /// Returns the conjugate of this complex number.
  var conjugate: Self { get }
  
  /// Returns the reciprocal of this complex number.
  var reciprocal: Self { get }
  
  /// Returns the square root of this complex number
  var sqrt: Self { get }
  
  /// Negates `num`.
  prefix func -(num: Self) -> Self
  
  /// Returns the sum of `lhs` and `rhs`.
  func +(lhs: Self, rhs: Self) -> Self
  
  /// Returns the difference between `lhs` and `rhs`.
  func -(lhs: Self, rhs: Self) -> Self
  
  /// Returns the result of multiplying `lhs` with `rhs`.
  func *(lhs: Self, rhs: Self) -> Self
  
  /// Returns the result of multiplying `lhs` with scalar `rhs`.
  func *(lhs: Self, rhs: Float) -> Self
  
  /// Returns the result of dividing `lhs` by `rhs`.
  func /(lhs: Self, rhs: Self) -> Self
  
  /// Assigns `lhs` the sum of `lhs` and `rhs`.
  func +=(inout lhs: Self, rhs: Self)
  
  /// Assigns `lhs` the difference between `lhs` and `rhs`.
  func -=(inout lhs: Self, rhs: Self)
  
  /// Assigns `lhs` the result of multiplying `lhs` with `rhs`.
  func *=(inout lhs: Self, rhs: Self)
  
  /// Assigns `lhs` the result of dividing `lhs` by `rhs`.
  func /=(inout lhs: Self, rhs: Self)
}


/// Protocol `RealNumberType` is supposed to be used in combination with struct
/// `Complex<T>`. It defines the functionality needed for a floating point
/// implementation to build complex numbers on top. The `FloatingPointType`
/// protocol from the Swift standard library is not sufficient currently.
///
/// - Note: For some reason, `_BuiltinFloatLiteralConvertible` is needed here to
///         allow `Complex<T>` to implement protocol `FloatLiteralConvertible`.
///         Replacing it with `FloatLiteralConvertible` does not work either.
public protocol RealNumberType: FloatingPointType,
                                Hashable,
                                SignedNumberType,
                                _BuiltinFloatLiteralConvertible {
  var i: Complex<Self> { get }
  var sqrt: Self { get }
  func +(lhs: Self, rhs: Self) -> Self
  func -(lhs: Self, rhs: Self) -> Self
  func *(lhs: Self, rhs: Self) -> Self
  func /(lhs: Self, rhs: Self) -> Self
  func hypot(rhs: Self) -> Self
}


/// Struct `Complex<T>` implements the `ComplexType` interface on top of the
/// floating point type `T`; i.e. both the rational and the imaginary part of the
/// complex number are represented as values of type `T`.
///
/// - Note: `T` needs to implement the `RealNumberType` protocol. The `FloatingPointType`
///         protocol that is defined in the Swift standard library is not sufficient to
///         implement a complex number as it does not, at all, define interfaces for
///         basic arithmetic operations.
public struct Complex<T: RealNumberType>: ComplexType,
                                          Hashable,
                                          IntegerLiteralConvertible,
                                          FloatLiteralConvertible,
                                          CustomStringConvertible {
  
  /// The real part of thix complex number.
  public let re: T
  
  /// The imaginary part of this complex number.
  public let im: T
  
  /// Creates a complex number with the given real part and no imaginary part.
  public init(_ re: T) {
    self.re = re
    self.im = T(0)
  }
  
  /// Creates a complex number with the given real and imaginary parts.
  public init(_ re: T, _ im: T) {
    self.re = re
    self.im = im
  }
  
  /// Creates a real number initialized to integer `value`.
  public init(integerLiteral value: IntMax) {
    self.init(T(value))
  }
  
  /// Creates a real number initialized to floating point number `value`.
  public init(floatLiteral value: T) {
    self.init(value)
  }
  
  /// Returns the real part of the complex number if the number has no complex
  /// part, nil otherwise
  var realValue: T? {
    return im.isZero ? re : nil
  }
  
  /// Returns true if this complex number has no imaginary part.
  public var isReal: Bool {
    return im.isZero
  }
  
  /// Returns true if this complex number is zero.
  public var isZero: Bool {
    return re.isZero && im.isZero
  }
  
  /// Returns true if either real or imaginary parts are not a number.
  public var isNaN: Bool {
    return re.isNaN || im.isNaN
  }
  
  /// Returns true if either real or imaginary parts are infinite.
  public var isInfinite: Bool {
    return re.isInfinite || im.isInfinite
  }
  
  /// Returns the absolute value of this complex number.
  public var abs: T {
    return re.hypot(im)
  }
  
  /// Returns the negated complex number.
  public var negate: Complex<T> {
    return Complex(-re, -im)
  }
  
  /// Multiplies `self` by i.
  public var i: Complex<T> {
    return Complex(-im, re)
  }
  
  /// Returns the conjugate of this complex number.
  public var conjugate: Complex<T> {
    return Complex(re, -im)
  }
  
  /// Returns the reciprocal of this complex number.
  public var reciprocal: Complex<T> {
    let s = re * re + im * im
    return Complex(re / s, -im / s)
  }
  
  /// Returns the square root of this complex number
  public var sqrt: Complex<T> {
    let r = ((re + abs) / T(2)).sqrt
    let i = ((-re + abs) / T(2)).sqrt
    return Complex(r, im.isSignMinus ? -i : i)
  }
  
  /// Returns a textual representation of this complex number
  public var description: String {
    if im.isZero {
      return String(re)
    } else if re.isZero {
      return String(im) + "i"
    } else {
      return im.isSignMinus ? "\(re)\(im)i" : "\(re)+\(im)i"
    }
  }
  
  /// Returns a hash value for this complex number
  public var hashValue: Int {
    return im.hashValue &* 31 &+ re.hashValue
  }
  
  /// Returns the sum of `self` and `rhs` as a complex number.
  public func plus(rhs: Complex<T>) -> Complex<T> {
    return Complex(self.re + rhs.re, self.im + rhs.im);
  }
  
  /// Returns the difference between `self` and `rhs` as a complex number.
  public func minus(rhs: Complex<T>) -> Complex<T> {
    return Complex(self.re - rhs.re, self.im - rhs.im);
  }
  
  /// Returns the result of multiplying `self` with `rhs` as a complex number.
  public func times(rhs: Complex<T>) -> Complex<T> {
    return Complex(self.re * rhs.re - self.im * rhs.im, self.re * rhs.im + self.im * rhs.re);
  }
  
  /// Returns the result of multiplying `self` with scalar `rhs` as a complex number.
  public func times(rhs: T) -> Complex<T> {
    return Complex(self.re * rhs, self.im * rhs);
  }
  
  /// Returns the result of dividing `self` by `rhs` as a complex number.
  public func dividedBy(rhs: Complex<T>) -> Complex<T> {
    return times(rhs.reciprocal)
  }
  
  /// Returns the result of dividing `self` by scalar `rhs` as a complex number.
  public func dividedBy(rhs: T) -> Complex<T> {
    return Complex(self.re / rhs, self.im / rhs);
  }
}


public func == <T: RealNumberType>(lhs: Complex<T>, rhs: Complex<T>) -> Bool {
  return lhs.re == rhs.re && lhs.im == rhs.im
}

public func != <T: RealNumberType>(lhs: Complex<T>, rhs: Complex<T>) -> Bool {
  return lhs.re != rhs.re || lhs.im != rhs.im
}

// Uncommeting the following lines will crash the compiler

/*
public func == <T: RealNumberType>(lhs: T, rhs: Complex<T>) -> Bool {
  return rhs.re == lhs && rhs.im.isZero
}

public func == <T: RealNumberType>(lhs: Complex<T>, rhs: T) -> Bool {
  return lhs.re == rhs && lhs.im.isZero
}

public func != <T: RealNumberType>(lhs: T, rhs: Complex<T>) -> Bool {
  return rhs.re != lhs || !rhs.im.isZero
}

public func != <T: RealNumberType>(lhs: Complex<T>, rhs: T) -> Bool {
  return lhs.re != rhs || !lhs.im.isZero
}
*/

/// Negates `num`.
public prefix func - <T: RealNumberType>(num: Complex<T>) -> Complex<T> {
  return num.negate
}

/// Returns the sum of `lhs` and `rhs`.
public func + <T: RealNumberType>(lhs: Complex<T>, rhs: Complex<T>) -> Complex<T> {
  return lhs.plus(rhs)
}

/// Returns the sum of `lhs` and `rhs`.
public func + <T: RealNumberType>(lhs: Complex<T>, rhs: T) -> Complex<T> {
  return lhs.plus(Complex(rhs))
}

/// Returns the sum of `lhs` and `rhs`.
public func + <T: RealNumberType>(lhs: T, rhs: Complex<T>) -> Complex<T> {
  return Complex(lhs).plus(rhs)
}

/// Returns the difference between `lhs` and `rhs`.
public func - <T: RealNumberType>(lhs: Complex<T>, rhs: Complex<T>) -> Complex<T> {
  return lhs.minus(rhs)
}

/// Returns the difference between `lhs` and `rhs`.
public func - <T: RealNumberType>(lhs: Complex<T>, rhs: T) -> Complex<T> {
  return lhs.minus(Complex(rhs))
}

/// Returns the difference between `lhs` and `rhs`.
public func - <T: RealNumberType>(lhs: T, rhs: Complex<T>) -> Complex<T> {
  return Complex(lhs).minus(rhs)
}

/// Multiplies `lhs` with `rhs` and returns the result.
public func * <T: RealNumberType>(lhs: Complex<T>, rhs: Complex<T>) -> Complex<T> {
  return lhs.times(rhs)
}

/// Multiplies complex number `lhs` with scalar `rhs` and returns the result.
public func * <T: RealNumberType>(lhs: Complex<T>, rhs: T) -> Complex<T> {
  return lhs.times(rhs)
}

/// Multiplies scalar `lhs` with complex number `rhs` and returns the result.
public func * <T: RealNumberType>(lhs: T, rhs: Complex<T>) -> Complex<T> {
  return rhs.times(lhs)
}

/// Divides `lhs` by `rhs` and returns the result.
public func / <T: RealNumberType>(lhs: Complex<T>, rhs: Complex<T>) -> Complex<T> {
  return lhs.dividedBy(rhs)
}

/// Divides complex number `lhs` by scalar `rhs` and returns the result.
public func / <T: RealNumberType>(lhs: Complex<T>, rhs: T) -> Complex<T> {
  return lhs.dividedBy(rhs)
}

/// Divides complex number `lhs` by scalar `rhs` and returns the result.
public func / <T: RealNumberType>(lhs: T, rhs: Complex<T>) -> Complex<T> {
  return Complex(lhs).dividedBy(rhs)
}

/// Assigns `lhs` the sum of `lhs` and `rhs`.
public func += <T: RealNumberType>(inout lhs: Complex<T>, rhs: Complex<T>) {
  lhs = lhs.plus(rhs)
}

/// Assigns `lhs` the sum of `lhs` and `rhs`.
public func += <T: RealNumberType>(inout lhs: Complex<T>, rhs: T) {
  lhs = lhs.plus(Complex(rhs))
}

/// Assigns `lhs` the difference between `lhs` and `rhs`.
public func -= <T: RealNumberType>(inout lhs: Complex<T>, rhs: Complex<T>) {
  lhs = lhs.minus(rhs)
}

/// Assigns `lhs` the difference between `lhs` and `rhs`.
public func -= <T: RealNumberType>(inout lhs: Complex<T>, rhs: T) {
  lhs = lhs.minus(Complex(rhs))
}

/// Assigns `lhs` the result of multiplying `lhs` with `rhs`.
public func *= <T: RealNumberType>(inout lhs: Complex<T>, rhs: Complex<T>) {
  lhs = lhs.times(rhs)
}

/// Assigns `lhs` the result of multiplying `lhs` with scalar `rhs`.
public func *= <T: RealNumberType>(inout lhs: Complex<T>, rhs: T) {
  lhs = lhs.times(rhs)
}

/// Assigns `lhs` the result of dividing `lhs` by `rhs`.
public func /= <T: RealNumberType>(inout lhs: Complex<T>, rhs: Complex<T>) {
  lhs = lhs.dividedBy(rhs)
}

/// Assigns `lhs` the result of dividing `lhs` by scalar `rhs`.
public func /= <T: RealNumberType>(inout lhs: Complex<T>, rhs: T) {
  lhs = lhs.dividedBy(rhs)
}


/// Make `Float` implement protocol `RealNumberType`
extension Float: RealNumberType {
  public var i: Complex<Float> {
    return Complex(0.0, self)
  }
  public var sqrt: Float {
    return Darwin.sqrt(self)
  }
  public func hypot(rhs: Float) -> Float {
    return Darwin.hypot(self, rhs)
  }
}


/// Make `Double` implement protocol `RealNumberType`
extension Double: RealNumberType {
  public var i: Complex<Double> {
    return Complex(0.0, self)
  }
  public var sqrt: Double {
    return Darwin.sqrt(self)
  }
  public func hypot(rhs: Double) -> Double {
    return Darwin.hypot(self, rhs)
  }
}
