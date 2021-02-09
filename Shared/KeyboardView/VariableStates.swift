//
//  VariableStates.swift
//  Keyboard
//
//  Created by β α on 2021/02/06.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

///実行中変更され、かつViewが変更を検知できるべき値。
final class VariableStates: ObservableObject{
    var action: ActionDepartment = ActionDepartment()
    static let shared = VariableStates()
    private var lastVerticalTabState: TabState? = nil
    var inputStyle: InputStyle = .direct

    private init(){}

    @Published var keyboardLanguage: KeyboardLanguage = .japanese
    @Published var keyboardOrientation: KeyboardOrientation = .vertical
    @Published var keyboardLayout: KeyboardLayout = .flick

    @Published var aAKeyState: AaKeyState = .normal
    @Published var enterKeyType: UIReturnKeyType = .default
    @Published var enterKeyState: EnterKeyState = .return(.default)
    @Published var tabState: TabState = .hira

    @Published var isTextMagnifying = false
    @Published var magnifyingText = ""

    @Published var showMoveCursorView = false

    @Published var refreshing = true

    func initialize(){
        if let lastTabState = self.lastVerticalTabState{
            self.setTabState(lastTabState)
            self.lastVerticalTabState = nil
        }
        self.setKeyboardType(for: self.tabState)
    }

    func refreshView(){
        refreshing.toggle()
    }

    enum RoughEnterKeyState{
        case `return`
        case edit
        case complete
    }

    func setEnterKeyState(_ state: RoughEnterKeyState){
        switch state{
        case .return:
            self.enterKeyState = .return(enterKeyType)
        case .edit:
            self.enterKeyState = .edit
        case .complete:
            self.enterKeyState = .complete
        }
    }

    func setTabState(_ state: TabState){
        if state == .abc{
            self.keyboardLanguage = .english
        }
        if state == .hira{
            self.keyboardLanguage = .japanese
        }
        self.lastVerticalTabState = self.tabState
        self.tabState = state
        self.setKeyboardType(for: state)
    }

    func setUIReturnKeyType(type: UIReturnKeyType){
        self.enterKeyType = type
        if case let .return(prev) = self.enterKeyState, prev != type{
            self.setEnterKeyState(.return)
        }
    }

    ///workarounds
    ///* 1回目に値を保存してしまう
    ///* if bool {} else{}にしてboolをvariableSectionに持たせてtoggleする。←これを採用した。
    func setOrientation(_ orientation: KeyboardOrientation){
        if self.keyboardOrientation == orientation{
            self.refreshView()
            return
        }
        self.keyboardOrientation = orientation
    }

    func setKeyboardType(for tab: TabState){
        let japaneseLayout = SettingData.shared.keyboardLayout(for: .japaneseKeyboardLayout)
        let type: KeyboardLayout
        switch tab{
        case .hira:
            type = japaneseLayout
        case .abc:
            type = SettingData.shared.keyboardLayout(for: .englishKeyboardLayout)
        default:
            type = Design.shared.layout
        }
        self.inputStyle = japaneseLayout == .flick ? .direct : .roman
        if self.keyboardLayout != type{
            self.keyboardLayout = type
            self.refreshView()
            return
        }
    }
}

