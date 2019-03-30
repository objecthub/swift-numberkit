//
//  BigIntTests.swift
//  NumberKit
//
//  Created by Matthias Zenger on 11/08/2015.
//  Copyright © 2015-2019 Matthias Zenger. All rights reserved.
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


class BigIntTests: XCTestCase {
  
  func testConstructors() {
    XCTAssert(BigInt(0).intValue == 0)
    XCTAssert(BigInt(1).intValue == 1)
    XCTAssert(BigInt(-1).intValue == -1)
    XCTAssert(BigInt(Int32.max / 3).intValue == Int64(Int32.max / 3))
    XCTAssert(BigInt(Int64(Int32.max) * 3).intValue == Int64(Int32.max) * 3)
    XCTAssert(BigInt(Int64(Int32.max) * Int64(Int32.max - 17)).intValue ==
              Int64(Int32.max) * Int64(Int32.max - 17))
    XCTAssert(BigInt(Int64(Int32.max) * Int64(Int32.max - 17)).uintValue ==
              UInt64(Int32.max) * UInt64(Int32.max - 17))
  }
  
  func testPlus() {
    let x1: BigInt = "314159265358979323846264338328"
    XCTAssert(x1.plus(x1) == "628318530717958647692528676656")
    XCTAssert(x1.plus(x1).plus(x1) == "942477796076937971538793014984")
    XCTAssert(x1.plus(x1).plus(x1).plus(x1) == "1256637061435917295385057353312")
    XCTAssert(x1.plus(x1).plus(x1).plus(0).plus(x1) == "1256637061435917295385057353312")
    XCTAssert(x1.plus(x1).plus(x1).plus(1).plus(x1) == "1256637061435917295385057353313")
    let x2: BigInt = "99564370914876591721233850654538777"
    XCTAssert(x2.plus(x2) == "199128741829753183442467701309077554")
    XCTAssert(x2.plus(x2).plus("9234567890123456789012345678901234567890") ==
      "9234767018865286542195788146602543645444")
  }
  
  func testMinus() {
    let x1: BigInt = "1134345924505409852113434"
    let x2: BigInt = "38274945700000001034304000024002450"
    XCTAssert(x1.minus(x2) == "-38274945698865655109798590171889016")
    XCTAssert(x1.minus(x1) == 0)
    XCTAssert(x2.minus(x2) == 0)
    XCTAssert(x2.plus(1).minus(x2) == 1)
    let x3: BigInt = "38274945700000001034304000024002449"
    XCTAssert(x2.minus(x3) == 1)
    XCTAssert(x3.minus(x2) == -1)
  }
  
  func testTimes() {
    let x1: BigInt = "89248574598402980294572048572242498123"
    let x2: BigInt = "84759720710000012134"
    XCTAssert(x1.times(x2) == "7564684256726238104741764542977591293635416602920472224482")
    let x3: BigInt = "-846372893840594837726622221119029"
    XCTAssert(x1.times(x3) ==
      "-75537574353998534693615828134454330968785329792741330257228043492082567")
  }
  
  func testDividedBy() {
    let x1: BigInt = "38274945700000001034304000022452452525224002449"
    let x2: BigInt = "1234567890123456789"
    let r1 = x1.divided(by: x2)
    XCTAssert(r1.quotient == "31002706296024357530217920519")
    XCTAssert(r1.remainder == "654242677691048958")
    let x3: BigInt = "3827494570900000103430410002245245252522400244999"
    let x4: BigInt = "12345678901234567892344542545242452245"
    let r2 = x3.divided(by: x4)
    XCTAssert(r2.quotient == "310027063033")
    XCTAssert(r2.remainder == "1772541951990552417813256094292885914")
    XCTAssert((x3 / x3) == BigInt(1))
    XCTAssert((x3 / (x3.times(10))) == BigInt(0))
  }
  
