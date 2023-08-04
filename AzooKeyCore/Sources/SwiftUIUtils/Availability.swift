//
//  Availability.swift
//  Availability
//
//  Created by ensan on 2021/07/21.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUI

public extension View {
    @ViewBuilder
    func iOS16_scrollContentBackground(_ visibility: Visibility) -> some View {
        if #available(iOS 16, macOS 13, *) {
            self.scrollContentBackground(visibility)
        } else {
            self
        }
    }
}
