//
//  TextFieldLocalization.swift
//  TextFieldLocalization
//
//  Created by β α on 2021/08/19.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import SwiftUI

extension TextField where Label == Text {
    init(localized titleKey: LocalizedStringKey, text: Binding<String>) {
        self.init(titleKey, text: text)
    }
}
