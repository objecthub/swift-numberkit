# Getting Started

Create numbers, convert them from and to strings, and compute with them.

## Arbitrary-size integers

``BigInt`` values are created from integers, floating-point numbers, or strings. They support
all the arithmetic, bitwise, and comparison operators of Swift's integer types.

```swift
let a = BigInt(from: "123456789012345678901234567890")!
let b: BigInt = 987654321
let c: BigInt = 123456789012345678901234567890   // integer literals can have any length
let (quotient, remainder) = a.divided(by: b)
let power = BigInt(2).toPower(of: 100)       // 1267650600228229401496703205376
let hex = power.toString(radix: 16)          // "10000000000000000000000000"
let parsed = BigInt("ff", radix: 16)         // Optional(255)
```

Number-theoretic functions are available as well:

```swift
BigInt.gcd(BigInt(1071), BigInt(462))                // 21
BigInt(1000).modPow(BigInt(5), modulus: BigInt(97))   // 45
BigInt(3).modInverse(BigInt(11))                      // Optional(4)
BigInt(97).isProbablePrime()                          // true
```

Use ``Integer`` instead of ``BigInt`` if most numbers are small:

```swift
let x: Integer = 9_223_372_036_854_775_807   // stored as Int64
let y = x + 1                                // automatically switches to a BigInt representation
```

## Rational numbers

``Rational`` numbers are always normalized: the denominator is positive and the numerator and
denominator are coprime.

```swift
let r = Rational<Int>(6, 8)       // 3/4
let s = r + Rational(1, 4)        // 1
r.rounded(.down)                  // 0
r.doubleValue                     // 0.75
Rational<Int>(from: "-3/12")      // Optional(-1/4)
```

## Complex numbers

``Complex`` numbers consist of a real and an imaginary part of floating-point type.

```swift
let z = Complex(3.0, 4.0)
z * z                              // -7.0+24.0i
z.abs                              // 5.0
exp(Complex(0.0, Double.pi))       // approximately -1
Complex<Double>("1+2i")            // Optional(1.0+2.0i)
```
