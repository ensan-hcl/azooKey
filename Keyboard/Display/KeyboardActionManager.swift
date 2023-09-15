//
//  KeyboardActionManager.swift
//  azooKey
//
//  Created by ensan on 2020/04/10.
//  Copyright © 2020 ensan. All rights reserved.
//

import AzooKeyUtils
import KanaKanjiConverterModule
import KeyboardViews
import SwiftUI
import SwiftUtils

/// キーボードへのアクション部門の動作を担う。
@MainActor final class KeyboardActionManager: UserActionManager {
    override init() {}

    private var inputManager = InputManager()
    private unowned var delegate: KeyboardViewController!

    // 即時変数
    private var tasks: [(type: LongpressActionType, task: Task<Void, any Error>)] = []
    private var tempTextData: (left: String, center: String, right: String)?

    // キーボードを閉じる際に呼び出す
    // inputManagerはキーボードを閉じる際にある種の操作を行う
    func closeKeyboard() {
        self.inputManager.closeKeyboard()
        for (_, task) in self.tasks {
            task.cancel()
        }
        self.tasks = []
        self.tempTextData = nil
    }

    func sendToDicdataStore(_ data: DicdataStore.Notification) {
        self.inputManager.sendToDicdataStore(data)
    }

    func setDelegateViewController(_ controller: KeyboardViewController) {
        self.delegate = controller
        self.inputManager.setTextDocumentProxy(.mainProxy(controller.textDocumentProxy))
        self.inputManager.setUpdateResult { [weak controller] in
            controller?.updateResultView($0)
        }
    }

    override func setTextDocumentProxy(_ proxy: AnyTextDocumentProxy) {
        self.inputManager.setTextDocumentProxy(proxy)
    }

    override func makeChangeKeyboardButtonView<Extension: ApplicationSpecificKeyboardViewExtension>() -> ChangeKeyboardButtonView<Extension> {
        delegate.makeChangeKeyboardButtonView(size: Design.fonts.iconFontSize(keyViewFontSizePreference: Extension.SettingProvider.keyViewFontSize))
    }

    /// 変換を確定した場合に呼ばれる。
    /// - Parameters:
    ///   - text: String。確定された文字列。
    ///   - count: Int。確定された文字数。例えば「検証」を確定した場合5。
    override func notifyComplete(_ candidate: any ResultViewItemData, variableStates: VariableStates) {
        let target = variableStates.tabManager.existentialTab().replacementTarget
        if let candidate = candidate as? Candidate {
            self.inputManager.complete(candidate: candidate)
            self.registerActions(candidate.actions.map(\.action), variableStates: variableStates)
        } else if let candidate = candidate as? ReplacementCandidate {
            self.inputManager.replaceLastCharacters(table: [candidate.target: candidate.replace], inputStyle: .direct)
            variableStates.keyboardInternalSettingManager.update(\.tabCharacterPreference) { item in
                switch candidate.targetType {
                case .emoji:
                    item.setPreference(base: candidate.base, replace: candidate.replace, for: .system(.emoji))
                }
            }
            variableStates.lastTabCharacterPreferenceUpdate = .now
        } else {
            debug("notifyComplete: 確定できません")
        }
        // 左右の文字列
        let (left, center, right) = self.inputManager.getSurroundingText()
        // MARK: Replacementの更新をする
        if !target.isEmpty {
            self.inputManager.updateTextReplacementCandidates(left: left, center: center, right: right, target: target)
        }
        // エンターキーの状態の更新
        variableStates.setEnterKeyState(self.inputManager.getEnterKeyState())
    }

    override func notifyForgetCandidate(_ candidate: any ResultViewItemData, variableStates: VariableStates) {
        if let candidate = candidate as? Candidate {
            self.sendToDicdataStore(.forgetMemory(candidate))
            variableStates.temporalMessage = .doneForgetCandidate
        }
    }

    private func showResultView(variableStates: VariableStates) {
        variableStates.barState = .none
    }

    private func shiftStateOff(variableStates: VariableStates) {
        variableStates.boolStates[VariableStates.BoolStates.isShiftedKey] = false
    }

