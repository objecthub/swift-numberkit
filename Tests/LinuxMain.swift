#if os(Linux)

import XCTest
@testable import NumberKitTests

XCTMain(
  [
    testCase(BigIntTests.allTests),
    testCase(ComplexTests.allTests),
    testCase(RationalTests.allTests),
    testCase(NumberUtilTests.allTests),
  ]
)

#endif
