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

All types are immutable value types. They are `Hashable`, `Codable`, and `Sendable`, and they
implement the numeric protocols of the Swift standard library wherever this is possible. There are no
dependencies other than Foundation.

**Note**: In the early days of Swift, with every major release, Apple introduced breaking changes in the foundational APIs of the numeric
types in Swift, consistently in backward incompatible ways. In order to be more isolated from
such changes, with Swift 3, I decided to introduce a distinct integer type used in NumberKit based on a
new protocol `IntegerNumber`. All standard numeric integer types implement this protocol. This is now consistent
with the usage of protocol `FloatingPointNumber` for floating point numbers, where there was, so far, never a
real, generic enough foundation (and still isn't).

## Installation

### Swift Package Manager

Add NumberKit as a dependency in your `Package.swift` file:

```swift
dependencies: [
  .package(url: "https://github.com/objecthub/swift-numberkit.git", from: "3.0.0"),
],
targets: [
  .target(name: "MyTarget", dependencies: [.product(name: "NumberKit", package: "swift-numberkit")]),
]
```

### CocoaPods and Carthage

```ruby
pod 'NumberKit'                                 # Podfile
```

```
github "objecthub/swift-numberkit"              # Cartfile
```

In your source files, import the framework with `import NumberKit`.

## BigInt

`BigInt` values are immutable, signed, arbitrary-size integers that can be used as a
drop-in replacement for the existing binary integer types of Swift 5.
[Struct `BigInt`](https://github.com/objecthub/swift-numberkit/blob/master/Sources/NumberKit/BigInt.swift) defines all
the standard arithmetic integer operations and implements the corresponding numeric
protocols of Swift.

### Creating and combining values

`BigInt` values are created from native integers, floating-point numbers, or strings:

```swift
import NumberKit

let a = BigInt(from: "123456789012345678901234567890")!   // parsing returns nil for invalid input
let b: BigInt = 987654321                                  // integer literal
let big: BigInt = 123456789012345678901234567890           // integer literals can be of arbitrary length
let c = BigInt(UInt64.max)                                 // 18446744073709551615
let d = BigInt(1.5e20)                                     // 150000000000000000000 (fractions are truncated)
let e: BigInt = "-98765432109876543210"                    // string literal (zero if invalid!)
BigInt(exactly: 2.5)                                       // nil
```

All the usual arithmetic and comparison operators are available. Division truncates towards zero
and the remainder has the sign of the dividend, like for Swift's integer types:

```swift
a + b                                  // 123456789012345678902222222211
a * b                                  // 121932631124828532112482853211126352690
let (q, r) = a.divided(by: b)          // q = 124999998873437499901, r = 574845669
a % BigInt(1_000_000_007)              // 197434842
-a                                     // -123456789012345678901234567890
(-a).abs                               // 123456789012345678901234567890
(-a).signum()                          // -1
a > b                                  // true
a.sqrt                                 // 351364182882014 (integer square root)
BigInt(2).toPower(of: 100)             // 1267650600228229401496703205376
BigInt(7) ** BigInt(30)                // 22539340290692258087863249
```

### Bit operations

Bitwise operations use the two's complement representation, just like native integers do:

```swift
let m = BigInt(0b1011_0110)
m & 0b1111                             // 6
m | 1                                  // 183
m ^ 0xff                               // 73
~BigInt(5)                             // -6
BigInt(1) << 100                       // 1267650600228229401496703205376
BigInt(-5) >> 1                        // -3 (arithmetic shift, rounds towards negative infinity)
m.isBitSet(1)                          // true
m.set(bit: 0, to: true)                // 183
m.bitCount                             // 5
m.firstBitSet                          // 1
m.lastBitSet                           // 8
```

### Strings and radixes

`toString` supports digit grouping, forced signs, and custom separators. Radixes between 2 and 36 are
supported:

```swift
let n = BigInt(from: "1234567890123456789")!
n.description                                              // "1234567890123456789"
n.toString(groupSep: ",")                                  // "1,234,567,890,123,456,789"
n.toString(groupSep: "_", groupSize: 4, forceSign: true)   // "+123_4567_8901_2345_6789"
n.toString(base: .hex)                                     // "112210F47DE98115"
n.toString(radix: 16)                                      // "112210f47de98115"
n.toString(radix: 36)                                      // "9do1sj396nf9"
BigInt("-zz", radix: 36)                                   // -1295
BigInt(from: "FF", base: .hex)                             // 255
BigInt(from: "  42  ")                                     // 42 (surrounding blanks are accepted)
BigInt(from: "12x")                                        // nil
```

Printing and parsing in base 2, 8, and 16 is linear; decimal conversion uses a divide and conquer algorithm.

### Conversions

```swift
BigInt(42).intValue                    // Optional(42)
(BigInt(1) << 70).intValue             // nil (does not fit into an Int64)
BigInt(UInt64.max).uintValue           // Optional(18446744073709551615)
Int(BigInt(123))                       // 123 (traps if the value does not fit)
Int(exactly: BigInt(1) << 70)          // nil
(BigInt(1) << 80).doubleValue          // 1.2089258196146292e+24 (correctly rounded)
BigInt(2).toPower(of: 2000).doubleValue   // inf
```

### Number theory

```swift
BigInt.gcd(BigInt(1071), BigInt(462))                  // 21
BigInt.lcm(BigInt(4), BigInt(6))                       // 12
BigInt.extendedGCD(BigInt(240), BigInt(46))            // (gcd: 2, x: 9, y: 47), i.e. 240 * 9 + 46 * 47 = 2
BigInt(1000).modPow(BigInt(5), modulus: BigInt(97))    // 45
BigInt(3).modInverse(BigInt(11))                       // Optional(4)
BigInt(6).modInverse(BigInt(9))                        // nil (not coprime)
((BigInt(1) << 61) - 1).isProbablePrime()              // true (a Mersenne prime)
(BigInt(10).toPower(of: 30) + 1).isProbablePrime()     // false
```

`isProbablePrime` is exact for numbers below 3.3 * 10^24 and uses the Miller-Rabin test with additional random
bases for larger numbers. Here is a toy RSA key pair built from these functions:

```swift
let (p, q) = (BigInt(61), BigInt(53))
let n = p * q                                  // 3233
let phi = (p - 1) * (q - 1)                    // 3120
let e = BigInt(17)
let d = e.modInverse(phi)!                     // 2753
let encrypted = BigInt(65).modPow(e, modulus: n)         // 2790
let decrypted = encrypted.modPow(d, modulus: n)          // 65
```

### Random numbers

```swift
BigInt.random(withMaxBits: 256)                        // a random number with up to 256 bits
BigInt.random(below: BigInt(100))                      // a random number in 0..<100

var generator = SystemRandomNumberGenerator()          // any RandomNumberGenerator can be used
BigInt.random(below: BigInt(10).toPower(of: 50), using: &generator)
```

### Some classics

```swift
var factorial = BigInt(1)
for i in 1...30 {
  factorial *= BigInt(i)
}
factorial                                      // 265252859812191058636308480000000

var (x, y) = (BigInt(0), BigInt(1))
for _ in 0..<200 {
  (x, y) = (y, x + y)
}
x                                              // 280571172992510140037611932413038677189525 (200th Fibonacci number)
```

## Integer

`Integer` values are immutable, signed, arbitrary-size integers that can be used as a
drop-in replacement for the existing binary integer types of Swift 5. As opposed to `BigInt`,
the representation of values is chosen to optimize for memory size and performance of
arithmetic operations. [Enum `Integer`](https://github.com/objecthub/swift-numberkit/blob/master/Sources/NumberKit/Integer.swift)
defines all the standard arithmetic integer operations and implements the corresponding
numeric protocols of Swift.

`Integer` is an enumeration with two cases: values that fit into 64 bits are stored as native
`Int64` numbers, all other values are stored as `BigInt` numbers. Arithmetic operations use fast
native paths as long as the operands and the results are small, and switch representations
automatically. Results are always normalized, i.e. a value fitting into 64 bits is never stored as a `BigInt`.

```swift
let x: Integer = 9_223_372_036_854_775_807   // Int64.max, stored as a native Int64
x + 1                                        // 9223372036854775808, now stored as a BigInt
(x + 1) - 1                                  // 9223372036854775807, back to a native Int64
x * x                                        // 85070591730234615847396907784232501249
let y: Integer = 314159265358979323846264338328   // literals of arbitrary length are supported
Integer(100) / Integer(7)                    // 14
Integer(100) % Integer(7)                    // 2
Integer(2).toPower(of: 70)                   // 1180591620717411303424
Integer(2) ** Integer(10)                    // 1024
Integer(5) < Integer(1) << 80                // true
x.bigIntValue                                // the value as a BigInt
Integer(BigInt(1) << 70)                     // 1180591620717411303424
```

Use `Integer` if most of your numbers are small but you need protection against overflow. Use `BigInt` if
your numbers are mostly large.

## Rational

[Struct `Rational<T>`](https://github.com/objecthub/swift-numberkit/blob/master/Sources/NumberKit/Rational.swift)
defines immutable, rational numbers based on an existing signed integer
type `T`, like `Int32`, `Int64`, `BigInt`, or `Integer`. A rational number is a signed number that can
be expressed as the quotient of two integers _a_ and _b_: _a / b_.

Rational numbers are always normalized: the denominator is positive, and numerator and denominator are coprime.

### Creating values

```swift
let r = Rational<Int>(6, 8)               // 3/4
r.numerator                               // 3
r.denominator                             // 4
Rational<Int>(3, -6)                      // -1/2
Rational<Int>(0.75)                       // 3/4 (rationalizes floating-point numbers)
Rational<Int>(3.14159, precision: 1e-4)   // 333/106
let s: Rational<Int> = "3/9"              // 1/3 (string literal; zero if invalid)
Rational<Int>(from: "-10/4")              // Optional(-5/2)
Rational<Int>(from: "f/10", radix: 16)    // Optional(15/16)
Rational<Int>(8, 4).intValue              // Optional(2)
Rational<Int>(1, 3).intValue              // nil
```

### Arithmetic and comparison

```swift
r - Rational(1, 2)                        // 1/4
r * r                                     // 9/16
r / Rational(1, 2)                        // 3/2
-r                                        // -3/4
r.reciprocal                              // 4/3
r.toPower(of: 3)                          // 27/64
r.toPower(of: -2)                         // 16/9
r > Rational(2, 3)                        // true
r == Rational(3, 4)                       // true
max(r, Rational(4, 5))                    // 4/5
```

### Rounding and conversion

`rounded` supports all the rounding rules of Swift's floating-point types:

```swift
Rational<Int>(7, 2).rounded()                          // 4 (to nearest, ties away from zero)
Rational<Int>(7, 2).rounded(.down)                     // 3 (floor)
Rational<Int>(-7, 2).rounded(.up)                      // -3 (ceiling)
Rational<Int>(5, 2).rounded(.toNearestOrEven)          // 2
Rational<Int>(1, 3).doubleValue                        // 0.3333333333333333
Rational<Int>(22, 7).floatValue                        // 3.142857
```

### Exact arithmetic with big numbers

Combining `Rational` with `BigInt` or `Integer` gives exact arithmetic without overflow. Parsing supports
numbers of any size and `doubleValue` is also correct for numbers that are too large for `Double`:

```swift
var harmonic = Rational<BigInt>(0)
for k in 1...20 {
  harmonic = harmonic + Rational<BigInt>(BigInt(1), BigInt(k))
}
harmonic                                   // 55835135/15519504
harmonic.doubleValue                       // 3.597739657143682

Rational<BigInt>(from: "246913578024691357802469135780/370370367037037036703703703670")   // 2/3
```

### Overflow

Arithmetic on rational numbers based on fixed-width integer types traps if the result cannot be represented.
Use the `*ReportingOverflow` methods to detect overflows explicitly:

```swift
let (sum, overflow) = Rational<Int>(Int.max, 1).addingReportingOverflow(Rational(1, 1))
overflow                                   // true

Rational<Int8>(100, 3).multipliedReportingOverflow(by: Rational(3, 1)).overflow    // true
```

Comparisons never overflow, and products are cross-reduced before multiplying, so no overflow occurs if the
result is representable.

## Complex

[Struct `Complex<T>`](https://github.com/objecthub/swift-numberkit/blob/master/Sources/NumberKit/Complex.swift)
defines complex numbers based on an existing floating point type `T`, like `Float` or `Double`. A complex number
consists of two components, a real part _re_ and an imaginary part _im_ and is typically written as: _re + im * i_
where _i_ is the _imaginary unit_.

### Creating values and accessing components

```swift
let z = Complex(3.0, 4.0)                  // 3.0+4.0i
let w = Complex(1.0, -2.0)                 // 1.0-2.0i
z.re                                       // 3.0
z.im                                       // 4.0
z.abs                                      // 5.0 (Euclidean norm; same as z.norm)
z.arg                                      // 0.9272952180016122 (phase)
z.magnitude                                // 4.0 (the ∞-norm)
Complex(abs: 2.0, arg: Double.pi / 2)      // approximately 2.0i (polar coordinates)
Complex<Double>.i * Complex<Double>.i      // -1.0
Complex(2.0, 0.0).isReal                   // true
Complex(2.0, 0.0).realValue                // Optional(2.0)
```

### Arithmetic

All operators work with complex numbers as well as with a mix of complex numbers and scalars. Division and
reciprocals use Smith's algorithm and do not overflow or underflow in intermediate results:

```swift
z + w                                      // 4.0+2.0i
z - w                                      // 2.0+6.0i
z * w                                      // 11.0-2.0i
z / w                                      // -1.0+2.0i
-z                                         // -3.0-4.0i
z.conjugate                                // 3.0-4.0i
z.reciprocal                               // 0.12-0.16i
z * 2.0                                    // 6.0+8.0i
2.0 * z                                    // 6.0+8.0i
z.toPower(of: Complex(2.0, 0.0))           // -7.0+24.0i (integral exponents use repeated squaring)
[z, w, Complex(1.0, 1.0)].reduce(Complex.zero, +)   // 5.0+3.0i
```

### Functions

The exponential, logarithm, square root, as well as the trigonometric and hyperbolic functions and their
inverses are defined for complex numbers. They are available as global functions and, in part, as properties:

```swift
z.sqrt                                     // 2.0+1.0i
exp(Complex(0.0, Double.pi))               // approximately -1.0
log(z)                                     // 1.6094379124341003+0.9272952180016122i
sin(z)                                     // 3.853738037919377-27.016813258003932i
cos(z)                                     // -27.034945603074224-3.8511533348117775i
sinh(z)                                    // -6.548120040911002-7.619231720321411i
asin(Complex(2.0, 0.0))                    // 1.5707963267948966-1.3169578969248166i
pow(Complex(-8.0, 0.0), Complex(1.0 / 3.0, 0.0))   // 1.0+1.732050807568877i (principal value)
```

### Parsing and formatting

`Complex` values are `LosslessStringConvertible`: the string representation can be parsed again.

```swift
z.description                              // "3.0+4.0i"
Complex<Double>("2.5-1i")                  // Optional(2.5-1.0i)
Complex<Double>("3i")                      // Optional(3.0i)
Complex<Double>("x")                       // nil
```

### Example: the Mandelbrot set

```swift
func escapeTime(_ c: Complex<Double>) -> Int {
  var z = Complex<Double>.zero
  for i in 0..<50 {
    z = z * z + c
    if z.abs > 2 {
      return i
    }
  }
  return 50
}

escapeTime(Complex(0.0, 0.0))              // 50 (in the set)
escapeTime(Complex(1.0, 1.0))              // 1 (escapes immediately)
escapeTime(Complex(-0.75, 0.1))            // 32
```

## Protocols and generic programming

The numeric types are built on a small hierarchy of protocols, which makes it possible to write
algorithms that work for all of them:

| Protocol | Description | Implemented by |
| --- | --- | --- |
| `IntegerNumber` | signed integers | `Int`, `Int8` ... `Int64`, `BigInt`, `Integer` |
| `RationalNumber` | rational numbers | `Rational<T>` |
| `ComplexNumber` | complex numbers | `Complex<T>` |
| `FloatingPointNumber` | floating-point numbers needed for complex numbers | `Float`, `Double` |

`IntegerNumber` provides `zero`, `one`, `gcd`, `lcm`, `toPower(of:)`, `isOdd`, as well as methods
for arithmetic that report overflow:

```swift
func sum<T: IntegerNumber>(upTo n: T) -> T {
  var result = T.zero
  var k = T.one
  while k <= n {
    result += k
    k += T.one
  }
  return result
}

sum(upTo: 100 as Int)                      // 5050
sum(upTo: BigInt(100000))                  // 5000050000
sum(upTo: Integer(10))                     // 55

Int.gcd(12, 18)                            // 6
Int64.lcm(4, 6)                            // 12
2 ** 10                                    // 1024 (for all integer numbers)
min(BigInt(3), BigInt(5))                  // 3
bitcount(UInt32(255))                      // 8 (number of bits set in native integers)
```

## Codable and Hashable

All types are `Hashable` and can therefore be used in sets and as dictionary keys. Equal values have equal hash
values, no matter how they were created (e.g. `Rational(2, 4)` and `Rational(1, 2)`, or `Integer.int(5)` and
`Integer.bigInt(BigInt(5))`). All types are `Codable`; the JSON representation is:

```swift
// BigInt: a decimal string (numbers are accepted when decoding, too)
try JSONEncoder().encode([BigInt(from: "123456789012345678901234567890")!])
//   ["123456789012345678901234567890"]
try JSONDecoder().decode([BigInt].self, from: Data("[1, \"2\"]".utf8))     // [1, 2]

// Rational: an object with numerator and denominator
//   {"denominator":4,"numerator":3}

// Complex: an object with real and imaginary part
//   {"real":3,"imaginary":4}
```

## Notes

- Operations that cannot produce a result, like dividing by zero, trap. Arithmetic on `Rational`
  values based on fixed-width integers also traps on overflow; the `*ReportingOverflow` methods
  can be used to detect overflows explicitly. `BigInt`, `Integer`, and `Rational<BigInt>` never overflow.
- `BigInt` stores numbers as arrays of 32-bit words. Multiplication is quadratic, division uses
  Knuth's algorithm D, and decimal conversion uses divide and conquer. Conversions from and to
  binary, octal and hexadecimal strings are linear. Use `Integer` if most of your numbers are small.
- Parsing functions return `nil` for invalid input. Note that string literals, like `let x: BigInt = "123"`,
  silently evaluate to zero if they are invalid; use `BigInt(from:)` or `BigInt(_:radix:)` for untrusted input.
- Integer literals of arbitrary length are supported for `BigInt` and `Integer` (via `StaticBigInt`). This is
  the reason why NumberKit requires macOS 13.3, iOS 16.4, tvOS 16.4, or watchOS 9.4 as a minimum.
- `Complex.magnitude` is the ∞-norm; use `abs` or `norm` for the Euclidean norm.

## Documentation

The sources contain documentation comments for all public types and functions. A
[DocC](https://www.swift.org/documentation/docc/) catalogue with articles
is included in the package (`Sources/NumberKit/NumberKit.docc`). In Xcode, choose _Product > Build Documentation_
to browse it.

## Requirements

The following technologies are needed to build the components of the _Swift NumberKit_ framework:

- [Xcode 26](https://developer.apple.com/xcode/)
- [Swift 6](https://developer.apple.com/swift/) toolchain (both the Swift 5 and Swift 6 language modes are supported)
- [Swift Package Manager](https://swift.org/package-manager/)
- macOS 13.3+, iOS 16.4+, tvOS 16.4+, watchOS 9.4+, and Linux

## Copyright

Author: Matthias Zenger (<matthias@objecthub.net>)  
Copyright © 2016-2026 Matthias Zenger. All rights reserved.
