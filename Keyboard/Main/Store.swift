//
//  Store.swift
//  Calculator-Keyboard
//
//  Created by β α on 2020/04/10.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

final class Store {
    /// Storeのキーボードへのアクション部門の動作を全て切り出したオブジェクト。
    var action = KeyboardActionManager()

    func settingCheck() {
        if MemoryResetCondition.shouldReset() {
            self.action.sendToDicdataStore(.resetMemory)
        }
        @KeyboardSetting(.learningType) var learningType
        self.action.sendToDicdataStore(.notifyLearningType(learningType))
    }

    /// キーボードが表示された際に実行する
    func initialize() {
        debug("Storeを初期化します")
        self.action = KeyboardActionManager()
        // 初期化
        VariableStates.shared.initialize()
        // 設定の更新を確認
        self.settingCheck()
    }

    func closeKeyboard() {
        VariableStates.shared.closeKeybaord()
        self.action.closeKeyboard()
    }
}

extension Candidate: ResultViewItemData {}

// MARK: Storeのキーボードへのアクション部門の動作を全て切り出したオブジェクト。外部から参照されるのがこれ。
final class KeyboardActionManager: UserActionManager {
    override init() {}

    private var inputManager = InputManager()
    private unowned var delegate: KeyboardViewController!

    // 即時変数
    private var timers: [(type: LongpressActionType, timer: Timer)] = []
    private var tempTextData: (left: String, center: String, right: String)!
    private var tempSavedSelectedText: String!

    // キーボードを閉じる際に呼び出す
    // inputManagerはキーボードを閉じる際にある種の操作を行う
    func closeKeyboard() {
        self.inputManager.closeKeyboard()
        for (_, timer) in self.timers {
            timer.invalidate()
        }
        self.timers = []
    }

    func sendToDicdataStore(_ data: DicdataStore.Notification) {
        self.inputManager.sendToDicdataStore(data)
    }

    func setDelegateViewController(_ controller: KeyboardViewController) {
        self.delegate = controller
        self.inputManager.setTextDocumentProxy(controller.textDocumentProxy)
        self.inputManager.setUpdateResult(controller.updateResultView)
    }

    override func makeChangeKeyboardButtonView() -> ChangeKeyboardButtonView {
        delegate.makeChangeKeyboardButtonView(size: Design.fonts.iconFontSize)
    }

    /// 変換を確定した場合に呼ばれる。
    /// - Parameters:
    ///   - text: String。確定された文字列。
    ///   - count: Int。確定された文字数。例えば「検証」を確定した場合5。
    override func notifyComplete(_ candidate: any ResultViewItemData) {
        guard let candidate = candidate as? Candidate else {
            debug("確定できません")
            return
        }
        self.inputManager.complete(candidate: candidate)
        self.registerActions(candidate.actions)
    }

    private func showResultView() {
        VariableStates.shared.barState = .none
    }

