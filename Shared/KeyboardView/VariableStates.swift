//
//  VariableStates.swift
//  Keyboard
//
//  Created by ensan on 2021/02/06.
//  Copyright © 2021 ensan. All rights reserved.
//

import CustardExpressionEvaluator
import CustardKit
import Foundation
import SwiftUI

/// 実行中変更され、かつViewが変更を検知できるべき値。
final class VariableStates: ObservableObject {
    static let shared = VariableStates()
    private(set) var inputStyle: InputStyle = .direct
    private(set) var tabManager = TabManager()
    private(set) var clipboardHistoryManager = ClipboardHistoryManager()

    private init() {}

    @Published var keyboardLanguage: KeyboardLanguage = .ja_JP
    @Published var keyboardOrientation: KeyboardOrientation = .vertical
    @Published private(set) var keyboardLayout: KeyboardLayout = .flick

    struct BoolStates: CustardExpressionEvaluatorContext {
        func getValue(for key: String) -> ExpressionValue? {
            if let boolValue = self[key] {
                return .bool(boolValue)
            }
            return nil
        }

        var isTextMagnifying = false
        var isCapsLocked = false

        static let isCapsLockedKey = "isCapsLocked"
        static let hasFullAccessKey = "has_full_access"
        // ビルトインのステートとカスタムのステートの両方を適切に扱いたい
        fileprivate var custardStates: [String: Bool] = [:]

        func evaluateExpression(_ compiledExpression: CompiledExpression) -> Bool? {
            debug(self.custardStates)
            do {
                let condition = try CustardExpressionEvaluator(context: VariableStates.shared.boolStates).evaluate(compiledExpression: compiledExpression)
                if case let .bool(value) = condition {
                    return value
                }
                return nil
            } catch {
                debug("evaluateExpression", error)
                return nil
            }
        }

        mutating func initializeState(_ key: String, with value: Bool) {
            if !self.custardStates.keys.contains(key) {
                self.custardStates[key] = value
            }
        }

        subscript(_ key: String) -> Bool? {
            get {
                if key == "isTextMagnifying" {
                    return self.isTextMagnifying
                } else if key == Self.hasFullAccessKey {
                    return SemiStaticStates.shared.hasFullAccess
                } else if key == Self.isCapsLockedKey {
                    return self.isCapsLocked
                }
                return custardStates[key]
            }
            set {
                if let newValue {
                    if key == Self.hasFullAccessKey {
                        // subscript経由ではRead Onlyにする
                        return
                    } else if key == "isTextMagnifying" {
                        self.isTextMagnifying = newValue
                    } else if key == Self.isCapsLockedKey {
                        self.isCapsLocked = newValue
                    } else {
                        custardStates[key] = newValue
                    }
                }
            }
        }
    }

    // Bool値の変数はここにまとめる
    @Published var boolStates = BoolStates()

    // 片手モードの実行時、キーボードの幅はinterfaceSizeによって決定できる。
    @Published var interfaceSize: CGSize = .zero
    @Published var interfacePosition: CGPoint = .zero

    @Published var enterKeyType: UIReturnKeyType = .default
    @Published var enterKeyState: EnterKeyState = .return(.default)

    @Published var barState: BarState = .none

    @Published var magnifyingText = ""

    @Published var keyboardType: UIKeyboardType = .default

    @Published var refreshing = true

    @Published private(set) var resizingState: ResizingState = .fullwidth

    /// 周囲のテキストが変化した場合にインクリメントする値。変化の検出に利用する。
    /// - note: この値がどれだけ変化するかは実装によるので、変化量は意味をなさない。
    @Published var textChangedCount: Int = 0

    var moveCursorBarState = BetaMoveCursorBarState()

    func setResizingMode(_ state: ResizingState) {
        switch state {
        case .fullwidth:
            interfaceSize = .init(width: SemiStaticStates.shared.screenWidth, height: Design.keyboardScreenHeight)
        case .onehanded, .resizing:
            let item = KeyboardInternalSetting.shared.oneHandedModeSetting.item(layout: keyboardLayout, orientation: keyboardOrientation)
            // キーボードスクリーンのサイズを超えないように設定
            interfaceSize = CGSize(width: min(item.size.width, SemiStaticStates.shared.screenWidth), height: min(item.size.height, Design.keyboardScreenHeight))
            interfacePosition = item.position
        }
        self.resizingState = state
        KeyboardInternalSetting.shared.update(\.oneHandedModeSetting) {value in
            value.update(layout: keyboardLayout, orientation: keyboardOrientation) {value in
                value.isLastOnehandedMode = state != .fullwidth
            }
        }
    }

    func initialize() {
        self.tabManager.initialize()
        self.moveCursorBarState.clear()
        self.refreshView()
    }

    func closeKeyboard() {
        self.tabManager.closeKeyboard()
        // このタイミングでクリップボードを確認する
        self.clipboardHistoryManager.checkUpdate()
        // 保存処理を行う
        self.clipboardHistoryManager.save()
    }

    func refreshView() {
        refreshing.toggle()
    }

    func setKeyboardType(_ type: UIKeyboardType?) {
        debug("setKeyboardType:", type.debugDescription)
        guard let type else {
            return
        }
        switch type {
        case .default, .asciiCapable:
            return
        case .numbersAndPunctuation:
            return
        case .URL:
            self.setTab(.user_dependent(.english), temporary: true)
        case .numberPad:
            self.setTab(.existential(.custard(.numberPad)), temporary: true)
        case .phonePad:
            self.setTab(.existential(.custard(.phonePad)), temporary: true)
        case .namePhonePad:
            return
        case .emailAddress:
            self.setTab(.user_dependent(.english), temporary: true)
        case .decimalPad:
            self.setTab(.existential(.custard(.decimalPad)), temporary: true)
        case .twitter:
            return
        case .webSearch:
            return
        case .asciiCapableNumberPad:
            return
        @unknown default:
            return
        }
    }

    func setEnterKeyState(_ state: RoughEnterKeyState) {
        switch state {
        case .return:
            self.enterKeyState = .return(enterKeyType)
        case .edit:
            self.enterKeyState = .edit
        case .complete:
            self.enterKeyState = .complete
        }
    }

    func setTab(_ tab: Tab, temporary: Bool = false) {
        if temporary {
            self.tabManager.setTemporalTab(tab)
        } else {
            self.tabManager.moveTab(to: tab)
        }
        self.refreshView()
    }

    func setUIReturnKeyType(type: UIReturnKeyType) {
        self.enterKeyType = type
        if case let .return(prev) = self.enterKeyState, prev != type {
            self.setEnterKeyState(.return)
        }
    }

    func updateResizingState() {
        let isLastOnehandedMode = KeyboardInternalSetting.shared.oneHandedModeSetting.item(layout: keyboardLayout, orientation: keyboardOrientation).isLastOnehandedMode
        if isLastOnehandedMode {
            self.setResizingMode(.onehanded)
        } else {
            self.setResizingMode(.fullwidth)
        }
    }

    func setKeyboardLayout(_ layout: KeyboardLayout) {
        self.keyboardLayout = layout
        self.updateResizingState()
    }

    func setInputStyle(_ style: InputStyle) {
        self.inputStyle = style
    }

    /// workarounds
    /// * 1回目に値を保存してしまう
    /// * if bool {} else{}にしてboolをvariableSectionに持たせてtoggleする。←これを採用した。
    func setOrientation(_ orientation: KeyboardOrientation) {
        if self.keyboardOrientation == orientation {
            self.refreshView()
            return
        }
        self.keyboardOrientation = orientation
        self.updateResizingState()
    }

}
