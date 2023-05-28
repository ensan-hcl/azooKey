//
//  ClipboardHistoryTab.swift
//  azooKey
//
//  Created by ensan on 2023/02/26.
//  Copyright © 2023 ensan. All rights reserved.
//

import SwiftUI
import SwiftUIUtils
import SwiftUtils

private final class ClipboardHistory: ObservableObject {
    @Published private(set) var pinnedItems: [ClipboardHistoryManager.Item] = []
    @Published private(set) var notPinnedItems: [ClipboardHistoryManager.Item] = []

    func updatePinnedItems(manager: inout ClipboardHistoryManager, _ process: (inout [ClipboardHistoryManager.Item]) -> Void) {
        var copied = self.pinnedItems
        process(&copied)
        manager.items = copied + self.notPinnedItems
    }
    func updateNotPinnedItems(manager: inout ClipboardHistoryManager, _ process: (inout [ClipboardHistoryManager.Item]) -> Void) {
        var copied = self.notPinnedItems
        process(&copied)
        manager.items = self.pinnedItems + copied
    }
    func updateBothItems(manager: inout ClipboardHistoryManager, _ process: (inout [ClipboardHistoryManager.Item], inout [ClipboardHistoryManager.Item]) -> Void) {
        var pinnedItems = self.pinnedItems
        var notPinnedItems = self.notPinnedItems
        process(&pinnedItems, &notPinnedItems)
        manager.items = pinnedItems + notPinnedItems
    }

    func reload(manager: ClipboardHistoryManager) {
        self.pinnedItems = []
        self.notPinnedItems = []
        for item in manager.items {
            if item.pinnedDate != nil {
                self.pinnedItems.append(item)
            } else {
                self.notPinnedItems.append(item)
            }
        }
        self.pinnedItems.sort(by: >)
        self.notPinnedItems.sort(by: >)
        debug("reload", manager.items)
    }
}

struct ClipboardHistoryTab: View {
    @EnvironmentObject private var variableStates: VariableStates
    @StateObject private var target = ClipboardHistory()
    @Environment(\.themeEnvironment) private var theme
    @Environment(\.userActionManager) private var action

    private var listRowBackgroundColor: Color {
        Design.colors.prominentBackgroundColor(theme)
    }

