//
//  RationalTests.swift
//  NumberKit
//
//  Created by Matthias Zenger on 16/08/2015.
//  Copyright © 2015-2020 Matthias Zenger. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import XCTest
@testable import NumberKit

class RationalTests: XCTestCase {
  
  func testConstructors() {
    let r0: Rational<Int> = 8
    XCTAssert(r0.numerator == 8 && r0.denominator == 1)
    XCTAssert(r0 == 8)
    let r1: Rational<Int> = 7/2
    XCTAssert(r1.numerator == 7 && r1.denominator == 2)
    XCTAssert(r1.floatValue == 7.0/2.0)
    let r2 = Rational(43, 7)
    XCTAssert(r2.numerator == 43 && r2.denominator == 7)
    let r3 = Rational(19 * 3 * 5 * 7, 2 * 5 * 7)
    XCTAssert(r3.numerator == 19 * 3 && r3.denominator == 2)
    let r4: Rational<Int>? = Rational(from: "172346/254")
    if let r4u = r4 {
      XCTAssertEqual(r4u.numerator, 86173)
      XCTAssertEqual(r4u.denominator, 127)
    } else {
      XCTFail("cannot parse r4 string")
    }
    let r5: Rational<Int>? = Rational(from: "-128/64")
    if let r5u = r5 {
      XCTAssertEqual(r5u.numerator, -2)
      XCTAssertEqual(r5u.denominator, 1)
    } else {
      XCTFail("cannot parse r5 string")
    }
  }
  
  func testPlus() {
    let r1 = Rational(16348, 343).plus(24/7)
    XCTAssertEqual(r1, 17524/343)
    XCTAssert(r1 == Rational(from: "17524/343"))
    XCTAssert(r1 == 17524/343)
    let r2: Rational<Int> = (74433/215).plus(312/15)
    XCTAssert(r2 == 367)
    let r3: Rational<Int> = (458200/50).plus(3440/17)
    XCTAssert(r3 == 159228/17)
    let x = Rational(BigInt(458200)/BigInt(50))
    let r4: Rational<BigInt> = x.plus(Rational(BigInt(3440)/BigInt(17)))
    XCTAssert(r4 == Rational(BigInt(159228)/BigInt(17)))
  }
  
  func testMinus() {
    let r1 = Rational(123, 5).minus(247/10)
    XCTAssertEqual(r1, Rational(1, 10).negate)
    let r2 = Rational(0).minus(72372/30)
    XCTAssertEqual(r2, -Rational(72372, 30))
    let r3 = Rational(98232, 536).minus(123/12)
    XCTAssertEqual(r3, Rational(46369, 268))
  }
  
  func testTimes() {
    let r1 = Rational(4, 8).times(2)
    XCTAssertEqual(r1, 1)
    let r2 = Rational(83987, 12).times(48/42)
    XCTAssertEqual(r2, Rational(83987 * 48, 12 * 42))
    let r3 = Rational(170, 9).times(-17/72)
    XCTAssertEqual(r3, Rational(-170 * 17, 9 * 72))
  }
  
  func testDividedBy() {
    let r1 = Rational(10, -3).divided(by: -31/49)
    XCTAssertEqual(r1, Rational(10 * 49, 3 * 31))
  }
  
  func testRationalize() {
    let r1 = Rational<Int>(1.0/3.0)
    XCTAssertEqual(r1, Rational(1, 3))
    let r2 = Rational<Int>(1931.0 / 9837491.0, precision: 1.0e-14)
    XCTAssertEqual(r2, Rational(1931, 9837491))
    let r3 = Rational<Int>(-17.0/3.0)
    XCTAssertEqual(r3, -Rational(17, 3))
    let r4 = Rational<BigInt>(1931.0 / 9837491.0, precision: 1.0e-14)
    XCTAssertEqual(r4, Rational(BigInt(1931), BigInt(9837491)))
  }

