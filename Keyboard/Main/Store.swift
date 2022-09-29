//
//  Store.swift
//  Calculator-Keyboard
//
//  Created by β α on 2020/04/10.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI
import DequeModule

final class Store {
    static let shared = Store()
    private(set) var resultModelVariableSection = ResultModelVariableSection<Candidate>()
    /// Storeのキーボードへのアクション部門の動作を全て切り出したオブジェクト。
    var action: KeyboardActionDepartment {
        VariableStates.shared.action as! KeyboardActionDepartment
    }

    private init() {
        VariableStates.shared.action = KeyboardActionDepartment()
    }

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
        // まずActionDepartmentを上書きする
        VariableStates.shared.action = KeyboardActionDepartment()
        // ついで初期化
        VariableStates.shared.initialize()
        // 設定の更新を確認
        self.settingCheck()
    }

    fileprivate func registerResult(_ result: [Candidate]) {
        self.resultModelVariableSection.setResults(result)
    }

    func closeKeyboard() {
        VariableStates.shared.closeKeybaord()
        self.action.closeKeyboard()
    }
}

// MARK: Storeのキーボードへのアクション部門の動作を全て切り出したオブジェクト。外部から参照されるのがこれ。
final class KeyboardActionDepartment: ActionDepartment {
    fileprivate override init() {}

    private var inputManager = InputManager()
    private weak var delegate: KeyboardViewController!

    // 即時変数
    private var timers: [(type: LongpressActionType, timer: Timer)] = []
    private var tempTextData: (left: String, center: String, right: String)!
    private var tempSavedSelectedText: String!

    // キーボードを閉じる際に呼び出す
    // inputManagerはキーボードを閉じる際にある種の操作を行う
    fileprivate func closeKeyboard() {
        self.inputManager.closeKeyboard()
        for (_, timer) in self.timers {
            timer.invalidate()
        }
        self.timers = []
    }

    func setTextDocumentProxy(_ proxy: UITextDocumentProxy) {
        self.inputManager.setTextDocumentProxy(proxy)
    }

    enum DicdataStoreNotification {
        case notifyLearningType(LearningType)
        case importOSUserDict(OSUserDict)
        case notifyAppearAgain
        case reloadUserDict
        case closeKeyboard
        case resetMemory
    }

    func sendToDicdataStore(_ data: DicdataStoreNotification) {
        self.inputManager.sendToDicdataStore(data)
    }

    func setDelegateViewController(_ controller: KeyboardViewController) {
        self.delegate = controller
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
        self.doActions(candidate.actions)
    }

    private func showResultView() {
        VariableStates.shared.showTabBar = false
        VariableStates.shared.showMoveCursorBar = false
    }

    /// 複数のアクションを実行する
    /// - note: アクションを実行する前に最適化を施すことでパフォーマンスを向上させる
    ///  サポートされている最適化
    /// - `setResult`を一度のみ実施する
    private func doActions(_ actions: [ActionType]) {
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

    private func doAction(_ action: ActionType, requireSetResult: Bool = true) {
        switch action {
        case let .input(text):
            self.showResultView()
            if VariableStates.shared.aAKeyState == .capsLock && [.en_US, .el_GR].contains(VariableStates.shared.keyboardLanguage) {
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
        case let .changeCapsLockState(state):
            VariableStates.shared.aAKeyState = state
        case .toggleShowMoveCursorView:
            VariableStates.shared.showTabBar = false
            VariableStates.shared.showMoveCursorBar.toggle()
        case .enter:
            self.showResultView()
            let actions = self.inputManager.enter()
            self.doActions(actions)
        case .changeCharacterType:
            self.showResultView()
            self.inputManager.changeCharacter(requireSetResult: requireSetResult)
        case let .replaceLastCharacters(table):
            self.showResultView()
            self.inputManager.replaceLastCharacters(table: table, requireSetResult: requireSetResult)
        case let .moveTab(type):
            VariableStates.shared.setTab(type)
        case .toggleTabBar:
            VariableStates.shared.showMoveCursorBar = false
            VariableStates.shared.showTabBar.toggle()

        case .enableResizingMode:
            VariableStates.shared.setResizingMode(.resizing)

        case .hideLearningMemory:
            self.hideLearningMemory()

        case .dismissKeyboard:
            self.delegate.dismissKeyboard()

        case let .openApp(scheme):
            delegate.openApp(scheme: scheme)
        #if DEBUG
        // MARK: デバッグ用
        case .DEBUG_DATA_INPUT:
            self.inputManager.setDebugResult()
        #endif
        }
    }

    /// 押した場合に行われる。
    /// - Parameters:
    ///   - action: 行われた動作。
    override func registerAction(_ action: ActionType) {
        self.doAction(action)
    }

    /// 押した場合に行われる。
    /// - Parameters:
    ///   - action: 行われた複数の動作。
    override func registerActions(_ actions: [ActionType]) {
        self.doActions(actions)
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
                self?.doActions(action.repeat)
            }
        })
        self.timers.append((type: action, timer: startTimer))

