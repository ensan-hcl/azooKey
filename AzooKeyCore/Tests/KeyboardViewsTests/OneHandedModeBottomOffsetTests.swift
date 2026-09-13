import Foundation
@testable import KeyboardViews
import XCTest

final class OneHandedModeBottomOffsetTests: XCTestCase {
    func test_bottomHandleTransfersHeightToBottomOffset() throws {
        let result = try XCTUnwrap(
            OneHandedVerticalResizeResult.movingBottomHandle(
                initialHeight: 240,
                initialBottomOffset: 0,
                translation: -40,
                minimumHeight: 120,
                maximumHeight: 240
            )
        )

        XCTAssertEqual(result.height, 200)
        XCTAssertEqual(result.bottomOffset, 40)
        XCTAssertEqual(result.height + result.bottomOffset, 240)
    }

    func test_bottomHandleCanReturnOffsetToKeyHeight() throws {
        let result = try XCTUnwrap(
            OneHandedVerticalResizeResult.movingBottomHandle(
                initialHeight: 200,
                initialBottomOffset: 40,
                translation: 25,
                minimumHeight: 120,
                maximumHeight: 240
            )
        )

        XCTAssertEqual(result.height, 225)
        XCTAssertEqual(result.bottomOffset, 15)
        XCTAssertEqual(result.height + result.bottomOffset, 240)
    }

    func test_bottomHandleRejectsNegativeOffset() {
        XCTAssertNil(
            OneHandedVerticalResizeResult.movingBottomHandle(
                initialHeight: 200,
                initialBottomOffset: 40,
                translation: 50,
                minimumHeight: 120,
                maximumHeight: 240
            )
        )
    }

    func test_topHandleChangesHeightWithoutChangingBottomOffset() throws {
        let result = try XCTUnwrap(
            OneHandedVerticalResizeResult.movingTopHandle(
                initialHeight: 200,
                bottomOffset: 40,
                translation: 30,
                minimumHeight: 120,
                maximumHeight: 240
            )
        )

        XCTAssertEqual(result.height, 170)
        XCTAssertEqual(result.bottomOffset, 40)
    }

    func test_legacyHeightSettingDecodesWithoutBottomOffset() throws {
        let data = Data(
            #"{"height":240,"userHasOverwrittenKeyboardHeightSetting":true}"#.utf8
        )

        let item = try JSONDecoder().decode(OneHandedModeHeightSettingItem.self, from: data)

        XCTAssertNil(item.bottomOffset)
    }

    func test_settingStoresBottomOffsetAndDiscardsLegacyVerticalPosition() {
        var setting = OneHandedModeSetting()

        setting.set(
            orientation: .vertical,
            size: CGSize(width: 300, height: 200),
            position: CGPoint(x: -30, y: 50),
            bottomOffset: 40
        )

        XCTAssertEqual(setting.bottomOffset(orientation: .vertical), 40)
        XCTAssertEqual(setting.item(orientation: .vertical).position, CGPoint(x: -30, y: 0))
        XCTAssertEqual(setting.bottomOffset(orientation: .horizontal), 0)
    }
}
