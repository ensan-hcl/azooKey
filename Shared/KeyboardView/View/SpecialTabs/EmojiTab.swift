//
//  EmojiTab.swift
//  azooKey
//
//  Created by ensan on 2023/03/15.
//  Copyright © 2023 ensan. All rights reserved.
//

import SwiftUI

struct EmojiTab: View {
    @ObservedObject private var variableStates = VariableStates.shared
    @Environment(\.themeEnvironment) private var theme

    private struct EmojiData: Identifiable, Hashable {
        static func == (lhs: EmojiTab.EmojiData, rhs: EmojiTab.EmojiData) -> Bool {
            lhs.id == rhs.id
        }

        init(emoji: String, base: String) {
            self.emoji = emoji
            self.base = base
            self.keyModel = EmojiKeyModel(emoji, base: base, unpressedKeyColorType: .unimportant)
            self.id = UUID()
        }

        var id: UUID
        var emoji: String
        var base: String
        var keyModel: EmojiKeyModel

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

    private struct EmojiPreference: Codable {
        var lastUsedDate: Date?
    }

    private enum Genre: UInt8, CaseIterable, Identifiable {
        /// 最近使った絵文字
        case recent

        /// 😁👪👩‍🦼👩‍💻
        case smileys

        /// 🐱🍄☀️🔥
        case natures

        /// ☕️🍰🍉🍞
        case eats

        /// ⚽️🏄🥇🎲
        case activities

        /// 🚗🏔🌊🚥
        case trips

        /// 🗒💽🔍💻
        case items

        /// ♌️❤️💮🎵
        case symbols

        /// 🏳️‍🌈🇯🇵🇺🇳🇰🇷
        case flags

        var id: UInt8 {
            self.rawValue
        }

        var icon: String {
            switch self {
            case .smileys:
                return "face.smiling"
            case .natures:
                return "fish"
            case .eats:
                return "fork.knife"
            case .activities:
                return "soccerball"
            case .trips:
                return "building.columns"
            case .items:
                return "lightbulb"
            case .symbols:
                return "exclamationmark.questionmark"
            case .flags:
                return "flag"
            case .recent:
                return "clock"
            }
        }

        var title: LocalizedStringKey {
            switch self {
            case .smileys:
                return "顔と感情"
            case .natures:
                return "生き物と自然"
            case .eats:
                return "食事"
            case .activities:
                return "アクティビティ"
            case .trips:
                return "旅行と場所"
            case .items:
                return "物"
            case .symbols:
                return "記号"
            case .flags:
                return "旗"
            case .recent:
                return "よく使う絵文字"
            }
        }
    }

    /// 参考用
    private var keysHeight: CGFloat {
        TabDependentDesign(width: 1, height: 1, layout: .qwerty, orientation: VariableStates.shared.keyboardOrientation).keysHeight
    }

    private var scrollViewHeight: CGFloat {
        keysHeight * 0.85
    }

    private var footerHeight: CGFloat {
        keysHeight * 0.15
    }

    private var verticalCount: Int {
        switch VariableStates.shared.keyboardOrientation {
        case .vertical: return 5
        case .horizontal: return 3
        }
    }

    private var allGenre: [Genre] {
        Genre.allCases.sorted(by: {$0.rawValue < $1.rawValue})
    }

    @State private var emojis: [Genre: [EmojiData]] = Self.getEmojis()

    @State private var selectedGenre: Genre?

    // 正方形のキーにする
    private var keySize: CGFloat {
        scrollViewHeight / CGFloat(verticalCount)
    }

    private static func getEmojiDataItem(for emoji: String, replacements: [String: String]) -> EmojiData {
        .init(emoji: replacements[emoji, default: emoji], base: emoji)
    }

    private static func getEmojis() -> [Genre: [EmojiData]] {
        let fileURL: URL
        // 読み込むファイルはバージョンごとに変更する必要がある
        if #available(iOS 16.4, *) {
            fileURL = Bundle.main.bundleURL.appendingPathComponent("emoji_genre_E15.0.txt.gen", isDirectory: false)
        } else if #available(iOS 15.4, *) {
            fileURL = Bundle.main.bundleURL.appendingPathComponent("emoji_genre_E14.0.txt.gen", isDirectory: false)
        } else {
            fileURL = Bundle.main.bundleURL.appendingPathComponent("emoji_genre_E13.1.txt.gen", isDirectory: false)
        }
        let genres: [String: Genre] = [
            "Symbols": .symbols,
            "Flags": .flags,
            "Food & Drink": .eats,
            "Smileys & People": .smileys,
            "Activities": .activities,
            "Animals & Nature": .natures,
            "Travel & Places": .trips,
            "Objects": .items
        ]
        var emojis: [Genre: [String]] = [:]
        do {
            let string = try String(contentsOf: fileURL, encoding: .utf8)
            let lines = string.split(separator: "\n")
            for line in lines {
                let splited = line.split(separator: "\t", omittingEmptySubsequences: false)
                guard splited.count == 2 else {
                    debug("error", line)
                    return [:]
                }
                guard let genre = genres[String(splited[0])] else {
                    debug("unknown genre", line)
                    return [:]
                }
                emojis[genre, default: []].append(contentsOf: splited[1].split(separator: ",").map(String.init))
            }
        } catch {
            debug(error)
            return [:]
        }
        let preference = KeyboardInternalSetting.shared.tabCharacterPreference
        let recentlyUseed = preference.getRecentlyUsed(for: .system(.emoji), count: 29)
        emojis[.recent] = recentlyUseed

