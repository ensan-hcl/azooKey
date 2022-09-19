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
    private(set) var resultModel = ResultModel<Candidate>()
    /// Storeのキーボードへのアクション部門の動作を全て切り出したオブジェクト。
    private(set) var action = KeyboardActionDepartment()

    private init() {
        VariableStates.shared.action = action
    }

    func settingCheck() {
        if MemoryResetCondition.shouldReset() {
            self.action.sendToDicdataStore(.resetMemory)
        }
        @KeyboardSetting(.learningType) var learningType
        self.action.sendToDicdataStore(.notifyLearningType(learningType))
    }

    /// Call this method after initialize
    func initialize() {
        debug("Storeを初期化します")
        self.settingCheck()
        VariableStates.shared.initialize()
        self.action.initialize()
    }

    func appearedAgain() {
        debug("再び表示されました")
        self.settingCheck()
        VariableStates.shared.initialize()
        self.action.appearedAgain()
    }

    fileprivate func registerResult(_ result: [Candidate]) {
        self.resultModel.setResults(result)
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

    fileprivate func initialize() {
        self.inputManager.closeKeyboard()
        self.timers.forEach {$0.timer.invalidate()}
        self.timers = []
    }

    fileprivate func closeKeyboard() {
        self.initialize()
    }

    fileprivate func appearedAgain() {
        self.sendToDicdataStore(.reloadUserDict)
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
        candidate.actions.forEach {
            self.doAction($0)
        }
    }

    private func showResultView() {
        VariableStates.shared.showTabBar = false
        VariableStates.shared.showMoveCursorBar = false
    }

    private func doAction(_ action: ActionType) {
        switch action {
        case let .input(text):
            self.showResultView()
            if VariableStates.shared.aAKeyState == .capsLock && [.en_US, .el_GR].contains(VariableStates.shared.keyboardLanguage) {
                let input = text.uppercased()
                self.inputManager.input(text: input)
            } else {
                self.inputManager.input(text: text)
            }
        case let .delete(count):
            self.showResultView()
            self.inputManager.deleteBackward(count: count)

        case .smoothDelete:
            Sound.smoothDelete()
            self.showResultView()
            self.inputManager.smoothDelete()
        case let .smartDelete(item):
            switch item.direction {
            case .forward:
                self.inputManager.smoothDelete(to: item.targets.map {Character($0)})
            case .backward:
                self.inputManager.smoothDelete(to: item.targets.map {Character($0)})
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
            self.inputManager.moveCursor(count: count)
        case let .smartMoveCursor(item):
            switch item.direction {
            case .forward:
                self.inputManager.smartMoveCursorForward(to: item.targets.map {Character($0)})
            case .backward:
                self.inputManager.smartMoveCursorBackward(to: item.targets.map {Character($0)})
            }
        case let .changeCapsLockState(state):
            VariableStates.shared.aAKeyState = state
        case .toggleShowMoveCursorView:
            VariableStates.shared.showTabBar = false
            VariableStates.shared.showMoveCursorBar.toggle()
        case .enter:
            self.showResultView()
            let actions = self.inputManager.enter()
            actions.forEach {
                self.doAction($0)
            }
        case .changeCharacterType:
            self.showResultView()
            self.inputManager.changeCharacter()
        case let .replaceLastCharacters(table):
            self.showResultView()
            self.inputManager.replaceLastCharacters(table: table)
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
            self.inputManager.isDebugMode.toggle()
            if self.inputManager.isDebugMode {
                var left = self.inputManager.proxy.documentContextBeforeInput ?? "nil"
                if left == "\n"{
                    left = "↩︎"
                }

                var center = self.inputManager.proxy.selectedText ?? "nil"
                center = center.replacingOccurrences(of: "\n", with: "↩︎")

                var right = self.inputManager.proxy.documentContextAfterInput ?? "nil"
                if right == "\n"{
                    right = "↩︎"
                }
                if right.isEmpty {
                    right = "empty"
                }

                self.setDebugPrint("left:\(Array(left.unicodeScalars))/center:\(Array(center.unicodeScalars))/right:\(Array(right.unicodeScalars))")
            }
        #endif
        }
    }

    override func changeInputStyle(from beforeStyle: InputStyle, to afterStyle: InputStyle) {
        self.inputManager.changeInputStyle(from: beforeStyle, to: afterStyle)
    }

    /// 押した場合に行われる。
    /// - Parameters:
    ///   - action: 行われた動作。
    override func registerAction(_ action: ActionType) {
        self.doAction(action)
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
                action.repeat.forEach {
                    self?.doAction($0)
                }
            }
        })
        self.timers.append((type: action, timer: startTimer))

        let repeatTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: {[weak self] _ in
            action.start.first?.sound()
            action.start.forEach {
                self?.doAction($0)
            }
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
    // MARK: left/center/rightとして得られる情報は以下の通り
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

    /// 何かが変化した後に状態を比較し、どのような変化が起こったのか判断する関数。
    override func notifySomethingDidChange(a_left: String, a_center: String, a_right: String) {
        if self.inputManager.isAfterAdjusted() {
            return
        }
        if self.inputManager.liveConversionManager.enabled {
            self.inputManager.clear()
        }
        debug("something did happen by user!")
        let b_left = self.tempTextData.left
        let b_center = self.tempTextData.center
        let b_right = self.tempTextData.right

        let a_wholeText = a_left + a_center + a_right
        let b_wholeText = b_left + b_center + b_right
        let isWholeTextChanged = a_wholeText != b_wholeText
        let wasSelected = !b_center.isEmpty
        let isSelected = !a_center.isEmpty

        if isSelected {
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

    #if DEBUG
    func setDebugPrint(_ text: String) {
        self.inputManager.setDebugResult(text: text)
    }
    #endif
}

// ActionDepartmentの状態を保存する部分
private final class InputManager {
    fileprivate var proxy: UITextDocumentProxy!

    // セレクトされているか否か、現在入力中の文字全体がセレクトされているかどうかである。
    fileprivate var isSelected = false
    private var afterAdjusted: Bool = false

    private(set) var composingText = ComposingText()
    fileprivate var liveConversionManager = LiveConversionManager()
    private var liveConversionEnabled: Bool {
        return liveConversionManager.enabled && !self.isSelected
    }
    private var candidatesLog: Deque<DicdataElement> = []

    private func updateLog(candidate: Candidate) {
        candidatesLog.append(contentsOf: candidate.data)
        while candidatesLog.count > 100 {  // 最大100個までログを取る
            candidatesLog.removeFirst()
        }
    }

    private func getMatch(word: String) -> DicdataElement? {
        return candidatesLog.last(where: {$0.word == word})
    }

    private typealias RomanConverter = KanaKanjiConverter<RomanInputData, RomanLatticeNode>
    private typealias DirectConverter = KanaKanjiConverter<DirectInputData, DirectLatticeNode>
    /// かな漢字変換を受け持つ変換器。
    private var _romanConverter: RomanConverter?
    private var _directConverter: DirectConverter?

    private var romanConverter: RomanConverter {
        self._directConverter = nil
        if let romanConverter = self._romanConverter {
            return romanConverter
        }
        self._romanConverter = RomanConverter()
        return self._romanConverter!
    }

    private var directConverter: DirectConverter {
        self._romanConverter = nil
        if let flickConverter = self._directConverter {
            return flickConverter
        }
        self._directConverter = DirectConverter()
        return self._directConverter!
    }

    func changeInputStyle(from beforeStyle: InputStyle, to afterStyle: InputStyle) {
        self.composingText.setInputStyle(afterStyle)
        switch (beforeStyle, afterStyle) {
        case (.direct, .roman2kana):
            let converter = RomanConverter()
            converter.translated(from: self.directConverter)
            self._romanConverter = converter
            self._directConverter = nil
        case (.roman2kana, .direct):
            let converter = DirectConverter()
            converter.translated(from: self.romanConverter)
            self._directConverter = converter
            self._romanConverter = nil
        default:
            return
        }
    }

    func sendToDicdataStore(_ data: KeyboardActionDepartment.DicdataStoreNotification) {
        self._romanConverter?.sendToDicdataStore(data)
        self._directConverter?.sendToDicdataStore(data)
    }

    fileprivate func setTextDocumentProxy(_ proxy: UITextDocumentProxy) {
        self.proxy = proxy
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
        let count: Int
        if liveConversionEnabled {
            // composingText.convertTargetCursorPositionは変換前の「キョウノテンキ|」のような文字列における位置を示すが、ライブ変換中は「今日の天気|」のような状態になっている。そこでその場合には「今日の天気|」の方の長さを使って削除を実行する。
            count = self.liveConversionManager.lastUsedCandidate?.text.count ?? self.composingText.convertTargetCursorPosition
        } else {
            count = self.composingText.convertTargetCursorPosition
        }
        debug("complete: ", count, self.liveConversionManager.lastUsedCandidate)
        if !self.isSelected {
            (0..<count).forEach {_ in
                self.proxy.deleteBackward()
            }
        }
        self.isSelected = false

        self.composingText.setInputStyle(VariableStates.shared.inputStyle)
        debug("complete:", candidate, composingText)
        switch VariableStates.shared.inputStyle {
        case .direct:
            self.directConverter.updateLearningData(candidate)
        case .roman2kana:
            self.romanConverter.updateLearningData(candidate)
        }
        self.composingText.complete(correspondingCount: candidate.correspondingCount)
        self.proxy.insertText(candidate.text + self.composingText.convertTarget)
        if self.composingText.convertTarget.isEmpty {
            self.clear()
            VariableStates.shared.setEnterKeyState(.return)
            return
        }

        switch VariableStates.shared.inputStyle {
        case .direct:
            self.directConverter.setCompletedData(candidate)
        case .roman2kana:
            self.romanConverter.setCompletedData(candidate)
        }

        if liveConversionEnabled {
            if self.composingText.convertTarget.isEmpty {
                self.liveConversionManager.setLastUsedCandidate(nil)
            } else  {
                self.liveConversionManager.updateAfterFirstClauseCompletion()
            }
        }
        if self.composingText.isAtStartIndex {
            self.composingText.moveCursorFromCursorPosition(count: self.composingText.convertTarget.count)
            // 入力の直後、documentContextAfterInputは間違っていることがあるため、ここではoffsetをcomposingTextから直接計算する。
            let offset = self.composingText.convertTarget.utf16.count
            self.proxy.adjustTextPosition(byCharacterOffset: offset)
            self.afterAdjusted = true
        }
        self.setResult()
    }

    fileprivate func clear() {
        debug("クリアしました")
        self.composingText = .init()
        self.isSelected = false
        self.liveConversionManager.clear()
        self.setResult()
        self._romanConverter?.clear()
        self._directConverter?.clear()
        VariableStates.shared.setEnterKeyState(.return)
    }

    fileprivate func closeKeyboard() {
        debug("キーボードを閉じます")
        self.sendToDicdataStore(.closeKeyboard)
        self._romanConverter = nil
        self._directConverter = nil
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
        let actions: [ActionType]
        switch VariableStates.shared.inputStyle {
        case .direct:
            actions = self.directConverter.getApporopriateActions(_candidate)
            _candidate.withActions(actions)
            _candidate.parseTemplate()
            self.directConverter.updateLearningData(_candidate)
        case .roman2kana:
            actions = self.romanConverter.getApporopriateActions(_candidate)
            _candidate.withActions(actions)
            _candidate.parseTemplate()
            self.romanConverter.updateLearningData(_candidate)
        }
        self.clear()
        return actions
    }

    // MARK: キーボード経由でユーザがinputを行った場合に呼び出す
    fileprivate func input(text: String) {
        if self.isSelected {
            // 選択は解除される
            self.isSelected = false

            // キーボードの状態と無関係にdirectに設定し、入力をそのまま持たせる
            self.composingText.setInputStyle(.direct)
            let _ = self.composingText.insertAtCursorPosition(text)

            // 実際に入力する
            self.proxy.insertText(text)
            setResult()

            VariableStates.shared.setEnterKeyState(.complete)
            return
        }

        if text == "\n"{
            self.proxy.insertText(text)
            self.clear()
            return
        }
        // スペースだった場合
        if text == " " || text == "　" || text == "\t" || text == "\0"{
            self.proxy.insertText(text)
            self.clear()
            return
        }

        if VariableStates.shared.keyboardLanguage == .none {
            self.proxy.insertText(text)
            self.clear()
            return
        }

        self.composingText.setInputStyle(VariableStates.shared.inputStyle)
        let operation = self.composingText.insertAtCursorPosition(text)
        for _ in 0 ..< operation.delete {
            self.proxy.deleteBackward()
        }
        self.proxy.insertText(operation.input)

        debug("Input Manager input: ", composingText)

        VariableStates.shared.setEnterKeyState(.complete)

        setResult()
    }

    /// テキストの進行方向に削除する
    /// `ab|c → ab|`のイメージ
    fileprivate func deleteForward(count: Int, requireSetResult: Bool = true) {
        if count < 0 {
            return
        }

        if self.composingText.convertTarget.isEmpty {
            self.proxy.deleteForward(count: count)
            return
        }

        // 一番右端にいるときは削除させない
        if !self.composingText.isEmpty && self.composingText.isAtEndIndex {
            return
        }


        self.composingText.setInputStyle(VariableStates.shared.inputStyle)
        self.composingText.moveCursorFromCursorPosition(count: count)
        self.composingText.backspaceFromCursorPosition(count: count)
        debug("Input Manager deleteForward: ", composingText)
        // 削除を実行する
        self.proxy.deleteForward(count: count)

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
            self.proxy.deleteBackward()
            self.clear()
            return
        }
        // 条件
        if count < 0 {
            self.deleteForward(count: abs(count), requireSetResult: requireSetResult)
            return
        }
        // 一番左端にいるときは削除させない
        if !self.composingText.isEmpty && self.composingText.isAtStartIndex {
            return
        }

        self.composingText.setInputStyle(VariableStates.shared.inputStyle)
        self.composingText.backspaceFromCursorPosition(count: count)
        debug("Input Manager deleteBackword: ", composingText)
        // 削除を実行する
        self.proxy.deleteBackward(count: count)

        if requireSetResult {
            setResult()
        }

        if self.composingText.isEmpty {
            VariableStates.shared.setEnterKeyState(.return)
        }
    }

    /// 特定の文字まで削除する
    fileprivate func smoothDelete(to nexts: [Character] = ["、", "。", "！", "？", ".", ",", "．", "，", "\n"]) {
        // 選択状態ではオール削除になる
        if self.isSelected {
            self.proxy.deleteBackward()
            self.clear()
            return
        }
        // 入力中の場合
        if !self.composingText.isEmpty {
            // 削除を実行する
            let leftSideText = self.composingText.convertTargetBeforeCursor

            if liveConversionEnabled {
                self.proxy.deleteBackward(count: self.liveConversionManager.lastUsedCandidate?.text.count ?? leftSideText.count)
            } else {
                self.proxy.deleteBackward(count: leftSideText.count)
            }
            // カーソルより前を全部消す
            self.composingText.backspaceFromCursorPosition(count: self.composingText.convertTargetCursorPosition)

            // カーソルを先頭に移動する
            self.moveCursor(count: self.composingText.convertTarget.count)
            // 文字がもうなかった場合
            if self.composingText.isEmpty {
                self.clear()
                return
            }
            setResult()
            return
        }

        var deletedCount = 0
        while let last = self.proxy.documentContextBeforeInput?.last {
            if nexts.contains(last) {
                break
            } else {
                self.proxy.deleteBackward()
                deletedCount += 1
            }
        }
        if deletedCount == 0 {
            self.proxy.deleteBackward()
        }
    }

    /// テキストの進行方向に、特定の文字まで削除する
    /// 入力中はカーソルから右側を全部消す
    fileprivate func smoothDeleteForward(to nexts: [Character] = ["、", "。", "！", "？", ".", ",", "．", "，", "\n"]) {
        // 選択状態ではオール削除になる
        if self.isSelected {
            self.proxy.deleteBackward()
            self.clear()
            return
        }
        // 入力中の場合
        if !self.composingText.isEmpty {
            let count = self.composingText.convertTarget.count - self.composingText.convertTargetCursorPosition

            self.composingText.setInputStyle(VariableStates.shared.inputStyle)
            self.composingText.moveCursorFromCursorPosition(count: count)
            self.composingText.backspaceFromCursorPosition(count: count)

            self.proxy.moveCursor(count: count)
            self.proxy.deleteBackward(count: count)
            // 文字がもうなかった場合
            if self.composingText.isEmpty {
                clear()
                setResult()
            }
            return
        }

        var deletedCount = 0
        while let first = self.proxy.documentContextAfterInput?.first {
            if nexts.contains(first) {
                break
            } else {
                self.proxy.deleteForward()
                deletedCount += 1
            }
        }
        if deletedCount == 0 {
            self.proxy.deleteForward()
        }
    }

    /// テキストの進行方向と逆に、特定の文字までカーソルを動かす
    fileprivate func smartMoveCursorBackward(to nexts: [Character] = ["、", "。", "！", "？", ".", ",", "．", "，", "\n"]) {
        // 選択状態では最も左にカーソルを移動
        if isSelected {
            deselect()
            self.composingText.moveCursorFromCursorPosition(count: -self.composingText.convertTargetCursorPosition)
            setResult()
            return
        }
        // 入力中の場合
        if !composingText.isEmpty {
            self.composingText.moveCursorFromCursorPosition(count: -self.composingText.convertTargetCursorPosition)
            setResult()
            return
        }

        var movedCount = 0
        while let last = proxy.documentContextBeforeInput?.last {
            if nexts.contains(last) {
                break
            } else {
                proxy.moveCursor(count: -1)
                movedCount += 1
            }
        }
        if movedCount == 0 {
            proxy.moveCursor(count: -1)
        }
    }

    /// テキストの進行方向に、特定の文字までカーソルを動かす
    fileprivate func smartMoveCursorForward(to nexts: [Character] = ["、", "。", "！", "？", ".", ",", "．", "，", "\n"]) {
        // 選択状態では最も左にカーソルを移動
        if isSelected {
            deselect()
            self.composingText.moveCursorFromCursorPosition(count: self.composingText.convertTarget.count - self.composingText.convertTargetCursorPosition)
            setResult()
            return
        }
        // 入力中の場合
        if !composingText.isEmpty {
            self.composingText.moveCursorFromCursorPosition(count: self.composingText.convertTarget.count - self.composingText.convertTargetCursorPosition)
            setResult()
            return
        }

        var movedCount = 0
        while let first = proxy.documentContextAfterInput?.first {
            if nexts.contains(first) {
                break
            } else {
                proxy.moveCursor(count: 1)
                movedCount += 1
            }
        }
        if movedCount == 0 {
            proxy.moveCursor(count: 1)
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
            deleteBackward(count: 1)
            input(text: selectedText)
            VariableStates.shared.setEnterKeyState(.complete)
        }
    }

    /// 文字のreplaceを実施する
    /// `changeCharacter`を`CustardKit`で扱うためのAPI。
    /// キーボード経由でのみ実行される。
    fileprivate func replaceLastCharacters(table: [String: String]) {
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
            for count in (counts.min...counts.max).reversed() where count <= composingText.convertTargetCursorPosition {
                if let replace = table[String(leftside.suffix(count))] {
                    // deleteとinputを効率的に行うため、setResultを要求しない (変換を行わない)
                    self.deleteBackward(count: count, requireSetResult: false)
                    // ここで変換が行われる。内部的には差分管理システムによって「置換」の場合のキャッシュ変換が呼ばれる。
                    self.input(text: replace)
                    break
                }
            }
            return
        }
        // 入力状態ではない場合、または言語の指定がない場合は、入力中のテキストの範囲でreplaceを実施する。
        if VariableStates.shared.keyboardLanguage == .none {
            let leftside = proxy.documentContextBeforeInput ?? ""
            for count in (counts.min...counts.max).reversed() where count <= leftside.count {
                if let replace = table[String(leftside.suffix(count))] {
                    self.proxy.deleteBackward(count: count)
                    self.input(text: replace)
                    break
                }
            }
        }
    }

    /// カーソル左側の1文字を変更する関数
    /// ひらがなの場合は小書き・濁点・半濁点化し、英字・ギリシャ文字・キリル文字の場合は大文字・小文字化する
    fileprivate func changeCharacter() {
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
        self.input(text: changed)
    }

    /// キーボード経由でのカーソル移動
    fileprivate func moveCursor(count: Int) {
        // ライブ変換中のカーソル移動はとてもじゃないがハンドルできないのでクリアする
        if liveConversionEnabled {
            self.clear()
        }
        if count == 0 {
            return
        }
        // カーソルを移動した直後、挙動が不安定であるためにafterAdjustedを使う
        afterAdjusted = true
        // 入力中の文字が空の場合は普通に動かす
        if composingText.isEmpty {
            proxy.moveCursor(count: count)
            return
        }
        debug("Input Manager moveCursor:", composingText, count)
        // カーソル位置の正規化
        // 動かしすぎないようにする
        var count = count
        if composingText.convertTargetCursorPosition + count > composingText.convertTarget.count {
            count = composingText.convertTarget.count - composingText.convertTargetCursorPosition
        } else if composingText.convertTargetCursorPosition + count < 0 {
            count = 0 - composingText.convertTargetCursorPosition
        }
        proxy.moveCursor(count: count)
        composingText.moveCursorFromCursorPosition(count: count)

        setResult()
    }

    // MARK: userが勝手にカーソルを何かした場合の後処理
    fileprivate func userMovedCursor(count: Int) {
        debug("userによるカーソル移動を検知、今の位置は\(composingText.convertTargetCursorPosition)、動かしたオフセットは\(count)")
        if composingText.isEmpty {
            // 入力がない場合はreturnしておかないと、入力していない時にカーソルを動かせなくなってしまう。
            return
        }

        let originalPossition = composingText.convertTargetCursorPosition
        let actualPosition = originalPossition + count
        if actualPosition > composingText.convertTarget.count {
            proxy.moveCursor(count: composingText.convertTarget.count - actualPosition)
            composingText.moveCursorFromCursorPosition(count: composingText.convertTarget.count - originalPossition)
            setResult()
            afterAdjusted = true
            return
        }
        if actualPosition < 0 {
            proxy.moveCursor(count: -actualPosition)
            composingText.moveCursorFromCursorPosition(count: 0 - originalPossition)
            setResult()
            afterAdjusted = true
            return
        }

        composingText.moveCursorFromCursorPosition(count: count)
        setResult()
    }

    // ユーザがキーボードを経由せずペーストした場合の処理
    fileprivate func userPastedText(text: String) {
        // 入力された分を反映する
        self.composingText.setInputStyle(.direct)
        _ = self.composingText.insertAtCursorPosition(text)
        self.composingText.setInputStyle(VariableStates.shared.inputStyle)

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
        self.composingText.setInputStyle(.direct)
        _ = self.composingText.insertAtCursorPosition(text)
        self.composingText.setInputStyle(VariableStates.shared.inputStyle)

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
        composingText.setInputStyle(.direct)
        if let element = self.getMatch(word: text) {
            _ = self.composingText.insertAtCursorPosition(element.ruby.toHiragana())
        } else {
            _ = self.composingText.insertAtCursorPosition(text)
        }
        self.composingText.setInputStyle(VariableStates.shared.inputStyle)

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
        let input_hira = String(self.composingText.convertTargetBeforeCursor)
        let result: [Candidate]
        switch VariableStates.shared.inputStyle {
        case .direct:
            let inputData = DirectInputData(input_hira)
            debug("value to be input", inputData)
            (result, firstClauseResults) = self.directConverter.requestCandidates(inputData, N_best: 10)
        case .roman2kana:
            let inputData = RomanInputData(self.composingText)
            debug("value to be input", inputData)
            let requireJapanesePrediction = VariableStates.shared.keyboardLanguage == .ja_JP
            let requireEnglishPrediction = VariableStates.shared.keyboardLanguage == .en_US
            (result, firstClauseResults) = self.romanConverter.requestCandidates(inputData, N_best: 10, requirePrediction: requireJapanesePrediction, requireEnglishPrediction: requireEnglishPrediction)
        }
        results.append(contentsOf: result)
        // TODO: 最後の1単語のライブ変換を抑制したい
        // TODO: ローマ字入力中に最後の単語が優先される問題
        if liveConversionEnabled {
            var candidate: Candidate
            if self.composingText.convertTargetCursorPosition > 1, let firstCandidate = result.first(where: {$0.data.map {$0.ruby}.joined().count == input_hira.count}) {
                candidate = firstCandidate
            } else {
                candidate = .init(text: String(input_hira), value: 0, correspondingCount: input_hira.count, lastMid: 0, data: [.init(ruby: String(input_hira), cid: 0, mid: 0, value: 0)])
            }
            self.liveConversionManager.adjustCandidate(candidate: &candidate)
            debug("Live Conversion:", candidate)

            // カーソルなどを調整する
            if self.composingText.convertTargetCursorPosition > 0 {
                let deleteCount = self.liveConversionManager.calculateNecessaryBackspaceCount(rubyCursorPosition: self.composingText.convertTargetCursorPosition)
                self.proxy.deleteBackward(count: deleteCount)
                self.proxy.insertText(candidate.text)
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

    fileprivate func setDebugResult(text: String) {
        #if DEBUG
        if !isDebugMode {
            return
        }

        Store.shared.registerResult([Candidate(text: text, value: .zero, correspondingCount: 0, lastMid: 500, data: [])])
        isDebugMode = true
        #endif
    }
}

extension UITextDocumentProxy {
    private func getActualOffset(count: Int) -> Int {
        if count == 0 {
            return 0
        } else if count>0 {
            if let after = self.documentContextAfterInput {
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
            if let before = self.documentContextBeforeInput {
                let pre = before.suffix(-count)
                debug("前の文字は、", pre, -pre.utf16.count)

                return -pre.utf16.count

            } else {
                return -1
            }
        }
    }

    func moveCursor(count: Int) {
        let offset = self.getActualOffset(count: count)
        self.adjustTextPosition(byCharacterOffset: offset)
    }

    func deleteBackward(count: Int) {
        if count == 0 {
            return
        }
        if count < 0 {
            self.deleteForward(count: abs(count))
            return
        }
        (0..<count).forEach { _ in
            self.deleteBackward()
        }
    }

    func deleteForward(count: Int = 1) {
        if count == 0 {
            return
        }
        if count < 0 {
            self.deleteBackward(count: abs(count))
            return
        }
        (0..<count).forEach { _ in
            if self.documentContextAfterInput == nil {
                return
            }
            self.moveCursor(count: 1)
            self.deleteBackward()
        }
    }

}

/// ユーザ入力、変換対象文字列、ディスプレイされる文字列、の3つを同時にハンドルするための構造体
/// ローマ字入力でライブ変換を使う場合を考える。`kyouhaame`との入力は
///  - `input`: `[k, y, o, u, h, a, a, m, e]`
///  - `convertTarget`: `きょうはあめ`
///  - `displayText`:`今日は雨
/// のようになる。`
/// カーソルのポジションもこのクラスが管理する。
struct ComposingText {
    private(set) var inputStyle: InputStyle = .direct
    var liveConversionEnabled: Bool = false

    var convertTargetCursorPosition: Int = 0
    private(set) var input: [Character] = []
    private(set) var convertTarget: String = ""
    private(set) var displayText: String = ""

    /// ライブ変換が有効化されている場合、カーソル移動を許さない
    var allowCursorMove: Bool {
        return !liveConversionEnabled
    }

    /// 変換しなくて良いか
    var isEmpty: Bool {
        return self.convertTarget.isEmpty
    }

    /// カーソルが右端に存在するか
    var isAtEndIndex: Bool {
        return self.convertTarget.count == self.convertTargetCursorPosition
    }

    /// カーソルが左端に存在するか
    var isAtStartIndex: Bool {
        return 0 == self.convertTargetCursorPosition
    }

    /// カーソルより前の変換対象
    var convertTargetBeforeCursor: some StringProtocol {
        return self.convertTarget.prefix(self.convertTargetCursorPosition)
    }

    /// `input`でのカーソル位置を無理やり作り出す関数
    /// `target`が左側に来るようなカーソルの位置を返す。
    /// 例えば`input`が`[k, y, o, u]`で`target`が`き|`の場合を考える。
    /// この状態では`input`に対応するカーソル位置が存在しない。
    /// この場合、`input`を`[き, ょ, u]`と置き換えた上で`1`を返す。

    private mutating func forceGetInputCursorPosition(target: some StringProtocol) -> Int {
        debug("ComposingText forceGetInputCursorPosition", target, input, convertTarget)
        if target.isEmpty {
            return 0
        }
        // inputを変換するメソッド
        switch inputStyle {
        case .direct:
            // 直接入力の場合、厳密に一致する
            return target.count
        case .roman2kana:
            // 動作例1
            // input: `k, a, n, s, h, a`
            // convetTarget: `か ん し| ゃ`
            // convertTargetCursorPosition: 3
            // target: かんし
            // 動作
            // 1. character = "k"
            //    roman2kana = "k"
            //    count = 1
            // 2. character = "a"
            //    roman2kana = "か"
            //    count = 2
            //    target.hasPrefix(roman2kana)がtrueなので、lastPrefixIndex = 2, lastPrefix = "か"
            // 3. character = "n"
            //    roman2kana = "かn"
            //    count = 3
            // 4. character = "s"
            //    roman2kana = "かんs"
            //    count = 4
            // 5. character = "h"
            //    roman2kana = "かんsh"
            //    count = 5
            // 6. character = "a"
            //    roman2kana = "かんしゃ"
            //    count = 6
            //    roman2kana.hasPrefix(target)がtrueなので、変換しすぎているとみなして調整の実行
            //    replaceCountは6-2 = 4、したがって`n, s, h, a`が消去される
            //    input = [k, a]
            //    count = 2
            //    roman2kana.count == 4, lastPrefix.count = 1なので、3文字分のsuffix`ん,し,ゃ`が追加される
            //    input = [k, a, ん, し, ゃ]
            //    count = 5
            //    while
            //       1. roman2kana = かんし
            //          count = 4
            //       break
            // return count = 4
            //
            // 動作例2
            // input: `k, a, n, s, h, a`
            // convetTarget: `か ん し| ゃ`
            // convertTargetCursorPosition: 2
            // target: かん
            // 動作
            // 1. character = "k"
            //    roman2kana = "k"
            //    count = 1
            // 2. character = "a"
            //    roman2kana = "か"
            //    count = 2
            //    target.hasPrefix(roman2kana)がtrueなので、lastPrefixIndex = 2, lastPrefix = "か"
            // 3. character = "n"
            //    roman2kana = "かn"
            //    count = 3
            // 4. character = "s"
            //    roman2kana = "かんs"
            //    count = 4
            //    roman2kana.hasPrefix(target)がtrueなので、変換しすぎているとみなして調整の実行
            //    replaceCountは4-2 = 2、したがって`n, s`が消去される
            //    input = [k, a] ... [h, a]
            //    count = 2
            //    roman2kana.count == 3, lastPrefix.count = 1なので、2文字分のsuffix`ん,s`が追加される
            //    input = [k, a, ん, s]
            //    count = 4
            //    while
            //       1. roman2kana = かん
            //          count = 3
            //       break
            // return count = 3
            //
            // 動作例3
            // input: `i, t, t, a`
            // convetTarget: `い っ| た`
            // convertTargetCursorPosition: 2
            // target: いっ
            // 動作
            // 1. character = "i"
            //    roman2kana = "い"
            //    count = 1
            //    target.hasPrefix(roman2kana)がtrueなので、lastPrefixIndex = 1, lastPrefix = "い"
            // 2. character = "t"
            //    roman2kana = "いt"
            //    count = 2
            // 3. character = "t"
            //    roman2kana = "いっt"
            //    count = 3
            //    roman2kana.hasPrefix(target)がtrueなので、変換しすぎているとみなして調整の実行
            //    replaceCountは3-1 = 2、したがって`t, t`が消去される
            //    input = [i] ... [a]
            //    count = 1
            //    roman2kana.count == 3, lastPrefix.count = 1なので、2文字分のsuffix`っ,t`が追加される
            //    input = [i, っ, t, a]
            //    count = 3
            //    while
            //       1. roman2kana = いっ
            //          count = 2
            //       break
            // return count = 2

            var roman2kana = ""
            var count = 0
            var lastPrefixIndex = 0
            var lastPrefix = ""
            for character in input {
                (roman2kana, _, _) = String.roman2hiragana(currentText: roman2kana, added: String(character))
                count += 1

                // 一致していたらその時点のカウントを返す
                if roman2kana == target {
                    return count
                }
                // 一致ではないのにhasPrefixが成立する場合、変換しすぎている
                // この場合、inputの変換が必要になる。
                // 例えばcovnertTargetが「あき|ょ」で、`[a, k, y, o]`まで見て「あきょ」になってしまった場合、「あき」がprefixとなる。
                // この場合、lastPrefix=1なので、1番目から現在までの入力をひらがなで置き換える
                else if roman2kana.hasPrefix(target) {
                    let replaceCount = count - lastPrefixIndex
                    let suffix = roman2kana.suffix(roman2kana.count - lastPrefix.count)
                    self.input = self.input.prefix(count - replaceCount) + suffix + self.input.suffix(self.input.count - count)

                    count -= replaceCount
                    count += suffix.count
                    while roman2kana != target {
                        _ = roman2kana.popLast()
                        count -= 1
                    }
                    break
                }
                // prefixになっている場合は更新する
                else if target.hasPrefix(roman2kana) {
                    lastPrefixIndex = count
                    lastPrefix = roman2kana
                }

            }
            return count
        }
    }

    struct ViewOperation {
        var delete: Int
        var input: String
        var moveCursor: Int
    }

    /// 現在のカーソル位置に文字を追加する関数
    mutating func insertAtCursorPosition(_ string: String) -> ViewOperation {
        let inputCursorPosition = self.forceGetInputCursorPosition(target: self.convertTarget.prefix(convertTargetCursorPosition))

        // input, convertTarget, convertTargetCursorPositionの3つを更新する

        switch inputStyle {
        case .direct:
            // inputを更新
            self.input.insert(contentsOf: Array(string), at: inputCursorPosition)
            self.convertTarget = String(self.input)
            // カーソルを1つ進める
            self.convertTargetCursorPosition += string.count

            return ViewOperation(delete: 0, input: string, moveCursor: 0)
        case .roman2kana:
            // inputを更新
            self.input.insert(contentsOf: Array(string), at: inputCursorPosition)
            var roman2kana = ""
            for c in self.input.prefix(inputCursorPosition) {
                (roman2kana, _, _) = String.roman2hiragana(currentText: roman2kana, added: String(c))
            }
            let (newConvertTargetPrefix, deleteCount, input) = String.roman2hiragana(currentText: roman2kana, added: string)
            // convertTargetの更新
            self.convertTarget.removeFirst(convertTargetCursorPosition)
            self.convertTarget.insert(contentsOf: newConvertTargetPrefix, at: convertTarget.startIndex)
            // カーソルを更新する
            self.convertTargetCursorPosition = newConvertTargetPrefix.count

            return ViewOperation(delete: deleteCount, input: input, moveCursor: 0)
        }
    }

    /// 現在のカーソル位置から文字を削除する関数
    /// エッジケースとして、`sha: しゃ|`の状態で1文字消すような場合がある。
    mutating func backspaceFromCursorPosition(count: Int) {
        if self.convertTargetCursorPosition == 0 {
            return
        }
        let count = min(convertTargetCursorPosition, count)

        // input, convertTarget, convertTargetCursorPositionの3つを更新する
        switch inputStyle {
        case .direct:
            self.input = self.input.prefix(convertTargetCursorPosition - count) + self.input.suffix(self.convertTarget.count - self.convertTargetCursorPosition)
            self.convertTargetCursorPosition -= count
            self.convertTarget = String(self.input)
        case .roman2kana:
            // 動作例1
            // convertTarget: かんしゃ|
            // input: [k, a, n, s, h, a]
            // count = 1
            // currentPrefix = かんしゃ
            // これから行く位置
            //  targetCursorPosition = forceGetInputCursorPosition(かんし) = 4
            //  副作用でinputは[k, a, ん, し, ゃ]
            // 現在の位置
            //  inputCursorPosition = forceGetInputCursorPosition(かんしゃ) = 5
            //  副作用でinputは[k, a, ん, し, ゃ]
            // inputを更新する
            //  input =   (input.prefix(targetCursorPosition) = [k, a, ん, し])
            //          + (input.suffix(input.count - inputCursorPosition) = [])
            //        =   [k, a, ん, し]

            // 動作例2
            // convertTarget: かんしゃ|
            // input: [k, a, n, s, h, a]
            // count = 2
            // currentPrefix = かんしゃ
            // これから行く位置
            //  targetCursorPosition = forceGetInputCursorPosition(かん) = 3
            //  副作用でinputは[k, a, ん, s, h, a]
            // 現在の位置
            //  inputCursorPosition = forceGetInputCursorPosition(かんしゃ) = 6
            //  副作用でinputは[k, a, ん, s, h, a]
            // inputを更新する
            //  input =   (input.prefix(targetCursorPosition) = [k, a, ん])
            //          + (input.suffix(input.count - inputCursorPosition) = [])
            //        =   [k, a, ん]

            // 今いる位置
            let currentPrefix = self.convertTarget.prefix(convertTargetCursorPosition)

            // この2つの値はこの順で計算する。
            // これから行く位置
            let targetCursorPosition = self.forceGetInputCursorPosition(target: currentPrefix.dropLast(count))
            // 現在の位置
            let inputCursorPosition = self.forceGetInputCursorPosition(target: currentPrefix)

            // inputを更新する
            self.input = self.input.prefix(targetCursorPosition) + self.input.suffix(self.input.count - inputCursorPosition)
            // カーソルを更新する
            self.convertTargetCursorPosition -= count

            // convetTargetを更新する
            var roman2kana = ""
            for c in self.input {
                (roman2kana, _, _) = String.roman2hiragana(currentText: roman2kana, added: String(c))
            }
            self.convertTarget = roman2kana
        }
    }

    /// 現在のカーソル位置からカーソルを動かす関数
    mutating func moveCursorFromCursorPosition(count: Int) {
        self.convertTargetCursorPosition += count
        self.convertTargetCursorPosition = max(0, self.convertTargetCursorPosition)
        self.convertTargetCursorPosition = min(self.convertTargetCursorPosition, self.convertTarget.count)
    }

    /// 文頭の方を確定させる関数
    ///  - parameters:
    ///   - correspondingCount: `converTarget`において対応する文字数
    mutating func complete(correspondingCount: Int) {
        let correspondingCount = min(correspondingCount, self.input.count)
        self.input.removeFirst(correspondingCount)

        // convetTargetを更新する
        switch inputStyle {
        case .direct:
            // カーソルの位置は、消す文字数の分削除する
            let cursorDelta = self.convertTarget.count - self.input.count
            self.convertTarget = String(self.input)
            self.convertTargetCursorPosition -= cursorDelta
        case .roman2kana:
            var roman2kana = ""
            for c in self.input {
                (roman2kana, _, _) = String.roman2hiragana(currentText: roman2kana, added: String(c))
            }
            // カーソルの位置は、消す文字数の分削除する
            let cursorDelta = self.convertTarget.count - roman2kana.count

            self.convertTarget = roman2kana
            self.convertTargetCursorPosition -= cursorDelta
        }
    }

    mutating func setInputStyle(_ newStyle: InputStyle) {
        if newStyle == inputStyle {
            return
        }
        self.input = Array(self.convertTarget)
        self.inputStyle = newStyle
    }

    func prefixToCursorPosition() -> ComposingText {
        var text = self
        let index = text.forceGetInputCursorPosition(target: text.convertTarget.prefix(text.convertTargetCursorPosition))
        text.input = Array(text.input.prefix(index))
        text.convertTarget = String(text.convertTarget.prefix(text.convertTargetCursorPosition))
        return text
    }
}
