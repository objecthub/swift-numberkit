# Swift NumberKit

## Overview

This is a library providing advanced numeric data types for the Swift 2 programming language.
The current version implements three new numeric types:

  1. `BigInt`: arbitrary-precision signed integers
  2. `Rational`: signed rational numbers
  3. `Complex`: complex floating-point numbers

**Requirements**: Xcode 7.3, Swift 2.2


## BigInt

`BigInt` objects are immutable, signed, arbitrary-precision integers that can be used as a
drop-in replacement for the existing integer types of Swift 2. Class `BigInt` defines all
the standard arithmetic integer operations and implements the corresponding protocols defined
in the standard library.


## Rational

Struct `Rational<T>` defines rational numbers based on an existing signed integer type
`T`, like `Int32`, `Int64`, or `BigInt`. A rational number is a signed number that can
be expressed as the quotient of two integers _a_ and _b_: _a / b_.


## Complex

Struct `Complex<T>` defines complex numbers based on an existing floating point type `T`,
like `Float` or `Double`. A complex number consists of two components, a real part _re_
and an imaginary part _im_ and is typically written as: _re + im * i_ where _i_ is
the _imaginary unit_.
