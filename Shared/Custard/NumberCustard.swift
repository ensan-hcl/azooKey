//
//  NumberCustard.swift
//  azooKey
//
//  Created by ensan on 2022/10/29.
//  Copyright © 2022 ensan. All rights reserved.
//

import CustardKit
import Foundation

extension Custard {
    private static var one_key: CustardInterfaceCustomKey {
        CustardInterfaceCustomKey(
            design: CustardKeyDesign(label: .text("1"), color: .normal),
            press_actions: [.input("1")],
            longpress_actions: .none,
            variations: []
        )
    }

    private static var two_key: CustardInterfaceCustomKey {
        CustardInterfaceCustomKey(
            design: CustardKeyDesign(label: .text("2"), color: .normal),
            press_actions: [.input("2")],
            longpress_actions: .none,
            variations: []
        )
    }

    private static var three_key: CustardInterfaceCustomKey {
        CustardInterfaceCustomKey(
            design: CustardKeyDesign(label: .text("3"), color: .normal),
            press_actions: [.input("3")],
            longpress_actions: .none,
            variations: []
        )
    }

    private static var four_key: CustardInterfaceCustomKey {
        CustardInterfaceCustomKey(
            design: CustardKeyDesign(label: .text("4"), color: .normal),
            press_actions: [.input("4")],
            longpress_actions: .none,
            variations: []
        )
    }

    private static var five_key: CustardInterfaceCustomKey {
        CustardInterfaceCustomKey(
            design: CustardKeyDesign(label: .text("5"), color: .normal),
            press_actions: [.input("5")],
            longpress_actions: .none,
            variations: []
        )
    }

    private static var six_key: CustardInterfaceCustomKey {
        CustardInterfaceCustomKey(
            design: CustardKeyDesign(label: .text("6"), color: .normal),
            press_actions: [.input("6")],
            longpress_actions: .none,
            variations: []
        )
    }

    private static var seven_key: CustardInterfaceCustomKey {
        CustardInterfaceCustomKey(
            design: CustardKeyDesign(label: .text("7"), color: .normal),
            press_actions: [.input("7")],
            longpress_actions: .none,
            variations: []
        )
    }

    private static var eight_key: CustardInterfaceCustomKey {
        CustardInterfaceCustomKey(
            design: CustardKeyDesign(label: .text("8"), color: .normal),
            press_actions: [.input("8")],
            longpress_actions: .none,
            variations: []
        )
    }

    private static var nine_key: CustardInterfaceCustomKey {
        CustardInterfaceCustomKey(
            design: CustardKeyDesign(label: .text("9"), color: .normal),
            press_actions: [.input("9")],
            longpress_actions: .none,
            variations: []
        )
    }

    private static var zero_key: CustardInterfaceCustomKey {
        CustardInterfaceCustomKey(
            design: CustardKeyDesign(label: .text("0"), color: .normal),
            press_actions: [.input("0")],
            longpress_actions: .none,
            variations: []
        )
    }

    private static var point_key: CustardInterfaceCustomKey {
        CustardInterfaceCustomKey(
            design: CustardKeyDesign(label: .text("."), color: .unimportant),
            press_actions: [.input(".")],
            longpress_actions: .none,
            variations: []
        )
    }

    private static var delete_key: CustardInterfaceCustomKey {
        var delete = CustardInterfaceCustomKey.flickDelete()
        delete.design.color = .unimportant
        return delete
    }

    private static var phone_symbols_key: CustardInterfaceCustomKey {
        CustardInterfaceCustomKey(
            design: CustardKeyDesign(label: .text("+#*"), color: .normal),
            press_actions: [.input("+")],
            longpress_actions: .none,
            variations: [
                CustardInterfaceVariation(type: .flickVariation(.top), key: CustardInterfaceVariationKey(
                    design: CustardVariationKeyDesign(label: .text("#")),
                    press_actions: [.input("#")],
                    longpress_actions: .none
                )),
                CustardInterfaceVariation(type: .flickVariation(.right), key: CustardInterfaceVariationKey(
                    design: CustardVariationKeyDesign(label: .text("*")),
                    press_actions: [.input("*")],
                    longpress_actions: .none
                ))
            ]
        )
    }

