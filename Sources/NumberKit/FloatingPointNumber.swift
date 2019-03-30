//
//  FloatingPointNumber.swift
//  NumberKit
//
//  Created by Matthias Zenger on 23/09/2017.
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


/// Protocol `FloatingPointNumber` is used in combination with struct
/// `Complex<T>`. It defines the functionality needed for a floating point
/// implementation to build complex numbers on top. The `FloatingPoint`
/// protocol from the Swift 4 standard library is not sufficient currently.
///
/// - Note: For some reason, `_ExpressibleByBuiltinFloatLiteral` is needed here to
///         allow `Complex<T>` to implement protocol `ExpressibleByFloatLiteral`.
///         Replacing it with `ExpressibleByFloatLiteral` does not work either.
public protocol FloatingPointNumber: FloatingPoint, _ExpressibleByBuiltinFloatLiteral {
  var i: Complex<Self> { get }
  var abs: Self { get }
  var sqrt: Self { get }
  var sin: Self { get }
  var cos: Self { get }
  var exp: Self { get }
  var log: Self { get }
  func pow(_ ex: Self) -> Self
  func hypot(_ y: Self) -> Self
  func atan2(_ y: Self) -> Self
}

/// Make `Float` implement protocol `FloatingPointNumber`.
extension Float: FloatingPointNumber {
  public var i: Complex<Float> {
    return Complex<Float>(0.0, self)
  }
  public var abs: Float {
    return Swift.abs(self)
  }
  public var sqrt: Float {
    return Foundation.sqrt(self)
  }
  public var sin: Float {
    return Foundation.sin(self)
  }
  public var cos: Float {
    return Foundation.cos(self)
  }
  public var exp: Float {
    return Foundation.exp(self)
  }
  public var log: Float {
    return Foundation.log(self)
  }
  public func pow(_ ex: Float) -> Float {
    return Foundation.pow(self, ex)
  }
  public func hypot(_ y: Float) -> Float {
    return Foundation.hypot(self, y)
  }
  public func atan2(_ y: Float) -> Float {
    return Foundation.atan2(self, y)
  }
}

/// Make `Double` implement protocol `FloatingPointNumber`.
extension Double: FloatingPointNumber {
  public var i: Complex<Double> {
    return Complex(0.0, self)
  }
  public var abs: Double {
    return Swift.abs(self)
  }
  public var sqrt: Double {
    return Foundation.sqrt(self)
  }
  public var sin: Double {
    return Foundation.sin(self)
  }
  public var cos: Double {
    return Foundation.cos(self)
  }
  public var exp: Double {
    return Foundation.exp(self)
  }
  public var log: Double {
    return Foundation.log(self)
  }
  public func pow(_ ex: Double) -> Double {
    return Foundation.pow(self, ex)
  }
  public func hypot(_ y: Double) -> Double {
    return Foundation.hypot(self, y)
  }
  public func atan2(_ y: Double) -> Double {
    return Foundation.atan2(self, y)
  }
}
