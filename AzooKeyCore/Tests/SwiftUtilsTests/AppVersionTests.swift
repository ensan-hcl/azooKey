//
//  AppVersionTests.swift
//  azooKeyTests
//
//  Created by ensan on 2022/12/19.
//  Copyright © 2022 ensan. All rights reserved.
//

@testable import SwiftUtils
import XCTest

final class AppVersionTests: XCTestCase {

    func testInitFromString() throws {
        do {
            let version = AppVersion("1.9.3")
            XCTAssertNotNil(version)
            XCTAssertEqual(version!.majorVersion, 1)
            XCTAssertEqual(version!.minorVersion, 9)
            XCTAssertEqual(version!.patchVersion, 3)
        }
        do {
            let version = AppVersion("1.10")
            XCTAssertNotNil(version)
            XCTAssertEqual(version!.majorVersion, 1)
            XCTAssertEqual(version!.minorVersion, 10)
            XCTAssertEqual(version!.patchVersion, 0)
        }
        do {
            let version = AppVersion("1")
            XCTAssertNotNil(version)
            XCTAssertEqual(version!.majorVersion, 1)
            XCTAssertEqual(version!.minorVersion, 0)
            XCTAssertEqual(version!.patchVersion, 0)
        }
        do {
            let version = AppVersion("X")
            XCTAssertNil(version)
        }
    }

    func testComparable() throws {
        XCTAssertTrue(AppVersion("1.9.1")! < AppVersion("1.10")!)
        XCTAssertTrue(AppVersion("1.7")! < AppVersion("1.7.1")!)
        XCTAssertTrue(AppVersion("1.10")! < AppVersion("2.1")!)
        XCTAssertFalse(AppVersion("1.9.1")! < AppVersion("1.9.1")!)
        XCTAssertFalse(AppVersion("2.5")! < AppVersion("2.4.9")!)

        XCTAssertTrue(AppVersion("2.5")! > AppVersion("2.4.9")!)
        XCTAssertTrue(AppVersion("3.1")! > AppVersion("1.4.9")!)
        XCTAssertFalse(AppVersion("1.9.1")! > AppVersion("1.9.1")!)
        XCTAssertFalse(AppVersion("1.9.1")! > AppVersion("1.10")!)
        XCTAssertFalse(AppVersion("1.7")! > AppVersion("1.7.1")!)
        XCTAssertFalse(AppVersion("1.10")! > AppVersion("2.1")!)
    }

}