    @ViewBuilder
    private func listItemView(_ item: ClipboardHistoryManager.Item, index: Int?, pinned: Bool = false) -> some View {
        Group {
            switch item.content {
            case .text(let string):
                HStack {
                    if string.hasPrefix("https://") || string.hasPrefix("http://"), let url = URL(string: string) {
                        RichLinkView(url: url, options: [.icon])
                            .padding(.vertical, 2)
                    } else {
                        if pinned {
                            HStack {
                                Image(systemName: "pin.circle.fill")
                                    .foregroundColor(.orange)
                                Text(string)
                                    .lineLimit(2)
                            }
                        } else {
                            Text(string)
                                .lineLimit(2)
                        }
                    }
                    Spacer()
                    Button("入力") {
                        action.registerAction(.input(string), variableStates: variableStates)
                        variableStates.undoAction = .init(action: .replaceLastCharacters([string: ""]), textChangedCount: variableStates.textChangedCount)
                        KeyboardFeedback.click()
                    }
                    .buttonStyle(.bordered)
                }
                .contextMenu {
                    Group {
                        Button {
                            action.registerAction(.input(string), variableStates: variableStates)
                            variableStates.undoAction = .init(action: .replaceLastCharacters([string: ""]), textChangedCount: variableStates.textChangedCount)
                        } label: {
                            Label("入力する", systemImage: "text.badge.plus")
                        }
                        Button {
                            UIPasteboard.general.string = string
                        } label: {
                            Label("コピーする", systemImage: "doc.on.doc")
                        }
                        if pinned {
                            Button {
                                guard let index else { return }
                                self.unpinItem(item: item, at: index)
                            } label: {
                                Label("固定を解除", systemImage: "pin.slash")
                            }
                        } else {
                            Button {
                                guard let index else { return }
                                self.pinItem(item: item, at: index)
                            } label: {
                                Label("ピンで固定する", systemImage: "pin")
                            }
                        }
                        Button(role: .destructive) {
                            guard let index else { return }
                            if pinned {
                                self.target.updatePinnedItems(manager: &variableStates.clipboardHistoryManager) {
                                    $0.remove(at: index)
                                }
                            } else {
                                self.target.updateNotPinnedItems(manager: &variableStates.clipboardHistoryManager) {
                                    $0.remove(at: index)
                                }
                            }
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    }
                }

            }
        }
        .listRowBackground(listRowBackgroundColor)
        .listRowInsets(EdgeInsets())
        .padding(.leading, 7)
        .padding(.trailing, 2)
    }

    private var listView: some View {
        List {
            if !self.target.pinnedItems.isEmpty {
                Section {
                    ForEach(self.target.pinnedItems.indices, id: \.self) { index in
                        let item = self.target.pinnedItems[index]
                        listItemView(item, index: index, pinned: true)
                            .swipeActions(edge: .leading) {
                                Button {
                                    self.unpinItem(item: item, at: index)
                                } label: {
                                    Label("固定を解除", systemImage: "pin.slash.fill")
                                        .labelStyle(.iconOnly)
                                }
                                .tint(.orange)
                            }
                    }
                    .onDelete { indices in
                        self.target.updatePinnedItems(manager: &variableStates.clipboardHistoryManager) {
                            $0.remove(atOffsets: indices)
                        }
                    }
                }
            }
            if self.target.notPinnedItems.isEmpty {
                listItemView(.init(content: .text("テキストをコピーするとここに追加されます"), createdData: .now), index: nil)
            } else {
                Section {
                    ForEach(self.target.notPinnedItems.indices, id: \.self) { index in
                        let item = self.target.notPinnedItems[index]
                        listItemView(item, index: index)
                            .swipeActions(edge: .leading) {
                                Button {
                                    self.pinItem(item: item, at: index)
                                } label: {
                                    Label("ピンで固定する", systemImage: "pin.fill")
                                        .labelStyle(.iconOnly)
                                }
                                .tint(.orange)
                            }
                    }
                    .onDelete { indices in
                        self.target.updateNotPinnedItems(manager: &variableStates.clipboardHistoryManager) {
                            $0.remove(atOffsets: indices)
                        }
                    }
                }
            }
        }
        .iOS16_scrollContentBackground(.hidden)
    }

    private func enterKey(_ design: TabDependentDesign) -> some View {
        SimpleKeyView(model: SimpleEnterKeyModel(), tabDesign: design)
    }
    private func deleteKey(_ design: TabDependentDesign) -> some View {
        SimpleKeyView(model: SimpleKeyModel(keyLabelType: .image("delete.left"), unpressedKeyColorType: .special, pressActions: [.delete(1)], longPressActions: .init(repeat: [.delete(1)])), tabDesign: design)
    }

    var body: some View {
        Group {
            switch variableStates.keyboardOrientation {
            case .vertical:
                VStack {
                    listView
                    HStack {
                        let design = TabDependentDesign(width: 2, height: 7, interfaceSize: variableStates.interfaceSize, layout: .flick, orientation: .vertical)
                        enterKey(design)
                        deleteKey(design)
                    }
                }
            case .horizontal:
                HStack {
                    listView
                    VStack {
                        let design = TabDependentDesign(width: 8, height: 2, interfaceSize: variableStates.interfaceSize, layout: .flick, orientation: .horizontal)
                        deleteKey(design)
                        enterKey(design)
                    }
                }
            }
        }
        .font(Design.fonts.resultViewFont(theme: theme))
        .foregroundColor(theme.resultTextColor.color)
        .onAppear {
            self.target.reload(manager: variableStates.clipboardHistoryManager)
        }
        .onChange(of: variableStates.clipboardHistoryManager.items) { _ in
            self.target.reload(manager: variableStates.clipboardHistoryManager)
        }
    }

    private func unpinItem(item: ClipboardHistoryManager.Item, at index: Int) {
        self.target.updateBothItems(manager: &variableStates.clipboardHistoryManager) { (pinned, notPinned) in
            pinned.remove(at: index)
            var item = item
            item.pinnedDate = nil
            notPinned.append(item)
            notPinned.sort(by: >)
        }
    }
    private func pinItem(item: ClipboardHistoryManager.Item, at index: Int) {
        self.target.updateBothItems(manager: &variableStates.clipboardHistoryManager) { (pinned, notPinned) in
            notPinned.remove(at: index)
            var item = item
            item.pinnedDate = .now
            pinned.append(item)
            pinned.sort(by: >)
        }
    }
}

import LinkPresentation

private struct RichLinkView: UIViewRepresentable {
    class UIViewType: LPLinkView {
        override var intrinsicContentSize: CGSize { CGSize(width: 0, height: super.intrinsicContentSize.height) }
    }

    enum MetadataOption: Int8, Equatable {
        case icon, image, video
    }

    var url: URL
    var options: [MetadataOption] = []

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIViewType {
        if let cachedData = MetadataCache.get(urlString: url.absoluteString) {
            return UIViewType(metadata: cachedData)
        }
        return UIViewType(url: url)
    }

    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<Self>) {
        if let cachedData = MetadataCache.get(urlString: url.absoluteString) {
            uiView.metadata = cachedData
            uiView.sizeToFit()
        } else {
            let provider = LPMetadataProvider()
            Task {
                let metadata = try await provider.startFetchingMetadata(for: url)
                if !options.contains(.video) {
                    metadata.videoProvider = nil
                    metadata.remoteVideoURL = nil
                }
                if !options.contains(.image) {
                    metadata.imageProvider = nil
                }
                if !options.contains(.icon) {
                    metadata.iconProvider = nil
                }
                MetadataCache.cache(metadata: metadata)
                Task.detached { @MainActor in
                    uiView.metadata = metadata
                    uiView.sizeToFit()
                }
            }
        }
    }

    struct MetadataCache {
        private static var cache: [String: LPLinkMetadata] = [:]
        static func cache(metadata: LPLinkMetadata) {
            cache[metadata.url!.absoluteString] = metadata
        }

        static func get(urlString: String) -> LPLinkMetadata? {
            cache[urlString]
        }
    }

}