  func testRemainder() {
    let qp: BigInt = "76292485249"
    let qn: BigInt = "-76292485249"
    let x1p: BigInt = "12"
    let x1n: BigInt = "-12"
    let x2p: BigInt = "7629248524991"
    let x2n: BigInt = "-7629248524991"
    XCTAssert(x1p % qp == x1p)
    XCTAssert(x1n % qp == x1n)
    XCTAssert(x1p % qn == x1p)
    XCTAssert(x1n % qn == x1n)
    let rp: BigInt = "91"
    let rn: BigInt = "-91"
    XCTAssertEqual(x2p % qp, rp)
    XCTAssertEqual(x2n % qp, rn)
    XCTAssertEqual(x2p % qn, rp)
    XCTAssertEqual(x2n % qn, rn)
  }
  
  func testSqrt() {
    let x1: BigInt = "987248974087420857240857208746297469247698798798798700"
    XCTAssert(x1.sqrt == "993604032845791572092520365")
    let x2: BigInt = "785035630596835096835069835069385609358603956830596835096835069835608390000"
    XCTAssert(x2.sqrt == "28018487300295765553963049921800641599")
    let x3: BigInt = "1000000000000"
    XCTAssert(x3.sqrt == "1000000")
  }
  
  func testPowerOf() {
    let x1: BigInt = "84570248572048572408572048572048"
    let y1 = x1 * x1 * x1 * x1
    XCTAssert(x1.toPower(of: BigInt(4)) == y1)
  }
  
  func testDoubleConversion() {
    let x1: Double = 34134342324888777666555444333.1343141341341 * 10000000000000000.0
    let y1 = BigInt(x1)
    XCTAssertEqual(x1, y1.doubleValue)
    let x2: Double = -998877665544332211.123456789 * 10000000000000000.0
    let y2 = BigInt(x2)
    XCTAssertEqual(x2, y2.doubleValue)
    let x3 = Double(UInt64.max)
    let y3 = BigInt(x3)
    XCTAssertEqual(x3, y3.doubleValue)
    let x4 = Double(UInt64.max)
    let y4 = BigInt(x4)
    let z4 = BigInt(UInt64.max)
    XCTAssertEqual(y4.doubleValue, z4.doubleValue)
  }
  
  func testFloatConversion() {
    let x0: Float = 34133.134314134134132
    let y0 = BigInt(exactly: x0)
    XCTAssertEqual(y0, nil)
    let x1: Float = 34134342324888777633.1343141341341 * 1000000000000.0
    let y1 = BigInt(exactly: x1)
    XCTAssertEqual(Double(x1), (y1 ?? BigInt.zero).doubleValue)
    let x2: Float = -998877665544332211.123456789 * 10000000000000000.0
    let y2 = BigInt(x2)
    XCTAssertEqual(Double(x2), y2.doubleValue)
    let x3 = Float(Int64.min)
    let y3 = BigInt(x3)
    XCTAssertEqual(Double(x3), y3.doubleValue)
  }
  
  func testAnd() {
    let x0: BigInt = "13"
    let y0: BigInt = "-234245400000000001111"
    XCTAssertEqual(x0.and(y0), BigInt(9))
    let x1: BigInt = "234245400000000001111"
    let y1: BigInt = "-9846504850258720458"
    let z1: BigInt = "224984655330917548054"
    XCTAssertEqual(x1.and(y1), z1)
    XCTAssertEqual(BigInt(-1).and(BigInt(-2)), BigInt(-2))
    let x2: BigInt = "-542455245094524566901"
    let y2: BigInt = "-542455245094524566900"
    let z2: BigInt = "-542455245094524566904"
    XCTAssertEqual(x2.and(y2), z2)
    let x3: BigInt = "9087536870576087630587630586735"
    let y3: BigInt = "-783098795876350358367035603567035670358"
    let z3: BigInt = "8879166037613449274055524745258"
    XCTAssertEqual(x3.and(y3), z3)
    let x4: BigInt = "-98040972987924857928456297456297659276249762976245659762459"
    let y4: BigInt = "9864520842504292089860983506873560870"
    let z4: BigInt = "58540432875177786070779388280897572"
    XCTAssertEqual(x4.and(y4), z4)
    let x5: BigInt = "-31"
    let y5: BigInt = "-4444335366627281172636646645342263748485595"
    let z5: BigInt = "-4444335366627281172636646645342263748485599"
    XCTAssertEqual(x5.and(y5), z5)
    let x6: BigInt = "-3453452461354444335366627281172636646645342263748485599"
    let y6: BigInt = "1023"
    let z6: BigInt = "545"
    XCTAssertEqual(x6.and(y6), z6)
  }
  