        let replacements = preference.getPreferences(for: .system(.emoji))
        return emojis.mapValues {
            $0.map {
                getEmojiDataItem(for: $0, replacements: replacements)
            }
        }
    }

    private func deleteKey() -> SimpleKeyView {
        SimpleKeyView(model: SimpleKeyModel(keyType: .functional, keyLabelType: .image("delete.left"), unpressedKeyColorType: .special, pressActions: [.delete(1)], longPressActions: .init(repeat: [.delete(1)])), width: footerHeight, height: footerHeight)
    }

    private func searchKey() -> SimpleKeyView {
        SimpleKeyView(model: SimpleKeyModel(keyType: .functional, keyLabelType: .image("magnifyingglass"), unpressedKeyColorType: .special, pressActions: [], longPressActions: .none), width: footerHeight, height: footerHeight)
    }

    private func tabBarKey() -> SimpleKeyView {
        SimpleKeyView(model: SimpleKeyModel(keyType: .functional, keyLabelType: .image("list.bullet"), unpressedKeyColorType: .special, pressActions: [.setTabBar(.toggle)], longPressActions: .none), width: footerHeight, height: footerHeight)
    }

    private func backTabKey() -> SimpleKeyView {
        SimpleKeyView(model: SimpleKeyModel(keyType: .functional, keyLabelType: .image("arrow.uturn.backward"), unpressedKeyColorType: .special, pressActions: [.moveTab(.last_tab)], longPressActions: .none), width: footerHeight, height: footerHeight)
    }

    private func genreKey(_ genre: Genre) -> some View {
        Button {
            self.selectedGenre = genre
        } label: {
            KeyLabel(.image(genre.icon), width: 10)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { proxy in
                    let gridItem = GridItem(.fixed(keySize), spacing: 0)
                    LazyHGrid(rows: Array(repeating: gridItem, count: verticalCount), spacing: 0) {
                        ForEach(allGenre) { genre in
                            let models = self.emojis[genre, default: []]
                            if !models.isEmpty {
                                Section {
                                    SimpleKeyView(model: SimpleKeyModel(keyType: .normal, keyLabelType: .image(genre.icon), unpressedKeyColorType: .selected, pressActions: []), width: keySize, height: keySize)
                                    ForEach(models) {model in
                                        SimpleKeyView(model: model.keyModel, width: keySize, height: keySize)
                                    }
                                } footer: {
                                    Spacer()
                                }
                            }
                        }
                    }
                    .onChange(of: selectedGenre) { newValue in
                        if let newValue {
                            proxy.scrollTo(newValue, anchor: .leading)
                        }
                    }
                    .padding(.vertical, 0)
                    .padding(.horizontal, 5)
                }
            }
            .frame(height: scrollViewHeight)

            HStack {
                backTabKey()
                tabBarKey()
                ForEach(allGenre, id: \.self) { genre in
                    if !self.emojis[genre, default: []].isEmpty {
                        genreKey(genre)
                    }
                }
                deleteKey()
                searchKey()
            }
            .labelStyle(.iconOnly)
            .frame(height: footerHeight)
        }
        .onChange(of: variableStates.lastTabCharacterPreferenceUpdate) { _ in
            self.emojis = Self.getEmojis()
        }
    }
}

private struct EmojiKeyModel: SimpleKeyModelProtocol {
    init(_ emoji: String, base: String, unpressedKeyColorType: SimpleUnpressedKeyColorType, longPressActions: LongpressActionType = .none) {
        self.emoji = emoji
        self.base = base
        self.unpressedKeyColorType = unpressedKeyColorType
        self.longPressActions = longPressActions
    }

    private var emoji: String
    private var base: String
    let unpressedKeyColorType: SimpleUnpressedKeyColorType
    let longPressActions: LongpressActionType
    var keyLabelType: KeyLabelType {
        .text(emoji)
    }

    var pressActions: [ActionType] {
        [.input(emoji)]
    }

    func label(width: CGFloat, states: VariableStates, theme: ThemeData) -> KeyLabel {
        KeyLabel(self.keyLabelType, width: width, textSize: .max)
    }

    func additionalOnPress() {
        KeyboardInternalSetting.shared.update(\.tabCharacterPreference) { value in
            value.setUsed(base: self.base, for: .system(.emoji))
            VariableStates.shared.lastTabCharacterPreferenceUpdate = .now
        }
    }
}