    private func doAction(_ action: ActionType, requireSetResult: Bool = true, variableStates: VariableStates) {
        debug("doAction", action)
        var undoAction: ActionType?
        switch action {
        case let .input(text, simpleInsert):
            self.showResultView(variableStates: variableStates)
            if (variableStates.boolStates.isCapsLocked || variableStates.boolStates.isShifted) && [.en_US, .el_GR].contains(variableStates.keyboardLanguage) {
                let input = text.uppercased()
                self.inputManager.input(text: input, requireSetResult: requireSetResult, simpleInsert: simpleInsert, inputStyle: variableStates.inputStyle)
            } else {
                self.inputManager.input(text: text, requireSetResult: requireSetResult, simpleInsert: simpleInsert, inputStyle: variableStates.inputStyle)
            }
            self.shiftStateOff(variableStates: variableStates)
        case let .insertMainDisplay(text):
            self.inputManager.insertMainDisplayText(text)
            self.shiftStateOff(variableStates: variableStates)
        case let .delete(count):
            self.showResultView(variableStates: variableStates)
            self.shiftStateOff(variableStates: variableStates)
            self.inputManager.deleteBackward(convertTargetCount: count, requireSetResult: requireSetResult)
        case .smoothDelete:
            KeyboardFeedback<AzooKeyKeyboardViewExtension>.smoothDelete()
            self.showResultView(variableStates: variableStates)
            self.shiftStateOff(variableStates: variableStates)
            let deletedText = self.inputManager.smoothDelete(requireSetResult: requireSetResult)
            if !deletedText.isEmpty {
                undoAction = .input(deletedText, simplyInsert: true)
            }
        case let .smartDelete(item):
            self.showResultView(variableStates: variableStates)
            self.shiftStateOff(variableStates: variableStates)
            let deletedText: String
            switch item.direction {
            case .forward:
                deletedText = self.inputManager.smoothDeleteForward(to: item.targets.map {Character($0)}, requireSetResult: requireSetResult)
            case .backward:
                deletedText = self.inputManager.smoothDelete(to: item.targets.map {Character($0)}, requireSetResult: requireSetResult)
            }
            if !deletedText.isEmpty {
                undoAction = .input(deletedText, simplyInsert: true)
            }
        case .paste:
            // ペーストではシフトを解除しない
            if SemiStaticStates.shared.hasFullAccess {
                self.inputManager.paste()
            }

        case let .moveCursor(count):
            // カーソル移動ではシフトを解除しない
            self.inputManager.moveCursor(count: count, requireSetResult: requireSetResult)

        case let .smartMoveCursor(item):
            switch item.direction {
            case .forward:
                self.inputManager.smartMoveCursorForward(to: item.targets.map {Character($0)}, requireSetResult: requireSetResult)
            case .backward:
                self.inputManager.smartMoveCursorBackward(to: item.targets.map {Character($0)}, requireSetResult: requireSetResult)
            }

        case let .setCursorBar(operation):
            let (left, center, right) = self.inputManager.getSurroundingText()
            variableStates.setSurroundingText(leftSide: left, center: center, rightSide: right)
            switch operation {
            case .on:
                variableStates.barState = .cursor
            case .off:
                variableStates.barState = .none
            case .toggle:
                if variableStates.barState == .cursor {
                    variableStates.barState = .none
                } else {
                    variableStates.barState = .cursor
                }
            }

        case .enter:
            self.showResultView(variableStates: variableStates)
            self.shiftStateOff(variableStates: variableStates)
            let actions = self.inputManager.enter()
            self.registerActions(actions, variableStates: variableStates)

        case .changeCharacterType:
            self.showResultView(variableStates: variableStates)
            self.shiftStateOff(variableStates: variableStates)
            self.inputManager.changeCharacter(requireSetResult: requireSetResult, inputStyle: variableStates.inputStyle)

        case let .replaceLastCharacters(table):
            self.showResultView(variableStates: variableStates)
            self.shiftStateOff(variableStates: variableStates)
            self.inputManager.replaceLastCharacters(table: table, requireSetResult: requireSetResult, inputStyle: variableStates.inputStyle)

        case let .moveTab(type):
            // タブ移動ではシフトを解除しない
            variableStates.setTab(type)

        case let .setUpsideComponent(type):
            switch type {
            case nil:
                if variableStates.upsideComponent != nil {
                    variableStates.upsideComponent = nil
                    self.delegate.reloadAllView()
                } else {
                    variableStates.upsideComponent = nil
                }
            case .some:
                variableStates.upsideComponent = type
                self.delegate.reloadAllView()
            }

        case let .setTabBar(operation):
            switch operation {
            case .on:
                variableStates.barState = .tab
            case .off:
                variableStates.barState = .none
            case .toggle:
                if variableStates.barState == .tab {
                    variableStates.barState = .none
                } else {
                    variableStates.barState = .tab
                }
            }

        case .enableResizingMode:
            variableStates.setResizingMode(.resizing)

        case .hideLearningMemory:
            self.hideLearningMemory()

        case .dismissKeyboard:
            self.delegate.dismissKeyboard()

        case let .openApp(scheme):
            delegate.openApp(scheme: scheme)

        case let .setBoolState(key, operation):
            switch operation {
            case .on:
                variableStates.boolStates[key] = true
            case .off:
                variableStates.boolStates[key] = false
            case .toggle:
                variableStates.boolStates[key]?.toggle()
            }

        //        case let ._setBoolState(key, compiledExpression):
        //            if let value = variableStates.boolStates.evaluateExpression(compiledExpression) {
        //                variableStates.boolStates[key] = value
        //            }
        //
        case let .boolSwitch(compiledExpression, trueAction, falseAction):
            if let condition = variableStates.boolStates.evaluateExpression(compiledExpression) {
                if condition {
                    self.registerActions(trueAction, variableStates: variableStates)
                } else {
                    self.registerActions(falseAction, variableStates: variableStates)
                }
            }
        case let .setSearchQuery(query, target):
            let results = self.inputManager.getSearchResult(query: query, target: target)
            variableStates.resultModelVariableSection.setSearchResults(results)
        }

        if requireSetResult {
            // MARK: VariableStateに操作の結果を反映する
            // 左右の文字列
            let (left, center, right) = self.inputManager.getSurroundingText()
            variableStates.setSurroundingText(leftSide: left, center: center, rightSide: right)
            // エンターキーの状態
            variableStates.setEnterKeyState(self.inputManager.getEnterKeyState())
            // 文字列の変更を適用
            variableStates.textChangedCount += self.inputManager.getTextChangedCountDelta()
            if let undoAction {
                variableStates.undoAction = .init(action: undoAction, textChangedCount: variableStates.textChangedCount)
            }
            // MARK: 言語を更新する
            self.inputManager.setKeyboardLanguage(variableStates.keyboardLanguage)
            // MARK: Replacementの更新をする
            if !variableStates.tabManager.existentialTab().replacementTarget.isEmpty {
                self.inputManager.updateTextReplacementCandidates(left: left, center: center, right: right, target: variableStates.tabManager.existentialTab().replacementTarget)
            }
        }
    }

