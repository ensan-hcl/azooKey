//
//  HorizontalQwertyDataProvider.swift
//  Keyboard
//
//  Created by β α on 2020/09/21.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

struct HorizontalQwertyDataProvider: KeyboardDataProviderProtocol {
    //横に並べる
    var numberKeyboard: [[QwertyKeyModelProtocol]] = [
        [
            QwertyKeyModel(
                labelType: .text("1"),
                pressActions: [.input("1")],
                variationsModel: VariationsModel([
                    (label: .text("1"), actions: [.input("1")] ),
                    (label: .text("１"), actions: [.input("１")] ),
                    (label: .text("一"), actions: [.input("一")] ),
                    (label: .text("①"), actions: [.input("①")] ),

                ], direction: .right)
            ),
            QwertyKeyModel(
                labelType: .text("2"),
                pressActions: [.input("2")],
                variationsModel: VariationsModel([
                    (label: .text("2"), actions: [.input("2")] ),
                    (label: .text("２"), actions: [.input("２")] ),
                    (label: .text("二"), actions: [.input("二")] ),
                    (label: .text("②"), actions: [.input("②")] ),

                ], direction: .right)
            ),
            QwertyKeyModel(
                labelType: .text("3"),
                pressActions: [.input("3")],
                variationsModel: VariationsModel([
                    (label: .text("3"), actions: [.input("3")] ),
                    (label: .text("３"), actions: [.input("３")] ),
                    (label: .text("三"), actions: [.input("三")] ),
                    (label: .text("③"), actions: [.input("③")] ),

                ])
            ),
            QwertyKeyModel(
                labelType: .text("4"),
                pressActions: [.input("4")],
                variationsModel: VariationsModel([
                    (label: .text("4"), actions: [.input("4")] ),
                    (label: .text("４"), actions: [.input("４")] ),
                    (label: .text("四"), actions: [.input("四")] ),
                    (label: .text("④"), actions: [.input("④")] ),
                ])
            ),
            QwertyKeyModel(
                labelType: .text("5"),
                pressActions: [.input("5")],
                variationsModel: VariationsModel([
                    (label: .text("5"), actions: [.input("5")] ),
                    (label: .text("５"), actions: [.input("５")] ),
                    (label: .text("五"), actions: [.input("五")] ),
                    (label: .text("⑤"), actions: [.input("⑤")] ),
                ])
            ),
            QwertyKeyModel(
                labelType: .text("6"),
                pressActions: [.input("6")],
                variationsModel: VariationsModel([
                    (label: .text("6"), actions: [.input("6")] ),
                    (label: .text("６"), actions: [.input("６")] ),
                    (label: .text("六"), actions: [.input("六")] ),
                    (label: .text("⑥"), actions: [.input("⑥")] ),
                ])
            ),
            QwertyKeyModel(
                labelType: .text("7"),
                pressActions: [.input("7")],
                variationsModel: VariationsModel([
                    (label: .text("7"), actions: [.input("7")] ),
                    (label: .text("７"), actions: [.input("７")] ),
                    (label: .text("七"), actions: [.input("七")] ),
                    (label: .text("⑦"), actions: [.input("⑦")] ),
                ])
            ),
            QwertyKeyModel(
                labelType: .text("8"),
                pressActions: [.input("8")],
                variationsModel: VariationsModel([
                    (label: .text("8"), actions: [.input("8")] ),
                    (label: .text("８"), actions: [.input("８")] ),
                    (label: .text("八"), actions: [.input("八")] ),
                    (label: .text("⑧"), actions: [.input("⑧")] ),
                ])
            ),
            QwertyKeyModel(
                labelType: .text("9"),
                pressActions: [.input("9")],
                variationsModel: VariationsModel([
                    (label: .text("9"), actions: [.input("9")] ),
                    (label: .text("９"), actions: [.input("９")] ),
                    (label: .text("九"), actions: [.input("九")] ),
                    (label: .text("⑨"), actions: [.input("⑨")] ),
                ], direction: .left)
            ),
            QwertyKeyModel(
                labelType: .text("0"),
                pressActions: [.input("0")],
                variationsModel: VariationsModel([
                    (label: .text("0"), actions: [.input("0")] ),
                    (label: .text("０"), actions: [.input("０")] ),
                    (label: .text("〇"), actions: [.input("〇")] ),
                    (label: .text("⓪"), actions: [.input("⓪")] ),
                ], direction: .left)
            ),
        ],
        [
            QwertyKeyModel(labelType: .text("-"), pressActions: [.input("-")]),
            QwertyKeyModel(
                labelType: .text("/"),
                pressActions: [.input("/")],
                variationsModel: VariationsModel([
                    (label: .text("/"), actions: [.input("/")] ),
                    (label: .text("\\"), actions: [.input("\\")] ),
                ])
            ),
            QwertyKeyModel(
                labelType: .text(":"),
                pressActions: [.input(":")],
                variationsModel: VariationsModel([
                    (label: .text(":"), actions: [.input(":")] ),
                    (label: .text("："), actions: [.input("：")] ),
                    (label: .text(";"), actions: [.input(";")] ),
                    (label: .text("；"), actions: [.input("；")] ),
                ])
            ),
            QwertyKeyModel(
                labelType: .text("@"),
                pressActions: [.input("@")],
                variationsModel: VariationsModel([
                    (label: .text("@"), actions: [.input("@")] ),
                    (label: .text("＠"), actions: [.input("＠")] ),
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
                    (label: .text("《"), actions: [.input("《")] ),
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
                            (label: .text("》"), actions: [.input("》")] ),
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
                    (label: .text("¤"), actions: [.input("¤")] ),
                ])
            ),
            QwertyKeyModel(labelType: .text("&"), pressActions: [.input("&")]),
        ],
        
        [
            QwertyFunctionalKeyModel(labelType: .text("#+="), rowInfo: (normal: 7, functional: 2, space: 0, enter: 0), pressActions: [.moveTab(.other(QwertyAdditionalTabs.symbols.identifier))]),
        ] + SettingData.shared.qwertyNumberTabKeySetting +
        [
            QwertyFunctionalKeyModel(labelType: .image("delete.left"), rowInfo: (normal: 7, functional: 2, space: 0, enter: 0), pressActions: [.delete(1)], longPressActions: [.delete]),
        ],

        [
            QwertyFunctionalKeyModel(labelType: .text("あいう"), rowInfo: (normal: 0, functional: 2, space: 1, enter: 1), pressActions: [.moveTab(.hira)]),
            QwertyChangeKeyboardKeyModel(rowInfo: (normal: 0, functional: 2, space: 1, enter: 1)),
            QwertySpaceKeyModel(),
            QwertyEnterKeyModel.shared,
        ],
    ]
    
