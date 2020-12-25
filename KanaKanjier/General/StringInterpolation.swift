//
//  StringInterpolation.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/25.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI
extension LocalizedStringKey.StringInterpolation{
    mutating func appendInterpolation(_ value: LocalizedStringKey, color: Color? = nil){
        self.appendInterpolation(Text(value).foregroundColor(color))
    }

    mutating func appendInterpolation(bold value: LocalizedStringKey){
        self.appendInterpolation(Text(value).bold())
    }

    mutating func appendInterpolation(underline value: LocalizedStringKey){
        self.appendInterpolation(Text(value).underline())
    }

    mutating func appendInterpolation(italic value: LocalizedStringKey){
        self.appendInterpolation(Text(value).italic())
    }

    mutating func appendInterpolation(monospaced value: LocalizedStringKey){
        self.appendInterpolation(Text(value).font(.system(.body, design: .monospaced)))
    }

    mutating func appendInterpolation(systemImage name: String, color: Color? = nil){
        self.appendInterpolation(Text("\(Image(systemName: name))").foregroundColor(color))
    }
}
