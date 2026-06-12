# Swift NumberKit

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fobjecthub%2Fswift-numberkit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/objecthub/swift-numberkit) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fobjecthub%2Fswift-numberkit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/objecthub/swift-numberkit) [![IDE: Xcode 26](https://img.shields.io/badge/IDE-Xcode%2026-blue.svg?style=flat)](https://developer.apple.com/xcode/) [![Package managers: SwiftPM, Carthage](https://img.shields.io/badge/Package%20managers-SwiftPM,%20Carthage-green.svg?style=flat)](https://github.com/Carthage/Carthage) [![License: Apache](http://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat)](https://raw.githubusercontent.com/objecthub/swift-numberkit/master/LICENSE)

## Overview

This is a lightweight framework implementing advanced numeric data types for the Swift programming
language on macOS, iOS, and Linux. Currently, the framework provides four new numeric types,
each represented as a struct or enumeration:

  1. `BigInt`: arbitrary-size signed integers
  2. `Integer`: arbitrary-size signed integers whose implementation depends on the size
      of the represented value.
  3. `Rational`: signed rational numbers
  4. `Complex`: complex floating-point numbers

**Note**: In the early days of Swift, with every major release, Apple introduced breaking changes in the foundational APIs of the numeric
types in Swift, consistently in backward incompatible ways. In order to be more isolated from
such changes, with Swift 3, I decided to introduce a distinct integer type used in NumberKit based on a
new protocol `IntegerNumber`. All standard numeric integer types implement this protocol. This is now consistent
with the usage of protocol `FloatingPointNumber` for floating point numbers, where there was, so far, never a
real, generic enough foundation (and still isn't).

## BigInt

`BigInt` values are immutable, signed, arbitrary-size integers that can be used as a
drop-in replacement for the existing binary integer types of Swift 5.
[Struct `BigInt`](https://github.com/objecthub/swift-numberkit/blob/master/Sources/NumberKit/BigInt.swift) defines all
the standard arithmetic integer operations and implements the corresponding numeric
protocols of Swift.

## Integer

`Integer` values are immutable, signed, arbitrary-size integers that can be used as a
drop-in replacement for the existing binary integer types of Swift 5. As opposed to `BigInt`,
the representation of values is chosen to optimize for memory size and performance of
arithmetic operations. [Enum `Integer`](https://github.com/objecthub/swift-numberkit/blob/master/Sources/NumberKit/Integer.swift)
defines all the standard arithmetic integer operations and implements the corresponding
numeric protocols of Swift.

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

- [Xcode 26](https://developer.apple.com/xcode/)
- [Swift 5](https://developer.apple.com/swift/)
- [Swift Package Manager](https://swift.org/package-manager/)
- macOS, iOS, tvOS, watchOS, and Linux

## Copyright

Author: Matthias Zenger (<matthias@objecthub.net>)  
Copyright © 2016-2026 Matthias Zenger. All rights reserved.
