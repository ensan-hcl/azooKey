//
//  WithMutableValueTests.swift
//  azooKeyTests
//
//  Created by ensan on 2022/12/22.
//  Copyright © 2022 ensan. All rights reserved.
//

import XCTest

final class WithMutableValueTests: XCTestCase {
    func testWithMutableValue() throws {
        var array = [0, 1, 2, 3]
        withMutableValue(&array[1]) { value in
            value = value * value + value / value
        }
        XCTAssertEqual(array, [0, 2, 2, 3])
    }

}
