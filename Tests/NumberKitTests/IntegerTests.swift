//
//  IntegerTests.swift
//  NumberKit
//
//  Created by Matthias Zenger on 12/04/2024.
//  Copyright © 2024 Matthias Zenger. All rights reserved.
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

class IntegerTests: XCTestCase {
  
  func testConstructors() {
    XCTAssert(Integer(0).intValue == 0)
    XCTAssert(Integer(1).intValue == 1)
    XCTAssert(Integer(-1).intValue == -1)
    XCTAssert(Integer(Int32.max / 3).intValue == Int64(Int32.max / 3))
    XCTAssert(Integer(Int64(Int32.max) * 3).intValue == Int64(Int32.max) * 3)
    XCTAssert(Integer(Int64(Int32.max) * Int64(Int32.max - 17)).intValue ==
              Int64(Int32.max) * Int64(Int32.max - 17))
  }
  
  func testPlus() {
    let x1: Integer = 314159265358979323846264338328
    XCTAssertEqual(x1 + x1, 628318530717958647692528676656)
    XCTAssertEqual(x1 + x1 + x1, 942477796076937971538793014984)
    XCTAssertEqual(x1 + x1 + x1 + x1, 1256637061435917295385057353312)
    XCTAssertEqual(x1 + x1 + x1 + 0 + x1, 1256637061435917295385057353312)
    XCTAssertEqual(x1 + x1 + x1 + 1 + x1, 1256637061435917295385057353313)
    let x2: Integer = 99564370914876591721233850654538777
    XCTAssertEqual(x2 + x2, 199128741829753183442467701309077554)
    XCTAssertEqual(x2 + x2 + 9234567890123456789012345678901234567890,
      9234767018865286542195788146602543645444)
  }
  
  func testPlusLiteral() {
    let x1: Integer = 31415926535897932384626433832809454874529274584894502801830108383756373931835
    XCTAssertEqual(x1 + x1, 62831853071795864769252867665618909749058549169789005603660216767512747863670)
    XCTAssertEqual(x1 + x1 + x1, 94247779607693797153879301498428364623587823754683508405490325151269121795505)
    XCTAssertEqual(x1 + x1 + x1 + x1, 125663706143591729538505735331237819498117098339578011207320433535025495727340)
  }
  
  func testMinus() {
    let x1: Integer = 1134345924505409852113434
    let x2: Integer = 38274945700000001034304000024002450
    XCTAssertEqual(x1 - x2, -38274945698865655109798590171889016)
    XCTAssertEqual(x1 - 17 - x1, -17)
    XCTAssertEqual(x2 - x2, 0)
    XCTAssertEqual(x2 - 517 - x2, -517)
    XCTAssertEqual(x2 + 1 - x2, 1)
    let x3: Integer = 38274945700000001034304000024002449
    XCTAssertEqual(x2 - x3, 1)
    XCTAssertEqual(x3 - x2 + 18, 17)
  }
  
  func testMinusLiteral() {
    let x1: Integer = -9999998765438765432131415926535897932384626433832809454874529274584894502801830108383756373931835
    let x2: Integer = -19999998765438765432131415926535897932384626433832809454874529274584894502801830108383756373931835
    XCTAssertEqual(1 + x1 - x2, 10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001)
    XCTAssertEqual(x1 + x1 + x1, -29999996296316296296394247779607693797153879301498428364623587823754683508405490325151269121795505)
    XCTAssertEqual(-10 + x1 + x1 + x1 + x2, -49999995061755061728525663706143591729538505735331237819498117098339578011207320433535025495727350)
  }
  
  func testTimes() {
    let x1: Integer = 89248574598402980294572048572242498123
    let x2: Integer = 84759720710000012134
    XCTAssertEqual(10 * x1 * x2, 75646842567262381047417645429775912936354166029204722244820)
    let x3: Integer = -846372893840594837726622221119029
    XCTAssertEqual(x1 * x3,
      -75537574353998534693615828134454330968785329792741330257228043492082567)
  }
  
  func testTimesLiteral() {
    let x1: Integer = 89248574598402980294572048572242498123
    let x2: Integer = 84759720710000012134
    XCTAssertEqual(x1 * x2, 7564684256726238104741764542977591293635416602920472224482)
    let x3: Integer = -846372893840594837726622221119029
    XCTAssertEqual(-100 * x1 * 1 * x3,
      7553757435399853469361582813445433096878532979274133025722804349208256700)
  }
  
  func testDividedBy() {
    let x1: Integer = 38274945700000001034304000022452452525224002449
    let x2: Integer = 1234567890123456789
    let r1 = x1.divided(by: x2)
    XCTAssertEqual(r1.quotient, 31002706296024357530217920519)
    XCTAssertEqual(r1.remainder, 654242677691048958)
    let x3: Integer = 3827494570900000103430410002245245252522400244999
    let x4: Integer = 12345678901234567892344542545242452245
    let r2 = x3.divided(by: x4)
    XCTAssertEqual(r2.quotient, 310027063033)
    XCTAssertEqual(r2.remainder, 1772541951990552417813256094292885914)
    XCTAssertEqual(x3 / x3, 1)
    XCTAssertEqual(x3 / (x3 * 10), 0)
  }
  
