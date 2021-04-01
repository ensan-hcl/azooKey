//
//  LocalizedStringKey.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/14.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import SwiftUI

extension LocalizedStringKey {
    func localized() -> String {
        let path = Bundle.main.path(forResource: "your language", ofType: "lproj")!
        if let bundle = Bundle(path: path) {
            let str = bundle.localized
            return str
        }
        return ""
    }
}
