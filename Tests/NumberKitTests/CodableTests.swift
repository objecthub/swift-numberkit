//
//  CodableTests.swift
//  NumberKitTests
//
//  Created by Matthias Zenger on 08/02/2020.
//  Copyright © 2020 Matthias Zenger. All rights reserved.
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

class CodableTests: XCTestCase {

  func testComplexCodable() {
    let c1: Complex<Double> = 987654.41 - 2.0.i
    XCTAssertEqual(self.recodeJSON(c1), c1)
    let c2: Complex<Double> = 1.5.i
    XCTAssertEqual(self.recodeJSON(c2), c2)
    let c3: Complex<Double> = 0.0
    XCTAssertEqual(self.recodeJSON(c3), c3)
  }
  
  func testRationalCodable() {
    let r1: Rational<Int> = 7/2
    XCTAssertEqual(self.recodeJSON(r1), r1)
    let r2: Rational<Int> = 7654321
    XCTAssertEqual(self.recodeJSON(r2), r2)
    let r3: Rational<Int> = 0
    XCTAssertEqual(self.recodeJSON(r3), r3)
  }
  
  func testBigIntCodable() {
    let x1: BigInt = "811248574598402980294572048572242498127"
    XCTAssertEqual(self.recodeJSON(x1), x1)
    let x2: BigInt = "847597200"
    XCTAssertEqual(self.recodeJSON(x2), x2)
    let x3: BigInt = "-75537574353998534693615828134454330968785329792741330257228043492082567"
    XCTAssertEqual(self.recodeJSON(x3), x3)
  }
    
  private func recodeJSON<T: Codable>(_ obj: T) -> T? {
    guard let encodedObj = self.encodeJSON(obj) else {
      return nil
    }
    return self.decodeJSON(type(of: obj), encodedObj)
  }
  
  private func encodeJSON<T: Codable>(_ obj: T) -> String? {
    guard let encodedObj = try? JSONEncoder().encode(obj) else {
      return nil
    }
    guard let res = String(data: encodedObj, encoding: .utf8) else {
      return nil
    }
    return res
  }
  
  private func decodeJSON<T: Codable>(_ type: T.Type, _ str: String) -> T? {
    return try? JSONDecoder().decode(type, from: str.data(using: .utf8)!)
  }
  
  static let allTests = [
    ("testComplexCodable", testComplexCodable),
    ("testRationalCodable", testRationalCodable),
    ("testBigIntCodable", testBigIntCodable),
  ]
}