  func testShifts() {
    let x1: BigInt = "987248974087420857"
    XCTAssertEqual(x1 << 1, x1 * 2)
    let x2: BigInt = "9872489740874208572408572"
    XCTAssertEqual(x2 << 1, x2 * 2)
    let x3: BigInt = "98724897408742085724085724524524524524524522454525245999"
    XCTAssertEqual(x3 << 9, x3 * 2 * 2 * 2 * 2 * 2 * 2 * 2 * 2 * 2)
    let x4: BigInt = "987248974087420857"
    XCTAssertEqual(x4 >> 1, x4 / 2)
    let x5: BigInt = "9872489740874208572408572"
    XCTAssertEqual(x5 >> 1, x5 / 2)
    let x6: BigInt = "98724897408742085724085724524524524524524522454525245999098037580357603865"
    XCTAssertEqual(x6 >> 5, x6 / 32)
    let x7: BigInt = "-234245400000000001111"
    let r7: BigInt = "-1830042187500000009"
    XCTAssertEqual(x7 >> 7, r7)
    let x8: BigInt = "-987248974087420857240857245245245245245245224545252459990980375803576038650"
    let r8: BigInt = "-28732726760424582090952237056488091045910411763041410012839489378"
    XCTAssertEqual(x8 >> 35, r8)
    let x9: BigInt = "-1"
    XCTAssertEqual(x9 >> 1, x9)
    let x10: BigInt = "-2"
    XCTAssertEqual(x10 >> 1, x9)
    let x11: BigInt = "-3"
    XCTAssertEqual(x11 >> 1, x10)
    let x12: BigInt = "-4"
    XCTAssertEqual(x12 >> 1, x10)
    let x13: BigInt = "-100000000000000000000000000000000"
    let r13: BigInt = "-79"
    XCTAssertEqual(x13 >> 100, r13)
    let r14: BigInt = "-126765060022822940149670320537600000000000000000000000000000000"
    XCTAssertEqual(x13 << 100, r14)
    let x15: BigInt = "-9872489740874208572408572"
    let r15: BigInt = "-1356864658148807688588085270081961984"
    XCTAssertEqual(x15 << 37, r15)
    let x16: BigInt = "-111308731087301939383033999999"
    let r16: BigInt = "-131410155234356299897170703642124868710991004696576"
    XCTAssertEqual(x16 << 70, r16)
  }
  
  func testBitCount() {
    let x0: BigInt = "172"
    XCTAssertEqual(x0.bitCount, 4)
    let x1: BigInt = "4285720457204597"
    XCTAssertEqual(x1.bitCount, 31)
    let x2: BigInt = "8708356703856085653607835677770"
    XCTAssertEqual(x2.bitCount, 55)
    let x3: BigInt = "98724897408742085724085724524524524524524522454525245999"
    XCTAssertEqual(x3.bitCount, 100)
    let x4: BigInt = "9872489740874208572408572452452452452452452245452524599909803758035760386501"
    XCTAssertEqual(x4.bitCount, 120)
    let x5: BigInt = "-127"
    XCTAssertEqual(x5.bitCount, -7)
    let x6: BigInt = "-4285720457204597"
    XCTAssertEqual(x6.bitCount, -31)
    let x7: BigInt = "-8708356703856085653607835677770"
    XCTAssertEqual(x7.bitCount, -56)
    let x8: BigInt = "-98724897408742085724085724524524524524524522454525245999"
    XCTAssertEqual(x8.bitCount, -100)
    let x9: BigInt = "-987248974087420857240857245245245245245245224545252459990980375803576038650"
    XCTAssertEqual(x9.bitCount, -115)
  }
  
