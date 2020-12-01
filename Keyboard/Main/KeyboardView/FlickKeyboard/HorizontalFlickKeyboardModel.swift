//
//  KeyboardModel.swift
//  Keyboard
//
//  Created by β α on 2020/04/12.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

final class HorizontalKeyboardModelVariableSection: ObservableObject{
    @Published var tabState: TabState = .hira
    @Published var isResultViewExpanded = false
}

//M：基本は変わらない
struct HorizontalFlickKeyboardModel: KeyboardModelProtocol{
    
    //変更の可能性がある部分
    var variableSection = HorizontalKeyboardModelVariableSection()

    let resultModel = ResultModel()
    let expandedResultModel = ExpandedResultModel()

    let enterKeyModel: EnterKeyModelProtocol = FlickEnterKeyModel.shared
    let hiraTabKeyModel = TabKeyModel.hiraTabKeyModel
    let abcTabKeyModel = TabKeyModel.abcTabKeyModel
    let numberTabKeyModel = TabKeyModel.numberTabKeyModel

    var tabState: TabState {
        return self.variableSection.tabState
    }

    func setTabState(state: TabState){
        self.variableSection.tabState = state
        self.hiraTabKeyModel.setKeyboardState(new: state)
        self.abcTabKeyModel.setKeyboardState(new: state)
        self.numberTabKeyModel.setKeyboardState(new: state)
    }

    func expandResultView(_ results: [ResultData]) {
        self.variableSection.isResultViewExpanded = true
        self.expandedResultModel.expand(results: results)
    }

    func collapseResultView(){
        self.variableSection.isResultViewExpanded = false
    }

