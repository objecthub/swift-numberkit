# Swift NumberKit

<p>
<a href="https://developer.apple.com/osx/"><img src="https://img.shields.io/badge/Platform-macOS-blue.svg?style=flat" alt="Platform: macOS" /></a>
<a href="https://developer.apple.com/swift/"><img src="https://img.shields.io/badge/Language-Swift%205-green.svg?style=flat" alt="Language: Swift 5" /></a>
<a href="https://developer.apple.com/xcode/"><img src="https://img.shields.io/badge/IDE-Xcode%2010.2-orange.svg?style=flat" alt="IDE: Xcode 10.2" /></a>
<a href="https://raw.githubusercontent.com/objecthub/swift-lispkit/master/LICENSE"><img src="http://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat" alt="License: Apache" /></a>
</p>

## Overview

This is a framework implementing advanced numeric data types for the Swift 4 programming
language. The current version provides three new numeric types:

  1. `BigInt`: arbitrary-precision signed integers
  2. `Rational`: signed rational numbers
  3. `Complex`: complex floating-point numbers

**Requirements**:
   - Xcode 10.2
   - Swift 5
   - macOS with Xcode or Swift Package Manager
   - Linux with Swift Package Manager

**Note**: So far, with every major version of Swift, Apple decided to change the foundational APIs of the numeric
types in Swift significantly and consistently in a backward incompatible way. In order to be more isolated from
such changes in future, with Swift 3, I decided to introduce a distinct integer type used in NumberKit based on a
new protocol `IntegerNumber`. All standard numeric integer types implement this protocol. This is now consistent
with the usage of protocol `FloatingPointNumber` for floating point numbers, where there was, so far, never a
real, generic enough foundation (and still isn't).


## BigInt

`BigInt` objects are immutable, signed, arbitrary-precision integers that can be used as a
drop-in replacement for the existing binary integer types of Swift 4. Struct `BigInt` defines all
the standard arithmetic integer operations and implements the corresponding protocols defined
in the standard library.


## Rational

Struct `Rational<T>` defines immutable, rational numbers based on an existing signed integer
type `T`, like `Int32`, `Int64`, or `BigInt`. A rational number is a signed number that can
be expressed as the quotient of two integers _a_ and _b_: _a / b_.


## Complex

Struct `Complex<T>` defines complex numbers based on an existing floating point type `T`,
like `Float` or `Double`. A complex number consists of two components, a real part _re_
and an imaginary part _im_ and is typically written as: _re + im * i_ where _i_ is
the _imaginary unit_.
