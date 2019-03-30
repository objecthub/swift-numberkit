# Changelog

## 2.3 (2019-03-30)
- Port to Swift 5
- Migrated project to Xcode 10.2
- Use new hashing API to improve hashing algorithm and to speed up hashing compound data structures

## 2.2 (2018-03-30)
- Port to Swift 4.1
- Migrated project to Xcode 9.3

## 2.1 (2018-01-24)
- Port to Swift 4.0.2
- Bug fix to support the Swift Package Manager for Swift 4
- Makes `BigInt` a fully integrated `SignedInteger` in Swift 4
- Re-introduces operations with overflow for `Rational` (which got lost in the Swift 4 migration)
- Optimize performance of `BigInt`
- Comprehensive support for bit operations on `BigInt` numbers
- Several bug fixes for existing bit operations
- Fixes numerous bugs in bit shifting logic
- Fixes serious bug in division and remainder logic for `BigInt` numbers

## 2.0 (2017-09-24)
- Ported NumberKit to Swift 4. This is a major change that might break existing clients
- Added support for `toPower(of:)` for all integer types
- Added new operators to `BigInt`: `<<`, `>>`, `<<=`, `>>=`, `%`, `%=`
- Introduced new integer protocol: `IntegerNumber`
- Renamed `FloatNumber` into `FloatingPointNumber`

## 1.6 (2017-05-01)
- Refactored directory structure
- Support for Swift Package Manager

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