    private func doAction(_ action: ActionType, requireSetResult: Bool = true) {
        switch action {
        case let .input(text):
            self.showResultView()
            if VariableStates.shared.boolStates.isCapsLocked && [.en_US, .el_GR].contains(VariableStates.shared.keyboardLanguage) {
                let input = text.uppercased()
                self.inputManager.input(text: input, requireSetResult: requireSetResult)
            } else {
                self.inputManager.input(text: text, requireSetResult: requireSetResult)
            }

        case let .delete(count):
            self.showResultView()
            self.inputManager.deleteBackward(count: count, requireSetResult: requireSetResult)

        case .smoothDelete:
            Sound.smoothDelete()
            self.showResultView()
            self.inputManager.smoothDelete(requireSetResult: requireSetResult)

        case let .smartDelete(item):
            switch item.direction {
            case .forward:
                self.inputManager.smoothDelete(to: item.targets.map {Character($0)}, requireSetResult: requireSetResult)
            case .backward:
                self.inputManager.smoothDelete(to: item.targets.map {Character($0)}, requireSetResult: requireSetResult)
            }

        case .deselectAndUseAsInputting:
            self.inputManager.edit()

        case .saveSelectedTextIfNeeded:
            if self.inputManager.isSelected {
                self.tempSavedSelectedText = self.inputManager.composingText.convertTarget
            }

        case .restoreSelectedTextIfNeeded:
            if let tmp = self.tempSavedSelectedText {
                self.inputManager.input(text: tmp)
                self.tempSavedSelectedText = nil
            }

        case let .moveCursor(count):
            self.inputManager.moveCursor(count: count, requireSetResult: requireSetResult)

        case let .smartMoveCursor(item):
            switch item.direction {
            case .forward:
                self.inputManager.smartMoveCursorForward(to: item.targets.map {Character($0)}, requireSetResult: requireSetResult)
            case .backward:
                self.inputManager.smartMoveCursorBackward(to: item.targets.map {Character($0)}, requireSetResult: requireSetResult)
            }

        case let .setCursorBar(operation):
            self.inputManager.updateSurroundingText()
            switch operation {
            case .on:
                VariableStates.shared.barState = .cursor
            case .off:
                VariableStates.shared.barState = .none
            case .toggle:
                if VariableStates.shared.barState == .cursor {
                    VariableStates.shared.barState = .none
                } else {
                    VariableStates.shared.barState = .cursor
                }
            }

        case .enter:
            self.showResultView()
            let actions = self.inputManager.enter()
            self.registerActions(actions)

        case .changeCharacterType:
            self.showResultView()
            self.inputManager.changeCharacter(requireSetResult: requireSetResult)

        case let .replaceLastCharacters(table):
            self.showResultView()
            self.inputManager.replaceLastCharacters(table: table, requireSetResult: requireSetResult)

        case let .moveTab(type):
            VariableStates.shared.setTab(type)

        case let .setTabBar(operation):
            switch operation {
            case .on:
                VariableStates.shared.barState = .tab
            case .off:
                VariableStates.shared.barState = .none
            case .toggle:
                if VariableStates.shared.barState == .tab {
                    VariableStates.shared.barState = .none
                } else {
                    VariableStates.shared.barState = .tab
                }
            }

        case .enableResizingMode:
            VariableStates.shared.setResizingMode(.resizing)

        case .hideLearningMemory:
            self.hideLearningMemory()

        case .dismissKeyboard:
            self.delegate.dismissKeyboard()

        case let .openApp(scheme):
            delegate.openApp(scheme: scheme)

        case let .setBoolState(key, operation):
            switch operation {
            case .on:
                VariableStates.shared.boolStates[key] = true
            case .off:
                VariableStates.shared.boolStates[key] = false
            case .toggle:
                VariableStates.shared.boolStates[key]?.toggle()
            }

        case let ._setBoolState(key, compiledExpression):
            if let value = VariableStates.shared.boolStates.evaluateExpression(compiledExpression) {
                VariableStates.shared.boolStates[key] = value
            }

        case let .boolSwitch(compiledExpression, trueAction, falseAction):
            if let condition = VariableStates.shared.boolStates.evaluateExpression(compiledExpression) {
                if condition {
                    self.registerActions(trueAction)
                } else {
                    self.registerActions(falseAction)
                }
            }
        #if DEBUG
        // MARK: デバッグ用
        case .DEBUG_DATA_INPUT:
            self.inputManager.setDebugResult()
        #endif
        }

        // VariableStateに操作の結果を反映する
        if requireSetResult {
            self.inputManager.updateSurroundingText()
        }
    }

    /// 押した場合に行われる。
    /// - Parameters:
    ///   - action: 行われた動作。
    override func registerAction(_ action: ActionType) {
        self.doAction(action)
    }

