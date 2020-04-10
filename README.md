# Swift NumberKit

[![Platforms: macOS, iOS, Linux](https://img.shields.io/badge/Platforms-macOS,%20iOS,%20Linux-blue.svg?style=flat)](https://developer.apple.com/osx/) [![Language: Swift](https://img.shields.io/badge/Language-Swift%205.2-green.svg?style=flat)](https://developer.apple.com/swift/) [![IDE: Xcode 11.4](https://img.shields.io/badge/IDE-Xcode%2011.4-orange.svg?style=flat)](https://developer.apple.com/xcode/) [![Package managers: SwiftPM, Carthage](https://img.shields.io/badge/Package%20managers-SwiftPM,%20Carthage-8E64B0.svg?style=flat)](https://github.com/Carthage/Carthage) [![License: Apache](http://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat)](https://raw.githubusercontent.com/objecthub/swift-numberkit/master/LICENSE)

## Overview

This is a framework implementing advanced numeric data types for the Swift programming
language on macOS and iOS. Currently, the framework provides three new numeric types,
each represented as a struct:

  1. `BigInt`: arbitrary-precision signed integers
  2. `Rational`: signed rational numbers
  3. `Complex`: complex floating-point numbers

**Note**: So far, with every major version of Swift, Apple decided to change the foundational APIs of the numeric
types in Swift significantly and consistently in a backward incompatible way. In order to be more isolated from
such changes in future, with Swift 3, I decided to introduce a distinct integer type used in NumberKit based on a
new protocol `IntegerNumber`. All standard numeric integer types implement this protocol. This is now consistent
with the usage of protocol `FloatingPointNumber` for floating point numbers, where there was, so far, never a
real, generic enough foundation (and still isn't).

## BigInt

`BigInt` objects are immutable, signed, arbitrary-precision integers that can be used as a
drop-in replacement for the existing binary integer types of Swift 5.
[Struct `BigInt`](https://github.com/objecthub/swift-numberkit/blob/master/Sources/NumberKit/BigInt.swift) defines all
the standard arithmetic integer operations and implements the corresponding protocols defined
in the standard library.


## Rational

[Struct `Rational<T>`](https://github.com/objecthub/swift-numberkit/blob/master/Sources/NumberKit/Rational.swift)
defines immutable, rational numbers based on an existing signed integer
type `T`, like `Int32`, `Int64`, or `BigInt`. A rational number is a signed number that can
be expressed as the quotient of two integers _a_ and _b_: _a / b_.


## Complex

[Struct `Complex<T>`](https://github.com/objecthub/swift-numberkit/blob/master/Sources/NumberKit/Complex.swift)
defines complex numbers based on an existing floating point type `T`, like `Float` or `Double`. A complex number
consists of two components, a real part _re_ and an imaginary part _im_ and is typically written as: _re + im * i_
where _i_ is the _imaginary unit_.

## Requirements

The following technologies are needed to build the components of the _Swift NumberKit_ framework:

- [Xcode 11.4](https://developer.apple.com/xcode/)
- [Swift 5.2](https://developer.apple.com/swift/)
- [Swift Package Manager](https://swift.org/package-manager/)
- macOS or Linux

## Copyright

Author: Matthias Zenger (<matthias@objecthub.net>)  
Copyright © 2016-2020 Matthias Zenger. All rights reserved.
