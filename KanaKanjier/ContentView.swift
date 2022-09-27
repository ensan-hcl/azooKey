//
//  ContentView.swift
//  KanaKanjier
//
//  Created by β α on 2020/09/03.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 0
    @ObservedObject private var storeVariableSection = Store.variableSection
    @State private var isPresented = true

    @State private var messageManager = MessageManager()
    @State private var showWalkthrough = false

    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                TipsTabView()
                    .tabItem {
                        TabItem(title: "使い方", systemImage: "lightbulb.fill")
                    }
                    .tag(0)
                ThemeTabView()
                    .tabItem {
                        TabItem(title: "着せ替え", systemImage: "photo")
                    }
                    .tag(1)
                CustomizeTabView()
                    .tabItem {
                        TabItem(title: "拡張", systemImage: "gearshape.2.fill")
                    }
                    .tag(2)
                SettingTabView()
                    .tabItem {
                        TabItem(title: "設定", systemImage: "wrench.fill")
                    }
                    .tag(3)
                #if DEBUG
                TestView(itemWidth: 50)
                    .tabItem {
                        TabItem(title: "テスト", systemImage: "keyboard")
                    }
                    .tag(4)
                #endif
            }
            .fullScreenCover(isPresented: $storeVariableSection.requireFirstOpenView) {
                EnableAzooKeyView()
            }
            .onChange(of: selection) {value in
                if value == 2 {
                    if ContainerInternalSetting.shared.walkthroughState.shouldDisplay(identifier: .extensions) {
                        self.showWalkthrough = true
                    }
                }
            }
            .onChange(of: storeVariableSection.importFile) { value in
                if value != nil {
                    selection = 2
                }
            }
            .sheet(isOpen: $showWalkthrough, maxHeight: UIScreen.main.bounds.height * 0.9, minHeight: 0, headerColor: .background) {
                CustomizeTabWalkthroughView(isShowing: $showWalkthrough)
                    .background(Color.background)
            }
            ForEach(messageManager.necessaryMessages, id: \.id) {data in
                if messageManager.requireShow(data.id) {
                    switch data.id {
                    case .mock, .liveconversion_introduction, .ver1_8_autocomplete_introduction:
                        EmptyView()
                    case .ver1_5_update_loudstxt:
                        // ユーザ辞書を更新する
                        DataUpdateView(id: data.id, manager: $messageManager) {
                            let builder = LOUDSBuilder(txtFileSplit: 2048)
                            builder.process()
                            Store.shared.noticeReloadUserDict()
                        }
                    case .iOS14_5_new_emoji, .iOS15_4_new_emoji:
                        // 絵文字を更新する
                        DataUpdateView(id: data.id, manager: $messageManager) {
                            AdditionalDictManager().userDictUpdate()
                        }
                    }
                }
            }
        }
    }
}

private struct TabItem: View {
    init(title: LocalizedStringKey, systemImage: String) {
        self.title = title
        self.systemImage = systemImage
    }

    private let title: LocalizedStringKey
    private let systemImage: String

    var body: some View {
        VStack {
            Image(systemName: systemImage).font(.system(size: 20, weight: .light))
                .foregroundColor(.systemGray2)
            Text(title)
        }
    }
}

#if DEBUG
struct TestView: View {
    private enum MoveCursorBarGestureState {
        case unactive
        case moving(start: CGPoint, last: CGPoint)
    }

    let itemWidth: CGFloat

    @State private var displayLeftIndex = 0
    @State private var displayRightIndex = 10
    @State private var delta: CGFloat = 0
    @State private var gestureState: MoveCursorBarGestureState = .unactive

    @State private var viewWidth: CGFloat = 3000

    private var gesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged {value in
                switch self.gestureState {
                case .unactive:
                    self.gestureState = .moving(start: value.location, last: value.location)
                case let .moving(startLocation, latestLocation):
                    gestureState = .moving(start: startLocation, last: value.location)
                    let dx = value.location.x - latestLocation.x
                    if dx.isZero {
                        break
                    }
                    withAnimation(.linear(duration: 0.05)) {
                        delta += dx
                        debug("delta: \(delta), dx: \(dx)")
                    }
                    // -100より小さい位置が先頭の場合はrangeを狭める
                    while CGFloat(displayLeftIndex) * itemWidth + delta < -2 * itemWidth {
                        displayLeftIndex += 1
                    }
                    // -70より小さい位置が先頭の場合はrangeを広げる
                    while CGFloat(displayLeftIndex) * itemWidth + delta >= -0.5 * itemWidth {
                        displayLeftIndex -= 1
                    }

                    // 800より大きい位置が末尾の場合はrangeを狭める
                    while CGFloat(displayRightIndex) * itemWidth + delta > viewWidth + 2 * itemWidth {
                        displayRightIndex -= 1
                    }
                    // 770より小さい位置が末尾の場合はrangeを広げる
                    while CGFloat(displayRightIndex) * itemWidth + delta <= viewWidth + 0.5 * itemWidth {
                        displayRightIndex += 1
                    }
                    debug(displayLeftIndex, displayRightIndex, delta, displayRightIndex - displayLeftIndex)
                }
            }
            .onEnded {_ in
                self.gestureState = .unactive
            }
    }

    let values = Array("あいうえおかきくけこ")

    func getItem(at index: Int) -> some View {
        Text(verbatim: String(values[((index % 10) + 10) % 10]))
            .padding()
            .background(Color.yellow)

    }

    var body: some View {
        GeometryReader { geometry in
            ForEach(displayLeftIndex ..< displayRightIndex, id: \.self) { i in
                getItem(at: i)
                    .frame(width: itemWidth)
                    .position(x: CGFloat(i) * itemWidth)
                    .offset(x: delta)
            }
            .gesture(gesture)
            .onAppear {
                viewWidth = geometry.size.width
            }
        }
    }
}
#endif