    /// 押した場合に行われる。
    /// - Parameters:
    ///   - action: 行われた動作。
    override func registerAction(_ action: ActionType, variableStates: VariableStates) {
        self.doAction(action, variableStates: variableStates)
    }

    /// 複数のアクションを実行する
    /// - note: アクションを実行する前に最適化を施すことでパフォーマンスを向上させる
    ///  サポートされている最適化
    /// - `setResult`を一度のみ実施する
    override func registerActions(_ actions: [ActionType], variableStates: VariableStates) {
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
                    self.doAction(action, requireSetResult: true, variableStates: variableStates)
                } else {
                    self.doAction(action, requireSetResult: false, variableStates: variableStates)
                }
            }
        } else {
            for action in actions {
                self.doAction(action, variableStates: variableStates)
            }
        }
    }

    /// 長押しを予約する関数。
    /// - Parameters:
    ///   - action: 長押しで起こる動作のタイプ。
    override func reserveLongPressAction(_ action: LongpressActionType, variableStates: VariableStates) {
        if tasks.contains(where: {$0.type == action}) {
            return
        }
        let startTask = Task {
            try await Task.sleep(nanoseconds: 0_400_000_000)
            action.start.first?.feedback(variableStates: variableStates, extension: AzooKeyKeyboardViewExtension.self)
            self.registerActions(action.start, variableStates: variableStates)
        }
        self.tasks.append((type: action, task: startTask))
        
        let repeatTask = Task {
            try await Task.sleep(nanoseconds: 0_400_000_000)
            while !Task.isCancelled {
                action.repeat.first?.feedback(variableStates: variableStates, extension: AzooKeyKeyboardViewExtension.self)
                self.registerActions(action.repeat, variableStates: variableStates)
                try await Task.sleep(nanoseconds: 0_100_000_000)
            }
        }
        self.tasks.append((type: action, task: repeatTask))
    }

    /// 長押しを終了する関数。継続的な動作、例えば連続的な文字削除を行っていたタイマーを停止する。
    /// - Parameters:
    ///   - action: どの動作を終了するか判定するために用いる。
    override func registerLongPressActionEnd(_ action: LongpressActionType) {
        tasks = tasks.compactMap {task in
            if task.type == action {
                task.task.cancel()
                return nil
            }
            return task
        }
    }

    override func notifyReportWrongConversion(_ candidate: any ResultViewItemData, index: Int?, variableStates: VariableStates) async {
        let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSfpYQqbX8u5SgGVfXjNzCPtKAH_5Mp7PCkUiCiUceEaevb8pQ/formResponse")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("no-cors", forHTTPHeaderField: "mode")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let surfaceCandidate = candidate.text
        let ruby: String
        if candidate is Candidate {
            let composingText = inputManager.getComposingText()
            // 以下のようなフォーマットになる
            // あか / roman(a) roman(k) roman(a)
            ruby = composingText.convertTarget + " / " + composingText.input.map {"\($0.inputStyle.rawValue)(\($0.character))"}.joined()
        } else {
            ruby = "Unknown case"
        }
        let index: String = index?.description ?? "nil"
        let version = SharedStore.currentAppVersion?.description ?? "Unknown Version"
        @KeyboardSetting(.learningType) var learningType
        let learning = learningType.needUsingMemory ? "有効" : "無効"
        request.httpBody = "entry.134904003=\(surfaceCandidate)&entry.869464972=\(ruby)&entry.1459534202=\(index)&entry.571429448=\(version)&entry.524189292=\(learning)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?
            .data(using: .utf8) ?? Data()
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            debug("notifyReportWrongConversion response", response)
            await MainActor.run {
                variableStates.temporalMessage = .doneReportWrongConversion
            }
        } catch {
            debug("notifyReportWrongConversion error", error)
            await MainActor.run {
                variableStates.temporalMessage = .failedReportWrongConversion
            }
        }
    }

    /// 何かが変化する前に状態の保存を行う関数。
    override func notifySomethingWillChange(left: String, center: String, right: String) {
        // self.tempTextDataが`nil`でない場合、上書きせず終了する
        guard self.tempTextData == nil else {
            debug("notifySomethingWillChange: There is already `tempTextData`: \(tempTextData!)")
            return
        }
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
    override func notifySomethingDidChange(a_left: String, a_center: String, a_right: String, variableStates: VariableStates) {
        defer {
            // moveCursorBarStateの更新
            variableStates.setSurroundingText(leftSide: a_left, center: a_center, rightSide: a_right)
            // エンターキーの状態の更新
            variableStates.setEnterKeyState(self.inputManager.getEnterKeyState())
            // Replacementの更新
            if !variableStates.tabManager.existentialTab().replacementTarget.isEmpty {
                self.inputManager.updateTextReplacementCandidates(left: a_left, center: a_center, right: a_right, target: variableStates.tabManager.existentialTab().replacementTarget)
            }
        }
        // 前のデータが保存されていない場合は操作しない
        guard let (tempLeft, b_center, b_right) = self.tempTextData else {
            debug("notifySomethingDidChange: Could not found `tempTextData`")
            return
        }
        // 終了時に必ずtempTextDataを`nil`にする
        defer {
            self.tempTextData = nil
        }

        // iOS16以降左側の文字列の設計が変わったので、adjustする
        let a_left = adjustLeftString(a_left)
        let b_left = adjustLeftString(tempLeft)

        // システムによる操作でこの関数が呼ばれた場合はスルーする
        if let operation = self.inputManager.getPreviousSystemOperation() {
            debug("non user operation \(operation)", a_left, a_center, a_right)
            return
        }

        let hasSomethingChanged = a_left != b_left || a_center != b_center || a_right != b_right
        // ライブ変換を行っていて入力中の場合、まずは確定してから話を進める
        if !self.inputManager.composingText.isEmpty && !self.inputManager.isSelected && self.inputManager.liveConversionManager.enabled && hasSomethingChanged {
            debug("in live conversion, user did change something: \((a_left, a_center, a_right)) \((b_left, b_center, b_right))")
            _ = self.inputManager.enter(shouldModifyDisplayedText: false)
        }

        // この場合はユーザによる操作であると考えられる
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
                let actions = self.inputManager.userMovedCursor(count: offset)
                for action in actions{
                    doAction(action, variableStates: variableStates)
                }
                return
            }

            // MarkedTextを有効化している場合、テキストの送信等でここに来ることがある
            if self.inputManager.displayedTextManager.isMarkedTextEnabled {
                debug("user operation id: 2.5")
                self.inputManager.stopComposition()
                return
            }
            // ただタップしただけ、などの場合ここにくる事がある。
            debug("user operation id: 3")

            return
        }
        // 以降isWholeTextChangedは常にtrue
        // 全体としてテキストが変化しており、前は左は改行コードになっていて選択範囲が存在し、かつ前の選択範囲と後の全体が一致する場合→行全体の選択が解除された
        // 行全体を選択している場合は改行コードが含まれる。

        defer {
            variableStates.textChangedCount += 1
        }

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

        // 全体としてテキストが変化しており、右側の文字列が不変であった場合→Undoしたと推測できる
        if b_left.hasPrefix(a_left) && b_right == a_right {
            debug("user operation id: 7")
            self.inputManager.stopComposition()
            return
        }

        if b_right == a_right {
            debug("user operation id: 8")
            self.inputManager.stopComposition()
            return
        }

        if a_left == "\n" && b_left.isEmpty && a_right == b_right {
            debug("user operation id: 9")
            self.inputManager.stopComposition()
            return
        }

        // 上記のどれにも引っかからず、なおかつテキスト全体が変更された場合
        debug("user operation id: 10, \((a_left, a_center, a_right)), \((b_left, b_center, b_right))")
        self.inputManager.stopComposition()
    }

    private func hideLearningMemory() {
        // TODO: Provide up-to-date implementation
    }
}
