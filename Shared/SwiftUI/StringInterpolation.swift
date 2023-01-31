//
//  StringInterpolation.swift
//  azooKey
//
//  Created by ensan on 2020/12/25.
//  Copyright © 2020 ensan. All rights reserved.
//

import Foundation
import SwiftUI
extension LocalizedStringKey.StringInterpolation {
    mutating func appendInterpolation(_ value: LocalizedStringKey, color: Color? = nil) {
        self.appendInterpolation(Text(value).foregroundColor(color))
    }

    mutating func appendInterpolation(bold value: LocalizedStringKey, color: Color? = nil) {
        self.appendInterpolation(Text(value).bold().foregroundColor(color))
    }

    mutating func appendInterpolation(underline value: LocalizedStringKey, color: Color? = nil) {
        self.appendInterpolation(Text(value).underline().foregroundColor(color))
    }

    mutating func appendInterpolation(italic value: LocalizedStringKey, color: Color? = nil) {
        self.appendInterpolation(Text(value).italic().foregroundColor(color))
    }

    mutating func appendInterpolation(monospaced value: LocalizedStringKey, color: Color? = nil) {
        self.appendInterpolation(Text(value).font(.system(.body, design: .monospaced)).foregroundColor(color))
    }

    mutating func appendInterpolation(systemImage name: String, color: Color? = nil) {
        self.appendInterpolation(Text("\(Image(systemName: name))").foregroundColor(color))
    }
}
