//
//  Complex.swift
//  NumberKit
//
//  Created by Matthias Zenger on 15/08/2015.
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

import Foundation


/// The `ComplexNumber` protocol defines an interface for complex numbers. A complex
/// number consists of two floating point components: a real part `re` and an imaginary
/// part `im`. It is typically expressed as: re + im * i where i is the imaginary unit.
/// i satisfies the equation i * i = -1.
///
/// - Note: The `ComplexNumber` protocol abstracts over the floating point type on which
///         the complex type implementation is based on.
/// - Todo: Implement the `Arithmetic` protocol. This requires that complex numbers are
///         mutable.
public protocol ComplexNumber: Equatable {
  
  /// The floating point number type on which this complex number is based.
  associatedtype Float: FloatingPoint
  
  /// Creates a complex number without imaginary part from the given real part.
  init(_ re: Float)
  
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
  
  /// Returns the argument/phase of this complex number.
  var arg: Float { get }
  
  /// Returns the negated complex number.
  var negate: Self { get }
  
  /// Multiplies `self` by i.
  var i: Self { get }
  
  /// Returns the conjugate of this complex number.
  var conjugate: Self { get }
  
  /// Returns the reciprocal of this complex number.
  var reciprocal: Self { get }
  
  /// Returns the norm of this complex number.
  var norm: Float { get }
  
  /// Returns the square root of this complex number
  var sqrt: Self { get }
  
  /// Returns the natural exponential of this complex number.
  var exp: Self { get }
  
  /// Returns the natural logarithm of this complex number.
  var log: Self { get }
  
  /// Returns the sum of `self` and `rhs` as a complex number.
  func plus(_ rhs: Self) -> Self
  
  /// Returns the difference between `self` and `rhs` as a complex number.
  func minus(_ rhs: Self) -> Self
  
  /// Returns the result of multiplying `self` with `rhs` as a complex number.
  func times(_ rhs: Self) -> Self
  
  /// Returns the result of multiplying `self` with scalar `rhs` as a complex number.
  func times(_ rhs: Float) -> Self
  
  /// Returns the result of dividing `self` by `rhs` as a complex number.
  func divided(by rhs: Self) -> Self
  
  /// Returns the result of dividing `self` by scalar `rhs` as a complex number.
  func divided(by rhs: Float) -> Self
  
  /// Returns this complex number taken to the power of `ex`.
  func toPower(of ex: Self) -> Self
}