    //縦に並べる
    var hiraKeyboard:[[FlickKeyModelProtocol]] = [
        //第1列
        [
            TabKeyModel.numberTabKeyModel,
            TabKeyModel.abcTabKeyModel,
            TabKeyModel.hiraTabKeyModel,
            FlickChangeKeyboardModel.shared
        ],
        //第2列
        [
            FlickKeyModel(labelType: .text("あ"), pressActions: [.input("あ")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("い"),
                    pressActions: [.input("い")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("う"),
                    pressActions: [.input("う")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("え"),
                    pressActions: [.input("え")]
                ),
                .bottom: FlickedKeyModel(
                    labelType: .text("お"),
                    pressActions: [.input("お")]
                )

            ]),
            FlickKeyModel(labelType: .text("た"), pressActions: [.input("た")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("ち"),
                    pressActions: [.input("ち")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("つ"),
                    pressActions: [.input("つ")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("て"),
                    pressActions: [.input("て")]
                ),
                .bottom: FlickedKeyModel(
                    labelType: .text("と"),
                    pressActions: [.input("と")]
                )
            ]),
            FlickKeyModel(labelType: .text("ま"), pressActions: [.input("ま")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("み"),
                    pressActions: [.input("み")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("む"),
                    pressActions: [.input("む")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("め"),
                    pressActions: [.input("め")]
                ),
                .bottom: FlickedKeyModel(
                    labelType: .text("も"),
                    pressActions: [.input("も")]
                )

            ]),
            KogakiKeyModel.shared

        ],
        //第3列
        [
            FlickKeyModel(labelType: .text("か"), pressActions: [.input("か")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("き"),
                    pressActions: [.input("き")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("く"),
                    pressActions: [.input("く")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("け"),
                    pressActions: [.input("け")]
                ),
                .bottom: FlickedKeyModel(
                    labelType: .text("こ"),
                    pressActions: [.input("こ")]
                )

            ]),
            FlickKeyModel(labelType: .text("な"), pressActions: [.input("な")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("に"),
                    pressActions: [.input("に")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("ぬ"),
                    pressActions: [.input("ぬ")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("ね"),
                    pressActions: [.input("ね")]
                ),
                .bottom: FlickedKeyModel(
                    labelType: .text("の"),
                    pressActions: [.input("の")]
                )

            ]),
            FlickKeyModel(labelType: .text("や"), pressActions: [.input("や")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("「"),
                    pressActions: [.input("「")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("ゆ"),
                    pressActions: [.input("ゆ")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("」"),
                    pressActions: [.input("」")]
                ),
                .bottom: FlickedKeyModel(
                    labelType: .text("よ"),
                    pressActions: [.input("よ")]
                )

            ]),
            FlickKeyModel(labelType: .text("わ"), pressActions: [.input("わ")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("を"),
                    pressActions: [.input("を")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("ん"),
                    pressActions: [.input("ん")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("ー"),
                    pressActions: [.input("ー")]
                )
            ]),

        ],
        //第4列
        [
            FlickKeyModel(labelType: .text("さ"), pressActions: [.input("さ")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("し"),
                    pressActions: [.input("し")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("す"),
                    pressActions: [.input("す")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("せ"),
                    pressActions: [.input("せ")]
                ),
                .bottom: FlickedKeyModel(
                    labelType: .text("そ"),
                    pressActions: [.input("そ")]
                )

            ]),
            FlickKeyModel(labelType: .text("は"), pressActions: [.input("は")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("ひ"),
                    pressActions: [.input("ひ")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("ふ"),
                    pressActions: [.input("ふ")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("へ"),
                    pressActions: [.input("へ")]
                ),
                .bottom: FlickedKeyModel(
                    labelType: .text("ほ"),
                    pressActions: [.input("ほ")]
                )

            ]),
            FlickKeyModel(labelType: .text("ら"), pressActions: [.input("ら")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("り"),
                    pressActions: [.input("り")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("る"),
                    pressActions: [.input("る")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("れ"),
                    pressActions: [.input("れ")]
                ),
                .bottom: FlickedKeyModel(
                    labelType: .text("ろ"),
                    pressActions: [.input("ろ")]
                )

            ]),
            FlickKeyModel(labelType: .text("､｡?!"), pressActions: [.input("、")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("。"),
                    pressActions: [.input("。")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("？"),
                    pressActions: [.input("？")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("！"),
                    pressActions: [.input("！")]
                )
            ]),
        ],
        //第5列
        [
            FlickKeyModel(labelType: .image("delete.left"), pressActions: [.delete(1)], longPressActions: [.delete], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .image("xmark"),
                    pressActions: [.smoothDelete]
                )
            ], needSuggestView: false, keycolorType: .tabkey),
            FlickKeyModel(labelType: .text("空白"), pressActions: [.input(" ")], longPressActions: [.toggleShowMoveCursorView], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("←"),
                    pressActions: [.moveCursor(-1)],
                    longPressActions: [.moveCursor(.left)]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("全角"),
                    pressActions: [.input("　")]
                ),
                .bottom: FlickedKeyModel(
                    labelType: .text("Tab"),
                    pressActions: [.input("\u{0009}")]
                )

            ], needSuggestView: false, keycolorType: .tabkey),
            FlickEnterKeyModel.shared
        ],

    ]

    //縦に並べる
    var abcKeyboard:[[FlickKeyModelProtocol]] = [
        //第1列
        [
            TabKeyModel.numberTabKeyModel,
            TabKeyModel.abcTabKeyModel,
            TabKeyModel.hiraTabKeyModel,
            FlickChangeKeyboardModel.shared

        ],
        //第2列
        [
            FlickKeyModel(labelType: .text("@#/&_"), pressActions: [.input("@")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("#"),
                    pressActions: [.input("#")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("/"),
                    pressActions: [.input("/")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("&"),
                    pressActions: [.input("&")]
                ),
                .bottom: FlickedKeyModel(
                    labelType: .text("_"),
                    pressActions: [.input("_")]
                )
            ]),
            FlickKeyModel(labelType: .text("GHI"), pressActions: [.input("g")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("H"),
                    pressActions: [.input("h")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("I"),
                    pressActions: [.input("i")]
                ),
            ]),
            FlickKeyModel(labelType: .text("PQRS"), pressActions: [.input("p")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("Q"),
                    pressActions: [.input("q")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("R"),
                    pressActions: [.input("r")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("S"),
                    pressActions: [.input("s")]
                ),
            ]),
            FlickKeyModel(labelType: .text("a/A"), pressActions: [.changeCharacterType], flickKeys: [:]),

        ],
        //第3列
        [
            FlickKeyModel(labelType: .text("ABC"), pressActions: [.input("a")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("B"),
                    pressActions: [.input("b")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("C"),
                    pressActions: [.input("c")]
                ),
            ]),
            FlickKeyModel(labelType: .text("JKL"), pressActions: [.input("j")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("K"),
                    pressActions: [.input("k")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("L"),
                    pressActions: [.input("l")]
                ),
            ]),
            FlickKeyModel(labelType: .text("TUV"), pressActions: [.input("t")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("U"),
                    pressActions: [.input("u")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("V"),
                    pressActions: [.input("v")]
                ),
            ]),
            FlickKeyModel(labelType: .text("\'\"()"), pressActions: [.input("\'")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("\""),
                    pressActions: [.input("\"")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("("),
                    pressActions: [.input("(")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text(")"),
                    pressActions: [.input(")")]
                ),
            ]),

        ],
        //第4列
        [
            FlickKeyModel(labelType: .text("DEF"), pressActions: [.input("d")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("E"),
                    pressActions: [.input("e")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("F"),
                    pressActions: [.input("f")]
                ),
            ]),

            FlickKeyModel(labelType: .text("MNO"), pressActions: [.input("m")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("N"),
                    pressActions: [.input("n")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("O"),
                    pressActions: [.input("o")]
                ),
            ]),

            FlickKeyModel(labelType: .text("WXYZ"), pressActions: [.input("w")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("X"),
                    pressActions: [.input("x")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("Y"),
                    pressActions: [.input("y")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("Z"),
                    pressActions: [.input("z")]
                ),
            ]),
            FlickKeyModel(labelType: .text(".,?!"), pressActions: [.input(".")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text(","),
                    pressActions: [.input(",")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("?"),
                    pressActions: [.input("?")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("!"),
                    pressActions: [.input("!")]
                )
            ]),
        ],
        //第5列
        [
            FlickKeyModel(labelType: .image("delete.left"), pressActions: [.delete(1)], longPressActions: [.delete], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .image("xmark"),
                    pressActions: [.smoothDelete]
                )
            ], needSuggestView: false, keycolorType: .tabkey),
            FlickKeyModel(labelType: .text("空白"), pressActions: [.input(" ")], longPressActions: [.toggleShowMoveCursorView], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("←"),
                    pressActions: [.moveCursor(-1)],
                    longPressActions: [.moveCursor(.left)]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("全角"),
                    pressActions: [.input("　")]
                ),
                .bottom: FlickedKeyModel(
                    labelType: .text("Tab"),
                    pressActions: [.input("\u{0009}")]
                )

            ], needSuggestView: false, keycolorType: .tabkey),
            FlickEnterKeyModel.shared
        ],

    ]
    //縦に並べる
    var numberKeyboard:[[FlickKeyModelProtocol]] = [
        //第1列
        [
            TabKeyModel.numberTabKeyModel,
            TabKeyModel.abcTabKeyModel,
            TabKeyModel.hiraTabKeyModel,
            FlickChangeKeyboardModel.shared
        ],
        //第2列
        [
            FlickKeyModel(labelType: .text("1"), pressActions: [.input("1")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("☆"),
                    pressActions: [.input("☆")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("♪"),
                    pressActions: [.input("♪")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("→"),
                    pressActions: [.input("→")]
                ),
            ]),
            FlickKeyModel(labelType: .text("4"), pressActions: [.input("4")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("○"),
                    pressActions: [.input("○")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("＊"),
                    pressActions: [.input("＊")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("・"),
                    pressActions: [.input("・")]
                ),
            ]),
            FlickKeyModel(labelType: .text("7"), pressActions: [.input("7")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("「"),
                    pressActions: [.input("「")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("」"),
                    pressActions: [.input("」")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text(":"),
                    pressActions: [.input(":")]
                ),
            ]),
            FlickKeyModel(labelType: .text("()[]"), pressActions: [.input("(")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text(")"),
                    pressActions: [.input(")")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("["),
                    pressActions: [.input("[")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("]"),
                    pressActions: [.input("]")]
                ),

            ]),
        ],
        //第3列
        [
            FlickKeyModel(labelType: .text("2"), pressActions: [.input("2")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("¥"),
                    pressActions: [.input("¥")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("$"),
                    pressActions: [.input("$")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("€"),
                    pressActions: [.input("€")]
                ),
            ]),
            FlickKeyModel(labelType: .text("5"), pressActions: [.input("5")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("+"),
                    pressActions: [.input("+")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("×"),
                    pressActions: [.input("×")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("÷"),
                    pressActions: [.input("÷")]
                ),
            ]),
            FlickKeyModel(labelType: .text("8"), pressActions: [.input("8")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("〒"),
                    pressActions: [.input("〒")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("々"),
                    pressActions: [.input("々")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("〆"),
                    pressActions: [.input("〆")]
                ),
            ]),
            FlickKeyModel(labelType: .text("0"), pressActions: [.input("0")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("〜"),
                    pressActions: [.input("〜")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("…"),
                    pressActions: [.input("…")]
                ),
            ]),

        ],
        //第4列
        [
            FlickKeyModel(labelType: .text("3"), pressActions: [.input("3")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("%"),
                    pressActions: [.input("%")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("°"),
                    pressActions: [.input("°")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("#"),
                    pressActions: [.input("#")]
                ),
            ]),

            FlickKeyModel(labelType: .text("6"), pressActions: [.input("6")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("<"),
                    pressActions: [.input("<")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("="),
                    pressActions: [.input("=")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text(">"),
                    pressActions: [.input(">")]
                ),
            ]),

            FlickKeyModel(labelType: .text("9"), pressActions: [.input("9")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("^"),
                    pressActions: [.input("^")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("|"),
                    pressActions: [.input("|")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("\\"),
                    pressActions: [.input("\\")]
                ),
            ]),
            FlickKeyModel(labelType: .text(".,-/"), pressActions: [.input(".")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text(","),
                    pressActions: [.input(",")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("-"),
                    pressActions: [.input("-")]
                ),
                .right: FlickedKeyModel(
                    labelType: .text("/"),
                    pressActions: [.input("/")]
                )
            ]),
        ],
        //第5列
        [
            FlickKeyModel(labelType: .image("delete.left"), pressActions: [.delete(1)], longPressActions: [.delete], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .image("xmark"),
                    pressActions: [.smoothDelete]
                )
            ], needSuggestView: false, keycolorType: .tabkey),
            FlickKeyModel(labelType: .text("空白"), pressActions: [.input(" ")], longPressActions: [.toggleShowMoveCursorView], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("←"),
                    pressActions: [.moveCursor(-1)],
                    longPressActions: [.moveCursor(.left)]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("全角"),
                    pressActions: [.input("　")]
                ),
                .bottom: FlickedKeyModel(
                    labelType: .text("Tab"),
                    pressActions: [.input("\u{0009}")]
                )

            ], needSuggestView: false, keycolorType: .tabkey),
            FlickEnterKeyModel.shared
        ],

    ]

}
