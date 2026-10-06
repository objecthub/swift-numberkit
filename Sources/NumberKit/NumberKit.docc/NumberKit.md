# ``NumberKit``

Advanced numeric data types: arbitrary-size integers, rational numbers, and complex numbers.

## Overview

NumberKit is a lightweight framework implementing numeric types that are missing from the
Swift standard library:

- ``BigInt`` implements immutable, signed, arbitrary-size integers.
- ``Integer`` implements signed integers of arbitrary size. Small values are stored as native
  `Int64` numbers, which makes arithmetic on them as fast as native arithmetic.
- ``Rational`` implements normalized rational numbers on top of any signed integer type, e.g.
  `Int`, `Int32`, ``BigInt``, or ``Integer``.
- ``Complex`` implements complex numbers on top of `Float` or `Double`.

All types are value types, are `Hashable`, `Codable`, and `Sendable`, and implement the numeric
protocols of the Swift standard library wherever this is possible.

```swift
let a = BigInt(from: "123456789012345678901234567890")!
let b = BigInt(2).toPower(of: 100)
print(a * b)

let r = Rational<BigInt>(1, 3) + Rational(1, 6)   // 1/2
let z = Complex(3.0, 4.0).sqrt                    // 2.0+1.0i
```

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:ErrorsAndOverflow>

### Integers

- ``BigInt``
- ``Integer``
- ``IntegerNumber``
- ``SomeIntegerNumber``

### Rational Numbers

- ``Rational``
- ``RationalNumber``

### Complex Numbers

- ``Complex``
- ``ComplexNumber``
- ``FloatingPointNumber``
