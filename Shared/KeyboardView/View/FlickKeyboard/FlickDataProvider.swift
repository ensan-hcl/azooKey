//
//  KeyboardModel.swift
//  Keyboard
//
//  Created by β α on 2020/04/12.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

// M：基本は変わらない
struct FlickDataProvider {
    @KeyboardSetting(.preferredLanguage) private static var preferredLanguage
    static func TabKeys() -> [FlickKeyModelProtocol] {
        let first: FlickKeyModelProtocol = {
            switch preferredLanguage.first {
            case .el_GR: return FlickChangeKeyboardModel.shared
            case .en_US: return FlickTabKeyModel.abcTabKeyModel
            case .ja_JP: return FlickTabKeyModel.hiraTabKeyModel
            case .none: return FlickChangeKeyboardModel.shared
            }
        }()

        let second: FlickKeyModelProtocol? = {
            guard let second = preferredLanguage.second else {
                return nil
            }
            switch second {
            case .none: return nil
            case .el_GR: return FlickChangeKeyboardModel.shared
            case .en_US: return FlickTabKeyModel.abcTabKeyModel
            case .ja_JP: return FlickTabKeyModel.hiraTabKeyModel
            }
        }()

        if let second {
            return [
                FlickTabKeyModel.numberTabKeyModel,
                second,
                first,
                FlickChangeKeyboardModel.shared
            ]
        } else {
            return [
                FlickKeyModel(
                    labelType: .image("list.bullet"),
                    pressActions: [.toggleTabBar], longPressActions: .init(start: [.toggleTabBar]),
                    flickKeys: [:],
                    needSuggestView: false,
                    keycolorType: .tabkey
                ),
                FlickTabKeyModel.numberTabKeyModel,
                first,
                FlickChangeKeyboardModel.shared
            ]
        }
    }
    // 縦に並べる
    var hiraKeyboard: [[FlickKeyModelProtocol]] = [
        // 第1列
        Self.TabKeys(),
        // 第2列
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
            FlickKogakiKeyModel.shared

        ],
        // 第3列
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
            ])

        ],
        // 第4列
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
            FlickKanaSymbolsKeyModel.shared
        ],
        // 第5列
        [
            FlickKeyModel.delete,
            FlickSpaceKeyModel.shared,
            FlickEnterKeyModel.shared
        ]

    ]

    // 縦に並べる
    var abcKeyboard: [[FlickKeyModelProtocol]] = [
        // 第1列
        Self.TabKeys(),
        // 第2列
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
                )
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
                )
            ]),
            FlickAaKeyModel.shared

        ],
        // 第3列
        [
            FlickKeyModel(labelType: .text("ABC"), pressActions: [.input("a")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("B"),
                    pressActions: [.input("b")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("C"),
                    pressActions: [.input("c")]
                )
            ]),
            FlickKeyModel(labelType: .text("JKL"), pressActions: [.input("j")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("K"),
                    pressActions: [.input("k")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("L"),
                    pressActions: [.input("l")]
                )
            ]),
            FlickKeyModel(labelType: .text("TUV"), pressActions: [.input("t")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("U"),
                    pressActions: [.input("u")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("V"),
                    pressActions: [.input("v")]
                )
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
                )
            ])

        ],
        // 第4列
        [
            FlickKeyModel(labelType: .text("DEF"), pressActions: [.input("d")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("E"),
                    pressActions: [.input("e")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("F"),
                    pressActions: [.input("f")]
                )
            ]),

            FlickKeyModel(labelType: .text("MNO"), pressActions: [.input("m")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("N"),
                    pressActions: [.input("n")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("O"),
                    pressActions: [.input("o")]
                )
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
                )
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
            ])
        ],
        // 第5列
        [
            FlickKeyModel.delete,
            FlickSpaceKeyModel.shared,
            FlickEnterKeyModel.shared
        ]

    ]
    // 縦に並べる
    var numberKeyboard: [[FlickKeyModelProtocol]] = [
        // 第1列
        Self.TabKeys(),
        // 第2列
        [
            FlickKeyModel(labelType: .symbols(["1", "☆", "♪", "→"]), pressActions: [.input("1")], flickKeys: [
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
                )
            ]),
            FlickKeyModel(labelType: .symbols(["4", "○", "＊", "・"]), pressActions: [.input("4")], flickKeys: [
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
                )
            ]),
            FlickKeyModel(labelType: .symbols(["7", "「", "」", ":"]), pressActions: [.input("7")], flickKeys: [
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
                )
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
                )

            ])
        ],
        // 第3列
        [
            FlickKeyModel(labelType: .symbols(["2", "¥", "$", "€"]), pressActions: [.input("2")], flickKeys: [
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
                )
            ]),
            FlickKeyModel(labelType: .symbols(["5", "+", "×", "÷"]), pressActions: [.input("5")], flickKeys: [
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
                )
                /*
                 .bottom: FlickedKeyModel(
                 labelType: .text("DEBUG"),
                 pressActions: [.DEBUG_DATA_INPUT]
                 ),
                 */
            ]),
            FlickKeyModel(labelType: .symbols(["8", "〒", "々", "〆"]), pressActions: [.input("8")], flickKeys: [
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
                )
            ]),
            FlickKeyModel(labelType: .symbols(["0", "〜", "…"]), pressActions: [.input("0")], flickKeys: [
                .left: FlickedKeyModel(
                    labelType: .text("〜"),
                    pressActions: [.input("〜")]
                ),
                .top: FlickedKeyModel(
                    labelType: .text("…"),
                    pressActions: [.input("…")]
                )
            ])

        ],
        // 第4列
        [
            FlickKeyModel(labelType: .symbols(["3", "%", "°", "#"]), pressActions: [.input("3")], flickKeys: [
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
                )
            ]),

            FlickKeyModel(labelType: .symbols(["6", "<", "=", ">"]), pressActions: [.input("6")], flickKeys: [
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
                )
            ]),

            FlickKeyModel(labelType: .symbols(["9", "^", "|", "\\"]), pressActions: [.input("9")], flickKeys: [
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
                )
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
            ])
        ],
        // 第5列
        [
            FlickKeyModel.delete,
            FlickSpaceKeyModel.shared,
            FlickEnterKeyModel.shared
        ]

    ]

}
