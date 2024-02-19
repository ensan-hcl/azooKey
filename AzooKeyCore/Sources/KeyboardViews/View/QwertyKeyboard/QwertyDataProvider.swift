//
//  VerticalQwertyKeyboardModel.swift
//  Keyboard
//
//  Created by ensan on 2020/09/18.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import enum CustardKit.TabData

struct QwertyDataProvider<Extension: ApplicationSpecificKeyboardViewExtension> {
    @MainActor static func tabKeys(rowInfo: (normal: Int, functional: Int, space: Int, enter: Int)) -> (languageKey: any QwertyKeyModelProtocol, numbersKey: any QwertyKeyModelProtocol, symbolsKey: any QwertyKeyModelProtocol, changeKeyboardKey: any QwertyKeyModelProtocol) {
        let preferredLanguage = Extension.SettingProvider.preferredLanguage
        let languageKey: any QwertyKeyModelProtocol
        let first = preferredLanguage.first
        if let second = preferredLanguage.second {
            languageKey = QwertySwitchLanguageKeyModel<Extension>(rowInfo: rowInfo, languages: (first, second))
        } else {
            let targetTab: TabData = switch first {
            case .en_US:
                .system(.user_english)
            case .ja_JP:
                .system(.user_japanese)
            case .none, .el_GR:
                .system(.user_japanese)
            }
            languageKey = QwertyFunctionalKeyModel<Extension>(labelType: .text(first.symbol), rowInfo: rowInfo, pressActions: [.moveTab(targetTab)], longPressActions: .none, needSuggestView: false)
        }

        let numbersKey: some QwertyKeyModelProtocol<Extension> = QwertyFunctionalKeyModel(labelType: .image("textformat.123"), rowInfo: rowInfo, pressActions: [.moveTab(.system(.qwerty_numbers))], longPressActions: .init(start: [.setTabBar(.toggle)]))
        let symbolsKey: some QwertyKeyModelProtocol<Extension> = QwertyFunctionalKeyModel(labelType: .text("#+="), rowInfo: rowInfo, pressActions: [.moveTab(.system(.qwerty_symbols))], longPressActions: .init(start: [.setTabBar(.toggle)]))
        let changeKeyboardKeySize: QwertyKeySizeType = .functional(normal: rowInfo.normal, functional: rowInfo.functional, enter: rowInfo.enter, space: rowInfo.space)
        let changeKeyboardKey: any QwertyKeyModelProtocol = if let second = preferredLanguage.second {
            QwertyConditionalKeyModel<Extension>(keySizeType: changeKeyboardKeySize, needSuggestView: false, unpressedKeyColorType: .special) { states in
                if SemiStaticStates.shared.needsInputModeSwitchKey {
                    // 地球儀キーが必要な場合
                    return switch states.tabManager.existentialTab() {
                    case .qwerty_abc:
                        // 英語ではシフトを押したら地球儀キーを表示
                        // leftbottom以外のケースでもこちらを表示する
                        if shiftBehaviorPreference != .leftbottom || (states.boolStates.isShifted || states .boolStates.isCapsLocked) {
                            QwertyChangeKeyboardKeyModel(keySizeType: changeKeyboardKeySize)
                        } else {
                            numbersKey
                        }
                    default: 
                        QwertyChangeKeyboardKeyModel(keySizeType: changeKeyboardKeySize)
                    }
                } else {
                    // 普通のキーで良い場合
                    let targetTab: TabData = switch second {
                    case .en_US:
                        .system(.user_english)
                    case .ja_JP, .none, .el_GR:
                        .system(.user_japanese)
                    }
                    return switch states.tabManager.existentialTab() {
                    case .qwerty_hira:
                        symbolsKey
                    case .qwerty_abc:
                        // 英語ではシフトを押したら#+=キーを表示
                        // leftbottom以外のケースでもこちらを表示する
                        if shiftBehaviorPreference != .leftbottom || (states.boolStates.isShifted || states .boolStates.isCapsLocked) {
                            symbolsKey
                        } else {
                            numbersKey
                        }
                    case .qwerty_numbers, .qwerty_symbols:
                        QwertyFunctionalKeyModel(labelType: .text(second.symbol), rowInfo: rowInfo, pressActions: [.moveTab(targetTab)])
                    default:
                        QwertyFunctionalKeyModel(labelType: .image("arrowtriangle.left.and.line.vertical.and.arrowtriangle.right"), rowInfo: rowInfo, pressActions: [.setCursorBar(.toggle)])
                    }
                }
            }
        } else {
            QwertyConditionalKeyModel<Extension>(keySizeType: changeKeyboardKeySize, needSuggestView: false, unpressedKeyColorType: .special) { states in
                if SemiStaticStates.shared.needsInputModeSwitchKey {
                    // 地球儀キーが必要な場合
                    QwertyChangeKeyboardKeyModel(keySizeType: changeKeyboardKeySize)
                } else {
                    QwertyFunctionalKeyModel(labelType: .image("arrowtriangle.left.and.line.vertical.and.arrowtriangle.right"), rowInfo: rowInfo, pressActions: [.setCursorBar(.toggle)])
                }
            }
        }
        return (
            languageKey: languageKey,
            numbersKey: numbersKey,
            symbolsKey: symbolsKey,
            changeKeyboardKey: changeKeyboardKey
        )
    }