    //横に並べる
    var hiraKeyboard: [[QwertyKeyModelProtocol]] = [
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
            QwertyKeyModel(labelType: .text("p"), pressActions: [.input("p")]),
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
            QwertyKeyModel(labelType: .text("ー"), pressActions: [.input("ー")]),
        ],
        [
            QwertyFunctionalKeyModel(labelType: .selectable("あ", "Ａ"), rowInfo: (normal: 7, functional: 2, space: 0, enter: 0), pressActions: [.moveTab(.abc)]),
            QwertyKeyModel(labelType: .text("z"), pressActions: [.input("z")]),
            QwertyKeyModel(labelType: .text("x"), pressActions: [.input("x")]),
            QwertyKeyModel(labelType: .text("c"), pressActions: [.input("c")]),
            QwertyKeyModel(labelType: .text("v"), pressActions: [.input("v")]),
            QwertyKeyModel(labelType: .text("b"), pressActions: [.input("b")]),
            QwertyKeyModel(labelType: .text("n"), pressActions: [.input("n")]),
            QwertyKeyModel(labelType: .text("m"), pressActions: [.input("m")]),
            QwertyFunctionalKeyModel(labelType: .image("delete.left"), rowInfo: (normal: 7, functional: 2, space: 0, enter: 0), pressActions: [.delete(1)], longPressActions: [.delete]),
        ],
        [
            QwertyFunctionalKeyModel(labelType: .image("textformat.123"), rowInfo: (normal: 0, functional: 2, space: 1, enter: 1), pressActions: [.moveTab(.number)]),
            QwertyChangeKeyboardKeyModel(rowInfo: (normal: 0, functional: 2, space: 1, enter: 1)),
            QwertySpaceKeyModel(),
            QwertyEnterKeyModel.shared,
        ],
    ]

    //横に並べる
    var abcKeyboard: [[QwertyKeyModelProtocol]] = [
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
            QwertyKeyModel(labelType: .text("p"), pressActions: [.input("p")]),
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
            QwertyAaKeyModel.shared,
        ],
        [
            QwertyFunctionalKeyModel(labelType: .selectable("Ａ", "あ"), rowInfo: (normal: 7, functional: 2, space: 0, enter: 0), pressActions: [.moveTab(.hira)]),
            QwertyKeyModel(labelType: .text("z"), pressActions: [.input("z")]),
            QwertyKeyModel(labelType: .text("x"), pressActions: [.input("x")]),
            QwertyKeyModel(labelType: .text("c"), pressActions: [.input("c")]),
            QwertyKeyModel(labelType: .text("v"), pressActions: [.input("v")]),
            QwertyKeyModel(labelType: .text("b"), pressActions: [.input("b")]),
            QwertyKeyModel(labelType: .text("n"), pressActions: [.input("n")]),
            QwertyKeyModel(labelType: .text("m"), pressActions: [.input("m")]),
            QwertyFunctionalKeyModel(labelType: .image("delete.left"), rowInfo: (normal: 7, functional: 2, space: 0, enter: 0), pressActions: [.delete(1)], longPressActions: [.delete]),
        ],
        [
            QwertyFunctionalKeyModel(labelType: .image("textformat.123"), rowInfo: (normal: 0, functional: 2, space: 1, enter: 1), pressActions: [.moveTab(.number)]),
            QwertyChangeKeyboardKeyModel(rowInfo: (normal: 0, functional: 2, space: 1, enter: 1)),
            QwertySpaceKeyModel(),
            QwertyEnterKeyModel.shared,
        ],
    ]

    //横に並べる
    var symbolsKeyboard: [[QwertyKeyModelProtocol]] = [
        [
            QwertyKeyModel(
                labelType: .text("["),
                pressActions: [.input("[")]
            ),
            QwertyKeyModel(
                labelType: .text("]"),
                pressActions: [.input("]")]
            ),
            QwertyKeyModel(
                labelType: .text("{"),
                pressActions: [.input("{")]
            ),
            QwertyKeyModel(
                labelType: .text("}"),
                pressActions: [.input("}")]
            ),
            QwertyKeyModel(
                labelType: .text("#"),
                pressActions: [.input("#")]
            ),
            QwertyKeyModel(
                labelType: .text("%"),
                pressActions: [.input("%")]
            ),
            QwertyKeyModel(
                labelType: .text("^"),
                pressActions: [.input("^")]
            ),
            QwertyKeyModel(
                labelType: .text("*"),
                pressActions: [.input("*")]
            ),
            QwertyKeyModel(
                labelType: .text("+"),
                pressActions: [.input("+")]
            ),
            QwertyKeyModel(
                labelType: .text("="),
                pressActions: [.input("=")]
            ),
        ],
        [
            QwertyKeyModel(labelType: .text("_"), pressActions: [.input("_")]),
            QwertyKeyModel(
                labelType: .text("\\"),
                pressActions: [.input("\\")],
                variationsModel: VariationsModel([
                    (label: .text("/"), actions: [.input("/")] ),
                    (label: .text("\\"), actions: [.input("\\")] ),
                ])
            ),
            QwertyKeyModel(
                labelType: .text(";"),
                pressActions: [.input(";")],
                variationsModel: VariationsModel([
                    (label: .text(":"), actions: [.input(":")] ),
                    (label: .text("："), actions: [.input("：")] ),
                    (label: .text(";"), actions: [.input(";")] ),
                    (label: .text("；"), actions: [.input("；")] ),
                ])
            ),
            QwertyKeyModel(
                labelType: .text("|"),
                pressActions: [.input("|")],
                variationsModel: VariationsModel([
                    (label: .text("@"), actions: [.input("@")] ),
                    (label: .text("＠"), actions: [.input("＠")] ),
                ])
            ),
            QwertyKeyModel(labelType: .text("<"), pressActions: [.input("<")]),
            QwertyKeyModel(labelType: .text(">"), pressActions: [.input(">")]),
            QwertyKeyModel(
                labelType: .text("\""),
                pressActions: [.input("\"")]
            ),
            QwertyKeyModel(
                labelType: .text("'"),
                pressActions: [.input("'")]
            ),

            QwertyKeyModel(
                labelType: .text("$"),
                pressActions: [.input("$")]
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
                    (label: .text("¤"), actions: [.input("¤")] ),
                ], direction: .left)
            ),
        ],

        [
            QwertyFunctionalKeyModel(labelType: .image("textformat.123"), rowInfo: (normal: 7, functional: 2, space: 0, enter: 0), pressActions: [.moveTab(.number)]),
            QwertyKeyModel(
                labelType: .text("."),
                pressActions: [.input(".")],
                variationsModel: VariationsModel([
                    (label: .text("。"), actions: [.input("。")] ),
                    (label: .text("."), actions: [.input(".")] ),
                ]),
                for: (7, 5)
            ),
            QwertyKeyModel(
                labelType: .text(","),
                pressActions: [.input(",")],
                variationsModel: VariationsModel([
                    (label: .text("、"), actions: [.input("、")] ),
                    (label: .text(","), actions: [.input(",")] ),
                ]),
                for: (7, 5)),
            QwertyKeyModel(
                labelType: .text("?"),
                pressActions: [.input("?")],
                variationsModel: VariationsModel([
                    (label: .text("？"), actions: [.input("？")] ),
                    (label: .text("?"), actions: [.input("?")] ),
                ]),
                for: (7, 5)
            ),
            QwertyKeyModel(
                labelType: .text("!"),
                pressActions: [.input("!")],
                variationsModel: VariationsModel([
                    (label: .text("！"), actions: [.input("！")] ),
                    (label: .text("!"), actions: [.input("!")] ),
                ]),
                for: (7, 5)),
            QwertyKeyModel(labelType: .text("・"), pressActions: [.input("…")], for: (7, 5)),
            QwertyFunctionalKeyModel(labelType: .image("delete.left"), rowInfo: (normal: 7, functional: 2, space: 0, enter: 0), pressActions: [.delete(1)], longPressActions: [.delete]),
        ],
        [
            QwertyChangeTabKeyModel(rowInfo: (normal: 0, functional: 2, space: 1, enter: 1)),
            QwertyChangeKeyboardKeyModel(rowInfo: (normal: 0, functional: 2, space: 1, enter: 1)),
            QwertySpaceKeyModel(),
            QwertyEnterKeyModel.shared,
        ],
    ]


}
