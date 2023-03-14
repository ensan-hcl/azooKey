//
//  ClipboardHistoryManager.swift
//  azooKey
//
//  Created by ensan on 2023/02/26.
//  Copyright © 2023 ensan. All rights reserved.
//

import class UIKit.UIPasteboard
import Foundation

final class ClipboardHistoryManager {
    static let maxCount = 50
    struct Item: Equatable, Comparable, Hashable, Codable, Identifiable {
        var content: Content
        var createdData: Date
        var pinnedDate: Date?

        static func == (lhs: ClipboardHistoryManager.Item, rhs: ClipboardHistoryManager.Item) -> Bool {
            lhs.content == rhs.content
        }

        static func < (lhs: ClipboardHistoryManager.Item, rhs: ClipboardHistoryManager.Item) -> Bool {
            if let rPinnedDate = rhs.pinnedDate {
                if let lPinnedDate = lhs.pinnedDate {
                    return lPinnedDate < rPinnedDate
                }
                return true
            }
            return lhs.createdData < rhs.createdData
        }

        var id: Int {
            self.createdData.hashValue
        }
    }
    enum Content: Hashable, Codable {
        case text(String)
    }

    var items: [Item] = []
    private var collapsed = false
    private var previousChangedCount = 0

    private var enabled: Bool {
        @KeyboardSetting(.enableClipboardHistoryManagerTab) var required: Bool
        return required && SemiStaticStates.shared.hasFullAccess
    }

    init() {
        // TODO: メモリ対策をやる必要がある。
        do {
            self.items = try Self.load()
            self.collapsed = false
        } catch {
            debug("ClipboardHistoryManager.init: load failed", error)
            self.items = []
            self.collapsed = true
        }
        self.sort()
    }

    func reload() {
        do {
            let newItems = try Self.load()
            self.items = newItems
            self.collapsed = false
        } catch {
            debug("ClipboardHistoryManager.reload: load failed", error)
            self.collapsed = true
        }
    }

    func save() {
        // 読み込みに失敗している場合は上書きを行わない
        guard !self.collapsed else {
            return
        }
        // 有効化されていなければ上書きしない
        guard self.enabled else {
            return
        }
        do {
            try Self.save(self.items)
        } catch {
            debug("ClipboardHistoryManager.init: save failed", error)
        }
    }

    private func sort() {
        self.items.sort(by: >)
    }

    func checkUpdate() {
        guard self.enabled else {
            return
        }
        if UIPasteboard.general.changeCount == self.previousChangedCount {
            return
        }
        if !UIPasteboard.general.hasStrings {
            return
        }
        self.previousChangedCount = UIPasteboard.general.changeCount

        if let string = UIPasteboard.general.string {
            var item = Item(content: .text(string), createdData: .now)
            if let index = self.items.firstIndex(where: {item.content == $0.content}) {
                let oldItem = self.items.remove(at: index)
                if oldItem.pinnedDate != nil {
                    item.pinnedDate = .now
                }
            }
            if self.items.isEmpty {
                self.items.append(item)
            } else if let index = self.items.firstIndex(where: {item > $0}) {
                self.items.insert(item, at: index)
            }
        }
        // 増えすぎないように削除する
        while self.items.count > Self.maxCount {
            self.items.removeLast()
        }
    }

    private static let directoryURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedStore.appGroupKey)
    private static var historyFileURL: URL? {
        directoryURL?.appendingPathComponent("clipboard_history.json", isDirectory: false)
    }

    static func load() throws -> [Item] {
        guard let historyFileURL else {
            throw IOError.sharedDirectoryInaccessible
        }
        let encoded: Data
        do {
            encoded = try Data(contentsOf: historyFileURL)
        } catch let error as NSError {
            // "No such file or directory"
            if error.code != 260 {
                throw error
            }
            return []
        }
        let items = try JSONDecoder().decode([Item].self, from: encoded)
        return items
    }

    enum IOError: Error {
        /// フルアクセスが存在しない
        case lackFullAccess
        /// 共有ディレクトリにアクセスできない
        case sharedDirectoryInaccessible
    }

    static func save(_ items: [Item]) throws {
        // jsonファイルとして共有空間に保存する
        // FullAccessがない場合は不可能なので`fail`にする
        guard SemiStaticStates.shared.hasFullAccess else {
            throw IOError.lackFullAccess
        }
        guard let historyFileURL else {
            throw IOError.sharedDirectoryInaccessible
        }
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(items)

        try encoded.write(to: historyFileURL)
    }
}

#if DEBUG
extension ClipboardHistoryManager.Content: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .text(let string): return string
        }
    }
}
#endif
