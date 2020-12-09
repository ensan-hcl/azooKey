//
//  VerticalRomanKeyboardModel.swift
//  Keyboard
//
//  Created by β α on 2020/09/18.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
final class VerticalRomanKeyboardModelVariableSection: ObservableObject{
    @Published var tabState: TabState = .hira
    @Published var isResultViewExpanded = false
}

struct VerticalRomanKeyboardModel: KeyboardModelProtocol{
    let resultModel = ResultModel()
    
    let enterKeyModel: EnterKeyModelProtocol = RomanEnterKeyModel.shared
    let expandedResultModel = ExpandedResultModel()
    var variableSection = VerticalRomanKeyboardModelVariableSection()
    
    func setTabState(state: TabState){
        self.variableSection.tabState = state
    }

    var tabState: TabState {
        return self.variableSection.tabState
    }

    func expandResultView(_ results: [ResultData]) {
        self.variableSection.isResultViewExpanded = true
        self.expandedResultModel.expand(results: results)
    }

    func collapseResultView(){
        self.variableSection.isResultViewExpanded = false
    }

    //横に並べる
    var numberKeyboard: [[RomanKeyModelProtocol]] {[
        [
            RomanKeyModel(
                labelType: .text("1"),
                pressActions: [.input("1")],
                variationsModel: VariationsModel([
                    (label: .text("1"), actions: [.input("1")] ),
                    (label: .text("１"), actions: [.input("１")] ),
                    (label: .text("一"), actions: [.input("一")] ),
                    (label: .text("①"), actions: [.input("①")] ),

                ], direction: .right)
            ),
            RomanKeyModel(
                labelType: .text("2"),
                pressActions: [.input("2")],
                variationsModel: VariationsModel([
                    (label: .text("2"), actions: [.input("2")] ),
                    (label: .text("２"), actions: [.input("２")] ),
                    (label: .text("二"), actions: [.input("二")] ),
                    (label: .text("②"), actions: [.input("②")] ),

                ], direction: .right)
            ),
            RomanKeyModel(
                labelType: .text("3"),
                pressActions: [.input("3")],
                variationsModel: VariationsModel([
                    (label: .text("3"), actions: [.input("3")] ),
                    (label: .text("３"), actions: [.input("３")] ),
                    (label: .text("三"), actions: [.input("三")] ),
                    (label: .text("③"), actions: [.input("③")] ),

                ])
            ),
            RomanKeyModel(
                labelType: .text("4"),
                pressActions: [.input("4")],
                variationsModel: VariationsModel([
                    (label: .text("4"), actions: [.input("4")] ),
                    (label: .text("４"), actions: [.input("４")] ),
                    (label: .text("四"), actions: [.input("四")] ),
                    (label: .text("④"), actions: [.input("④")] ),
                ])
            ),
            RomanKeyModel(
                labelType: .text("5"),
                pressActions: [.input("5")],
                variationsModel: VariationsModel([
                    (label: .text("5"), actions: [.input("5")] ),
                    (label: .text("５"), actions: [.input("５")] ),
                    (label: .text("五"), actions: [.input("五")] ),
                    (label: .text("⑤"), actions: [.input("⑤")] ),
                ])
            ),
            RomanKeyModel(
                labelType: .text("6"),
                pressActions: [.input("6")],
                variationsModel: VariationsModel([
                    (label: .text("6"), actions: [.input("6")] ),
                    (label: .text("６"), actions: [.input("６")] ),
                    (label: .text("六"), actions: [.input("六")] ),
                    (label: .text("⑥"), actions: [.input("⑥")] ),
                ])
            ),
            RomanKeyModel(
                labelType: .text("7"),
                pressActions: [.input("7")],
                variationsModel: VariationsModel([
                    (label: .text("7"), actions: [.input("7")] ),
                    (label: .text("７"), actions: [.input("７")] ),
                    (label: .text("七"), actions: [.input("七")] ),
                    (label: .text("⑦"), actions: [.input("⑦")] ),
                ])
            ),
            RomanKeyModel(
                labelType: .text("8"),
                pressActions: [.input("8")],
                variationsModel: VariationsModel([
                    (label: .text("8"), actions: [.input("8")] ),
                    (label: .text("８"), actions: [.input("８")] ),
                    (label: .text("八"), actions: [.input("八")] ),
                    (label: .text("⑧"), actions: [.input("⑧")] ),
                ])
            ),
            RomanKeyModel(
                labelType: .text("9"),
                pressActions: [.input("9")],
                variationsModel: VariationsModel([
                    (label: .text("9"), actions: [.input("9")] ),
                    (label: .text("９"), actions: [.input("９")] ),
                    (label: .text("九"), actions: [.input("九")] ),
                    (label: .text("⑨"), actions: [.input("⑨")] ),
                ], direction: .left)
            ),
            RomanKeyModel(
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
            RomanKeyModel(labelType: .text("-"), pressActions: [.input("-")]),
            RomanKeyModel(
                labelType: .text("/"),
                pressActions: [.input("/")],
                variationsModel: VariationsModel([
                    (label: .text("/"), actions: [.input("/")] ),
                    (label: .text("\\"), actions: [.input("\\")] ),
                ])
            ),
            RomanKeyModel(
                labelType: .text(":"),
                pressActions: [.input(":")],
                variationsModel: VariationsModel([
                    (label: .text(":"), actions: [.input(":")] ),
                    (label: .text("："), actions: [.input("：")] ),
                    (label: .text(";"), actions: [.input(";")] ),
                    (label: .text("；"), actions: [.input("；")] ),
                ])
            ),
            RomanKeyModel(
                labelType: .text("@"),
                pressActions: [.input("@")],
                variationsModel: VariationsModel([
                    (label: .text("@"), actions: [.input("@")] ),
                    (label: .text("＠"), actions: [.input("＠")] ),
                ])
            ),
            RomanKeyModel(labelType: .text("("), pressActions: [.input("(")]),
            RomanKeyModel(labelType: .text(")"), pressActions: [.input(")")]),
            RomanKeyModel(
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
            RomanKeyModel(
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
            RomanKeyModel(
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
                ], direction: .left)
            ),
            RomanKeyModel(labelType: .text("&"), pressActions: [.input("&")]),
        ],

        [
            RomanFunctionalKeyModel(labelType: .text("#+="), rowInfo: (normal: 7, functional: 2, space: 0, enter: 0), pressActions: [.moveTab(.other(RomanAdditionalTabs.symbols.identifier))]),
        ] + Store.shared.userSetting.romanNumberTabKeySetting +
        [
            RomanFunctionalKeyModel(labelType: .image("delete.left"), rowInfo: (normal: 7, functional: 2, space: 0, enter: 0), pressActions: [.delete(1)], longPressActions: [.delete]),
        ],

        [
            RomanFunctionalKeyModel(labelType: .text("あ"), rowInfo: (normal: 0, functional: 2, space: 1, enter: 1), pressActions: [.moveTab(.hira)]),
            RomanChangeKeyboardKeyModel(rowInfo: (normal: 0, functional: 2, space: 1, enter: 1)),
            RomanSpaceKeyModel(),
            RomanEnterKeyModel.shared,
        ],
    ]
    }
    //横に並べる
    var symbolsKeyboard: [[RomanKeyModelProtocol]] = [
        [
            RomanKeyModel(
                labelType: .text("["),
                pressActions: [.input("[")],
                variationsModel: VariationsModel([
                    (label: .text("1"), actions: [.input("1")] ),
                    (label: .text("１"), actions: [.input("１")] ),
                    (label: .text("一"), actions: [.input("一")] ),
                    (label: .text("①"), actions: [.input("①")] ),

                ], direction: .right)
            ),
            RomanKeyModel(
                labelType: .text("]"),
                pressActions: [.input("]")],
                variationsModel: VariationsModel([
                    (label: .text("2"), actions: [.input("2")] ),
                    (label: .text("２"), actions: [.input("２")] ),
                    (label: .text("二"), actions: [.input("二")] ),
                    (label: .text("②"), actions: [.input("②")] ),

                ], direction: .right)
            ),
            RomanKeyModel(
                labelType: .text("{"),
                pressActions: [.input("}")],
                variationsModel: VariationsModel([
                    (label: .text("3"), actions: [.input("3")] ),
                    (label: .text("３"), actions: [.input("３")] ),
                    (label: .text("三"), actions: [.input("三")] ),
                    (label: .text("③"), actions: [.input("③")] ),

                ])
            ),
            RomanKeyModel(
                labelType: .text("}"),
                pressActions: [.input("}")],
                variationsModel: VariationsModel([
                    (label: .text("3"), actions: [.input("3")] ),
                    (label: .text("３"), actions: [.input("３")] ),
                    (label: .text("三"), actions: [.input("三")] ),
                    (label: .text("③"), actions: [.input("③")] ),

                ])
            ),
            RomanKeyModel(
                labelType: .text("#"),
                pressActions: [.input("#")],
                variationsModel: VariationsModel([
                    (label: .text("4"), actions: [.input("4")] ),
                    (label: .text("４"), actions: [.input("４")] ),
                    (label: .text("四"), actions: [.input("四")] ),
                    (label: .text("④"), actions: [.input("④")] ),
                ])
            ),
            RomanKeyModel(
                labelType: .text("%"),
                pressActions: [.input("%")],
                variationsModel: VariationsModel([
                    (label: .text("5"), actions: [.input("5")] ),
                    (label: .text("５"), actions: [.input("５")] ),
                    (label: .text("五"), actions: [.input("五")] ),
                    (label: .text("⑤"), actions: [.input("⑤")] ),
                ])
            ),
            RomanKeyModel(
                labelType: .text("^"),
                pressActions: [.input("^")],
                variationsModel: VariationsModel([
                    (label: .text("6"), actions: [.input("6")] ),
                    (label: .text("６"), actions: [.input("６")] ),
                    (label: .text("六"), actions: [.input("六")] ),
                    (label: .text("⑥"), actions: [.input("⑥")] ),
                ])
            ),
            RomanKeyModel(
                labelType: .text("*"),
                pressActions: [.input("*")],
                variationsModel: VariationsModel([
                    (label: .text("7"), actions: [.input("7")] ),
                    (label: .text("７"), actions: [.input("７")] ),
                    (label: .text("七"), actions: [.input("七")] ),
                    (label: .text("⑦"), actions: [.input("⑦")] ),
                ])
            ),
            RomanKeyModel(
                labelType: .text("+"),
                pressActions: [.input("+")],
                variationsModel: VariationsModel([
                    (label: .text("8"), actions: [.input("8")] ),
                    (label: .text("８"), actions: [.input("８")] ),
                    (label: .text("八"), actions: [.input("八")] ),
                    (label: .text("⑧"), actions: [.input("⑧")] ),
                ])
            ),
            RomanKeyModel(
                labelType: .text("="),
                pressActions: [.input("=")],
                variationsModel: VariationsModel([
                    (label: .text("9"), actions: [.input("9")] ),
                    (label: .text("９"), actions: [.input("９")] ),
                    (label: .text("九"), actions: [.input("九")] ),
                    (label: .text("⑨"), actions: [.input("⑨")] ),
                ], direction: .left)
            ),
        ],
        [
            RomanKeyModel(labelType: .text("_"), pressActions: [.input("_")]),
            RomanKeyModel(
                labelType: .text("\\"),
                pressActions: [.input("\\")],
                variationsModel: VariationsModel([
                    (label: .text("/"), actions: [.input("/")] ),
                    (label: .text("\\"), actions: [.input("\\")] ),
                ])
            ),
            RomanKeyModel(
                labelType: .text(";"),
                pressActions: [.input(";")],
                variationsModel: VariationsModel([
                    (label: .text(":"), actions: [.input(":")] ),
                    (label: .text("："), actions: [.input("：")] ),
                    (label: .text(";"), actions: [.input(";")] ),
                    (label: .text("；"), actions: [.input("；")] ),
                ])
            ),
            RomanKeyModel(
                labelType: .text("|"),
                pressActions: [.input("|")],
                variationsModel: VariationsModel([
                    (label: .text("@"), actions: [.input("@")] ),
                    (label: .text("＠"), actions: [.input("＠")] ),
                ])
            ),
            RomanKeyModel(labelType: .text("<"), pressActions: [.input("<")]),
            RomanKeyModel(labelType: .text(">"), pressActions: [.input(">")]),
            RomanKeyModel(
                labelType: .text("\""),
                pressActions: [.input("\"")],
                variationsModel: VariationsModel([
                    (label: .text("「"), actions: [.input("「")] ),
                    (label: .text("『"), actions: [.input("『")] ),
                    (label: .text("【"), actions: [.input("【")] ),
                    (label: .text("（"), actions: [.input("（")] ),
                    (label: .text("《"), actions: [.input("《")] ),
                ])
            ),
            RomanKeyModel(
                labelType: .text("'"),
                pressActions: [.input("'")],
                variationsModel: VariationsModel([
                    (label: .text("「"), actions: [.input("「")] ),
                    (label: .text("『"), actions: [.input("『")] ),
                    (label: .text("【"), actions: [.input("【")] ),
                    (label: .text("（"), actions: [.input("（")] ),
                    (label: .text("《"), actions: [.input("《")] ),
                ])
            ),

            RomanKeyModel(
                labelType: .text("$"),
                pressActions: [.input("$")],
                variationsModel: VariationsModel([
                    (label: .text("」"), actions: [.input("」")] ),
                    (label: .text("』"), actions: [.input("』")] ),
                    (label: .text("】"), actions: [.input("】")] ),
                    (label: .text("）"), actions: [.input("）")] ),
                    (label: .text("》"), actions: [.input("》")] ),
                ])
            ),
            RomanKeyModel(
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
            RomanFunctionalKeyModel(labelType: .image("textformat.123"), rowInfo: (normal: 7, functional: 2, space: 0, enter: 0), pressActions: [.moveTab(.number)]),
            RomanKeyModel(
                labelType: .text("."),
                pressActions: [.input(".")],
                variationsModel: VariationsModel([
                    (label: .text("。"), actions: [.input("。")] ),
                    (label: .text("."), actions: [.input(".")] ),
                ]),
                for: (7, 5)
            ),
            RomanKeyModel(
                labelType: .text(","),
                pressActions: [.input(",")],
                variationsModel: VariationsModel([
                    (label: .text("、"), actions: [.input("、")] ),
                    (label: .text(","), actions: [.input(",")] ),
                ]),
                for: (7, 5)),
            RomanKeyModel(
                labelType: .text("?"),
                pressActions: [.input("?")],
                variationsModel: VariationsModel([
                    (label: .text("？"), actions: [.input("？")] ),
                    (label: .text("?"), actions: [.input("?")] ),
                ]),
                for: (7, 5)
            ),
            RomanKeyModel(
                labelType: .text("!"),
                pressActions: [.input("!")],
                variationsModel: VariationsModel([
                    (label: .text("！"), actions: [.input("！")] ),
                    (label: .text("!"), actions: [.input("!")] ),
                ]),
                for: (7, 5)),
            RomanKeyModel(labelType: .text("…"), pressActions: [.input("・")], for: (7, 5)),
            RomanFunctionalKeyModel(labelType: .image("delete.left"), rowInfo: (normal: 7, functional: 2, space: 0, enter: 0), pressActions: [.delete(1)], longPressActions: [.delete]),
        ],
        [
            RomanFunctionalKeyModel(labelType: .text("あ"), rowInfo: (normal: 0, functional: 2, space: 1, enter: 1), pressActions: [.moveTab(.hira)]),
            RomanChangeKeyboardKeyModel(rowInfo: (normal: 0, functional: 2, space: 1, enter: 1)),
            RomanSpaceKeyModel(),
            RomanEnterKeyModel.shared,
        ],
    ]

    //横に並べる
    var hiraKeyboard: [[RomanKeyModelProtocol]] = [
        [
            RomanKeyModel(labelType: .text("q"), pressActions: [.input("q")]),
            RomanKeyModel(labelType: .text("w"), pressActions: [.input("w")]),
            RomanKeyModel(labelType: .text("e"), pressActions: [.input("e")]),
            RomanKeyModel(labelType: .text("r"), pressActions: [.input("r")]),
            RomanKeyModel(labelType: .text("t"), pressActions: [.input("t")]),
            RomanKeyModel(labelType: .text("y"), pressActions: [.input("y")]),
            RomanKeyModel(labelType: .text("u"), pressActions: [.input("u")]),
            RomanKeyModel(labelType: .text("i"), pressActions: [.input("i")]),
            RomanKeyModel(labelType: .text("o"), pressActions: [.input("o")]),
            RomanKeyModel(labelType: .text("p"), pressActions: [.input("p")]),
        ],
        [
            RomanKeyModel(labelType: .text("a"), pressActions: [.input("a")]),
            RomanKeyModel(labelType: .text("s"), pressActions: [.input("s")]),
            RomanKeyModel(labelType: .text("d"), pressActions: [.input("d")]),
            RomanKeyModel(labelType: .text("f"), pressActions: [.input("f")]),
            RomanKeyModel(labelType: .text("g"), pressActions: [.input("g")]),
            RomanKeyModel(labelType: .text("h"), pressActions: [.input("h")]),
            RomanKeyModel(labelType: .text("j"), pressActions: [.input("j")]),
            RomanKeyModel(labelType: .text("k"), pressActions: [.input("k")]),
            RomanKeyModel(labelType: .text("l"), pressActions: [.input("l")]),
            RomanKeyModel(labelType: .text("ー"), pressActions: [.input("ー")]),
        ],
        [
            RomanFunctionalKeyModel(labelType: .selectable("あ", "A"), rowInfo: (normal: 7, functional: 2, space: 0, enter: 0), pressActions: [.moveTab(.abc)]),
            RomanKeyModel(labelType: .text("z"), pressActions: [.input("z")]),
            RomanKeyModel(labelType: .text("x"), pressActions: [.input("x")]),
            RomanKeyModel(labelType: .text("c"), pressActions: [.input("c")]),
            RomanKeyModel(labelType: .text("v"), pressActions: [.input("v")]),
            RomanKeyModel(labelType: .text("b"), pressActions: [.input("b")]),
            RomanKeyModel(labelType: .text("n"), pressActions: [.input("n")]),
            RomanKeyModel(labelType: .text("m"), pressActions: [.input("m")]),
            RomanFunctionalKeyModel(labelType: .image("delete.left"), rowInfo: (normal: 7, functional: 2, space: 0, enter: 0), pressActions: [.delete(1)], longPressActions: [.delete]),
        ],
        [
            RomanFunctionalKeyModel(labelType: .image("textformat.123"), rowInfo: (normal: 0, functional: 2, space: 1, enter: 1), pressActions: [.moveTab(.number)]),
            RomanChangeKeyboardKeyModel(rowInfo: (normal: 0, functional: 2, space: 1, enter: 1)),
            RomanSpaceKeyModel(),
            RomanEnterKeyModel.shared,
        ],
    ]

    //横に並べる
    var abcKeyboard: [[RomanKeyModelProtocol]] = [
        [
            RomanKeyModel(labelType: .text("q"), pressActions: [.input("q")]),
            RomanKeyModel(labelType: .text("w"), pressActions: [.input("w")]),
            RomanKeyModel(labelType: .text("e"), pressActions: [.input("e")]),
            RomanKeyModel(labelType: .text("r"), pressActions: [.input("r")]),
            RomanKeyModel(labelType: .text("t"), pressActions: [.input("t")]),
            RomanKeyModel(labelType: .text("y"), pressActions: [.input("y")]),
            RomanKeyModel(labelType: .text("u"), pressActions: [.input("u")]),
            RomanKeyModel(labelType: .text("i"), pressActions: [.input("i")]),
            RomanKeyModel(labelType: .text("o"), pressActions: [.input("o")]),
            RomanKeyModel(labelType: .text("p"), pressActions: [.input("p")]),
        ],
        [
            RomanKeyModel(labelType: .text("a"), pressActions: [.input("a")]),
            RomanKeyModel(labelType: .text("s"), pressActions: [.input("s")]),
            RomanKeyModel(labelType: .text("d"), pressActions: [.input("d")]),
            RomanKeyModel(labelType: .text("f"), pressActions: [.input("f")]),
            RomanKeyModel(labelType: .text("g"), pressActions: [.input("g")]),
            RomanKeyModel(labelType: .text("h"), pressActions: [.input("h")]),
            RomanKeyModel(labelType: .text("j"), pressActions: [.input("j")]),
            RomanKeyModel(labelType: .text("k"), pressActions: [.input("k")]),
            RomanKeyModel(labelType: .text("l"), pressActions: [.input("l")]),
            RomanFunctionalKeyModel(labelType: .image("textformat.alt"), rowInfo: (normal: 9, functional: 1, space: 0, enter: 0), pressActions: [.changeCharacterType]),
        ],
        [
            RomanFunctionalKeyModel(labelType: .selectable("A", "あ"), rowInfo: (normal: 7, functional: 2, space: 0, enter: 0), pressActions: [.moveTab(.hira)]),
            RomanKeyModel(labelType: .text("z"), pressActions: [.input("z")]),
            RomanKeyModel(labelType: .text("x"), pressActions: [.input("x")]),
            RomanKeyModel(labelType: .text("c"), pressActions: [.input("c")]),
            RomanKeyModel(labelType: .text("v"), pressActions: [.input("v")]),
            RomanKeyModel(labelType: .text("b"), pressActions: [.input("b")]),
            RomanKeyModel(labelType: .text("n"), pressActions: [.input("n")]),
            RomanKeyModel(labelType: .text("m"), pressActions: [.input("m")]),
            RomanFunctionalKeyModel(labelType: .image("delete.left"), rowInfo: (normal: 7, functional: 2, space: 0, enter: 0), pressActions: [.delete(1)], longPressActions: [.delete]),
        ],
        [
            RomanFunctionalKeyModel(labelType: .image("textformat.123"), rowInfo: (normal: 0, functional: 2, space: 1, enter: 1), pressActions: [.moveTab(.number)]),
            RomanChangeKeyboardKeyModel(rowInfo: (normal: 0, functional: 2, space: 1, enter: 1)),
            RomanSpaceKeyModel(),
            RomanEnterKeyModel.shared,
        ],
    ]


}
