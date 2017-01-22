# Changelog

## 1.5 (2016-09-03)
- Migrated library to Xcode 8.0, Swift 3.0
- Renamed protocols to match the Swift 3 style guidelines
- Simplified a few implementations, making use of new Swift 3 APIs

## 1.4 (2016-03-28)

- Code now compatible with Xcode 7.3, Swift 2.2
- Turned `BigInt` into a struct to avoid garbage collection overhead

## 1.3 (2016-02-09)

- Significant performance improvements to speed up the BigInt/String conversion method
- Minor feature additions to rational numbers
- Playground (created by Dan Kogai)

## 1.2 (2016-01-17)

- Added arithmetic operations to `Rational<T>` which keep track of overflows
- Simplified implementation of `BigInt`
- Included new `BigInt` operations, e.g. a computed property for coercions to `Double`

## 1.1 (2015-10-19)

- Completed implementation of `Complex<T>`

## 1.0 (2015-08-24)

- Completed implementation of `BigInt`
- Completed implementation of `Rational<T>`
- `Complex<T>` still missing a large range of functions and tests