        let repeatTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: {[weak self] _ in
            action.start.first?.sound()
            self?.doActions(action.start)
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
    override func notifySomethingWillChange(left: String, center: String, right: String) {
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
    override func notifySomethingDidChange(a_left: String, a_center: String, a_right: String) {
        if self.inputManager.isAfterAdjusted() {
            return
        }
        if self.inputManager.liveConversionManager.enabled {
            self.inputManager.clear()
        }
        let a_left = adjustLeftString(a_left)

        let b_left = adjustLeftString(self.tempTextData.left)
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

// ActionDepartmentの状態を保存する部分
private final class InputManager {
    // 入力中の文字列を管理する構造体
    private(set) var composingText = ComposingText()
    // 表示される文字列を管理するクラス
    private var displayedTextManager = DisplayedTextManager()
    // TODO: displayedTextManagerとliveConversionManagerを何らかの形で統合したい
    // ライブ変換を管理するクラス
    fileprivate var liveConversionManager = LiveConversionManager()

    // セレクトされているか否か、現在入力中の文字全体がセレクトされているかどうかである。
    // TODO: isSelectedとafterAdjustedはdisplayedTextManagerが持っているべき
    fileprivate var isSelected = false
    private var afterAdjusted: Bool = false

    // 再変換機能の提供のために用いる辞書
    private var candidatesLog: Deque<DicdataElement> = []

    private var liveConversionEnabled: Bool {
        return liveConversionManager.enabled && !self.isSelected
    }

    private func updateLog(candidate: Candidate) {
        candidatesLog.append(contentsOf: candidate.data)
        while candidatesLog.count > 100 {  // 最大100個までログを取る
            candidatesLog.removeFirst()
        }
    }

    private func getMatch(word: String) -> DicdataElement? {
        return candidatesLog.last(where: {$0.word == word})
    }

    /// かな漢字変換を受け持つ変換器。
    private var kanaKanjiConverter = KanaKanjiConverter()

    func sendToDicdataStore(_ data: KeyboardActionDepartment.DicdataStoreNotification) {
        self.kanaKanjiConverter.sendToDicdataStore(data)
    }

    fileprivate func setTextDocumentProxy(_ proxy: UITextDocumentProxy) {
        self.displayedTextManager.setTextDocumentProxy(proxy)
    }

    func isAfterAdjusted() -> Bool {
        if self.afterAdjusted {
            self.afterAdjusted = false
            return true
        }
        return false
    }

    /// 変換を選択した場合に呼ばれる
    fileprivate func complete(candidate: Candidate) {
        self.updateLog(candidate: candidate)
        // カーソルから左の入力部分を削除し、変換後の文字列+残りの文字列を後で入力し直す
        if !self.isSelected {
            // 消しすぎることはないのでエラーは無視できる
            try? self.displayedTextManager.deleteBackward(count: self.displayedTextManager.displayedTextCursorPosition)
        }
        self.isSelected = false

        debug("complete:", candidate, composingText)
        self.kanaKanjiConverter.updateLearningData(candidate)
        self.composingText.complete(correspondingCount: candidate.correspondingCount)
        self.displayedTextManager.insertText(candidate.text, isComposing: false)
        self.displayedTextManager.insertText(String(self.composingText.convertTargetBeforeCursor))
        guard !self.composingText.isEmpty else {
            self.clear()
            VariableStates.shared.setEnterKeyState(.return)
            return
        }
        self.kanaKanjiConverter.setCompletedData(candidate)

        if liveConversionEnabled {
            self.liveConversionManager.updateAfterFirstClauseCompletion()
        }
        // 左端にある場合はカーソルを右端に持っていく
        if self.composingText.isAtStartIndex {
            _ = self.composingText.moveCursorFromCursorPosition(count: self.composingText.convertTarget.count)
            // 入力の直後、documentContextAfterInputは間違っていることがあるため、ここではoffsetをcomposingTextから直接計算する。
            let offset = self.composingText.convertTarget.utf16.count
            self.displayedTextManager.unsafeMoveCursor(unsafeCount: offset)
            self.afterAdjusted = true
        }
        self.setResult()
    }

    fileprivate func clear() {
        debug("クリアしました")
        self.composingText.clear()
        self.displayedTextManager.clear()
        self.isSelected = false
        self.liveConversionManager.clear()
        self.setResult()
        self.kanaKanjiConverter.clear()
        VariableStates.shared.setEnterKeyState(.return)
    }

    fileprivate func closeKeyboard() {
        debug("キーボードを閉じます")
        self.sendToDicdataStore(.closeKeyboard)
        self.clear()
    }

    // MARK: 単純に確定した場合はひらがな列に対して候補を作成する
    fileprivate func enter() -> [ActionType] {
        var _candidate = Candidate(
            text: self.composingText.convertTarget,
            value: -18,
            correspondingCount: self.composingText.input.count,
            lastMid: 501,
            data: [
                DicdataElement(ruby: self.composingText.convertTarget.toKatakana(), cid: CIDData.固有名詞.cid, mid: 501, value: -18)
            ]
        )
        if liveConversionEnabled, let candidate = liveConversionManager.lastUsedCandidate {
            _candidate = candidate
        }
        self.updateLog(candidate: _candidate)
        let actions = self.kanaKanjiConverter.getApporopriateActions(_candidate)
        _candidate.withActions(actions)
        _candidate.parseTemplate()
        self.kanaKanjiConverter.updateLearningData(_candidate)
        self.clear()
        return actions
    }

    // MARK: キーボード経由でユーザがinputを行った場合に呼び出す
    fileprivate func input(text: String, requireSetResult: Bool = true) {
        if self.isSelected {
            // 選択は解除される
            self.isSelected = false
            // composingTextをクリアする
            self.composingText.clear()
            // キーボードの状態と無関係にdirectに設定し、入力をそのまま持たせる
            let _ = self.composingText.insertAtCursorPosition(text, inputStyle: .direct)

            // 実際に入力する
            self.displayedTextManager.insertText(text)
            setResult()

            VariableStates.shared.setEnterKeyState(.complete)
            return
        }

        if text == "\n"{
            self.clear()
            self.displayedTextManager.insertText(text, isComposing: false)
            return
        }
        // スペースだった場合
        if text == " " || text == "　" || text == "\t" || text == "\0"{
            self.clear()
            self.displayedTextManager.insertText(text, isComposing: false)
            return
        }

        if VariableStates.shared.keyboardLanguage == .none {
            self.clear()
            self.displayedTextManager.insertText(text, isComposing: false)
            return
        }

        let operation = self.composingText.insertAtCursorPosition(text, inputStyle: VariableStates.shared.inputStyle)
        debug("Input Manager input: ", composingText)
        self.displayedTextManager.replace(count: operation.delete, with: operation.input)

        VariableStates.shared.setEnterKeyState(.complete)

        if requireSetResult {
            setResult()
        }
    }

    /// テキストの進行方向に削除する
    /// `ab|c → ab|`のイメージ
    fileprivate func deleteForward(count: Int, requireSetResult: Bool = true) {
        if count < 0 {
            return
        }

        guard !self.composingText.isEmpty else {
            // 消し過ぎの可能性は考えなくて大丈夫な状況
            try? self.displayedTextManager.deleteForward(count: count, isComposing: false)
            return
        }

        let operation = self.composingText.deleteForwardFromCursorPosition(count: count)
        debug("Input Manager deleteForward: ", composingText)
        // 削除を実行する
        // 消し過ぎの可能性は考えなくて大丈夫な状況
        // ただしoperation.deleteは負の値である
        try? self.displayedTextManager.deleteForward(count: -operation.delete)

        if requireSetResult {
            setResult()
        }

        if self.composingText.isEmpty {
            VariableStates.shared.setEnterKeyState(.return)
        }
    }

    /// テキストの進行方向と逆に削除する
    /// `ab|c → a|c`のイメージ
    fileprivate func deleteBackward(count: Int, requireSetResult: Bool = true) {
        if count == 0 {
            return
        }
        // 選択状態ではオール削除になる
        if self.isSelected {
            self.displayedTextManager.rawDeleteBackward()
            self.clear()
            return
        }
        // 条件
        if count < 0 {
            self.deleteForward(count: abs(count), requireSetResult: requireSetResult)
            return
        }
        guard !self.composingText.isEmpty else {
            // 消し過ぎの可能性は考えなくて大丈夫な状況
            try? self.displayedTextManager.deleteBackward(count: count, isComposing: false)
            return
        }

        let operation = self.composingText.deleteBackwardFromCursorPosition(count: count)
        debug("Input Manager deleteBackword: ", composingText)

        // 削除を実行する
        // 消し過ぎの可能性は考えなくて大丈夫な状況
        try? self.displayedTextManager.deleteBackward(count: operation.delete)

        if requireSetResult {
            setResult()
        }

        if self.composingText.isEmpty {
            VariableStates.shared.setEnterKeyState(.return)
        }
    }

    /// 特定の文字まで削除する
    fileprivate func smoothDelete(to nexts: [Character] = ["、", "。", "！", "？", ".", ",", "．", "，", "\n"], requireSetResult: Bool = true) {
        // 選択状態ではオール削除になる
        if self.isSelected {
            self.displayedTextManager.rawDeleteBackward()
            self.clear()
            return
        }
        // 入力中の場合
        if !self.composingText.isEmpty {
            // カーソルより前を全部消す
            // 消し過ぎの可能性は考えなくて大丈夫な状況
            try? self.displayedTextManager.deleteBackward(count: self.displayedTextManager.displayedTextCursorPosition)
            // カーソルより前を全部消す
            // 戻り値は無視できる
            _ = self.composingText.deleteBackwardFromCursorPosition(count: self.composingText.convertTargetCursorPosition)

            // カーソルを先頭に移動する
            self.moveCursor(count: self.composingText.convertTarget.count)
            // 文字がもうなかった場合
            if self.composingText.isEmpty {
                self.clear()
                return
            }
            if requireSetResult {
                setResult()
            }
            return
        }

        var deletedCount = 0
        while let last = self.displayedTextManager.documentContextBeforeInput?.last {
            if nexts.contains(last) {
                break
            } else {
                // 消し過ぎの可能性は考えなくて大丈夫な状況
                try? self.displayedTextManager.deleteBackward(count: 1, isComposing: false)
                deletedCount += 1
            }
        }
        if deletedCount == 0 {
            // 消し過ぎの可能性は考えなくて大丈夫な状況
            try? self.displayedTextManager.deleteBackward(count: 1, isComposing: false)
        }
    }

    /// テキストの進行方向に、特定の文字まで削除する
    /// 入力中はカーソルから右側を全部消す
    fileprivate func smoothDeleteForward(to nexts: [Character] = ["、", "。", "！", "？", ".", ",", "．", "，", "\n"], requireSetResult: Bool = true) {
        // 選択状態ではオール削除になる
        if self.isSelected {
            self.displayedTextManager.rawDeleteBackward()
            self.clear()
            return
        }
        // 入力中の場合
        if !self.composingText.isEmpty {
            // 消し過ぎの可能性は考えなくて大丈夫な状況
            try? self.displayedTextManager.deleteForward(count: self.displayedTextManager.displayedText.count -  self.displayedTextManager.displayedTextCursorPosition)
            // count文字消せるのは自明なので、返り値は無視できる
            _ = self.composingText.deleteForwardFromCursorPosition(count: self.composingText.convertTarget.count - self.composingText.convertTargetCursorPosition)
            // 文字がもうなかった場合
            if self.composingText.isEmpty {
                clear()
                setResult()
            }
            return
        }

        var deletedCount = 0
        while let first = self.displayedTextManager.documentContextAfterInput?.first {
            if nexts.contains(first) {
                break
            } else {
                // 消し過ぎの可能性は考えなくて大丈夫な状況
                try? self.displayedTextManager.deleteForward(count: 1, isComposing: false)
                deletedCount += 1
            }
        }
        if deletedCount == 0 {
            // 消し過ぎの可能性は考えなくて大丈夫な状況
            try? self.displayedTextManager.deleteForward(count: 1, isComposing: false)
        }
    }

    /// テキストの進行方向と逆に、特定の文字までカーソルを動かす
    fileprivate func smartMoveCursorBackward(to nexts: [Character] = ["、", "。", "！", "？", ".", ",", "．", "，", "\n"], requireSetResult: Bool = true) {
        // 選択状態では最も左にカーソルを移動
        if isSelected {
            let count = self.composingText.convertTarget.count
            deselect()
            try? self.displayedTextManager.moveCursor(count: count, isComposing: false)
            if requireSetResult {
                setResult()
            }
            return
        }
        // 入力中の場合
        if !composingText.isEmpty {
            let operation = self.composingText.moveCursorFromCursorPosition(count: -self.composingText.convertTargetCursorPosition)
            do {
                try self.displayedTextManager.moveCursor(count: operation.cursor)
            } catch {
                self.clear()
                return
            }
            if requireSetResult {
                setResult()
            }
            return
        }

        var movedCount = 0
        while let last = displayedTextManager.documentContextBeforeInput?.last {
            if nexts.contains(last) {
                break
            } else {
                // ここを実行する場合変換中ではないので例外は無視できる
                try? self.displayedTextManager.moveCursor(count: -1)
                movedCount += 1
            }
        }
        if movedCount == 0 {
            // ここを実行する場合変換中ではないので例外は無視できる
            try? self.displayedTextManager.moveCursor(count: -1)
        }
    }

    /// テキストの進行方向に、特定の文字までカーソルを動かす
    fileprivate func smartMoveCursorForward(to nexts: [Character] = ["、", "。", "！", "？", ".", ",", "．", "，", "\n"], requireSetResult: Bool = true) {
        // 選択状態では最も右にカーソルを移動
        if isSelected {
            deselect()
            try? self.displayedTextManager.moveCursor(count: 1, isComposing: false)
            if requireSetResult {
                setResult()
            }
            return
        }
        // 入力中の場合
        if !composingText.isEmpty {
            let operation = self.composingText.moveCursorFromCursorPosition(count: self.composingText.convertTarget.count - self.composingText.convertTargetCursorPosition)
            do {
                try self.displayedTextManager.moveCursor(count: operation.cursor)
            } catch {
                self.clear()
                return
            }
            if requireSetResult {
                setResult()
            }
            return
        }

        var movedCount = 0
        while let first = displayedTextManager.documentContextAfterInput?.first {
            if nexts.contains(first) {
                break
            } else {
                // ここを実行する場合変換中ではないので例外は無視できる
                try? self.displayedTextManager.moveCursor(count: 1)
                movedCount += 1
            }
        }
        if movedCount == 0 {
            // ここを実行する場合変換中ではないので例外は無視できる
            try? self.displayedTextManager.moveCursor(count: 1)
        }
    }

    /// これから選択を解除するときに呼ぶ関数
    /// ぶっちゃけ役割不明
    fileprivate func deselect() {
        if isSelected {
            clear()
            VariableStates.shared.setEnterKeyState(.return)
        }
    }

    /// 選択状態にあるテキストを再度入力し、編集可能な状態にする
    fileprivate func edit() {
        if isSelected {
            let selectedText = composingText.convertTarget
            self.displayedTextManager.rawDeleteBackward()
            self.isSelected = false
            self.composingText.clear()
            self.input(text: selectedText)
            VariableStates.shared.setEnterKeyState(.complete)
        }
    }

    /// 文字のreplaceを実施する
    /// `changeCharacter`を`CustardKit`で扱うためのAPI。
    /// キーボード経由でのみ実行される。
    fileprivate func replaceLastCharacters(table: [String: String], requireSetResult: Bool = true) {
        debug(table, composingText, isSelected)
        if isSelected {
            return
        }
        let counts: (max: Int, min: Int) = table.keys.reduce(into: (max: 0, min: .max)) {
            $0.max = max($0.max, $1.count)
            $0.min = min($0.min, $1.count)
        }
        // 入力状態の場合、入力中のテキストの範囲でreplaceを実施する。
        if !composingText.isEmpty {
            let leftside = composingText.convertTargetBeforeCursor
            var found = false
            for count in (counts.min...counts.max).reversed() where count <= composingText.convertTargetCursorPosition {
                if let replace = table[String(leftside.suffix(count))] {
                    // deleteとinputを効率的に行うため、setResultを要求しない (変換を行わない)
                    self.deleteBackward(count: leftside.suffix(count).count, requireSetResult: false)
                    // ここで変換が行われる。内部的には差分管理システムによって「置換」の場合のキャッシュ変換が呼ばれる。
                    self.input(text: replace, requireSetResult: requireSetResult)
                    found = true
                    break
                }
            }
            if !found && requireSetResult {
                self.setResult()
            }
            return
        }
        // 言語の指定がない場合は、入力中のテキストの範囲でreplaceを実施する。
        if VariableStates.shared.keyboardLanguage == .none {
            let leftside = displayedTextManager.documentContextBeforeInput ?? ""
            for count in (counts.min...counts.max).reversed() where count <= leftside.count {
                if let replace = table[String(leftside.suffix(count))] {
                    self.displayedTextManager.replace(count: count, with: replace, isComposing: false)
                    break
                }
            }
        }
    }

    /// カーソル左側の1文字を変更する関数
    /// ひらがなの場合は小書き・濁点・半濁点化し、英字・ギリシャ文字・キリル文字の場合は大文字・小文字化する
    fileprivate func changeCharacter(requireSetResult: Bool = true) {
        if self.isSelected {
            return
        }
        guard let char = self.composingText.convertTargetBeforeCursor.last else {
            return
        }
        let changed = char.requestChange()
        // 同じ文字の場合は無視する
        if Character(changed) == char {
            return
        }
        // deleteとinputを効率的に行うため、setResultを要求しない (変換を行わない)
        self.deleteBackward(count: 1, requireSetResult: false)
        // inputの内部でsetResultが発生する
        self.input(text: changed, requireSetResult: requireSetResult)
    }

    /// キーボード経由でのカーソル移動
    fileprivate func moveCursor(count: Int, requireSetResult: Bool = true) {
        if count == 0 {
            return
        }
        // カーソルを移動した直後、挙動が不安定であるためにafterAdjustedを使う
        afterAdjusted = true
        // 入力中の文字が空の場合は普通に動かす
        if composingText.isEmpty {
            // この場合は無視できる
            try? self.displayedTextManager.moveCursor(count: count, isComposing: false)
            return
        }
        debug("Input Manager moveCursor:", composingText, count)

        let operation = self.composingText.moveCursorFromCursorPosition(count: count)
        do {
            try self.displayedTextManager.moveCursor(count: operation.cursor)
        } catch {
            self.clear()
        }
        if count != 0 && requireSetResult {
            setResult()
        }
    }

    // MARK: userが勝手にカーソルを何かした場合の後処理
    fileprivate func userMovedCursor(count: Int) {
        debug("userによるカーソル移動を検知、今の位置は\(composingText.convertTargetCursorPosition)、動かしたオフセットは\(count)")
        if composingText.isEmpty {
            // 入力がない場合はreturnしておかないと、入力していない時にカーソルを動かせなくなってしまう。
            return
        }
        let operation = composingText.moveCursorFromCursorPosition(count: count)
        let delta = operation.cursor - count
        if delta != 0 {
            try? self.displayedTextManager.moveCursor(count: delta, isComposing: false)
            afterAdjusted = true
        }
        setResult()
    }

    // ユーザがキーボードを経由せずペーストした場合の処理
    fileprivate func userPastedText(text: String) {
        // 入力された分を反映する
        _ = self.composingText.insertAtCursorPosition(text, inputStyle: .direct)

        isSelected = false
        setResult()
        VariableStates.shared.setEnterKeyState(.complete)
    }

    // ユーザがキーボードを経由せずカットした場合の処理
    fileprivate func userCutText(text: String) {
        self.clear()
    }

    // ユーザが選択領域で文字を入力した場合
    fileprivate func userReplacedSelectedText(text: String) {
        // 新たな入力を反映
        _ = self.composingText.insertAtCursorPosition(text, inputStyle: .direct)

        isSelected = false

        setResult()
        VariableStates.shared.setEnterKeyState(.complete)
    }

    // ユーザが文章を選択した場合、その部分を入力中であるとみなす(再変換)
    fileprivate func userSelectedText(text: String) {
        if text.isEmpty {
            return
        }
        // 長すぎるのはダメ
        if text.count > 100 {
            return
        }
        if text.hasPrefix("http") {
            return
        }
        // 改行文字はだめ
        if text.contains("\n") || text.contains("\r") {
            return
        }
        // 空白文字もだめ
        if text.contains(" ") || text.contains("\t") {
            return
        }
        // 過去のログを見て、再変換に利用する
        // 再変換処理をもっと上手くやりたい
        composingText.clear()
        if let element = self.getMatch(word: text) {
            _ = self.composingText.insertAtCursorPosition(element.ruby.toHiragana(), inputStyle: .direct)
        } else {
            _ = self.composingText.insertAtCursorPosition(text, inputStyle: .direct)
        }

        isSelected = true
        setResult()
        VariableStates.shared.setEnterKeyState(.edit)
    }

    // 選択を解除した場合、clearとみなす
    fileprivate func userDeselectedText() {
        self.clear()
        VariableStates.shared.setEnterKeyState(.return)
    }

    // ライブ変換を管理するためのクラス
    fileprivate class LiveConversionManager {
        init() {
            @KeyboardSetting(.liveConversion) var enabled
            self.enabled = enabled
        }
        var enabled = false

        private(set) var isFirstClauseCompletion: Bool = false
        // 現在ディスプレイに表示されている候補
        private(set) var lastUsedCandidate: Candidate?
        private var headClauseCandidateHistories: [[Candidate]] = []

        func clear() {
            self.lastUsedCandidate = nil
            @KeyboardSetting(.liveConversion) var enabled
            self.enabled = enabled
            self.headClauseCandidateHistories = []
        }

        func updateAfterFirstClauseCompletion() {
            // ここはどうにかしたい
            self.lastUsedCandidate = nil
            // フラグを戻す
            self.isFirstClauseCompletion = false
            // 最初を落とす
            headClauseCandidateHistories.removeFirst()
        }

        private func updateHistories(newCandidate: Candidate, firstClauseCandidates: [Candidate]) {
            var data = newCandidate.data[...]
            var count = 0
            while data.count > 0 {
                var clause = Candidate.makePrefixClauseCandidate(data: data)
                // ローマ字向けに補正処理を入れる
                if count == 0, let first = firstClauseCandidates.first(where: {$0.text == clause.text}){
                    clause.correspondingCount = first.correspondingCount
                }
                if self.headClauseCandidateHistories.count <= count {
                    self.headClauseCandidateHistories.append([clause])
                } else {
                    self.headClauseCandidateHistories[count].append(clause)
                }
                data = data.dropFirst(clause.data.count)
                count += 1
            }
        }

        /// `lastUsedCandidate`を更新する関数
        func setLastUsedCandidate(_ candidate: Candidate?, firstClauseCandidates: [Candidate] = []) {
            if let candidate {
                // 削除や置換ではなく付加的な変更である場合に限って更新を実施したい。
                let diff: Int
                if let lastUsedCandidate {
                    let lastLength = lastUsedCandidate.data.reduce(0) {$0 + $1.ruby.count}
                    let newLength = candidate.data.reduce(0) {$0 + $1.ruby.count}
                    diff = newLength - lastLength
                } else {
                    diff = 1
                }
                self.lastUsedCandidate = candidate
                // 追加である場合
                if diff > 0 {
                    self.updateHistories(newCandidate: candidate, firstClauseCandidates: firstClauseCandidates)
                } else if diff < 0 {
                    // 削除の場合には最後尾のログを1つ落とす。
                    self.headClauseCandidateHistories.mutatingForeach {
                        _ = $0.popLast()
                    }
                } else {
                    // 置換の場合には更新を追加で入れる。
                    self.headClauseCandidateHistories.mutatingForeach {
                        _ = $0.popLast()
                    }
                    self.updateHistories(newCandidate: candidate, firstClauseCandidates: firstClauseCandidates)
                }
            } else {
                self.lastUsedCandidate = nil
                self.headClauseCandidateHistories = []
            }
        }

        /// 条件に応じてCandidateを微調整するための関数
        func adjustCandidate(candidate: inout Candidate) {
            if let last = candidate.data.last, last.ruby.count < 2 {
                let ruby_hira = last.ruby.toHiragana()
                let newElement = DicdataElement(word: ruby_hira, ruby: last.ruby, lcid: last.lcid, rcid: last.rcid, mid: last.mid, value: last.adjustedData(0).value(), adjust: last.adjust)
                var newCandidate = Candidate(text: candidate.data.dropLast().map {$0.word}.joined() + ruby_hira, value: candidate.value, correspondingCount: candidate.correspondingCount, lastMid: candidate.lastMid, data: candidate.data.dropLast() + [newElement])
                newCandidate.parseTemplate()
                debug(candidate, newCandidate)
                candidate = newCandidate
            }
        }

        /// `insert`の前に削除すべき長さを返す関数。
        func calculateNecessaryBackspaceCount(rubyCursorPosition: Int) -> Int {
            if let lastUsedCandidate {
                // 直前のCandidateでinsertされた長さ
                // 通常、この文字数を消せば問題がない
                let lastCount = lastUsedCandidate.text.count
                // 直前に部分確定が行われた場合は話が異なる
                // この場合、「本来の文字数 == ルビカウントの和」と「今のカーソルポジション」の差分をとり、その文字数がinsertされたのだと判定していた
                // 「愛してる」において「愛し」を部分確定した場合を考える
                // 本来のルビカウントは5である
                // 一方、rubyCursorPositionとしては2が与えられる
                // 故に3文字に対応する部分が確定されているので、
                // 現在のカーソル位置から、直前のCandidateのルビとしての長さを引いている
                // カーソル位置は「ルビとしての長さ」なので、「田中」に対するrubyCursorPositionは「タナカ|」の3であることが期待できる。
                // 一方lastUsedCandidate.data.reduce(0) {$0 + $1.ruby.count}はタナカの3文字なので3である。
                // 従ってこの例ではdelta=0と言える。
                debug("Live Conversion Delete Count Calc:", lastUsedCandidate, rubyCursorPosition)
                let delta = rubyCursorPosition - lastUsedCandidate.data.reduce(0) {$0 + $1.ruby.count}
                return lastCount + delta
            } else {
                return rubyCursorPosition
            }
        }

        /// 最初の文節を確定して良い場合Candidateを返す関数
        /// - warning:
        ///   この関数を呼んで結果を得た場合、必ずそのCandidateで確定処理を行う必要がある。
        func candidateForCompleteFirstClause() -> Candidate? {
            @KeyboardSetting(.automaticCompletionStrength) var strength
            guard let history = headClauseCandidateHistories.first else {
                return nil
            }
            if history.count < strength.treshold {
                return nil
            }

            // 過去十分な回数変動がなければ、prefixを確定して良い
            debug("History", history)
            let texts = history.suffix(strength.treshold).mapSet{ $0.text }
            if texts.count == 1 {
                self.isFirstClauseCompletion = true
                return history.last!
            } else {
                return nil
            }
        }
    }

    // 変換リクエストを送信し、結果を反映する関数
    fileprivate func setResult() {
        var results = [Candidate]()
        var firstClauseResults = [Candidate]()
        let result: [Candidate]
        let requireJapanesePrediction: Bool
        let requireEnglishPrediction: Bool
        switch VariableStates.shared.inputStyle {
        case .direct:
            requireJapanesePrediction = true
            requireEnglishPrediction = true
        case .roman2kana:
            requireJapanesePrediction = VariableStates.shared.keyboardLanguage == .ja_JP
            requireEnglishPrediction = VariableStates.shared.keyboardLanguage == .en_US
        }
        let inputData = composingText.prefixToCursorPosition()
        debug("setResult value to be input", inputData)
        (result, firstClauseResults) = self.kanaKanjiConverter.requestCandidates(inputData, N_best: 10, requirePrediction: requireJapanesePrediction, requireEnglishPrediction: requireEnglishPrediction)
        results.append(contentsOf: result)
        // TODO: 最後の1単語のライブ変換を抑制したい
        // TODO: ローマ字入力中に最後の単語が優先される問題
        if liveConversionEnabled {
            var candidate: Candidate
            if self.composingText.convertTargetCursorPosition > 1, let firstCandidate = result.first(where: {$0.data.map {$0.ruby}.joined().count == inputData.convertTarget.count}) {
                candidate = firstCandidate
            } else {
                candidate = .init(text: inputData.convertTarget, value: 0, correspondingCount: inputData.convertTarget.count, lastMid: 0, data: [.init(ruby: inputData.convertTarget.toKatakana(), cid: 0, mid: 0, value: 0)])
            }
            self.liveConversionManager.adjustCandidate(candidate: &candidate)
            debug("Live Conversion:", candidate)

            // カーソルなどを調整する
            if self.composingText.convertTargetCursorPosition > 0 {
                let deleteCount = self.liveConversionManager.calculateNecessaryBackspaceCount(rubyCursorPosition: self.composingText.convertTargetCursorPosition)
                self.displayedTextManager.replace(count: deleteCount, with: candidate.text)
                debug("Live Conversion View Update: delete \(deleteCount) letters, insert \(candidate.text)")
                self.liveConversionManager.setLastUsedCandidate(candidate, firstClauseCandidates: firstClauseResults)
            }
        }

        debug("results to be registered:", results)
        Store.shared.registerResult(results)

        if liveConversionEnabled {
            // 自動確定の実施
            if let firstClause = self.liveConversionManager.candidateForCompleteFirstClause() {
                debug("Complete first clause", firstClause)
                self.complete(candidate: firstClause)
            }
        }
    }

    #if DEBUG
    // debug中であることを示す。
    fileprivate var isDebugMode: Bool = false
    #endif

    #if DEBUG
    fileprivate func setDebugResult() {
        if !isDebugMode {
            return
        }

        var left = self.displayedTextManager.documentContextBeforeInput ?? "nil"
        if left == "\n"{
            left = "↩︎"
        }

        var center = self.displayedTextManager.selectedText ?? "nil"
        center = center.replacingOccurrences(of: "\n", with: "↩︎")

        var right = self.displayedTextManager.documentContextAfterInput ?? "nil"
        if right == "\n"{
            right = "↩︎"
        }
        if right.isEmpty {
            right = "empty"
        }
        let text = "left:\(Array(left.unicodeScalars))/center:\(Array(center.unicodeScalars))/right:\(Array(right.unicodeScalars))"

        Store.shared.registerResult([Candidate(text: text, value: .zero, correspondingCount: 0, lastMid: 500, data: [])])
        isDebugMode = true
    }
    #endif
}

/// UI側の入力中のテキストの更新を受け持つクラス
final class DisplayedTextManager {
    init() {
        @KeyboardSetting(.liveConversion) var enabled
        self.isLiveConversionEnabled = enabled

        @KeyboardSetting(.markedTextSetting) var markedTextEnabled
        self.isMarkedTextEnabled = markedTextEnabled != .disabled
    }
    // Viewに表示されているテキスト全体
    // ライブ変換が有効になっている場合、convertedTextが「きょうは」のときに「今日は」が入る
    // 無効になっている場合はconvertedTextと一致する
    private(set) var displayedText: String = ""
    // その中でのカーソルポジション
    private(set) var displayedTextCursorPosition = 0
    // ライブ変換の有効化状態
    private(set) var isLiveConversionEnabled: Bool
    // marked textの有効化状態
    private(set) var isMarkedTextEnabled: Bool
    // proxy
    private var proxy: UITextDocumentProxy!

    func setTextDocumentProxy(_ proxy: UITextDocumentProxy!) {
        self.proxy = proxy
    }

    var documentContextAfterInput: String? {
        return self.proxy.documentContextAfterInput
    }

    var selectedText: String? {
        return self.proxy.selectedText
    }

    var documentContextBeforeInput: String? {
        return self.proxy.documentContextBeforeInput
    }

    func clear() {
        // unmarkText()だけではSafariの検索Viewなどで破綻する。
        if isMarkedTextEnabled {
            self.proxy?.setMarkedText("", selectedRange: NSRange(location: 0, length: 0))
            self.proxy?.unmarkText()
            self.proxy?.insertText(self.displayedText)
        }
        @KeyboardSetting(.liveConversion) var enabled
        self.isLiveConversionEnabled = enabled
        @KeyboardSetting(.markedTextSetting) var markedTextEnabled
        self.isMarkedTextEnabled = markedTextEnabled != .disabled

        self.displayedText = ""
        self.displayedTextCursorPosition = 0
    }

    private func getActualOffset(count: Int) -> Int {
        if count == 0 {
            return 0
        } else if count>0 {
            if let after = self.proxy.documentContextAfterInput {
                // 改行があって右端の場合ここに来る。
                if after.isEmpty {
                    return 1
                }
                let suf = after.prefix(count)
                debug("あとの文字は、", suf, -suf.utf16.count)
                return suf.utf16.count
            } else {
                return 1
            }
        } else {
            if let before = self.proxy.documentContextBeforeInput {
                let pre = before.suffix(-count)
                debug("前の文字は、", pre, -pre.utf16.count)

                return -pre.utf16.count

            } else {
                return -1
            }
        }
    }

    /// MarkedTextを更新する関数
    /// この関数自体はisMarkedTextEnabledのチェックを行わない。
    func updateMarkedText() {
        self.proxy.setMarkedText(self.displayedText, selectedRange: NSRange(location: self.displayedTextCursorPosition, length: 0))
    }

    func insertText(_ text: String, isComposing: Bool = true) {
        if isComposing {
            self.displayedText.insert(
                contentsOf: text,
                at: self.displayedText.indexFromStart(displayedTextCursorPosition)
            )
            self.displayedTextCursorPosition += text.count
        }
        if isMarkedTextEnabled && isComposing {
            self.updateMarkedText()
        } else {
            self.proxy.insertText(text)
        }
    }

    // 与えられたカウントをそのまま使う
    // 正しい文字数移動できない可能性がある
    // DisplayedTextの位置は更新しない
    func unsafeMoveCursor(unsafeCount: Int) {
        self.proxy.adjustTextPosition(byCharacterOffset: unsafeCount)
    }

    enum OperationError: Error {
        case liveConversion
        case deleteTooMuch
    }

    func moveCursor(count: Int, isComposing: Bool = true) throws {
        // ライブ変換中はカーソル移動の場合変換を停止したいので、動かすだけ動かしてエラーを投げる。
        if isComposing && isLiveConversionEnabled {
            let offset = self.getActualOffset(count: count)
            self.proxy.adjustTextPosition(byCharacterOffset: offset)
            throw OperationError.liveConversion
        }
        // 更新
        if isComposing {
            self.displayedTextCursorPosition += count
        }
        // 反映
        if isMarkedTextEnabled && isComposing {
            self.updateMarkedText()
        } else {
            let offset = self.getActualOffset(count: count)
            self.proxy.adjustTextPosition(byCharacterOffset: offset)
        }
    }

    // ただ与えられた回数の削除を実行する関数
    func rawDeleteBackward(count: Int = 1) {
        for _ in 0 ..< count {
            self.proxy.deleteBackward()
        }
    }

    // isComposingの場合、countはadjust済みであることを期待する
    // されていなかった場合は例外を投げる
    func deleteBackward(count: Int, isComposing: Bool = true) throws {
        if count == 0 {
            return
        }
        if count < 0 {
            try self.deleteForward(count: abs(count), isComposing: isComposing)
            return
        }
        if !isComposing {
            self.rawDeleteBackward(count: count)
            return
        }

        let adjustedCount = min(self.displayedTextCursorPosition, count)
        let leftIndex = self.displayedText.indexFromStart(self.displayedTextCursorPosition - adjustedCount)
        let rightIndex = self.displayedText.indexFromStart(self.displayedTextCursorPosition)
        self.displayedText.removeSubrange(leftIndex ..< rightIndex)
        self.displayedTextCursorPosition -= adjustedCount

        if isMarkedTextEnabled && isComposing {
            self.updateMarkedText()
        } else {
            self.rawDeleteBackward(count: adjustedCount)
        }

        let delta = count - adjustedCount
        if delta > 0 {
            if isMarkedTextEnabled {
                if displayedText.isEmpty {
                    self.rawDeleteBackward(count: delta)
                    throw OperationError.deleteTooMuch
                }
            } else {
                self.rawDeleteBackward(count: delta)
                throw OperationError.deleteTooMuch
            }
        }
    }

    // ただ与えられた回数の削除を入力方向に実行する関数
    // カーソルが動かせない場合を検知するために工夫を入れている
    // TODO: iOS16以降のテキストフィールドの仕様変更で動かなくなっている。直す必要があるが、どうしようもない気がしている。
    func rawDeleteForward(count: Int) {
        for _ in 0 ..< count {
            let before_b = self.proxy.documentContextBeforeInput
            let before_a = self.proxy.documentContextAfterInput
            // 例外は無視できる
            try? self.moveCursor(count: 1, isComposing: false)
            if before_a != self.proxy.documentContextAfterInput || before_b != self.proxy.documentContextBeforeInput {
                self.proxy.deleteBackward()
            } else {
                return
            }
        }
    }

    // isComposingの場合、countはadjust済みであることを期待する
    // されていなかった場合は例外を投げる
    func deleteForward(count: Int = 1, isComposing: Bool = true) throws {
        if count == 0 {
            return
        }
        if count < 0 {
            try self.deleteBackward(count: abs(count), isComposing: isComposing)
            return
        }
        if !isComposing {
            self.rawDeleteForward(count: count)
            return
        }

        let adjustedCount = min(self.displayedText.count - self.displayedTextCursorPosition, count)
        let leftIndex = self.displayedText.indexFromStart(self.displayedTextCursorPosition)
        let rightIndex = self.displayedText.indexFromStart(self.displayedTextCursorPosition + adjustedCount)
        self.displayedText.removeSubrange(leftIndex ..< rightIndex)

        if isMarkedTextEnabled && isComposing {
            self.updateMarkedText()
        } else {
            self.rawDeleteForward(count: adjustedCount)
        }
        let delta = count - adjustedCount
        if delta > 0 {
            if isMarkedTextEnabled {
                if displayedText.isEmpty {
                    self.rawDeleteForward(count: delta)
                    throw OperationError.deleteTooMuch
                }
            } else {
                self.rawDeleteForward(count: delta)
                throw OperationError.deleteTooMuch
            }
        }
    }

    // カーソルから前count文字をtextで置換する
    func replace(count: Int, with text: String, isComposing: Bool = true) {
        if isComposing {
            let leftIndex = self.displayedText.indexFromStart(self.displayedTextCursorPosition - count)
            let rightIndex = self.displayedText.indexFromStart(self.displayedTextCursorPosition)
            self.displayedText.removeSubrange(leftIndex ..< rightIndex)
            self.displayedText.insert(contentsOf: text, at: leftIndex)
            self.displayedTextCursorPosition -= count
            self.displayedTextCursorPosition += text.count
        }

        if isMarkedTextEnabled && isComposing {
            self.updateMarkedText()
        } else {
            self.rawDeleteBackward(count: count)
            self.proxy.insertText(text)
        }
    }
}
