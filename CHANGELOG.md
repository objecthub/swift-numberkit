# Changelog

## 2.5 (2024-08-18)
- Fixes a serious bug which made unsigned integers implement the `IntegerNumber` protocol (which is designed for signed integers only)
- Enabled `IntegerNumberTests` also for Xcode
- Ready for usage with Swift 6

## 2.4.2 (2023-01-01)
- Support random number generation for Complex
- Migrated project to Swift 5.7 and Xcode 14

## 2.4.1 (2022-01-04)
- Support random number generation for BigInt
- Migrated project to Swift 5.5 and Xcode 13.2

## 2.4.0 (2021-05-12)
- Several enhancements of the `Complex` type
- Migrated project to Swift 5.4 and Xcode 12.5

## 2.3.9 (2020-10-04)
- Port to Swift 5.3
- Migrated project to Xcode 12.0

## 2.3.7 (2020-05-01)
- Fixed serious bug that was leading to a stack overflow if zero was added to a negative `BigInt` number
- Introduced new `Rational` constructor for approximating a `Double` number as a `Rational` 

## 2.3.6 (2020-04-10)
- Cleaned up Xcode project

## 2.3.5 (2020-04-05)
- Port to Swift 5.2
- Migrated project to Xcode 11.4

## 2.3.4 (2020-02-11)
- Include iOS build target

## 2.3.3 (2020-02-09)
- Made all numeric types support protocol `Codable`
- Migrated project to Xcode 11.3

## 2.3.2 (2019-10-20)
- Migrated project to Xcode 11.1
- Removed non-shared scheme from project

## 2.3.1 (2019-09-23)
- Port to Swift 5.1
- Migrated project to Xcode 11

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
