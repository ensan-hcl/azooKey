//
//  ClipboardHistoryTab.swift
//  azooKey
//
//  Created by ensan on 2023/02/26.
//  Copyright © 2023 ensan. All rights reserved.
//

import SwiftUI

private final class ClipboardHistory: ObservableObject {
    @Published private(set) var pinnedItems: [ClipboardHistoryManager.Item] = []
    @Published private(set) var notPinnedItems: [ClipboardHistoryManager.Item] = []

    func updatePinnedItems(variableStates: VariableStates, _ process: (inout [ClipboardHistoryManager.Item]) -> Void) {
        process(&self.pinnedItems)
        variableStates.clipboardHistoryManager.items = self.pinnedItems + self.notPinnedItems
    }
    func updateNotPinnedItems(variableStates: VariableStates, _ process: (inout [ClipboardHistoryManager.Item]) -> Void) {
        process(&self.notPinnedItems)
        variableStates.clipboardHistoryManager.items = self.pinnedItems + self.notPinnedItems
    }
}

struct ClipboardHistoryTab: View {
    @EnvironmentObject private var variableStates: VariableStates
    @ObservedObject private var target = ClipboardHistory()
    @Environment(\.themeEnvironment) private var theme
    @Environment(\.userActionManager) private var action
    @State private var lastInsertedText: (text: String, changedCount: Int)?

    private var listRowBackgroundColor: Color {
        Design.colors.prominentBackgroundColor(theme)
    }

    @ViewBuilder
    private func listItemView(_ item: ClipboardHistoryManager.Item, index: Int, pinned: Bool = false) -> some View {
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
                        self.lastInsertedText = (string, variableStates.textChangedCount)
                        KeyboardFeedback.click()
                    }
                    .buttonStyle(.bordered)
                }
                .contextMenu {
                    Group {
                        Button {
                            action.registerAction(.input(string), variableStates: variableStates)
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
                                self.target.updatePinnedItems(variableStates: variableStates) {
                                    $0.remove(at: index)
                                }
                                var item = item
                                item.pinnedDate = nil
                                self.target.updateNotPinnedItems(variableStates: variableStates) {
                                    $0.append(item)
                                    $0.sort(by: >)
                                }
                            } label: {
                                Label("固定を解除", systemImage: "pin.slash")
                            }
                        } else {
                            Button {
                                self.target.updateNotPinnedItems(variableStates: variableStates) {
                                    $0.remove(at: index)
                                }
                                var item = item
                                item.pinnedDate = Date()
                                self.target.updatePinnedItems(variableStates: variableStates) {
                                    $0.append(item)
                                    $0.sort(by: >)
                                }
                            } label: {
                                Label("ピンで固定する", systemImage: "pin")
                            }
                        }
                        Button(role: .destructive) {
                            if pinned {
                                self.target.updatePinnedItems(variableStates: variableStates) {
                                    $0.remove(at: index)
                                }
                            } else {
                                self.target.updateNotPinnedItems(variableStates: variableStates) {
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
                                    self.target.updatePinnedItems(variableStates: variableStates) {
                                        $0.remove(at: index)
                                    }
                                    var item = item
                                    item.pinnedDate = nil
                                    self.target.updateNotPinnedItems(variableStates: variableStates) {
                                        $0.append(item)
                                        $0.sort(by: >)
                                    }
                                } label: {
                                    Image(systemName: "pin.slash.fill")
                                }
                                .tint(.orange)
                            }
                    }
                    .onDelete { indices in
                        self.target.updatePinnedItems(variableStates: variableStates) {
                            $0.remove(atOffsets: indices)
                        }
                    }
                }
            }
            Section {
                ForEach(self.target.notPinnedItems.indices, id: \.self) { index in
                    let item = self.target.notPinnedItems[index]
                    listItemView(item, index: index)
                        .swipeActions(edge: .leading) {
                            Button {
                                self.target.updateNotPinnedItems(variableStates: variableStates) {
                                    $0.remove(at: index)
                                }
                                var item = item
                                item.pinnedDate = Date()
                                self.target.updatePinnedItems(variableStates: variableStates) {
                                    $0.append(item)
                                    $0.sort(by: >)
                                }
                            } label: {
                                Image(systemName: "pin.fill")
                            }
                            .tint(.orange)
                        }
                }
                .onDelete { indices in
                    self.target.updateNotPinnedItems(variableStates: variableStates) {
                        $0.remove(atOffsets: indices)
                    }
                }
            }
        }
        .iOS16_scrollContentBackground(.hidden)
    }

    private func enterKey(_ design: TabDependentDesign) -> SimpleKeyView {
        SimpleKeyView(model: SimpleEnterKeyModel(), tabDesign: design)
    }
    private func deleteKey(_ design: TabDependentDesign) -> SimpleKeyView {
        SimpleKeyView(model: SimpleKeyModel(keyLabelType: .image("delete.left"), unpressedKeyColorType: .special, pressActions: [.delete(1)], longPressActions: .init(repeat: [.delete(1)])), tabDesign: design)
    }

    private func undoKey(_ design: TabDependentDesign, text: String) -> SimpleKeyView {
        SimpleKeyView(model: SimpleKeyModel(keyLabelType: .text("取り消し"), unpressedKeyColorType: .special, pressActions: [.replaceLastCharacters([text: ""])]), tabDesign: design)
    }

    var body: some View {
        Group {
            switch variableStates.keyboardOrientation {
            case .vertical:
                VStack {
                    listView
                    HStack {
                        if let (text, count) = lastInsertedText, count == variableStates.textChangedCount {
                            let design = TabDependentDesign(width: 3, height: 7, interfaceSize: variableStates.interfaceSize, layout: .flick, orientation: .vertical)
                            enterKey(design)
                            undoKey(design, text: text)
                            deleteKey(design)
                        } else {
                            let design = TabDependentDesign(width: 2, height: 7, interfaceSize: variableStates.interfaceSize, layout: .flick, orientation: .vertical)
                            enterKey(design)
                            deleteKey(design)
                        }
                    }
                }
            case .horizontal:
                HStack {
                    listView
                    VStack {
                        if let (text, count) = lastInsertedText, count == variableStates.textChangedCount {
                            let design = TabDependentDesign(width: 8, height: 3, interfaceSize: variableStates.interfaceSize, layout: .flick, orientation: .horizontal)
                            deleteKey(design)
                            undoKey(design, text: text)
                            enterKey(design)
                        } else {
                            let design = TabDependentDesign(width: 8, height: 2, interfaceSize: variableStates.interfaceSize, layout: .flick, orientation: .horizontal)
                            deleteKey(design)
                            enterKey(design)
                        }
                    }
                }
            }
        }
        .font(Design.fonts.resultViewFont(theme: theme))
        .foregroundColor(theme.resultTextColor.color)
        .onAppear {
            for item in variableStates.clipboardHistoryManager.items {
                if item.pinnedDate != nil {
                    self.target.updatePinnedItems(variableStates: variableStates) {
                        $0.append(item)
                    }
                } else {
                    self.target.updateNotPinnedItems(variableStates: variableStates) {
                        $0.append(item)
                    }
                }
            }
            self.target.updatePinnedItems(variableStates: variableStates) {
                $0.sort(by: >)
            }
            self.target.updateNotPinnedItems(variableStates: variableStates) {
                $0.sort(by: >)
            }
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
