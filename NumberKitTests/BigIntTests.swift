//
//  BigIntTests.swift
//  NumberKit
//
//  Created by Matthias Zenger on 11/08/2015.
//  Copyright © 2015 Matthias Zenger. All rights reserved.
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
    let r1 = x1.dividedBy(x2)
    XCTAssert(r1.quotient == "31002706296024357530217920519")
    XCTAssert(r1.remainder == "654242677691048958")
    let x3: BigInt = "3827494570900000103430410002245245252522400244999"
    let x4: BigInt = "12345678901234567892344542545242452245"
    let r2 = x3.dividedBy(x4)
    XCTAssert(r2.quotient == "310027063033")
    XCTAssert(r2.remainder == "1772541951990552417813256094292885914")
    XCTAssert(x3 / x3 == 1)
    XCTAssert(x3 / (x3.times(10)) == 0)
  }
}
