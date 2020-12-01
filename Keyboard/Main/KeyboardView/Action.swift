//
//  Action.swift
//  Keyboard
//
//  Created by β α on 2020/04/11.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation

enum ActionType{
    //テキスト関係
    case input(String)          //テキストの入力
    case delete(Int)            //テキストの削除
    case smoothDelete           //テキストの一括削除
    case deselectAndUseAsInputting   //選択を解除して編集中とみなす
    //取り込み関係
    case saveSelectedTextIfNeeded           //選択部分が存在していたら一時保存する。
    case restoreSelectedTextIfNeeded        //選択部分の一時保存したデータを取り出して代入する
    //カーソル関係
    case moveCursor(Int)
    case toggleShowMoveCursorView

    //変換関連
    case enter
    case changeCharacterType    //濁点、半濁点、小さい文字

    case hideLearningMemory
    //タブの変更
    case moveTab(TabState)
    //デバッグ用
    case DEBUG_DATA_INPUT
}

extension ActionType{
    static func makeFunctionInputActionSet(name: String, argumentCount: Int = 1) -> [ActionType] {
        /*
         sqrt()
         ↑.saveSelectedTextIfNeeded, .input("sqrt()"), .moveCursor(-1), .restoreSelectedTextIfNeeded
         のようにする。ただしこの返り値を利用する場合には.flatmap{$0}が必須。
         */
        return [
            .saveSelectedTextIfNeeded,
            .input("\(name)()"),
            .moveCursor(-1),
            .restoreSelectedTextIfNeeded
        ]
    }
}

enum MoveDirection{
    case left
    case right
}

//長押しor長フリックされた際の挙動のタイプ
enum KeyLongPressActionType: Equatable{
    //ここに値を追加するときは、必ずEquatableの実装も更新する必要がある。
    case input(String)
    case delete
    case moveCursor(MoveDirection)
    case toggleShowMoveCursorView

    
    static func == (lsb: KeyLongPressActionType, rsb: KeyLongPressActionType) -> Bool {
        switch (lsb, rsb){
        case let (.input(l), .input(r)):
            return l == r
        case (.delete, .delete):
            return true
        case let (.moveCursor(l),.moveCursor(r)):
            return l == r
        case (.toggleShowMoveCursorView,.toggleShowMoveCursorView):
            return true
        default:
            return false
        }
    }
}

