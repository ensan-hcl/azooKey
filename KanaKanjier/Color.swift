//
//  Color.swift
//  KanaKanjier
//
//  Created by β α on 2020/11/28.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

extension Color{
    static let systemGray: Color = Color(UIColor.systemGray)
    static let systemGray2: Color = Color(UIColor.systemGray2)
    static let systemGray3: Color = Color(UIColor.systemGray3)
    static let systemGray4: Color = Color(UIColor.systemGray4)
    static let systemGray5: Color = Color(UIColor.systemGray5)
    static let systemGray6: Color = Color(UIColor.systemGray6)
}

extension LocalizedStringKey.StringInterpolation{
    mutating func appendInterpolation(bold value: LocalizedStringKey){
        self.appendInterpolation(Text(value).bold())
    }

    mutating func appendInterpolation(underline value: LocalizedStringKey){
        self.appendInterpolation(Text(value).underline())
    }

    mutating func appendInterpolation(italic value: LocalizedStringKey){
        self.appendInterpolation(Text(value).italic())
    }

    mutating func appendInterpolation(systemImage name: String){
        self.appendInterpolation(Image(systemName: name))
    }
}
