# Errors and Overflow

Understand which operations trap, which return `nil`, and how overflow is handled.

## Operations that trap

Like the arithmetic of the Swift standard library, NumberKit traps if a result is undefined:

- Dividing by zero, for ``BigInt``, ``Integer``, and ``Rational``.
- Computing the square root of a negative ``BigInt``.
- Raising an integer to a negative power with `toPower(of:)`.
- Using an unsupported radix. Radixes between 2 and 36 are supported for parsing and printing,
  but only 2, 8, 10, and 16 are available via ``BigInt/Base``.
- Converting infinity or NaN to a ``BigInt`` or ``Integer``.

## Parsing

Parsing functions such as `BigInt(_:radix:)`, `BigInt(from:)`, `Rational(from:radix:)`, and the
`Complex` string initializer return `nil` for invalid input. String _literals_, in contrast, evaluate
to zero if they are invalid because literal initializers cannot fail.

## Overflow

``BigInt``, ``Integer``, and `Rational<BigInt>` have no overflow. ``Rational`` numbers based on
fixed-width integer types trap on overflow. The `addingReportingOverflow(_:)`,
`subtractingReportingOverflow(_:)`, `multipliedReportingOverflow(by:)` and
`dividedReportingOverflow(by:)` methods report overflow without trapping.

## Floating-point conversion

`BigInt.doubleValue` and `Rational.doubleValue` return the closest `Double` value. Numbers that are
too large are converted to infinity.
