//
//  TabBarButton.swift
//
//
//  Created by miwa on 2023/10/05.
//

import SwiftUI

struct TabBarButton<Extension: ApplicationSpecificKeyboardViewExtension>: View {
    @Environment(\.userActionManager) private var action
    @EnvironmentObject private var variableStates: VariableStates
    @State private var calendar = Calendar.current

    // クリスマスには専用アイコンを表示する
    var isXmas: Bool {
        let values = calendar.dateComponents([.month, .day], from: .now)
        return values.month == 12 && values.day == 25
    }

    // 8/1には夏アイコンを表示する
    var isSummerDay: Bool {
        let values = calendar.dateComponents([.month, .day], from: .now)
        return values.month == 8 && values.day == 1
    }

    var body: some View {
        KeyboardBarButton<Extension>(label: .azooKeyIcon(isXmas ? .santaClaus : isSummerDay ? .strawHat : .normal)) {
            self.action.registerAction(.setTabBar(.toggle), variableStates: variableStates)
        }
    }
}