/// Struct `Complex<T>` implements the `ComplexNumber` interface on top of the
/// floating point type `T`; i.e. both the rational and the imaginary part of the
/// complex number are represented as values of type `T`.
///
/// - Note: `T` needs to implement the `FloatingPointNumber` protocol. The `FloatingPoint`
///         protocol that is defined in the Swift standard library is not sufficient to
///         implement a complex number as it does not define interfaces for trigonometric
///         functions.
public struct Complex<T: FloatingPointNumber>: ComplexNumber,
                                       Hashable,
                                       ExpressibleByIntegerLiteral,
                                       ExpressibleByFloatLiteral,
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
  
  /// Creates a complex number with the given real and integer imaginary parts.
  public init(_ re: T, _ im: Int64) {
    self.init(re, T(im))
  }

  /// Creates a complex number with the given real and imaginary parts.
  public init(_ re: T, _ im: T) {
    self.re = re
    self.im = im
  }
  
  /// Creates a complex number from polar coordinates
  public init(abs: T, arg: T) {
    self.re = abs * arg.cos
    self.im = abs * arg.sin
  }
  
  /// Creates a real number initialized to integer `value`.
  public init(integerLiteral value: Int64) {
    self.init(T(value))
  }
  
  /// Creates a real number initialized to floating point number `value`.
  public init(floatLiteral value: T) {
    self.init(value)
  }
  
  /// Returns a textual representation of this complex number
  public var description: String {
    if im.isZero {
      return String(describing: re)
    } else if re.isZero {
      return String(describing: im) + "i"
    } else {
      return (im.sign == .minus) ? "\(re)\(im)i" : "\(re)+\(im)i"
    }
  }
  
  /// For hashing values.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(re)
    hasher.combine(im)
  }
  
  /// Returns the real part of the complex number if the number has no complex
  /// part, nil otherwise
  public var realValue: T? {
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
  
  /// Returns the argument/phase of this complex number.
  public var arg: T {
    return im.atan2(re)
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
  
  /// Returns the norm of this complex number.
  public var norm: T {
    return re.hypot(im)
  }
  
  /// exp(x) function for complex numbers x.
  public var exp: Complex<T> {
    let abs = re.exp
    return Complex(abs * im.cos, abs * im.sin)
  }
  
  /// log(x) function for complex numbers x.
  public var log: Complex<T> {
    return Complex(abs.log, arg)
  }
  
  /// Returns the square root of this complex number
  public var sqrt: Complex<T> {
    let r = ((re + abs) / T(2)).sqrt
    let i = ((-re + abs) / T(2)).sqrt
    return Complex(r, (im.sign == .minus) ? -i : i)
  }
  
  /// Returns this complex number taken to the power of `ex`.
  public func toPower(of ex: Complex<T>) -> Complex<T> {
    return isZero ? (ex.isZero ? 1 : 0) : log.times(ex).exp
  }
  
  /// Returns the sum of `self` and `rhs` as a complex number.
  public func plus(_ rhs: Complex<T>) -> Complex<T> {
    return Complex(self.re + rhs.re, self.im + rhs.im);
  }
  
  /// Returns the difference between `self` and `rhs` as a complex number.
  public func minus(_ rhs: Complex<T>) -> Complex<T> {
    return Complex(self.re - rhs.re, self.im - rhs.im);
  }
  
  /// Returns the result of multiplying `self` with `rhs` as a complex number.
  public func times(_ rhs: Complex<T>) -> Complex<T> {
    return Complex(self.re * rhs.re - self.im * rhs.im, self.re * rhs.im + self.im * rhs.re);
  }
  
  /// Returns the result of multiplying `self` with scalar `rhs` as a complex number.
  public func times(_ rhs: T) -> Complex<T> {
    return Complex(self.re * rhs, self.im * rhs);
  }
  
  /// Returns the result of dividing `self` by `rhs` as a complex number.
  public func divided(by rhs: Complex<T>) -> Complex<T> {
    return times(rhs.reciprocal)
  }
  
  /// Returns the result of dividing `self` by scalar `rhs` as a complex number.
  public func divided(by rhs: T) -> Complex<T> {
    return Complex(self.re / rhs, self.im / rhs);
  }
}

// Implement equality

public func == <C: ComplexNumber>(lhs: C, rhs: C) -> Bool {
  return lhs.re == rhs.re && lhs.im == rhs.im
}

public func == <C: ComplexNumber>(lhs: C.Float, rhs: C) -> Bool {
  return rhs.re == lhs && rhs.im.isZero
}

public func == <C: ComplexNumber>(lhs: C, rhs: C.Float) -> Bool {
  return lhs.re == rhs && lhs.im.isZero
}

public func != <C: ComplexNumber>(lhs: C, rhs: C) -> Bool {
  return lhs.re != rhs.re || lhs.im != rhs.im
}

public func != <C: ComplexNumber>(lhs: C.Float, rhs: C) -> Bool {
  return rhs.re != lhs || !rhs.im.isZero
}

public func != <C: ComplexNumber>(lhs: C, rhs: C.Float) -> Bool {
  return lhs.re != rhs || !lhs.im.isZero
}


/// Negates complex number `z`.
public prefix func - <C: ComplexNumber>(z: C) -> C {
  return z.negate
}

/// Returns the sum of `lhs` and `rhs`.
public func + <C: ComplexNumber>(lhs: C, rhs: C) -> C {
  return lhs.plus(rhs)
}

/// Returns the sum of `lhs` and `rhs`.
public func + <C: ComplexNumber>(lhs: C, rhs: C.Float) -> C {
  return lhs.plus(C(rhs))
}

/// Returns the sum of `lhs` and `rhs`.
public func + <C: ComplexNumber>(lhs: C.Float, rhs: C) -> C {
  return C(lhs).plus(rhs)
}

/// Returns the difference between `lhs` and `rhs`.
public func - <C: ComplexNumber>(lhs: C, rhs: C) -> C {
  return lhs.minus(rhs)
}

/// Returns the difference between `lhs` and `rhs`.
public func - <C: ComplexNumber>(lhs: C, rhs: C.Float) -> C {
  return lhs.minus(C(rhs))
}

/// Returns the difference between `lhs` and `rhs`.
public func - <C: ComplexNumber>(lhs: C.Float, rhs: C) -> C {
  return C(lhs).minus(rhs)
}

/// Multiplies `lhs` with `rhs` and returns the result.
public func * <C: ComplexNumber>(lhs: C, rhs: C) -> C {
  return lhs.times(rhs)
}

/// Multiplies complex number `lhs` with scalar `rhs` and returns the result.
public func * <C: ComplexNumber>(lhs: C, rhs: C.Float) -> C {
  return lhs.times(rhs)
}

/// Multiplies scalar `lhs` with complex number `rhs` and returns the result.
public func * <C: ComplexNumber>(lhs: C.Float, rhs: C) -> C {
  return rhs.times(lhs)
}

/// Divides `lhs` by `rhs` and returns the result.
public func / <C: ComplexNumber>(lhs: C, rhs: C) -> C {
  return lhs.divided(by: rhs)
}

/// Divides complex number `lhs` by scalar `rhs` and returns the result.
public func / <C: ComplexNumber>(lhs: C, rhs: C.Float) -> C {
  return lhs.divided(by: rhs)
}

/// Divides complex number `lhs` by scalar `rhs` and returns the result.
public func / <C: ComplexNumber>(lhs: C.Float, rhs: C) -> C {
  return C(lhs).divided(by: rhs)
}

/// Assigns `lhs` the sum of `lhs` and `rhs`.
public func += <C: ComplexNumber>(lhs: inout C, rhs: C) {
  lhs = lhs.plus(rhs)
}

/// Assigns `lhs` the sum of `lhs` and `rhs`.
public func += <C: ComplexNumber>(lhs: inout C, rhs: C.Float) {
  lhs = lhs.plus(C(rhs))
}

/// Assigns `lhs` the difference between `lhs` and `rhs`.
public func -= <C: ComplexNumber>(lhs: inout C, rhs: C) {
  lhs = lhs.minus(rhs)
}

/// Assigns `lhs` the difference between `lhs` and `rhs`.
public func -= <C: ComplexNumber>(lhs: inout C, rhs: C.Float) {
  lhs = lhs.minus(C(rhs))
}

/// Assigns `lhs` the result of multiplying `lhs` with `rhs`.
public func *= <C: ComplexNumber>(lhs: inout C, rhs: C) {
  lhs = lhs.times(rhs)
}

/// Assigns `lhs` the result of multiplying `lhs` with scalar `rhs`.
public func *= <C: ComplexNumber>(lhs: inout C, rhs: C.Float) {
  lhs = lhs.times(rhs)
}

/// Assigns `lhs` the result of dividing `lhs` by `rhs`.
public func /= <C: ComplexNumber>(lhs: inout C, rhs: C) {
  lhs = lhs.divided(by: rhs)
}

/// Assigns `lhs` the result of dividing `lhs` by scalar `rhs`.
public func /= <C: ComplexNumber>(lhs: inout C, rhs: C.Float) {
  lhs = lhs.divided(by: rhs)
}

/// Returns the absolute value of the given complex number `z`.
public func abs<C: ComplexNumber>(_ z: C) -> C.Float {
  return z.abs
}

/// Returns the argument/phase of the given complex number `z`.
public func arg<C: ComplexNumber>(_ z: C) -> C.Float {
  return z.arg
}

/// Returns the real part of the given complex number `z`.
public func real<C: ComplexNumber>(_ z: C) -> C.Float {
  return z.re
}

/// Returns the imaginary part of the given complex number `z`.
public func imag<C: ComplexNumber>(_ z: C) -> C.Float {
  return z.im
}

/// Returns the norm of the given complex number `z`.
public func norm<C: ComplexNumber>(_ z: C) -> C.Float {
  return z.norm
}

/// Returns the conjugate of the given complex number `z`.
public func conj<C: ComplexNumber>(_ z: C) -> C {
  return z.conjugate
}

/// Returns the exponential of the given complex number `z`.
public func exp<C: ComplexNumber>(_ z: C) -> C {
  return z.exp
}

/// Returns the logarithm of the given complex number `z`.
public func log<C: ComplexNumber>(_ z: C) -> C {
  return z.log
}

/// Returns `base` to the power of `ex`.
public func pow<C: ComplexNumber>(_ base: C, _ ex: C) -> C {
  return base.toPower(of: ex)
}

/// Returns `base` to the power of `ex`.
public func pow<C: ComplexNumber>(_ base: C.Float, _ ex: C) -> C {
  return C(base).toPower(of: ex)
}

/// Returns `base` to the power of `ex`.
public func pow<C: ComplexNumber>(_ base: C, _ ex: C.Float) -> C {
  return base.toPower(of: C(ex))
}

/// Returns the square root of the given complex number `z`.
public func sqrt<C: ComplexNumber>(_ z: C) -> C {
  return z.sqrt
}

/// Returns `sin(z)` for the given complex number `z`.
public func sin<C: ComplexNumber>(_ z: C) -> C {
  return exp(-z.i).minus(exp(z.i)).i.divided(by: C.Float(2))
}

/// Returns `cos(z)` for the given complex number `z`.
public func cos<C: ComplexNumber>(_ z: C) -> C {
  return exp(z.i).plus(exp(-z.i)).divided(by: C.Float(2))
}

/// Returns `tan(z)` for the given complex number `z`.
public func tan<C: ComplexNumber>(_ z: C) -> C {
  let x = exp(z.i)
  let y = exp(-z.i)
  return x.minus(y).divided(by: x.plus(y).i)
}

/// Returns `asin(z)` for the given complex number `z`.
public func asin<C: ComplexNumber>(_ z: C) -> C {
  return -log(z.i.plus(sqrt(C(C.Float(1)).minus(z.times(z))))).i
}

/// Returns `acos(z)` for the given complex number `z`.
public func acos<C: ComplexNumber>(_ z: C) -> C {
  return log(z.minus(sqrt(C(C.Float(1)).minus(z.times(z))).i)).i
}

/// Returns `atan(z)` for the given complex number `z`.
public func atan<C: ComplexNumber>(_ z: C) -> C {
  let x = log(C(C.Float(1)).minus(z.i))
  let y = log(C(C.Float(1)).plus(z.i))
  return x.minus(y).i.divided(by: C.Float(2))
}

/// Returns `cos(r)` for the given floating point number `r`.
public func atan<T: FloatingPointNumber>(_ r: T) -> T {
  return atan(Complex(r)).re
}

/// Returns `atan2(z1, z2)` for the given complex numbers `z1` and `z2`.
public func atan2<C: ComplexNumber>(_ z1: C, _ z2: C) -> C {
  return atan(z1.divided(by: z2))
}

/// Returns `sinh(z)` for the given complex number `z`.
public func sinh<C: ComplexNumber>(_ z: C) -> C {
  return exp(z).minus(exp(-z)).divided(by: C.Float(2))
}

/// Returns `cosh(z)` for the given complex number `z`.
public func cosh<C: ComplexNumber>(_ z: C) -> C {
  return exp(z).plus(exp(-z)).divided(by: C.Float(2))
}

/// Returns `tanh(z)` for the given complex number `z`.
public func tanh<C: ComplexNumber>(_ z: C) -> C {
  let x = exp(z)
  let y = exp(-z)
  return x.minus(y).divided(by: x.plus(y))
}

/// Returns `asinh(z)` for the given complex number `z`.
public func asinh<C: ComplexNumber>(_ z: C) -> C {
  return log(z.plus(sqrt(z.times(z).plus(C(C.Float(1))))))
}

/// Returns `acosh(z)` for the given complex number `z`.
public func acosh<C: ComplexNumber>(_ z: C) -> C {
  return log(z.plus(sqrt(z.times(z).minus(C(C.Float(1))))))
}

/// Returns `atanh(z)` for the given complex number `z`.
public func atanh<C: ComplexNumber>(_ z: C) -> C {
  let x = C(C.Float(1)).plus(z)
  let y = C(C.Float(1)).minus(z)
  return log(x.divided(by: y)).divided(by: C.Float(2))
}