  func testZeroBits() {
    let x0: BigInt = "170"
    XCTAssertEqual(x0.bitSize, 32)
    XCTAssertEqual(x0.trailingZeroBitCount, 1)
    XCTAssertEqual(x0.firstBitSet, 1)
    let x1: BigInt = "4285720457200"
    XCTAssertEqual(x1.bitSize, 64)
    XCTAssertEqual(x1.trailingZeroBitCount, 4)
    XCTAssertEqual(x1.firstBitSet, 4)
    let x2: BigInt = "-4"
    XCTAssertEqual(x2.trailingZeroBitCount, 2)
    XCTAssertEqual(x2.firstBitSet, 2)
    let x3: BigInt = "81623247908021670355559786741760"
    XCTAssertEqual(x3.trailingZeroBitCount, 74)
    XCTAssertEqual(x3.firstBitSet, 74)
    let x4: BigInt = "-157334116307980970279619537141760"
    XCTAssertEqual(x4.trailingZeroBitCount, 74)
    XCTAssertEqual(x4.firstBitSet, 74)
    XCTAssertEqual(BigInt.zero.trailingZeroBitCount, BigInt.zero.bitWidth)
    XCTAssertEqual(BigInt.zero.firstBitSet, -1)
  }
  
  func testBitTest() {
    let x0: BigInt = "2863311530"
    for i in 0..<32 {
      XCTAssertEqual(x0.isBitSet(i), i.isOdd)
    }
    XCTAssertEqual(x0.isBitSet(32), false)
    XCTAssertEqual(x0.isBitSet(33), false)
    XCTAssertEqual(x0.isBitSet(34), false)
    XCTAssertEqual(x0.isBitSet(35), false)
    XCTAssertEqual(x0.lastBitSet, 32)
    let x1: BigInt = "64942224592110934030034938344746347339829000900128380"
    let bits1: Set<Int> =
      [2, 3, 4, 5, 6, 9, 10, 11, 13, 16, 17, 20, 22, 23, 24, 26, 27, 31, 33, 34, 35, 37,
       38, 39, 41, 43, 44, 47, 48, 49, 50, 52, 54, 55, 59, 65, 68, 71, 72, 75, 77, 78,
       79, 80, 82, 83, 84, 85, 87, 90, 91, 92, 94, 95, 100, 102, 103, 110, 111, 112,
       113, 114, 123, 124, 127, 129, 130, 135, 136, 137, 138, 141, 142, 143, 145,
       148, 149, 150, 151, 152, 154, 158, 160, 161, 164, 167, 168, 170, 171, 173, 175]
    for i in 0..<300 {
      XCTAssertEqual(x1.isBitSet(i), bits1.contains(i))
    }
    XCTAssertEqual(x1.lastBitSet, 176)
    let x2: BigInt = "-1234567894257563210000294749382000039387453720000987383000032"
    let zeros1: Set<Int> =
      [0, 1, 2, 3, 4, 6, 7, 8, 9, 11, 13, 14, 15, 19, 20, 21, 23, 24, 27, 28, 32, 34, 35,
       36, 37, 38, 40, 41, 42, 43, 44, 48, 49, 53, 58, 65, 66, 68, 71, 73, 75, 77, 79,
       80, 81, 82, 85, 86, 88, 90, 92, 95, 96, 98, 99, 101, 102, 105, 106, 107, 108,
       110, 111, 118, 121, 122, 123, 125, 130, 132, 135, 136, 139, 141, 144, 145,
       146, 147, 150, 151, 154, 162, 163, 164, 165, 166, 167, 168, 169, 171, 172,
       173, 177, 180, 183, 184, 186, 187, 189, 191, 194, 198, 199]
    for i in 0..<400 {
      XCTAssertEqual(x2.isBitSet(i), !zeros1.contains(i))
    }
    XCTAssertEqual(x2.lastBitSet, 200)
  }
  