    static let numberPad = Custard(
        identifier: "azooKey_internal_number_pad",
        language: .none,
        input_style: .direct,
        metadata: CustardMetadata(custard_version: .v1_2, display_name: "数字"),
        interface: CustardInterface(
            keyStyle: .tenkeyStyle,
            keyLayout: .gridFit(.init(rowCount: 3, columnCount: 4)),
            keys: [
                .gridFit(.init(x: 0, y: 0)): .custom(one_key),
                .gridFit(.init(x: 1, y: 0)): .custom(two_key),
                .gridFit(.init(x: 2, y: 0)): .custom(three_key),
                .gridFit(.init(x: 0, y: 1)): .custom(four_key),
                .gridFit(.init(x: 1, y: 1)): .custom(five_key),
                .gridFit(.init(x: 2, y: 1)): .custom(six_key),
                .gridFit(.init(x: 0, y: 2)): .custom(seven_key),
                .gridFit(.init(x: 1, y: 2)): .custom(eight_key),
                .gridFit(.init(x: 2, y: 2)): .custom(nine_key),
                .gridFit(.init(x: 0, y: 3)): .system(.changeKeyboard),
                .gridFit(.init(x: 1, y: 3)): .custom(zero_key),
                .gridFit(.init(x: 2, y: 3)): .custom(delete_key)
            ]
        )
    )

    // 正の10進数を打つキーボード
    static let decimalPad = Custard(
        identifier: "azooKey_internal_decimal_pad",
        language: .none,
        input_style: .direct,
        metadata: CustardMetadata(custard_version: .v1_2, display_name: "数字"),
        interface: CustardInterface(
            keyStyle: .tenkeyStyle,
            keyLayout: .gridFit(.init(rowCount: 3, columnCount: 4)),
            keys: [
                .gridFit(.init(x: 0, y: 0)): .custom(one_key),
                .gridFit(.init(x: 1, y: 0)): .custom(two_key),
                .gridFit(.init(x: 2, y: 0)): .custom(three_key),
                .gridFit(.init(x: 0, y: 1)): .custom(four_key),
                .gridFit(.init(x: 1, y: 1)): .custom(five_key),
                .gridFit(.init(x: 2, y: 1)): .custom(six_key),
                .gridFit(.init(x: 0, y: 2)): .custom(seven_key),
                .gridFit(.init(x: 1, y: 2)): .custom(eight_key),
                .gridFit(.init(x: 2, y: 2)): .custom(nine_key),
                .gridFit(.init(x: 0, y: 3)): .custom(point_key),
                .gridFit(.init(x: 1, y: 3)): .custom(zero_key),
                .gridFit(.init(x: 2, y: 3)): .custom(delete_key)
            ]
        )
    )

    // 電話番号を打つキーボード
    static let phonePad = Custard(
        identifier: "azooKey_internal_phone_pad",
        language: .none,
        input_style: .direct,
        metadata: CustardMetadata(custard_version: .v1_2, display_name: "数字"),
        interface: CustardInterface(
            keyStyle: .tenkeyStyle,
            keyLayout: .gridFit(.init(rowCount: 3, columnCount: 4)),
            keys: [
                .gridFit(.init(x: 0, y: 0)): .custom(one_key),
                .gridFit(.init(x: 1, y: 0)): .custom(two_key),
                .gridFit(.init(x: 2, y: 0)): .custom(three_key),
                .gridFit(.init(x: 0, y: 1)): .custom(four_key),
                .gridFit(.init(x: 1, y: 1)): .custom(five_key),
                .gridFit(.init(x: 2, y: 1)): .custom(six_key),
                .gridFit(.init(x: 0, y: 2)): .custom(seven_key),
                .gridFit(.init(x: 1, y: 2)): .custom(eight_key),
                .gridFit(.init(x: 2, y: 2)): .custom(nine_key),
                .gridFit(.init(x: 0, y: 3)): .custom(phone_symbols_key),
                .gridFit(.init(x: 1, y: 3)): .custom(zero_key),
                .gridFit(.init(x: 2, y: 3)): .custom(delete_key)
            ]
        )
    )
}
