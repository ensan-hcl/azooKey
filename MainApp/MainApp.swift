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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(MainAppStates())
        }
    }
}