  func testBitSet() {
    var x1 = BigInt.zero
    for i in [2, 3, 4, 5, 6, 9, 10, 11, 13, 16, 17, 20, 22, 23, 24, 26, 27, 31, 33, 34, 35, 37,
              38, 39, 41, 43, 44, 47, 48, 49, 50, 52, 54, 55, 59, 65, 68, 71, 72, 75, 77, 78,
              79, 80, 82, 83, 84, 85, 87, 90, 91, 92, 94, 95, 100, 102, 103, 110, 111, 112,
              113, 114, 123, 124, 127, 129, 130, 135, 136, 137, 138, 141, 142, 143, 145,
              148, 149, 150, 151, 152, 154, 158, 160, 161, 164, 167, 168, 170, 171, 173, 175] {
      x1 = x1.set(bit: i, to: true)
    }
    let y1: BigInt = "64942224592110934030034938344746347339829000900128380"
    XCTAssertEqual(x1, y1)
    XCTAssertEqual(x1.bitSize, y1.bitSize)
  }
  
  func testWords() {
    let x1: BigInt = "39998740587340080087986767562130873870358038157034635280980314708375001"
    XCTAssertEqual(x1.words, [17444856893563336153,
                              10071105391305811219,
                              12534310513326413052,
                              6372167008517,
                              0])
    let x2: BigInt = -x1
    XCTAssertEqual(x2.words, [1001887180146215463,
                              8375638682403740396,
                              5912433560383138563,
                              18446737701542543098,
                              18446744073709551615])
    let x3: BigInt = x1 >> 64
    XCTAssertEqual(x3.words, [10071105391305811219,
                              12534310513326413052,
                              6372167008517,
                              0])
    let x4: BigInt = BigInt(UInt.max)
    XCTAssertEqual(x4.words, [18446744073709551615, 0])
    let x5: BigInt = -x4
    XCTAssertEqual(x5.words, [1,18446744073709551615])
    let x6: BigInt = -x5
    XCTAssertEqual(x6.words, [18446744073709551615, 0])
    let x7: BigInt = BigInt(UInt.max) + 1
    XCTAssertEqual(x7.words, [0, 1, 0])
  }
  
  func testDescription() {
    let x1s = "1234"
    let x1n = BigInt(stringLiteral: x1s)
    XCTAssertEqual(x1n.description, x1s)
    let x2s =
      "9475620485742095824587024587249578098356095863059683095683560358605398039524642958276579245"
    let x2n = BigInt(stringLiteral: x2s)
    XCTAssertEqual(x2n.description, x2s)
    let x3s =
      "-495874504574059783459734085730678509678305968735867305978630697350673056497624524"
    let x3n = BigInt(stringLiteral: x3s)
    XCTAssertEqual(x3n.description, x3s)
  }
  
  static let allTests = [
    ("testConstructors", testConstructors),
    ("testPlus", testPlus),
    ("testMinus", testMinus),
    ("testTimes", testTimes),
    ("testDividedBy", testDividedBy),
    ("testRemainder", testRemainder),
    ("testSqrt", testSqrt),
    ("testPowerOf", testPowerOf),
    ("testDoubleConversion", testDoubleConversion),
    ("testFloatConversion", testFloatConversion),
    ("testAnd", testAnd),
    ("testShifts", testShifts),
    ("testBitCount", testBitCount),
    ("testZeroBits", testZeroBits),
    ("testBitTest", testBitTest),
    ("testBitSet", testBitSet),
    ("testWords", testWords),
    ("testDescription", testDescription),
  ]
}
