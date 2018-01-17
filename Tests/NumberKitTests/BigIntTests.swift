//
//  BigIntTests.swift
//  NumberKit
//
//  Created by Matthias Zenger on 11/08/2015.
//  Copyright © 2015-2018 Matthias Zenger. All rights reserved.
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
  }
  
  func testZeroBits() {
    let x0: BigInt = "170"
    XCTAssertEqual(x0.bitSize, 32)
    XCTAssertEqual(x0.trailingZeroBits, 1)
    XCTAssertEqual(x0.leadingZeroBits, 24)
    let x1: BigInt = "4285720457200"
    XCTAssertEqual(x1.bitSize, 64)
    XCTAssertEqual(x1.trailingZeroBits, 4)
    XCTAssertEqual(x1.leadingZeroBits, 22)
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
}
