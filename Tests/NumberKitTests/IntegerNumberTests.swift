//
// IntegerNumberTests.swift
// NumberKit
//
// Created by John DeTreville on 25/06/2023.
// Copyright © 2023 John DeTreville. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
// the license. You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
//  specific language governing permissions and limitations under the License.
//

import XCTest

@testable import NumberKit

class IntegerNumberTest: XCTestCase {

  func testGcd() {
    XCTAssert(Int32.gcdWithOverflow(1, 1) == (1, false))
    XCTAssert(Int32.gcdWithOverflow(1, 0) == (1, false))
    XCTAssert(Int32.gcdWithOverflow(0, 1) == (1, false))
    XCTAssert(Int32.gcdWithOverflow(0, 0) == (0, false))
    XCTAssert(Int32.gcdWithOverflow(1, -1) == (1, false))
    XCTAssert(Int32.gcdWithOverflow(-1, 1) == (1, false))
    XCTAssert(Int32.gcdWithOverflow(-1, -1) == (1, false))

    let factorial: Int64 = 2_432_902_008_176_640_000  // 20!
    let lcm: Int64 = 232_792_560  // lcm[1..20]
    XCTAssert(Int64.gcdWithOverflow(factorial, lcm) == (lcm, false))
    XCTAssert(Int64.gcdWithOverflow(factorial, lcm + 1) == (1, false))

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
      let (gcd, overflow) = UInt64.gcdWithOverflow(fibonaccis[i + 1], fibonaccis[i])
      XCTAssert((gcd == 1) != overflow)  // The Fibonacci numbers are relatively prime.
    }

    XCTAssert(Int64.gcdWithOverflow(Int64.min, Int64.min) == (Int64.min, true))
    XCTAssert(Int64.gcdWithOverflow(Int64.max, Int64.max) == (Int64.max, false))

    XCTAssert(UInt64.gcdWithOverflow(UInt64.min, UInt64.min) == (UInt64.min, false))
    XCTAssert(UInt64.gcdWithOverflow(UInt64.max, UInt64.max) == (UInt64.max, false))
  }

  func testLcm() {
    XCTAssert(Int32.lcmWithOverflow(1, 1) == (1, false))
    XCTAssert(Int32.lcmWithOverflow(1, 0) == (0, false))
    XCTAssert(Int32.lcmWithOverflow(0, 1) == (0, false))
    XCTAssert(Int32.lcmWithOverflow(0, 0) == (0, false))
    XCTAssert(Int32.lcmWithOverflow(1, -1) == (1, false))
    XCTAssert(Int32.lcmWithOverflow(-1, 1) == (1, false))
    XCTAssert(Int32.lcmWithOverflow(-1, -1) == (1, false))

    let factorial: Int64 = 2_432_902_008_176_640_000  // 20!
    let lcm: Int64 = 232_792_560  // lcm[1..20]
    XCTAssert(Int64.lcmWithOverflow(factorial, lcm) == (factorial, false))

    XCTAssert(Int64.lcmWithOverflow(Int64.min, Int64.min) == (Int64.min, true))
    XCTAssert(Int64.lcmWithOverflow(Int64.max, Int64.max) == (Int64.max, false))

    XCTAssert(UInt64.lcmWithOverflow(UInt64.min, UInt64.min) == (UInt64.min, false))
    XCTAssert(UInt64.lcmWithOverflow(UInt64.max, UInt64.max) == (UInt64.max, false))
  }

  static let allTests = [
    ("testGcd", testGcd),
    ("testLcm", testLcm),
  ]
}
