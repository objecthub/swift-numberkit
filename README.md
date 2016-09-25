# Swift NumberKit

<p>
<a href="https://developer.apple.com/osx/"><img src="https://img.shields.io/badge/Platform-OS X-blue.svg?style=flat" alt="Platform: OS X" /></a>
<a href="https://developer.apple.com/swift/"><img src="https://img.shields.io/badge/Language-Swift%203.0-green.svg?style=flat" alt="Language: Swift 3" /></a>
<a href="https://raw.githubusercontent.com/objecthub/swift-lispkit/master/LICENSE"><img src="http://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat" alt="License: Apache" /></a>
</p>

## Overview

This is a library providing advanced numeric data types for the Swift 3 programming language.
The current version implements three new numeric types:

  1. `BigInt`: arbitrary-precision signed integers
  2. `Rational`: signed rational numbers
  3. `Complex`: complex floating-point numbers

**Requirements**: Xcode 8.0, Swift 3.0


## BigInt

`BigInt` objects are immutable, signed, arbitrary-precision integers that can be used as a
drop-in replacement for the existing integer types of Swift 3. Struct `BigInt` defines all
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
