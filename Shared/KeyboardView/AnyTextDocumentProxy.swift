//
//  AnyTextDocumentProxy.swift
//  azooKey
//
//  Created by ensan on 2023/03/14.
//  Copyright © 2023 ensan. All rights reserved.
//

import SwiftUI

enum AnyTextDocumentProxy {
    /// メインの`UITextDocumentProxy`の設定に用いる
    case mainProxy((any UITextDocumentProxy)?)
    /// `IKTextEditor`系の`UITextDocumentProxy`の設定に用いる
    case ikTextFieldProxy(UUID, (any UITextDocumentProxy)?)
    /// 設定を切り替える場合に用いる
    case preference(Preference)

    enum Preference: UInt8 {
        /// `mainProxy`を優先する
        case main
        /// `ikTextFieldProxy`を優先する
        case ikTextField
    }
}