    /// 複数のアクションを実行する
    /// - note: アクションを実行する前に最適化を施すことでパフォーマンスを向上させる
    ///  サポートされている最適化
    /// - `setResult`を一度のみ実施する
    override func registerActions(_ actions: [ActionType]) {
        let isSetActionTrigger = actions.map { action in
            switch action {
            case .input, .delete, .changeCharacterType, .smoothDelete, .smartDelete, .moveCursor, .replaceLastCharacters, .smartMoveCursor:
                return true
            default:
                return false
            }
        }
        if let lastIndex = isSetActionTrigger.lastIndex(where: { $0 }) {
            for (i, action) in actions.enumerated() {
                if i == lastIndex {
                    self.doAction(action, requireSetResult: true)
                } else {
                    self.doAction(action, requireSetResult: false)
                }
            }
        } else {
            for action in actions {
                self.doAction(action)
            }
        }
    }

    /// 長押しを予約する関数。
    /// - Parameters:
    ///   - action: 長押しで起こる動作のタイプ。
    override func reserveLongPressAction(_ action: LongpressActionType) {
        if timers.contains(where: {$0.type == action}) {
            return
        }
        let startTime = Date()

        let startTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {[weak self] (timer) in
            let span: TimeInterval = timer.fireDate.timeIntervalSince(startTime)
            if span > 0.4 {
                action.repeat.first?.sound()
                self?.registerActions(action.repeat)
            }
        })
        self.timers.append((type: action, timer: startTimer))

