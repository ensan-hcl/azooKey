//
//  IdentifiableItems.swift
//  KanaKanjier
//
//  Created by β α on 2021/04/30.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

extension Binding where Value: RandomAccessCollection & MutableCollection, Value.Element: Identifiable, Value.Index: Hashable {
    struct IdentifiableItem: Identifiable {
        let item: Value.Element
        let bindedItem: Binding<Value.Element>
        let id: Value.Element.ID
    }

    var identifiableItems: [IdentifiableItem] {
        // debug("return indices", self.wrappedValue.indices)
        // Listが再描画の際に落ちる問題は、Bindingが悪さをしているせいだと考えられる。
        // そこでここでは`Binding`を生成し直すことで対処している。今のところうまく行っている。
        return self.wrappedValue.indices.map { i in
            return .init(
                item: self.wrappedValue[i],
                bindedItem: .init {
                    self.wrappedValue[i]
                } set: {newValue in
                    self.wrappedValue[i] = newValue
                },
                id: self.wrappedValue[i].id
            )
        }
    }
}