    @MainActor static func spaceKey() -> any QwertyKeyModelProtocol {
        Extension.SettingProvider.useNextCandidateKey ? QwertyNextCandidateKeyModel<Extension>() : QwertySpaceKeyModel<Extension>()
    }
    private enum ShiftBehaviorPreference {
        /// Version 2.2.3から導入。シフトキーは左下に配置
        ///  - 2.2.3以降に初めてシフトキーを使い始めた人はデフォルトでこちら
        ///  - iOS 18以降は全員こちら
        case leftbottom
        /// Version 2.2で導入したが、不評なので挙動を変える予定
        ///  - 2.2.3より前に初めてシフトキーを使い始めた人はこちら
        ///  - ただしiOS 18以降ではこのオプションを削除する
        case left
        /// シフトは使わない（デフォルト）
        case off
    }

    @MainActor
    private static var shiftBehaviorPreference: ShiftBehaviorPreference {
        if #available(iOS 18, *) {
            if Extension.SettingProvider.useShiftKey {
                .leftbottom
            } else {
                .off
            }
        } else {
            if Extension.SettingProvider.useShiftKey {
                if Extension.SettingProvider.keepDeprecatedShiftKeyBehavior {
                    .left
                } else {
                    .leftbottom
                }
            } else {
                .off
            }
        }
    }

    // 横に並べる
    @MainActor static var numberKeyboard: [[any QwertyKeyModelProtocol]] {[
        [
            QwertyKeyModel<Extension>(
                labelType: .text("1"),
                pressActions: [.input("1")],
                variationsModel: VariationsModel([
                    (label: .text("1"), actions: [.input("1")] ),
                    (label: .text("１"), actions: [.input("１")] ),
                    (label: .text("一"), actions: [.input("一")] ),
                    (label: .text("①"), actions: [.input("①")] )

                ], direction: .right)
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("2"),
                pressActions: [.input("2")],
                variationsModel: VariationsModel([
                    (label: .text("2"), actions: [.input("2")] ),
                    (label: .text("２"), actions: [.input("２")] ),
                    (label: .text("二"), actions: [.input("二")] ),
                    (label: .text("②"), actions: [.input("②")] )

                ], direction: .right)
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("3"),
                pressActions: [.input("3")],
                variationsModel: VariationsModel([
                    (label: .text("3"), actions: [.input("3")] ),
                    (label: .text("３"), actions: [.input("３")] ),
                    (label: .text("三"), actions: [.input("三")] ),
                    (label: .text("③"), actions: [.input("③")] )

                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("4"),
                pressActions: [.input("4")],
                variationsModel: VariationsModel([
                    (label: .text("4"), actions: [.input("4")] ),
                    (label: .text("４"), actions: [.input("４")] ),
                    (label: .text("四"), actions: [.input("四")] ),
                    (label: .text("④"), actions: [.input("④")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("5"),
                pressActions: [.input("5")],
                variationsModel: VariationsModel([
                    (label: .text("5"), actions: [.input("5")] ),
                    (label: .text("５"), actions: [.input("５")] ),
                    (label: .text("五"), actions: [.input("五")] ),
                    (label: .text("⑤"), actions: [.input("⑤")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("6"),
                pressActions: [.input("6")],
                variationsModel: VariationsModel([
                    (label: .text("6"), actions: [.input("6")] ),
                    (label: .text("６"), actions: [.input("６")] ),
                    (label: .text("六"), actions: [.input("六")] ),
                    (label: .text("⑥"), actions: [.input("⑥")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("7"),
                pressActions: [.input("7")],
                variationsModel: VariationsModel([
                    (label: .text("7"), actions: [.input("7")] ),
                    (label: .text("７"), actions: [.input("７")] ),
                    (label: .text("七"), actions: [.input("七")] ),
                    (label: .text("⑦"), actions: [.input("⑦")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("8"),
                pressActions: [.input("8")],
                variationsModel: VariationsModel([
                    (label: .text("8"), actions: [.input("8")] ),
                    (label: .text("８"), actions: [.input("８")] ),
                    (label: .text("八"), actions: [.input("八")] ),
                    (label: .text("⑧"), actions: [.input("⑧")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("9"),
                pressActions: [.input("9")],
                variationsModel: VariationsModel([
                    (label: .text("9"), actions: [.input("9")] ),
                    (label: .text("９"), actions: [.input("９")] ),
                    (label: .text("九"), actions: [.input("九")] ),
                    (label: .text("⑨"), actions: [.input("⑨")] )
                ], direction: .left)
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("0"),
                pressActions: [.input("0")],
                variationsModel: VariationsModel([
                    (label: .text("0"), actions: [.input("0")] ),
                    (label: .text("０"), actions: [.input("０")] ),
                    (label: .text("〇"), actions: [.input("〇")] ),
                    (label: .text("⓪"), actions: [.input("⓪")] )
                ], direction: .left)
            )
        ],
        [
            QwertyKeyModel<Extension>(labelType: .text("-"), pressActions: [.input("-")]),
            QwertyKeyModel<Extension>(
                labelType: .text("/"),
                pressActions: [.input("/")],
                variationsModel: VariationsModel([
                    (label: .text("/"), actions: [.input("/")] ),
                    (label: .text("\\"), actions: [.input("\\")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text(":"),
                pressActions: [.input(":")],
                variationsModel: VariationsModel([
                    (label: .text(":"), actions: [.input(":")] ),
                    (label: .text("："), actions: [.input("：")] ),
                    (label: .text(";"), actions: [.input(";")] ),
                    (label: .text("；"), actions: [.input("；")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("@"),
                pressActions: [.input("@")],
                variationsModel: VariationsModel([
                    (label: .text("@"), actions: [.input("@")] ),
                    (label: .text("＠"), actions: [.input("＠")] )
                ])
            ),
            QwertyKeyModel<Extension>(labelType: .text("("), pressActions: [.input("(")]),
            QwertyKeyModel<Extension>(labelType: .text(")"), pressActions: [.input(")")]),
            QwertyKeyModel<Extension>(
                labelType: .text("「"),
                pressActions: [.input("「")],
                variationsModel: VariationsModel([
                    (label: .text("「"), actions: [.input("「")] ),
                    (label: .text("『"), actions: [.input("『")] ),
                    (label: .text("【"), actions: [.input("【")] ),
                    (label: .text("（"), actions: [.input("（")] ),
                    (label: .text("《"), actions: [.input("《")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("」"),
                pressActions: [.input("」")],
                variationsModel: VariationsModel([
                    (label: .text("」"), actions: [.input("」")] ),
                    (label: .text("』"), actions: [.input("』")] ),
                    (label: .text("】"), actions: [.input("】")] ),
                    (label: .text("）"), actions: [.input("）")] ),
                    (label: .text("》"), actions: [.input("》")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("¥"),
                pressActions: [.input("¥")],
                variationsModel: VariationsModel([
                    (label: .text("¥"), actions: [.input("¥")] ),
                    (label: .text("￥"), actions: [.input("￥")] ),
                    (label: .text("$"), actions: [.input("$")] ),
                    (label: .text("＄"), actions: [.input("＄")] ),
                    (label: .text("€"), actions: [.input("€")] ),
                    (label: .text("₿"), actions: [.input("₿")] ),
                    (label: .text("£"), actions: [.input("£")] ),
                    (label: .text("¤"), actions: [.input("¤")] )
                ], direction: .left)
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("&"),
                pressActions: [.input("&")],
                variationsModel: VariationsModel([
                    (label: .text("&"), actions: [.input("&")]),
                    (label: .text("＆"), actions: [.input("＆")])
                ], direction: .left)
            )
        ],

        [
            Self.tabKeys(rowInfo: (7, 2, 0, 0)).symbolsKey
        ] + Extension.SettingProvider.numberTabCustomKeysSetting.compiled(extension: Extension.self) +
        [
            QwertyFunctionalKeyModel<Extension>.delete
        ],

        [
            Self.tabKeys(rowInfo: (0, 2, 1, 1)).languageKey,
            Self.tabKeys(rowInfo: (0, 2, 1, 1)).changeKeyboardKey,
            Self.spaceKey(),
            QwertyEnterKeyModel<Extension>.shared
        ]
    ]
    }
    // 横に並べる
    @MainActor static func symbolsKeyboard() -> [[any QwertyKeyModelProtocol]] {[
        [
            QwertyKeyModel<Extension>(
                labelType: .text("["),
                pressActions: [.input("[")],
                variationsModel: VariationsModel([
                    (label: .text("["), actions: [.input("[")]),
                    (label: .text("［"), actions: [.input("［")])
                ], direction: .right)
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("]"),
                pressActions: [.input("]")],
                variationsModel: VariationsModel([
                    (label: .text("]"), actions: [.input("]")]),
                    (label: .text("］"), actions: [.input("］")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("{"),
                pressActions: [.input("{")],
                variationsModel: VariationsModel([
                    (label: .text("{"), actions: [.input("{")]),
                    (label: .text("｛"), actions: [.input("｛")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("}"),
                pressActions: [.input("}")],
                variationsModel: VariationsModel([
                    (label: .text("}"), actions: [.input("}")]),
                    (label: .text("｝"), actions: [.input("｝")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("#"),
                pressActions: [.input("#")],
                variationsModel: VariationsModel([
                    (label: .text("#"), actions: [.input("#")]),
                    (label: .text("＃"), actions: [.input("＃")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("%"),
                pressActions: [.input("%")],
                variationsModel: VariationsModel([
                    (label: .text("%"), actions: [.input("%")]),
                    (label: .text("％"), actions: [.input("％")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("^"),
                pressActions: [.input("^")],
                variationsModel: VariationsModel([
                    (label: .text("^"), actions: [.input("^")]),
                    (label: .text("＾"), actions: [.input("＾")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("*"),
                pressActions: [.input("*")],
                variationsModel: VariationsModel([
                    (label: .text("*"), actions: [.input("*")]),
                    (label: .text("＊"), actions: [.input("＊")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("+"),
                pressActions: [.input("+")],
                variationsModel: VariationsModel([
                    (label: .text("+"), actions: [.input("+")]),
                    (label: .text("＋"), actions: [.input("＋")]),
                    (label: .text("±"), actions: [.input("±")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("="),
                pressActions: [.input("=")],
                variationsModel: VariationsModel([
                    (label: .text("="), actions: [.input("=")]),
                    (label: .text("＝"), actions: [.input("＝")]),
                    (label: .text("≡"), actions: [.input("≡")]),
                    (label: .text("≒"), actions: [.input("≒")]),
                    (label: .text("≠"), actions: [.input("≠")])
                ], direction: .left)
            )
        ],
        [
            QwertyKeyModel<Extension>(labelType: .text("_"), pressActions: [.input("_")]),
            QwertyKeyModel<Extension>(
                labelType: .text("\\"),
                pressActions: [.input("\\")],
                variationsModel: VariationsModel([
                    (label: .text("/"), actions: [.input("/")] ),
                    (label: .text("\\"), actions: [.input("\\")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text(";"),
                pressActions: [.input(";")],
                variationsModel: VariationsModel([
                    (label: .text(":"), actions: [.input(":")] ),
                    (label: .text("："), actions: [.input("：")] ),
                    (label: .text(";"), actions: [.input(";")] ),
                    (label: .text("；"), actions: [.input("；")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("|"),
                pressActions: [.input("|")],
                variationsModel: VariationsModel([
                    (label: .text("|"), actions: [.input("|")] ),
                    (label: .text("｜"), actions: [.input("｜")] )
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("<"),
                pressActions: [.input("<")],
                variationsModel: VariationsModel([
                    (label: .text("<"), actions: [.input("<")]),
                    (label: .text("＜"), actions: [.input("＜")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text(">"),
                pressActions: [.input(">")],
                variationsModel: VariationsModel([
                    (label: .text(">"), actions: [.input(">")]),
                    (label: .text("＞"), actions: [.input("＞")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("\""),
                pressActions: [.input("\"")],
                variationsModel: VariationsModel([
                    (label: .text("\""), actions: [.input("\"")]),
                    (label: .text("＂"), actions: [.input("＂")]),
                    (label: .text("“"), actions: [.input("“")]),
                    (label: .text("”"), actions: [.input("”")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("'"),
                pressActions: [.input("'")],
                variationsModel: VariationsModel([
                    (label: .text("'"), actions: [.input("'")]),
                    (label: .text("`"), actions: [.input("`")])
                ])
            ),

            QwertyKeyModel<Extension>(
                labelType: .text("$"),
                pressActions: [.input("$")],
                variationsModel: VariationsModel([
                    (label: .text("$"), actions: [.input("$")]),
                    (label: .text("＄"), actions: [.input("＄")])
                ])
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("€"),
                pressActions: [.input("€")],
                variationsModel: VariationsModel([
                    (label: .text("¥"), actions: [.input("¥")] ),
                    (label: .text("￥"), actions: [.input("￥")] ),
                    (label: .text("$"), actions: [.input("$")] ),
                    (label: .text("＄"), actions: [.input("＄")] ),
                    (label: .text("€"), actions: [.input("€")] ),
                    (label: .text("₿"), actions: [.input("₿")] ),
                    (label: .text("£"), actions: [.input("£")] ),
                    (label: .text("¤"), actions: [.input("¤")] )
                ], direction: .left)
            )
        ],

        [
            Self.tabKeys(rowInfo: (7, 2, 0, 0)).numbersKey,
            QwertyKeyModel<Extension>(
                labelType: .text("."),
                pressActions: [.input(".")],
                variationsModel: VariationsModel([
                    (label: .text("。"), actions: [.input("。")] ),
                    (label: .text("."), actions: [.input(".")] )
                ]),
                for: (7, 5)
            ),
            QwertyKeyModel<Extension>(
                labelType: .text(","),
                pressActions: [.input(",")],
                variationsModel: VariationsModel([
                    (label: .text("、"), actions: [.input("、")] ),
                    (label: .text(","), actions: [.input(",")] )
                ]),
                for: (7, 5)),
            QwertyKeyModel<Extension>(
                labelType: .text("?"),
                pressActions: [.input("?")],
                variationsModel: VariationsModel([
                    (label: .text("？"), actions: [.input("？")] ),
                    (label: .text("?"), actions: [.input("?")] )
                ]),
                for: (7, 5)
            ),
            QwertyKeyModel<Extension>(
                labelType: .text("!"),
                pressActions: [.input("!")],
                variationsModel: VariationsModel([
                    (label: .text("！"), actions: [.input("！")] ),
                    (label: .text("!"), actions: [.input("!")] )
                ]),
                for: (7, 5)),
            QwertyKeyModel<Extension>(labelType: .text("・"), pressActions: [.input("…")], for: (7, 5)),
            QwertyFunctionalKeyModel<Extension>.delete
        ],
        [
            Self.tabKeys(rowInfo: (0, 2, 1, 1)).languageKey,
            Self.tabKeys(rowInfo: (0, 2, 1, 1)).changeKeyboardKey,
            Self.spaceKey(),
            QwertyEnterKeyModel<Extension>.shared
        ]
    ]}

    // 横に並べる
    @MainActor static func hiraKeyboard() -> [[any QwertyKeyModelProtocol]] {[
        [
            QwertyKeyModel<Extension>(labelType: .text("q"), pressActions: [.input("q")]),
            QwertyKeyModel<Extension>(labelType: .text("w"), pressActions: [.input("w")]),
            QwertyKeyModel<Extension>(labelType: .text("e"), pressActions: [.input("e")]),
            QwertyKeyModel<Extension>(labelType: .text("r"), pressActions: [.input("r")]),
            QwertyKeyModel<Extension>(labelType: .text("t"), pressActions: [.input("t")]),
            QwertyKeyModel<Extension>(labelType: .text("y"), pressActions: [.input("y")]),
            QwertyKeyModel<Extension>(labelType: .text("u"), pressActions: [.input("u")]),
            QwertyKeyModel<Extension>(labelType: .text("i"), pressActions: [.input("i")]),
            QwertyKeyModel<Extension>(labelType: .text("o"), pressActions: [.input("o")]),
            QwertyKeyModel<Extension>(labelType: .text("p"), pressActions: [.input("p")])
        ],
        [
            QwertyKeyModel<Extension>(labelType: .text("a"), pressActions: [.input("a")]),
            QwertyKeyModel<Extension>(labelType: .text("s"), pressActions: [.input("s")]),
            QwertyKeyModel<Extension>(labelType: .text("d"), pressActions: [.input("d")]),
            QwertyKeyModel<Extension>(labelType: .text("f"), pressActions: [.input("f")]),
            QwertyKeyModel<Extension>(labelType: .text("g"), pressActions: [.input("g")]),
            QwertyKeyModel<Extension>(labelType: .text("h"), pressActions: [.input("h")]),
            QwertyKeyModel<Extension>(labelType: .text("j"), pressActions: [.input("j")]),
            QwertyKeyModel<Extension>(labelType: .text("k"), pressActions: [.input("k")]),
            QwertyKeyModel<Extension>(labelType: .text("l"), pressActions: [.input("l")]),
            QwertyKeyModel<Extension>(
                labelType: .text("ー"),
                pressActions: [.input("ー")],
                variationsModel: VariationsModel(
                    [
                        (label: .text("ー"), actions: [.input("ー")]),
                        (label: .text("。"), actions: [.input("。")]),
                        (label: .text("、"), actions: [.input("、")]),
                        (label: .text("！"), actions: [.input("！")]),
                        (label: .text("？"), actions: [.input("？")]),
                        (label: .text("・"), actions: [.input("・")]),
                    ],
                    direction: .left
                )
            )
        ],
        [
            Self.tabKeys(rowInfo: (7, 2, 0, 0)).languageKey,
            QwertyKeyModel<Extension>(labelType: .text("z"), pressActions: [.input("z")]),
            QwertyKeyModel<Extension>(labelType: .text("x"), pressActions: [.input("x")]),
            QwertyKeyModel<Extension>(labelType: .text("c"), pressActions: [.input("c")]),
            QwertyKeyModel<Extension>(labelType: .text("v"), pressActions: [.input("v")]),
            QwertyKeyModel<Extension>(labelType: .text("b"), pressActions: [.input("b")]),
            QwertyKeyModel<Extension>(labelType: .text("n"), pressActions: [.input("n")]),
            QwertyKeyModel<Extension>(labelType: .text("m"), pressActions: [.input("m")]),
            QwertyFunctionalKeyModel<Extension>.delete
        ],
        [
            Self.tabKeys(rowInfo: (0, 2, 1, 1)).numbersKey,
            Self.tabKeys(rowInfo: (0, 2, 1, 1)).changeKeyboardKey,
            Self.spaceKey(),
            QwertyEnterKeyModel<Extension>.shared
        ]
    ]}

    // 横に並べる
    @MainActor static func abcKeyboard() -> [[any QwertyKeyModelProtocol]] {[
        [
            QwertyKeyModel<Extension>(labelType: .text("q"), pressActions: [.input("q")]),
            QwertyKeyModel<Extension>(labelType: .text("w"), pressActions: [.input("w")]),
            QwertyKeyModel<Extension>(labelType: .text("e"), pressActions: [.input("e")]),
            QwertyKeyModel<Extension>(labelType: .text("r"), pressActions: [.input("r")]),
            QwertyKeyModel<Extension>(labelType: .text("t"), pressActions: [.input("t")]),
            QwertyKeyModel<Extension>(labelType: .text("y"), pressActions: [.input("y")]),
            QwertyKeyModel<Extension>(labelType: .text("u"), pressActions: [.input("u")]),
            QwertyKeyModel<Extension>(labelType: .text("i"), pressActions: [.input("i")]),
            QwertyKeyModel<Extension>(labelType: .text("o"), pressActions: [.input("o")]),
            QwertyKeyModel<Extension>(labelType: .text("p"), pressActions: [.input("p")])
        ],
        // offの場合は一番右にAaキーを、leftの場合は一番左にShiftキーを、leftbottomの場合は一番右にピリオドキーを置く
        {
            let core: [any QwertyKeyModelProtocol] = [
                QwertyKeyModel<Extension>(labelType: .text("a"), pressActions: [.input("a")]),
                QwertyKeyModel<Extension>(labelType: .text("s"), pressActions: [.input("s")]),
                QwertyKeyModel<Extension>(labelType: .text("d"), pressActions: [.input("d")]),
                QwertyKeyModel<Extension>(labelType: .text("f"), pressActions: [.input("f")]),
                QwertyKeyModel<Extension>(labelType: .text("g"), pressActions: [.input("g")]),
                QwertyKeyModel<Extension>(labelType: .text("h"), pressActions: [.input("h")]),
                QwertyKeyModel<Extension>(labelType: .text("j"), pressActions: [.input("j")]),
                QwertyKeyModel<Extension>(labelType: .text("k"), pressActions: [.input("k")]),
                QwertyKeyModel<Extension>(labelType: .text("l"), pressActions: [.input("l")]),
            ]
            return switch shiftBehaviorPreference {
            case .leftbottom:
                core + [QwertyKeyModel<Extension>(
                    labelType: .text("."),
                    pressActions: [.input(".")],
                    variationsModel: VariationsModel(
                        [
                            (label: .text("."), actions: [.input(".")]),
                            (label: .text(","), actions: [.input(",")]),
                            (label: .text("!"), actions: [.input("!")]),
                            (label: .text("?"), actions: [.input("?")]),
                            (label: .text("'"), actions: [.input("'")]),
                            (label: .text("\""), actions: [.input("\"")]),
                        ],
                        direction: .left
                    )
                )]
            case .left:
                [QwertyShiftKeyModel<Extension>.shared] + core
            case .off:
                core + [QwertyAaKeyModel<Extension>.shared]
        }}(),
        [
            Self.tabKeys(rowInfo: (7, 2, 0, 0)).languageKey,
            QwertyKeyModel<Extension>(labelType: .text("z"), pressActions: [.input("z")]),
            QwertyKeyModel<Extension>(labelType: .text("x"), pressActions: [.input("x")]),
            QwertyKeyModel<Extension>(labelType: .text("c"), pressActions: [.input("c")]),
            QwertyKeyModel<Extension>(labelType: .text("v"), pressActions: [.input("v")]),
            QwertyKeyModel<Extension>(labelType: .text("b"), pressActions: [.input("b")]),
            QwertyKeyModel<Extension>(labelType: .text("n"), pressActions: [.input("n")]),
            QwertyKeyModel<Extension>(labelType: .text("m"), pressActions: [.input("m")]),
            QwertyFunctionalKeyModel<Extension>.delete
        ],
        [
            // left, offの場合は単にnumbersKeyを表示し、leftbottomの場合はシフトキーをこの位置に表示する
            {switch shiftBehaviorPreference {
            case .left, .off: Self.tabKeys(rowInfo: (0, 2, 1, 1)).numbersKey
            case .leftbottom: QwertyShiftKeyModel<Extension>(keySizeType: .functional(normal: 0, functional: 2, enter: 1, space: 1))
            }}(),
            Self.tabKeys(rowInfo: (0, 2, 1, 1)).changeKeyboardKey,
            Self.spaceKey(),
            QwertyEnterKeyModel<Extension>.shared
        ]
    ]}
}
