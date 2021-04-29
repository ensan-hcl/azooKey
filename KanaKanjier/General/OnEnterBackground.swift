//
//  OnEnterBackground.swift
//  KanaKanjier
//
//  Created by β α on 2021/04/22.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    func onEnterBackground(perform action: @escaping (NotificationCenter.Publisher.Output) -> Void ) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification), perform: action)
    }
    
    func onEnterForeground(perform action: @escaping (NotificationCenter.Publisher.Output) -> Void ) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification), perform: action)
    }
}
