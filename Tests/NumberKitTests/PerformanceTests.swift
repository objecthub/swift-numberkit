//
//  PerformanceTests.swift
//  NumberKit
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import XCTest

@testable import NumberKit

/// Benchmarks for the performance critical operations. The tests do not fail on slow
/// executions; run them in release mode (`swift test -c release -Xswiftc -enable-testing
/// --filter PerformanceTests`) to get meaningful numbers.
class PerformanceTests: XCTestCase {
  private let digits = String(repeating: "123456789", count: 1000)  // 9000 digits
  private lazy var number = BigInt(from: digits)!
  private lazy var divisor = BigInt(from: String(digits.prefix(4000)))!

  func testParsing() {
    measure {
      for _ in 0..<2 {
        XCTAssertNotEqual(BigInt(from: digits), 0)
      }
    }
  }

  func testPrintingDecimal() {
    measure {
      for _ in 0..<2 {
        XCTAssertEqual(number.description.count, 9000)
      }
    }
  }

  func testPrintingHexadecimal() {
    measure {
      for _ in 0..<50 {
        XCTAssertFalse(number.toString(base: .hex).isEmpty)
      }
    }
  }

  func testMultiplication() {
    measure {
      for _ in 0..<1 {
        XCTAssertNotEqual(number * number, 0)
      }
    }
  }

  func testDivision() {
    measure {
      for _ in 0..<4 {
        XCTAssertNotEqual(number / divisor, 0)
      }
    }
  }

  func testSquareRoot() {
    measure {
      XCTAssertNotEqual(divisor.sqrt, 0)
    }
  }

  func testPower() {
    measure {
      for _ in 0..<2 {
        XCTAssertNotEqual(BigInt(3).toPower(of: BigInt(10000)), 0)
      }
    }
  }

  func testModularExponentiation() {
    let modulus = (BigInt(1) << 255) - BigInt(19)
    let exponent = modulus - BigInt(2)
    measure {
      for _ in 0..<5 {
        XCTAssertNotEqual(BigInt(3).modPow(exponent, modulus: modulus), 0)
      }
    }
  }

  func testPrimality() {
    let prime = (BigInt(1) << 127) - BigInt(1)
    measure {
      XCTAssert(prime.isProbablePrime())
    }
  }

  func testGCD() {
    let (a, b) = (BigInt(from: String(digits.prefix(1500)))!, BigInt(from: String(digits.suffix(1400)))!)
    measure {
      XCTAssertNotEqual(BigInt.gcd(a, b), 0)
    }
  }

  func testIntegerSmallArithmetic() {
    measure {
      var x = Integer(1)
      for i in 1...100_000 {
        x = (x * Integer(3) + Integer(i)) % Integer(1_000_003)
      }
      XCTAssertNotEqual(x, -1)
    }
  }

  func testRationalSummation() {
    measure {
      var sum = Rational<BigInt>(0)
      for i in 1...300 {
        sum = sum + Rational<BigInt>(BigInt(1), BigInt(i))
      }
      XCTAssertEqual(sum.denominator.description.count > 100, true)
    }
  }

  func testComplexArithmetic() {
    measure {
      var z = Complex(0.0, 0.0)
      let c = Complex(-0.4, 0.6)
      for _ in 0..<100_000 {
        z = z * z + c
        if z.abs > 2 {
          z = Complex(0.0, 0.0)
        }
      }
      XCTAssertFalse(z.isNaN)
    }
  }
}
