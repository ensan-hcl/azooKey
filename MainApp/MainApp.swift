//
//  App.swift
//  App
//
//  Created by ensan on 2021/08/22.
//  Copyright © 2021 ensan. All rights reserved.
//

import SwiftUI

@main
struct MainApp: App {
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
