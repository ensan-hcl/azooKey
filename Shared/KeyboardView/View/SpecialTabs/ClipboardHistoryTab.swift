//
//  ClipboardHistoryTab.swift
//  azooKey
//
//  Created by ensan on 2023/02/26.
//  Copyright © 2023 ensan. All rights reserved.
//

import SwiftUI

private final class ClipboardHistory: ObservableObject {
    @Published var pinnedItems: [ClipboardHistoryManager.Item] = [] {
        didSet {
            VariableStates.shared.clipboardHistoryManager.items = self.pinnedItems + self.notPinnedItems
        }
    }
    @Published var notPinnedItems: [ClipboardHistoryManager.Item] = [] {
        didSet {
            VariableStates.shared.clipboardHistoryManager.items = self.pinnedItems + self.notPinnedItems
        }
    }
}

struct ClipboardHistoryTab: View {
    @ObservedObject private var variableStates = VariableStates.shared
    @ObservedObject private var target = ClipboardHistory()
    @Environment(\.themeEnvironment) private var theme
    @Environment(\.userActionManager) private var action

    init() {
        for item in VariableStates.shared.clipboardHistoryManager.items {
            if item.pinnedDate != nil {
                self.target.pinnedItems.append(item)
            } else {
                self.target.notPinnedItems.append(item)
            }
        }
        self.target.pinnedItems.sort(by: >)
        self.target.notPinnedItems.sort(by: >)
    }

    private var listRowBackgroundColor: Color {
        ColorTools.hsv(theme.resultBackgroundColor.color) { h, s, v, a in
            Color(hue: h, saturation: s, brightness: min(1, 0.7 * v + 0.3), opacity: min(1, 0.8 * a + 0.2 ))
        } ?? theme.normalKeyFillColor.color
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
                        action.registerAction(.input(string))
                        KeyboardFeedback.click()
                    }
                    .buttonStyle(.bordered)
                }
                .contextMenu {
                    Group {
                        Button {
                            action.registerAction(.input(string))
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
                                self.target.pinnedItems.remove(at: index)
                                var item = item
                                item.pinnedDate = nil
                                self.target.notPinnedItems.append(item)
                                self.target.notPinnedItems.sort(by: >)
                            } label: {
                                Label("固定を解除", systemImage: "pin.slash")
                            }
                        } else {
                            Button {
                                self.target.notPinnedItems.remove(at: index)
                                var item = item
                                item.pinnedDate = Date()
                                self.target.pinnedItems.append(item)
                                self.target.pinnedItems.sort(by: >)
                            } label: {
                                Label("ピンで固定する", systemImage: "pin")
                            }
                        }
                        Button(role: .destructive) {
                            if pinned {
                                self.target.pinnedItems.remove(at: index)
                            } else {
                                self.target.notPinnedItems.remove(at: index)
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
                                    self.target.pinnedItems.remove(at: index)
                                    var item = item
                                    item.pinnedDate = nil
                                    self.target.notPinnedItems.append(item)
                                    self.target.notPinnedItems.sort(by: >)
                                } label: {
                                    Image(systemName: "pin.slash.fill")
                                }
                                .tint(.orange)
                            }
                    }
                    .onDelete { indices in
                        self.target.pinnedItems.remove(atOffsets: indices)
                    }
                }
            }
            Section {
                ForEach(self.target.notPinnedItems.indices, id: \.self) { index in
                    let item = self.target.notPinnedItems[index]
                    listItemView(item, index: index)
                        .swipeActions(edge: .leading) {
                            Button {
                                self.target.notPinnedItems.remove(at: index)
                                var item = item
                                item.pinnedDate = Date()
                                self.target.pinnedItems.append(item)
                                self.target.pinnedItems.sort(by: >)
                            } label: {
                                Image(systemName: "pin.fill")
                            }
                            .tint(.orange)
                        }
                }
                .onDelete { indices in
                    self.target.notPinnedItems.remove(atOffsets: indices)
                }
            }
        }
        .iOS16_scrollContentBackground(.hidden)
    }

    var body: some View {
        Group {
            switch variableStates.keyboardOrientation {
            case .vertical:
                VStack {
                    listView
                    HStack {
                        let design = TabDependentDesign(width: 2, height: 7, layout: .flick, orientation: .vertical)
                        SimpleKeyView(model: SimpleEnterKeyModel(), tabDesign: design)
                        SimpleKeyView(model: SimpleKeyModel(keyType: .functional, keyLabelType: .image("delete.left"), unpressedKeyColorType: .special, pressActions: [.delete(1)], longPressActions: .init(repeat: [.delete(1)])), tabDesign: design)
                    }
                }
            case .horizontal:
                HStack {
                    listView
                    VStack {
                        let design = TabDependentDesign(width: 8, height: 2, layout: .flick, orientation: .horizontal)
                        SimpleKeyView(model: SimpleKeyModel(keyType: .functional, keyLabelType: .image("delete.left"), unpressedKeyColorType: .special, pressActions: [.delete(1)], longPressActions: .init(repeat: [.delete(1)])), tabDesign: design)
                        SimpleKeyView(model: SimpleEnterKeyModel(), tabDesign: design)
                    }
                }
            }
        }
        .font(Design.fonts.resultViewFont(theme: theme))
        .foregroundColor(theme.resultTextColor.color)
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