  func testRemainder() {
    let qp: Integer = 76292485249
    let qn: Integer = -76292485249
    let x1p: Integer = 12
    let x1n: Integer = -12
    let x2p: Integer = 7629248524991
    let x2n: Integer = -7629248524991
    XCTAssert(x1p % qp == x1p)
    XCTAssert(x1n % qp == x1n)
    XCTAssert(x1p % qn == x1p)
    XCTAssert(x1n % qn == x1n)
    let rp: Integer = 91
    let rn: Integer = -91
    XCTAssertEqual(x2p % qp, rp)
    XCTAssertEqual(x2n % qp, rn)
    XCTAssertEqual(x2p % qn, rp)
    XCTAssertEqual(x2n % qn, rn)
  }
  
  func testSqrt() {
    let x1: Integer = 987248974087420857240857208746297469247698798798798700
    XCTAssertEqual(x1.sqrt, 993604032845791572092520365)
    let x2: Integer = 785035630596835096835069835069385609358603956830596835096835069835608390000
    XCTAssertEqual(x2.sqrt, 28018487300295765553963049921800641599)
    let x3: Integer = 1000000000000
    XCTAssertEqual(x3.sqrt, 1000000)
  }
  
  func testPowerOf() {
    let x1: Integer = 84570248572048572408572048572048
    let y1 = x1 * x1 * x1 * x1
    XCTAssert(x1.toPower(of: Integer(4)) == y1)
  }
  
  func testDoubleConversion() {
    let x1: Double = 34134342324888777666555444333.1343141341341 * 10000000000000000.0
    let y1 = Integer(x1)
    XCTAssertEqual(x1, y1.doubleValue)
    let x2: Double = -998877665544332211.123456789 * 10000000000000000.0
    let y2 = Integer(x2)
    XCTAssertEqual(x2, y2.doubleValue)
    let x3 = Double(UInt64.max)
    let y3 = Integer(x3)
    XCTAssertEqual(x3, y3.doubleValue)
    let x4 = Double(UInt64.max)
    let y4 = Integer(x4)
    let z4 = Integer(UInt64.max)
    XCTAssertEqual(y4.doubleValue, z4.doubleValue)
  }
  
  func testFloatConversion() {
    let x0: Float = 34133.134314134134132
    let y0 = Integer(exactly: x0)
    XCTAssertEqual(y0, nil)
    let x1: Float = 34134342324888777633.1343141341341 * 1000000000000.0
    let y1 = Integer(exactly: x1)
    XCTAssertEqual(Double(x1), (y1 ?? Integer.zero).doubleValue)
    let x2: Float = -998877665544332211.123456789 * 10000000000000000.0
    let y2 = Integer(x2)
    XCTAssertEqual(Double(x2), y2.doubleValue)
    let x3 = Float(Int64.min)
    let y3 = Integer(x3)
    XCTAssertEqual(Double(x3), y3.doubleValue)
  }
  
  func testAnd() {
    let x0: Integer = 13
    let y0: Integer = -234245400000000001111
    XCTAssertEqual(x0 & y0, Integer(9))
    let x1: Integer = 234245400000000001111
    let y1: Integer = -9846504850258720458
    let z1: Integer = 224984655330917548054
    XCTAssertEqual(x1 & y1, z1)
    XCTAssertEqual(Integer(-1) & Integer(-2), Integer(-2))
    let x2: Integer = -542455245094524566901
    let y2: Integer = -542455245094524566900
    let z2: Integer = -542455245094524566904
    XCTAssertEqual(x2 & y2, z2)
    let x3: Integer = 9087536870576087630587630586735
    let y3: Integer = -783098795876350358367035603567035670358
    let z3: Integer = 8879166037613449274055524745258
    XCTAssertEqual(x3 & y3, z3)
    let x4: Integer = -98040972987924857928456297456297659276249762976245659762459
    let y4: Integer = 9864520842504292089860983506873560870
    let z4: Integer = 58540432875177786070779388280897572
    XCTAssertEqual(x4 & y4, z4)
    let x5: Integer = -31
    let y5: Integer = -4444335366627281172636646645342263748485595
    let z5: Integer = -4444335366627281172636646645342263748485599
    XCTAssertEqual(x5 & y5, z5)
    let x6: Integer = -3453452461354444335366627281172636646645342263748485599
    let y6: Integer = 1023
    let z6: Integer = 545
    XCTAssertEqual(x6 & y6, z6)
  }
  