  func testGcd() {
    XCTAssert(Rational.gcdWithOverflow(1, 1) == (1, false))
    XCTAssert(Rational.gcdWithOverflow(1, 0) == (1, false))
    XCTAssert(Rational.gcdWithOverflow(0, 1) == (1, false))
    XCTAssert(Rational.gcdWithOverflow(0, 0) == (0, false))
    XCTAssert(Rational.gcdWithOverflow(1, -1) == (1, false))
    XCTAssert(Rational.gcdWithOverflow(-1, 1) == (1, false))
    XCTAssert(Rational.gcdWithOverflow(-1, -1) == (1, false))

    let factorial: Int64 = 2_432_902_008_176_640_000  // 20!
    let lcm: Int64 = 232_792_560  // lcm[1..20]
    XCTAssert(Rational.gcdWithOverflow(factorial, lcm) == (lcm, false))
    XCTAssert(Rational.gcdWithOverflow(factorial, lcm + 1) == (1, false))

    let fibonaccis: [UInt64] = [
      0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765,
      10946, 17711, 28657, 46368, 75025, 121393, 196418, 317811, 514229, 832040, 1_346_269,
      2_178_309, 3_524_578, 5_702_887, 9_227_465, 14_930_352, 24_157_817, 39_088_169, 63_245_986,
      102_334_155, 165_580_141, 267_914_296, 433_494_437, 701_408_733, 1_134_903_170,
      1_836_311_903, 2_971_215_073, 4_807_526_976, 7_778_742_049, 12_586_269_025, 20_365_011_074,
      32_951_280_099, 53_316_291_173, 86_267_571_272, 139_583_862_445, 225_851_433_717,
      365_435_296_162, 591_286_729_879, 956_722_026_041, 1_548_008_755_920, 2_504_730_781_961,
      4_052_739_537_881, 6_557_470_319_842, 10_610_209_857_723, 17_167_680_177_565,
      27_777_890_035_288, 44_945_570_212_853, 72_723_460_248_141, 117_669_030_460_994,
      190_392_490_709_135, 308_061_521_170_129, 498_454_011_879_264, 806_515_533_049_393,
      1_304_969_544_928_657, 2_111_485_077_978_050, 3_416_454_622_906_707, 5_527_939_700_884_757,
      8_944_394_323_791_464, 14_472_334_024_676_221, 23_416_728_348_467_685,
      37_889_062_373_143_906, 61_305_790_721_611_591, 99_194_853_094_755_497,
      160_500_643_816_367_088, 259_695_496_911_122_585, 420_196_140_727_489_673,
      679_891_637_638_612_258, 1_100_087_778_366_101_931, 1_779_979_416_004_714_189,
      2_880_067_194_370_816_120, 4_660_046_610_375_530_309, 7_540_113_804_746_346_429,
      12_200_160_415_121_876_738,
    ]
    for i in fibonaccis.indices.dropLast(1) {
      let (gcd, overflow) = Rational.gcdWithOverflow(fibonaccis[i + 1], fibonaccis[i])
      XCTAssert((gcd == 1) != overflow)  // The Fibonacci numbers are relatively prime iff there's no overflow.
    }

    XCTAssert(Rational.gcdWithOverflow(Int64.min, Int64.min) == (Int64.min, true))
  }

  func testLcm() {
    XCTAssert(Rational.lcmWithOverflow(1, 1) == (1, false))
    XCTAssert(Rational.lcmWithOverflow(1, 0) == (0, false))
    XCTAssert(Rational.lcmWithOverflow(0, 1) == (0, false))
    XCTAssert(Rational.lcmWithOverflow(0, 0) == (0, false))
    XCTAssert(Rational.lcmWithOverflow(1, -1) == (1, false))
    XCTAssert(Rational.lcmWithOverflow(-1, 1) == (1, false))
    XCTAssert(Rational.lcmWithOverflow(-1, -1) == (1, false))

    let factorial: Int64 = 2_432_902_008_176_640_000  // 20!
    let lcm: Int64 = 232_792_560  // lcm[1..20]
    XCTAssert(Rational.lcmWithOverflow(factorial, lcm) == (factorial, false))

    XCTAssert(Rational.lcmWithOverflow(Int64.min, Int64.min) == (Int64.min, true))
  }

  static let allTests = [
    ("testConstructors", testConstructors),
    ("testPlus", testPlus),
    ("testMinus", testMinus),
    ("testTimes", testTimes),
    ("testDividedBy", testDividedBy),
    ("testGcd", testGcd),
    ("testLcm", testLcm),
  ]
}
