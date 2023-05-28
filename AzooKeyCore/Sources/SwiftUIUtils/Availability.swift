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
    @available(iOS 15.0, *)
    @ViewBuilder
    func iOS16_scrollContentBackground(_ visibility: Visibility) -> some View {
        if #available(iOS 16, *) {
            self.scrollContentBackground(visibility)
        } else {
            self
        }
    }
}