        let repeatTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: {[weak self] _ in
            action.start.first?.sound()
            self?.registerActions(action.start)
        })
        self.timers.append((type: action, timer: repeatTimer))
    }

    /// 長押しを終了する関数。継続的な動作、例えば連続的な文字削除を行っていたタイマーを停止する。
    /// - Parameters:
    ///   - action: どの動作を終了するか判定するために用いる。
    override func registerLongPressActionEnd(_ action: LongpressActionType) {
        timers = timers.compactMap {timer in
            if timer.type == action {
                timer.timer.invalidate()
                return nil
            }
            return timer
        }
    }

    /// 何かが変化する前に状態の保存を行う関数。
    func notifySomethingWillChange(left: String, center: String, right: String) {
        self.tempTextData = (left: left, center: center, right: right)
    }
    // MARK: iOS16以降
    /*
     |はカーソル位置。二つある場合は選択範囲
     ---------------------
     |abc              :nil/nil/abc
     ---------------------
     abc|def           :abc/nil/def
     ---------------------
     abc|def|ghi       :abc/def/ghi
     ---------------------
     abc|              :abc/nil/nil
     ---------------------
     abc|              :abc/nil/nil  // MARK: ここが以前と違う。以前はこの場合afterInputにEmptyが来ていたが、nilになっている。

     ---------------------
     :\n/nil/def
     |def
     ---------------------
     abc|              :abc/nil/nil  // MARK: ここが以前と違う。以前はこの場合afterInputにEmptyが来ていたが、nilになっている。
     def
     ---------------------
     abc
     |def              :abc\n/nil/def  // MARK: ここが以前と違う。以前はこの場合afterInputにEmptyが来ていたが、\nabcになっている。
     ---------------------
     a|bc
     d|ef              :a/bc \n d/ef
     ---------------------
     */

    // MARK: iOS15以前でleft/center/rightとして得られる情報は以下の通り
    /*
     |はカーソル位置。二つある場合は選択範囲
     ---------------------
     |abc              :nil/nil/abc
     ---------------------
     abc|def           :abc/nil/def
     ---------------------
     abc|def|ghi       :abc/def/ghi
     ---------------------
     abc|              :abc/nil/nil
     ---------------------
     abc|              :abc/nil/empty

     ---------------------
     :\n/nil/def
     |def
     ---------------------
     abc|              :abc/nil/empty
     def
     ---------------------
     abc
     |def              :\n/nil/def
     ---------------------
     a|bc
     d|ef              :a/bc \n d/ef
     ---------------------
     */

    private func adjustLeftString(_ left: String) -> String {
        if #available(iOS 16, *) {
            var newLeft = left.components(separatedBy: "\n").last ?? ""
            if left.contains("\n") && newLeft.isEmpty {
                newLeft = "\n"
            }
            return newLeft
        }
        return left
    }

    /// 何かが変化した後に状態を比較し、どのような変化が起こったのか判断する関数。
    func notifySomethingDidChange(a_left: String, a_center: String, a_right: String) {
        let a_left = adjustLeftString(a_left)
        let b_left = adjustLeftString(self.tempTextData.left)
        // moveCursorBarStateの更新
        VariableStates.shared.moveCursorBarState.updateLine(leftText: a_left + a_center, rightText: a_right)
        // カーソルを動かした直後に一度通知がくるので無視する
        if self.inputManager.isAfterAdjusted() {
            debug("non user operation: after cursor move", a_left, a_center, a_right)
            return
        }
        if self.inputManager.liveConversionManager.enabled {
            self.inputManager.clear()
        }
        let b_center = self.tempTextData.center
        let b_right = self.tempTextData.right
        debug("user operation happend: \((a_left, a_center, a_right)), \((b_left, b_center, b_right))")

        let a_wholeText = a_left + a_center + a_right
        let b_wholeText = b_left + b_center + b_right
        let isWholeTextChanged = a_wholeText != b_wholeText
        let wasSelected = !b_center.isEmpty
        let isSelected = !a_center.isEmpty

        if isSelected {
            debug("user operation id: 0", a_center)
            self.inputManager.userSelectedText(text: a_center)
            return
        }

        // 全体としてテキストが変化せず、選択範囲が存在している場合→新たに選択した、または選択範囲を変更した
        if !isWholeTextChanged {
            // 全体としてテキストが変化せず、選択範囲が無くなっている場合→選択を解除した
            if wasSelected && !isSelected {
                self.inputManager.userDeselectedText()
                debug("user operation id: 1")
                return
            }

            // 全体としてテキストが変化せず、選択範囲は前後ともになく、左側(右側)の文字列だけが変わっていた場合→カーソルを移動した
            if !wasSelected && !isSelected && b_left != a_left {
                debug("user operation id: 2", b_left, a_left)
                let offset = a_left.count - b_left.count
                self.inputManager.userMovedCursor(count: offset)
                return
            }
            // ただタップしただけ、などの場合ここにくる事がある。
            debug("user operation id: 3")
            return
        }
        // 以降isWholeTextChangedは常にtrue
        // 全体としてテキストが変化しており、前は左は改行コードになっていて選択範囲が存在し、かつ前の選択範囲と後の全体が一致する場合→行全体の選択が解除された
        // 行全体を選択している場合は改行コードが含まれる。
        if b_left == "\n" && b_center == a_wholeText {
            debug("user operation id: 5")
            self.inputManager.userDeselectedText()
            return
        }

        // 全体としてテキストが変化しており、左右の文字列を合わせたものが不変である場合→カットしたのではないか？
        if b_left + b_right == a_left + a_right {
            debug("user operation id: 6")
            self.inputManager.userCutText(text: b_center)
            return
        }

        // 全体としてテキストが変化しており、右側の文字列が不変であった場合→ペーストしたのではないか？
        if b_right == a_right {
            // もしクリップボードに文字列がコピーされており、かつ、前の左側文字列にその文字列を加えた文字列が後の左側の文字列に一致した場合→確実にペースト
            if let pastedText = UIPasteboard.general.string, a_left.hasSuffix(pastedText) {
                if wasSelected {
                    debug("user operation id: 7")
                    self.inputManager.userReplacedSelectedText(text: pastedText)
                } else {
                    debug("user operation id: 8")
                    self.inputManager.userPastedText(text: pastedText)
                }
                return
            }
        }

        if a_left == "\n" && b_left.isEmpty && a_right == b_right {
            debug("user operation id: 9")
            return
        }

        // 上記のどれにも引っかからず、なおかつテキスト全体が変更された場合
        debug("user operation id: 10, \((a_left, a_center, a_right)), \((b_left, b_center, b_right))")
        self.inputManager.clear()
    }

    private func hideLearningMemory() {
        LearningTypeSetting.value = .nothing
        self.sendToDicdataStore(.notifyLearningType(.nothing))
    }
}
