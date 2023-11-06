@testable import KeyboardExtensionUtils
import KanaKanjiConverterModule
import XCTest

final class KeyboardExtensionUtils: XCTestCase {
    @MainActor
    func testOperation() throws {
        let manager = DisplayedTextManager(isLiveConversionEnabled: false, isMarkedTextEnabled: false)
        var composingText = ComposingText()

        let mockProxy = MockTextDocumentProxy()
        manager.setTextDocumentProxy(.mainProxy(mockProxy))

        composingText.insertAtCursorPosition("a", inputStyle: .direct)
        manager.updateComposingText(composingText: composingText, newLiveConversionText: nil)
        XCTAssertEqual(manager.composingText, composingText)
        XCTAssertEqual(mockProxy.documentContextBeforeInput, "a")
        print("Here1")
        composingText.insertAtCursorPosition("b", inputStyle: .direct)
        manager.updateComposingText(composingText: composingText, newLiveConversionText: nil)
        XCTAssertEqual(manager.composingText, composingText)
        XCTAssertEqual(mockProxy.documentContextBeforeInput, "ab")
        print("Here2")
        let _ = composingText.moveCursorFromCursorPosition(count: -1)
        manager.updateComposingText(composingText: composingText, newLiveConversionText: nil)
        XCTAssertEqual(manager.composingText, composingText)
        XCTAssertEqual(mockProxy.documentContextBeforeInput, "a")
        XCTAssertEqual(mockProxy.documentContextAfterInput, "b")
        print("Here3")
        composingText.deleteBackwardFromCursorPosition(count: 1)
        manager.updateComposingText(composingText: composingText, newLiveConversionText: nil)
        XCTAssertEqual(manager.composingText, composingText)
        XCTAssertEqual(mockProxy.documentContextBeforeInput, "")
        XCTAssertEqual(mockProxy.documentContextAfterInput, "b")

        let _ = composingText.moveCursorFromCursorPosition(count: 1)
        manager.updateComposingText(composingText: composingText, newLiveConversionText: nil)
        XCTAssertEqual(manager.composingText, composingText)
        XCTAssertEqual(mockProxy.documentContextBeforeInput, "b")
        XCTAssertEqual(mockProxy.documentContextAfterInput, "")
    }
}
