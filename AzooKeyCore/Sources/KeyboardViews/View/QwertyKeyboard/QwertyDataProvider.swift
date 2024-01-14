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
    @MainActor static func tabKeys(rowInfo: (normal: Int, functional: Int, space: Int, enter: Int)) -> (languageKey: any QwertyKeyModelProtocol<Extension>, numbersKey: any QwertyKeyModelProtocol<Extension>, symbolsKey: any QwertyKeyModelProtocol<Extension>, changeKeyboardKey: any QwertyKeyModelProtocol<Extension>) {
        let preferredLanguage = Extension.SettingProvider.preferredLanguage
        let languageKey: any QwertyKeyModelProtocol<Extension>
        let first = preferredLanguage.first
        if let second = preferredLanguage.second {
            languageKey = QwertySwitchLanguageKeyModel(rowInfo: rowInfo, languages: (first, second))
        } else {
            let targetTab: TabData = {
                switch first {
                case .en_US:
                    .system(.user_english)
                case .ja_JP:
                    .system(.user_japanese)
                case .none, .el_GR:
                    .system(.user_japanese)
                }
            }()
            languageKey = QwertyFunctionalKeyModel(labelType: .text(first.symbol), rowInfo: rowInfo, pressActions: [.moveTab(targetTab)], longPressActions: .none, needSuggestView: false)
        }

        let numbersKey: any QwertyKeyModelProtocol<Extension> = QwertyFunctionalKeyModel(labelType: .image("textformat.123"), rowInfo: rowInfo, pressActions: [.moveTab(.system(.qwerty_numbers))], longPressActions: .init(start: [.setTabBar(.toggle)]))
        let symbolsKey: any QwertyKeyModelProtocol<Extension> = QwertyFunctionalKeyModel(labelType: .text("#+="), rowInfo: rowInfo, pressActions: [.moveTab(.system(.qwerty_symbols))], longPressActions: .init(start: [.setTabBar(.toggle)]))

        let changeKeyboardKey: any QwertyKeyModelProtocol<Extension>
        if let second = preferredLanguage.second {
            changeKeyboardKey = QwertyChangeKeyboardKeyModel(keySizeType: .functional(normal: rowInfo.normal, functional: rowInfo.functional, enter: rowInfo.enter, space: rowInfo.space), fallBackType: .secondTab(secondLanguage: second))
        } else {
            changeKeyboardKey = QwertyChangeKeyboardKeyModel(keySizeType: .functional(normal: rowInfo.normal, functional: rowInfo.functional, enter: rowInfo.enter, space: rowInfo.space), fallBackType: .tabBar)
        }
        return (
            languageKey: languageKey,
            numbersKey: numbersKey,
            symbolsKey: symbolsKey,
            changeKeyboardKey: changeKeyboardKey
        )
    }

    @MainActor static func spaceKey() -> any QwertyKeyModelProtocol<Extension> {
        Extension.SettingProvider.useNextCandidateKey ? QwertyNextCandidateKeyModel() : QwertySpaceKeyModel()
    }

    // 横に並べる
    @MainActor static var numberKeyboard: [[any QwertyKeyModelProtocol<Extension>]] {[
        [
            QwertyKeyModel(
                labelType: .text("1"),
                pressActions: [.input("1")],
                variationsModel: VariationsModel([
                    (label: .text("1"), actions: [.input("1")] ),
                    (label: .text("１"), actions: [.input("１")] ),
                    (label: .text("一"), actions: [.input("一")] ),
                    (label: .text("①"), actions: [.input("①")] )

                ], direction: .right)
            ),
            QwertyKeyModel(
                labelType: .text("2"),
                pressActions: [.input("2")],
                variationsModel: VariationsModel([
                    (label: .text("2"), actions: [.input("2")] ),
                    (label: .text("２"), actions: [.input("２")] ),
                    (label: .text("二"), actions: [.input("二")] ),
                    (label: .text("②"), actions: [.input("②")] )

                ], direction: .right)
            ),
            QwertyKeyModel(
                labelType: .text("3"),
                pressActions: [.input("3")],
                variationsModel: VariationsModel([
                    (label: .text("3"), actions: [.input("3")] ),
                    (label: .text("３"), actions: [.input("３")] ),
                    (label: .text("三"), actions: [.input("三")] ),
                    (label: .text("③"), actions: [.input("③")] )

                ])
            ),
            QwertyKeyModel(
                labelType: .text("4"),
                pressActions: [.input("4")],
                variationsModel: VariationsModel([
                    (label: .text("4"), actions: [.input("4")] ),
                    (label: .text("４"), actions: [.input("４")] ),
                    (label: .text("四"), actions: [.input("四")] ),
                    (label: .text("④"), actions: [.input("④")] )
                ])
            ),
            QwertyKeyModel(
                labelType: .text("5"),
                pressActions: [.input("5")],
                variationsModel: VariationsModel([
                    (label: .text("5"), actions: [.input("5")] ),
                    (label: .text("５"), actions: [.input("５")] ),
                    (label: .text("五"), actions: [.input("五")] ),
                    (label: .text("⑤"), actions: [.input("⑤")] )
                ])
            ),
            QwertyKeyModel(
                labelType: .text("6"),
                pressActions: [.input("6")],
                variationsModel: VariationsModel([
                    (label: .text("6"), actions: [.input("6")] ),
                    (label: .text("６"), actions: [.input("６")] ),
                    (label: .text("六"), actions: [.input("六")] ),
                    (label: .text("⑥"), actions: [.input("⑥")] )
                ])
            ),
            QwertyKeyModel(
                labelType: .text("7"),
                pressActions: [.input("7")],
                variationsModel: VariationsModel([
                    (label: .text("7"), actions: [.input("7")] ),
                    (label: .text("７"), actions: [.input("７")] ),
                    (label: .text("七"), actions: [.input("七")] ),
                    (label: .text("⑦"), actions: [.input("⑦")] )
                ])
            ),
            QwertyKeyModel(
                labelType: .text("8"),
                pressActions: [.input("8")],
                variationsModel: VariationsModel([
                    (label: .text("8"), actions: [.input("8")] ),
                    (label: .text("８"), actions: [.input("８")] ),
                    (label: .text("八"), actions: [.input("八")] ),
                    (label: .text("⑧"), actions: [.input("⑧")] )
                ])
            ),
            QwertyKeyModel(
                labelType: .text("9"),
                pressActions: [.input("9")],
                variationsModel: VariationsModel([
                    (label: .text("9"), actions: [.input("9")] ),
                    (label: .text("９"), actions: [.input("９")] ),
                    (label: .text("九"), actions: [.input("九")] ),
                    (label: .text("⑨"), actions: [.input("⑨")] )
                ], direction: .left)
            ),
            QwertyKeyModel(
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
            QwertyKeyModel(labelType: .text("-"), pressActions: [.input("-")]),
            QwertyKeyModel(
                labelType: .text("/"),
                pressActions: [.input("/")],
                variationsModel: VariationsModel([
                    (label: .text("/"), actions: [.input("/")] ),
                    (label: .text("\\"), actions: [.input("\\")] )
                ])
            ),
            QwertyKeyModel(
                labelType: .text(":"),
                pressActions: [.input(":")],
                variationsModel: VariationsModel([
                    (label: .text(":"), actions: [.input(":")] ),
                    (label: .text("："), actions: [.input("：")] ),
                    (label: .text(";"), actions: [.input(";")] ),
                    (label: .text("；"), actions: [.input("；")] )
                ])
            ),
            QwertyKeyModel(
                labelType: .text("@"),
                pressActions: [.input("@")],
                variationsModel: VariationsModel([
                    (label: .text("@"), actions: [.input("@")] ),
                    (label: .text("＠"), actions: [.input("＠")] )
                ])
            ),
            QwertyKeyModel(labelType: .text("("), pressActions: [.input("(")]),
            QwertyKeyModel(labelType: .text(")"), pressActions: [.input(")")]),
            QwertyKeyModel(
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
            QwertyKeyModel(
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
            QwertyKeyModel(
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
            QwertyKeyModel(
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
            QwertyFunctionalKeyModel.delete
        ],

        [
            Self.tabKeys(rowInfo: (0, 2, 1, 1)).languageKey,
            Self.tabKeys(rowInfo: (0, 2, 1, 1)).changeKeyboardKey,
            Self.spaceKey(),
            QwertyEnterKeyModel.shared
        ]
    ]
    }
    // 横に並べる
    @MainActor static func symbolsKeyboard() -> [[any QwertyKeyModelProtocol<Extension>]] {[
        [
            QwertyKeyModel(
                labelType: .text("["),
                pressActions: [.input("[")],
                variationsModel: VariationsModel([
                    (label: .text("["), actions: [.input("[")]),
                    (label: .text("［"), actions: [.input("［")])
                ], direction: .right)
            ),
            QwertyKeyModel(
                labelType: .text("]"),
                pressActions: [.input("]")],
                variationsModel: VariationsModel([
                    (label: .text("]"), actions: [.input("]")]),
                    (label: .text("］"), actions: [.input("］")])
                ])
            ),
            QwertyKeyModel(
                labelType: .text("{"),
                pressActions: [.input("{")],
                variationsModel: VariationsModel([
                    (label: .text("{"), actions: [.input("{")]),
                    (label: .text("｛"), actions: [.input("｛")])
                ])
            ),
            QwertyKeyModel(
                labelType: .text("}"),
                pressActions: [.input("}")],
                variationsModel: VariationsModel([
                    (label: .text("}"), actions: [.input("}")]),
                    (label: .text("｝"), actions: [.input("｝")])
                ])
            ),
            QwertyKeyModel(
                labelType: .text("#"),
                pressActions: [.input("#")],
                variationsModel: VariationsModel([
                    (label: .text("#"), actions: [.input("#")]),
                    (label: .text("＃"), actions: [.input("＃")])
                ])
            ),
            QwertyKeyModel(
                labelType: .text("%"),
                pressActions: [.input("%")],
                variationsModel: VariationsModel([
                    (label: .text("%"), actions: [.input("%")]),
                    (label: .text("％"), actions: [.input("％")])
                ])
            ),
            QwertyKeyModel(
                labelType: .text("^"),
                pressActions: [.input("^")],
                variationsModel: VariationsModel([
                    (label: .text("^"), actions: [.input("^")]),
                    (label: .text("＾"), actions: [.input("＾")])
                ])
            ),
            QwertyKeyModel(
                labelType: .text("*"),
                pressActions: [.input("*")],
                variationsModel: VariationsModel([
                    (label: .text("*"), actions: [.input("*")]),
                    (label: .text("＊"), actions: [.input("＊")])
                ])
            ),
            QwertyKeyModel(
                labelType: .text("+"),
                pressActions: [.input("+")],
                variationsModel: VariationsModel([
                    (label: .text("+"), actions: [.input("+")]),
                    (label: .text("＋"), actions: [.input("＋")]),
                    (label: .text("±"), actions: [.input("±")])
                ])
            ),
            QwertyKeyModel(
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
            QwertyKeyModel(labelType: .text("_"), pressActions: [.input("_")]),
            QwertyKeyModel(
                labelType: .text("\\"),
                pressActions: [.input("\\")],
                variationsModel: VariationsModel([
                    (label: .text("/"), actions: [.input("/")] ),
                    (label: .text("\\"), actions: [.input("\\")] )
                ])
            ),
            QwertyKeyModel(
                labelType: .text(";"),
                pressActions: [.input(";")],
                variationsModel: VariationsModel([
                    (label: .text(":"), actions: [.input(":")] ),
                    (label: .text("："), actions: [.input("：")] ),
                    (label: .text(";"), actions: [.input(";")] ),
                    (label: .text("；"), actions: [.input("；")] )
                ])
            ),
            QwertyKeyModel(
                labelType: .text("|"),
                pressActions: [.input("|")],
                variationsModel: VariationsModel([
                    (label: .text("|"), actions: [.input("|")] ),
                    (label: .text("｜"), actions: [.input("｜")] )
                ])
            ),
            QwertyKeyModel(
                labelType: .text("<"),
                pressActions: [.input("<")],
                variationsModel: VariationsModel([
                    (label: .text("<"), actions: [.input("<")]),
                    (label: .text("＜"), actions: [.input("＜")])
                ])
            ),
            QwertyKeyModel(
                labelType: .text(">"),
                pressActions: [.input(">")],
                variationsModel: VariationsModel([
                    (label: .text(">"), actions: [.input(">")]),
                    (label: .text("＞"), actions: [.input("＞")])
                ])
            ),
            QwertyKeyModel(
                labelType: .text("\""),
                pressActions: [.input("\"")],
                variationsModel: VariationsModel([
                    (label: .text("\""), actions: [.input("\"")]),
                    (label: .text("＂"), actions: [.input("＂")]),
                    (label: .text("“"), actions: [.input("“")]),
                    (label: .text("”"), actions: [.input("”")])
                ])
            ),
            QwertyKeyModel(
                labelType: .text("'"),
                pressActions: [.input("'")],
                variationsModel: VariationsModel([
                    (label: .text("'"), actions: [.input("'")]),
                    (label: .text("`"), actions: [.input("`")])
                ])
            ),

            QwertyKeyModel(
                labelType: .text("$"),
                pressActions: [.input("$")],
                variationsModel: VariationsModel([
                    (label: .text("$"), actions: [.input("$")]),
                    (label: .text("＄"), actions: [.input("＄")])
                ])
            ),
            QwertyKeyModel(
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
            QwertyKeyModel(
                labelType: .text("."),
                pressActions: [.input(".")],
                variationsModel: VariationsModel([
                    (label: .text("。"), actions: [.input("。")] ),
                    (label: .text("."), actions: [.input(".")] )
                ]),
                for: (7, 5)
            ),
            QwertyKeyModel(
                labelType: .text(","),
                pressActions: [.input(",")],
                variationsModel: VariationsModel([
                    (label: .text("、"), actions: [.input("、")] ),
                    (label: .text(","), actions: [.input(",")] )
                ]),
                for: (7, 5)),
            QwertyKeyModel(
                labelType: .text("?"),
                pressActions: [.input("?")],
                variationsModel: VariationsModel([
                    (label: .text("？"), actions: [.input("？")] ),
                    (label: .text("?"), actions: [.input("?")] )
                ]),
                for: (7, 5)
            ),
            QwertyKeyModel(
                labelType: .text("!"),
                pressActions: [.input("!")],
                variationsModel: VariationsModel([
                    (label: .text("！"), actions: [.input("！")] ),
                    (label: .text("!"), actions: [.input("!")] )
                ]),
                for: (7, 5)),
            QwertyKeyModel(labelType: .text("・"), pressActions: [.input("…")], for: (7, 5)),
            QwertyFunctionalKeyModel.delete
        ],
        [
            Self.tabKeys(rowInfo: (0, 2, 1, 1)).languageKey,
            Self.tabKeys(rowInfo: (0, 2, 1, 1)).changeKeyboardKey,
            Self.spaceKey(),
            QwertyEnterKeyModel.shared
        ]
    ]}

    // 横に並べる
    @MainActor static func hiraKeyboard() -> [[any QwertyKeyModelProtocol<Extension>]] {[
        [
            QwertyKeyModel(labelType: .text("q"), pressActions: [.input("q")]),
            QwertyKeyModel(labelType: .text("w"), pressActions: [.input("w")]),
            QwertyKeyModel(labelType: .text("e"), pressActions: [.input("e")]),
            QwertyKeyModel(labelType: .text("r"), pressActions: [.input("r")]),
            QwertyKeyModel(labelType: .text("t"), pressActions: [.input("t")]),
            QwertyKeyModel(labelType: .text("y"), pressActions: [.input("y")]),
            QwertyKeyModel(labelType: .text("u"), pressActions: [.input("u")]),
            QwertyKeyModel(labelType: .text("i"), pressActions: [.input("i")]),
            QwertyKeyModel(labelType: .text("o"), pressActions: [.input("o")]),
            QwertyKeyModel(labelType: .text("p"), pressActions: [.input("p")])
        ],
        [
            QwertyKeyModel(labelType: .text("a"), pressActions: [.input("a")]),
            QwertyKeyModel(labelType: .text("s"), pressActions: [.input("s")]),
            QwertyKeyModel(labelType: .text("d"), pressActions: [.input("d")]),
            QwertyKeyModel(labelType: .text("f"), pressActions: [.input("f")]),
            QwertyKeyModel(labelType: .text("g"), pressActions: [.input("g")]),
            QwertyKeyModel(labelType: .text("h"), pressActions: [.input("h")]),
            QwertyKeyModel(labelType: .text("j"), pressActions: [.input("j")]),
            QwertyKeyModel(labelType: .text("k"), pressActions: [.input("k")]),
            QwertyKeyModel(labelType: .text("l"), pressActions: [.input("l")]),
            QwertyKeyModel(labelType: .text("ー"), pressActions: [.input("ー")])
        ],
        [
            Self.tabKeys(rowInfo: (7, 2, 0, 0)).languageKey,
            QwertyKeyModel(labelType: .text("z"), pressActions: [.input("z")]),
            QwertyKeyModel(labelType: .text("x"), pressActions: [.input("x")]),
            QwertyKeyModel(labelType: .text("c"), pressActions: [.input("c")]),
            QwertyKeyModel(labelType: .text("v"), pressActions: [.input("v")]),
            QwertyKeyModel(labelType: .text("b"), pressActions: [.input("b")]),
            QwertyKeyModel(labelType: .text("n"), pressActions: [.input("n")]),
            QwertyKeyModel(labelType: .text("m"), pressActions: [.input("m")]),
            QwertyFunctionalKeyModel.delete
        ],
        [
            Self.tabKeys(rowInfo: (0, 2, 1, 1)).numbersKey,
            Self.tabKeys(rowInfo: (0, 2, 1, 1)).changeKeyboardKey,
            Self.spaceKey(),
            QwertyEnterKeyModel.shared
        ]
    ]}

    // 横に並べる
    @MainActor static func abcKeyboard() -> [[any QwertyKeyModelProtocol<Extension>]] {[
        [
            QwertyKeyModel(labelType: .text("q"), pressActions: [.input("q")]),
            QwertyKeyModel(labelType: .text("w"), pressActions: [.input("w")]),
            QwertyKeyModel(labelType: .text("e"), pressActions: [.input("e")]),
            QwertyKeyModel(labelType: .text("r"), pressActions: [.input("r")]),
            QwertyKeyModel(labelType: .text("t"), pressActions: [.input("t")]),
            QwertyKeyModel(labelType: .text("y"), pressActions: [.input("y")]),
            QwertyKeyModel(labelType: .text("u"), pressActions: [.input("u")]),
            QwertyKeyModel(labelType: .text("i"), pressActions: [.input("i")]),
            QwertyKeyModel(labelType: .text("o"), pressActions: [.input("o")]),
            QwertyKeyModel(labelType: .text("p"), pressActions: [.input("p")])
        ],
        Extension.SettingProvider.useShiftKey ?
            [
                QwertyShiftKeyModel.shared,
                QwertyKeyModel(labelType: .text("a"), pressActions: [.input("a")]),
                QwertyKeyModel(labelType: .text("s"), pressActions: [.input("s")]),
                QwertyKeyModel(labelType: .text("d"), pressActions: [.input("d")]),
                QwertyKeyModel(labelType: .text("f"), pressActions: [.input("f")]),
                QwertyKeyModel(labelType: .text("g"), pressActions: [.input("g")]),
                QwertyKeyModel(labelType: .text("h"), pressActions: [.input("h")]),
                QwertyKeyModel(labelType: .text("j"), pressActions: [.input("j")]),
                QwertyKeyModel(labelType: .text("k"), pressActions: [.input("k")]),
                QwertyKeyModel(labelType: .text("l"), pressActions: [.input("l")])
            ] : [
                QwertyKeyModel(labelType: .text("a"), pressActions: [.input("a")]),
                QwertyKeyModel(labelType: .text("s"), pressActions: [.input("s")]),
                QwertyKeyModel(labelType: .text("d"), pressActions: [.input("d")]),
                QwertyKeyModel(labelType: .text("f"), pressActions: [.input("f")]),
                QwertyKeyModel(labelType: .text("g"), pressActions: [.input("g")]),
                QwertyKeyModel(labelType: .text("h"), pressActions: [.input("h")]),
                QwertyKeyModel(labelType: .text("j"), pressActions: [.input("j")]),
                QwertyKeyModel(labelType: .text("k"), pressActions: [.input("k")]),
                QwertyKeyModel(labelType: .text("l"), pressActions: [.input("l")]),
                QwertyAaKeyModel.shared
            ],
        [
            Self.tabKeys(rowInfo: (7, 2, 0, 0)).languageKey,
            QwertyKeyModel(labelType: .text("z"), pressActions: [.input("z")]),
            QwertyKeyModel(labelType: .text("x"), pressActions: [.input("x")]),
            QwertyKeyModel(labelType: .text("c"), pressActions: [.input("c")]),
            QwertyKeyModel(labelType: .text("v"), pressActions: [.input("v")]),
            QwertyKeyModel(labelType: .text("b"), pressActions: [.input("b")]),
            QwertyKeyModel(labelType: .text("n"), pressActions: [.input("n")]),
            QwertyKeyModel(labelType: .text("m"), pressActions: [.input("m")]),
            QwertyFunctionalKeyModel.delete
        ],
        [
            Self.tabKeys(rowInfo: (0, 2, 1, 1)).numbersKey,
            Self.tabKeys(rowInfo: (0, 2, 1, 1)).changeKeyboardKey,
            Self.spaceKey(),
            QwertyEnterKeyModel.shared
        ]
    ]}
}