  func testShifts() {
    let x1: Integer = 987248974087420857
    XCTAssertEqual(x1 << 1, x1 * 2)
    let x2: Integer = 9872489740874208572408572
    XCTAssertEqual(x2 << 1, x2 * 2)
    let x3: Integer = 98724897408742085724085724524524524524524522454525245999
    XCTAssertEqual(x3 << 9, x3 * 2 * 2 * 2 * 2 * 2 * 2 * 2 * 2 * 2)
    let x4: Integer = 987248974087420857
    XCTAssertEqual(x4 >> 1, x4 / 2)
    let x5: Integer = 9872489740874208572408572
    XCTAssertEqual(x5 >> 1, x5 / 2)
    let x6: Integer = 98724897408742085724085724524524524524524522454525245999098037580357603865
    XCTAssertEqual(x6 >> 5, x6 / 32)
    let x7: Integer = -234245400000000001111
    let r7: Integer = -1830042187500000009
    XCTAssertEqual(x7 >> 7, r7)
    let x8: Integer = -987248974087420857240857245245245245245245224545252459990980375803576038650
    let r8: Integer = -28732726760424582090952237056488091045910411763041410012839489378
    XCTAssertEqual(x8 >> 35, r8)
    let x9: Integer = -1
    XCTAssertEqual(x9 >> 1, x9)
    let x10: Integer = -2
    XCTAssertEqual(x10 >> 1, x9)
    let x11: Integer = -3
    XCTAssertEqual(x11 >> 1, x10)
    let x12: Integer = -4
    XCTAssertEqual(x12 >> 1, x10)
    let x13: Integer = -100000000000000000000000000000000
    let r13: Integer = -79
    XCTAssertEqual(x13 >> 100, r13)
    let r14: Integer = -126765060022822940149670320537600000000000000000000000000000000
    XCTAssertEqual(x13 << 100, r14)
    let x15: Integer = -9872489740874208572408572
    let r15: Integer = -1356864658148807688588085270081961984
    XCTAssertEqual(x15 << 37, r15)
    let x16: Integer = -111308731087301939383033999999
    let r16: Integer = -131410155234356299897170703642124868710991004696576
    XCTAssertEqual(x16 << 70, r16)
  }
  
  func testBitCount() {
    let x0: Integer = 172
    XCTAssertEqual(x0.bitCount, 4)
    let x1: Integer = 4285720457204597
    XCTAssertEqual(x1.bitCount, 31)
    let x2: Integer = 8708356703856085653607835677770
    XCTAssertEqual(x2.bitCount, 55)
    let x3: Integer = 98724897408742085724085724524524524524524522454525245999
    XCTAssertEqual(x3.bitCount, 100)
    let x4: Integer = 9872489740874208572408572452452452452452452245452524599909803758035760386501
    XCTAssertEqual(x4.bitCount, 120)
    let x5: Integer = -127
    XCTAssertEqual(x5.bitCount, -7)
    let x6: Integer = -4285720457204597
    XCTAssertEqual(x6.bitCount, -31)
    let x7: Integer = -8708356703856085653607835677770
    XCTAssertEqual(x7.bitCount, -56)
    let x8: Integer = -98724897408742085724085724524524524524524522454525245999
    XCTAssertEqual(x8.bitCount, -100)
    let x9: Integer = -987248974087420857240857245245245245245245224545252459990980375803576038650
    XCTAssertEqual(x9.bitCount, -115)
  }
  
  func testWords() {
    let x1: Integer = 39998740587340080087986767562130873870358038157034635280980314708375001
    XCTAssertEqual(x1.words, [17444856893563336153,
                              10071105391305811219,
                              12534310513326413052,
                              6372167008517,
                              0])
    let x2: Integer = -x1
    XCTAssertEqual(x2.words, [1001887180146215463,
                              8375638682403740396,
                              5912433560383138563,
                              18446737701542543098,
                              18446744073709551615])
    let x3: Integer = x1 >> 64
    XCTAssertEqual(x3.words, [10071105391305811219,
                              12534310513326413052,
                              6372167008517,
                              0])
    let x4: Integer = Integer(UInt.max)
    XCTAssertEqual(x4.words, [18446744073709551615, 0])
    let x5: Integer = -x4
    XCTAssertEqual(x5.words, [1,18446744073709551615])
    let x6: Integer = -x5
    XCTAssertEqual(x6.words, [18446744073709551615, 0])
    let x7: Integer = Integer(UInt.max) + 1
    XCTAssertEqual(x7.words, [0, 1, 0])
  }
  
  func testRandom() {
    let rnd1 = Integer.random(withMaxBits: 218)
    XCTAssert(rnd1.bitCount <= 218)
    XCTAssert(rnd1.bitSize < 218 + UInt32.bitWidth)
    let rnd2 = Integer.random(withMaxBits: 22)
    XCTAssert(rnd2.bitCount <= 22)
    XCTAssert(rnd2.bitSize < 22 + UInt32.bitWidth)
    let bound: Integer = 9856024857249581231765137423436847588346498948545927456
    let rnd3 = Integer.random(below: bound)
    XCTAssert(rnd3 < bound)
    let bound2: Integer = 123123
    let rnd4 = Integer.random(below: bound2)
    XCTAssert(rnd4 < bound2)
  }
  
  func testBasicOpWithZero() {
    let x1: Integer = 0
    let x2: Integer = -1
    XCTAssertFalse(x1.isNegative)
    XCTAssertFalse(x1.negate.isNegative)
    XCTAssertEqual(x2 + x1, x2)
    XCTAssertEqual(x2 - x1, x2)
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
    ("testWords", testWords)
  ]
}
