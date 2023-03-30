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
    init(interfaceWidth: CGFloat? = nil, orientation: KeyboardOrientation? = nil) {
        if let interfaceWidth {
            self.setInterfaceSize(orientation: orientation ?? .vertical, screenWidth: interfaceWidth)
        } else if let orientation {
            // 小さめの値を適当に入れる
            self.setInterfaceSize(orientation: orientation, screenWidth: 200)
        }
    }

    struct BoolStates: CustardExpressionEvaluatorContext {
        func getValue(for key: String) -> ExpressionValue? {
            if let boolValue = self[key] {
                return .bool(boolValue)
            }
            return nil
        }

        var isTextMagnifying = false
        var hasUpsideComponent = false
        var isCapsLocked = false

        static let isCapsLockedKey = "isCapsLocked"
        static let hasUpsideComponentKey = "is_screen_expanded"
        static let hasFullAccessKey = "has_full_access"
        // ビルトインのステートとカスタムのステートの両方を適切に扱いたい
        fileprivate var custardStates: [String: Bool] = [:]

        func evaluateExpression(_ compiledExpression: CompiledExpression) -> Bool? {
            debug(self.custardStates)
            do {
                let condition = try CustardExpressionEvaluator(context: self).evaluate(compiledExpression: compiledExpression)
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
                } else if key == Self.hasUpsideComponentKey {
                    return self.hasUpsideComponent
                }
                return custardStates[key]
            }
            set {
                if let newValue {
                    if key == Self.hasFullAccessKey || key == Self.hasUpsideComponentKey {
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
    private(set) var inputStyle: InputStyle = .direct
    private(set) var tabManager = TabManager()
    private(set) var clipboardHistoryManager = ClipboardHistoryManager()

    @Published var keyboardLanguage: KeyboardLanguage = .ja_JP
    @Published private(set) var keyboardOrientation: KeyboardOrientation = .vertical
    @Published private(set) var keyboardLayout: KeyboardLayout = .flick

    /// `ResultModel`の変数
    @Published var resultModelVariableSection = ResultModelVariableSection()

    // Bool値の変数はここにまとめる
    @Published var boolStates = BoolStates()

    // 片手モードの実行時、キーボードの幅はinterfaceSizeによって決定できる。
    @Published var interfaceSize: CGSize = .zero
    @Published var interfacePosition: CGPoint = .zero

    /// 外部では利用しないが、`enterKeyState`の更新時に必要になる
    private var enterKeyType: UIReturnKeyType = .default
    @Published private(set) var enterKeyState: EnterKeyState = .return(.default)

    @Published var barState: BarState = .none

    @Published var magnifyingText = ""

    @Published var upsideComponent: UpsideComponent?

    // MARK: refresh用
    @Published var lastTabCharacterPreferenceUpdate = Date()

    /// 片手モード編集状態
    @Published private(set) var resizingState: ResizingState = .fullwidth

    /// 周囲のテキストが変化した場合にインクリメントする値。変化の検出に利用する。
    /// - note: この値がどれだけ変化するかは実装によるので、変化量は意味をなさない。
    @Published var textChangedCount: Int = 0

    struct UndoAction: Equatable {
        var action: ActionType
        var textChangedCount: Int
    }

    @Published var undoAction: UndoAction?

    @Published var moveCursorBarState = BetaMoveCursorBarState()

    @Published private(set) var leftSideText: String = ""
    @Published private(set) var centerText: String = ""
    @Published private(set) var rightSideText: String = ""

    @Published var temporalMessage: TemporalMessage?

    func setSurroundingText(leftSide: String, center: String, rightSide: String) {
        self.leftSideText = leftSide
        self.centerText = center
        self.rightSideText = rightSide
        self.moveCursorBarState.updateLine(leftText: leftSide + center, rightText: rightSide)
    }

    func setResizingMode(_ state: ResizingState) {
        switch state {
        case .fullwidth:
            interfaceSize = .init(width: SemiStaticStates.shared.screenWidth, height: Design.keyboardHeight(screenWidth: SemiStaticStates.shared.screenWidth, orientation: self.keyboardOrientation) + 2)
        case .onehanded, .resizing:
            let item = KeyboardInternalSetting.shared.oneHandedModeSetting.item(layout: keyboardLayout, orientation: keyboardOrientation)
            // キーボードスクリーンのサイズを超えないように設定
            interfaceSize = CGSize(width: min(item.size.width, SemiStaticStates.shared.screenWidth), height: min(item.size.height, Design.keyboardScreenHeight(upsideComponent: self.upsideComponent, orientation: self.keyboardOrientation)))
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
        self.tabManager.initialize(variableStates: self)
        self.moveCursorBarState.clear()
    }

    func closeKeyboard() {
        self.tabManager.closeKeyboard()
        self.upsideComponent = nil
        // このタイミングでクリップボードを確認する
        self.clipboardHistoryManager.checkUpdate()
        // 保存処理を行う
        self.clipboardHistoryManager.save()
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
            self.tabManager.setTemporalTab(tab, variableStates: self)
        } else {
            self.tabManager.moveTab(to: tab, variableStates: self)
        }
    }

    func setUIReturnKeyType(type: UIReturnKeyType) {
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

    func setInterfaceSize(orientation: KeyboardOrientation, screenWidth: CGFloat) {
        let height = Design.keyboardHeight(screenWidth: screenWidth, orientation: orientation)
        if self.keyboardOrientation != orientation {
            self.keyboardOrientation = orientation
            self.updateResizingState()
        }
        let layout = self.keyboardLayout

        // 片手モードの処理
        KeyboardInternalSetting.shared.update(\.oneHandedModeSetting) {value in
            value.setIfFirst(layout: layout, orientation: orientation, size: .init(width: screenWidth, height: height), position: .zero)
        }
        switch self.resizingState {
        case .fullwidth:
            self.interfaceSize = CGSize(width: screenWidth, height: height)
        case .onehanded, .resizing:
            let item = KeyboardInternalSetting.shared.oneHandedModeSetting.item(layout: layout, orientation: orientation)
            // 安全のため、指示されたwidth, heightを超える値を許可しない。
            self.interfaceSize = CGSize(width: min(screenWidth, item.size.width), height: min(height, item.size.height))
            self.interfacePosition = item.position
        }
    }
}
