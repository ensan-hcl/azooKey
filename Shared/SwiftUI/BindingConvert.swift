//
//  BindingConvert.swift
//  KanaKanjier
//
//  Created by β α on 2021/04/28.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

public extension Binding {
    func converted<T>(forward forwardConverter: @escaping (Value) -> T, backward backwardConverter: @escaping (T) -> Value) -> Binding<T> {
        .init(
            get: {
                return forwardConverter(self.wrappedValue)
            },
            set: {newValue in
                self.wrappedValue = backwardConverter(newValue)
            }
        )
    }
    func converted<Translator: Intertranslator>(_ translator: Translator.Type) -> Binding<Translator.Second> where Translator.First == Value {
        .init(
            get: {
                return Translator.convert(self.wrappedValue)
            },
            set: {newValue in
                self.wrappedValue = Translator.convert(newValue)
            }
        )
    }
}
