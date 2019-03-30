//
//  ComplexTests.swift
//  NumberKit
//
//  Created by Matthias Zenger on 16/08/2015.
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


class ComplexTests: XCTestCase {
  
  func testConstructors() {
    let c1: Complex<Double> = 2.0 + 3.0.i
    XCTAssertEqual(c1, Complex(2.0, 3.0))
    let c2 = -1.0 - 2.0.i
    XCTAssertEqual(c2, Complex(-1.0, -2.0))
    let c3: Complex<Double> = 7
    XCTAssertEqual(c3, Complex(7.0))
  }
  
  func testImaginaryInvariant() {
    let c = 1.0.i
    XCTAssertEqual(c * c, -1)
  }
  
  static let allTests = [
    ("testConstructors", testConstructors),
    ("testImaginaryInvariant", testImaginaryInvariant),
  ]
}
