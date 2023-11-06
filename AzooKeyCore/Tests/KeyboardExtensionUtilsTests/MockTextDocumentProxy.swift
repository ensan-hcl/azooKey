import UIKit

final class MockTextDocumentProxy: NSObject, UITextDocumentProxy {
    var documentContextBeforeInput: String? {
        let prefix = utf16String.prefix(utf16CursorRange.startPosition)
        return String(utf16CodeUnits: Array(prefix), count: prefix.count)
    }

    var documentContextAfterInput: String? {
        let suffix = utf16String.dropFirst(utf16CursorRange.startPosition + utf16CursorRange.length)
        return String(utf16CodeUnits: Array(suffix), count: suffix.count)
    }

    var selectedText: String? {
        if utf16CursorRange.length == 0 {
            return nil
        } else {
            return String(utf16CodeUnits: Array(utf16String[utf16CursorRange.startPosition ..< utf16CursorRange.startPosition + utf16CursorRange.length]), count: utf16CursorRange.length)
        }
    }

    var documentInputMode: UITextInputMode? = nil

    var documentIdentifier: UUID = UUID()

    var utf16CursorRange = (startPosition: 0, length: 0)
    var utf16String: [UInt16] = []

    func adjustTextPosition(byCharacterOffset offset: Int) {
        if utf16CursorRange.length != 0 {
            utf16CursorRange = (utf16CursorRange.startPosition + utf16CursorRange.length, 0)
        } else {
            utf16CursorRange.startPosition += offset
            utf16CursorRange.startPosition = max(min(utf16CursorRange.startPosition, utf16String.endIndex), 0)
        }
    }

    func setMarkedText(_ markedText: String, selectedRange: NSRange) {
        // do nothing
    }

    func unmarkText() {
        // do nothing
    }

    var hasText: Bool {
        utf16String.isEmpty
    }

    func insertText(_ text: String) {
        if utf16CursorRange.length != 0 {
            utf16String.removeSubrange(utf16CursorRange.startPosition ..< utf16CursorRange.startPosition + utf16CursorRange.length)
            utf16CursorRange.length = 0
        }
        utf16String.insert(contentsOf: text.utf16, at: utf16CursorRange.startPosition)
        utf16CursorRange.startPosition += text.utf16.count
    }

    func deleteBackward() {
        if utf16CursorRange.startPosition == 0 {
            return
        }
        utf16String.remove(at: utf16CursorRange.startPosition - 1)
        utf16CursorRange.startPosition -= 1
    }
}
