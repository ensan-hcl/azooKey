//
//  Store.swift
//  Calculator-Keyboard
//
//  Created by β α on 2020/04/10.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

final class Store{
    static let shared = Store()
    private(set) var resultModel = ResultModel<Candidate>()
    ///Storeのキーボードへのアクション部門の動作を全て切り出したオブジェクト。
    private(set) var action = KeyboardActionDepartment()

    private init(){
        VariableStates.shared.action = action
    }

    func settingCheck(){
        SettingData.shared.reload()
        if SettingData.checkResetSetting(){
            self.action.sendToDicDataStore(.resetMemory)
        }
        self.action.sendToDicDataStore(.notifyLearningType(SettingData.shared.learningType))
    }

    ///Call this method after initialize
    func initialize(){
        debug("Storeを初期化します")
        self.settingCheck()
        VariableStates.shared.initialize()
        self.action.initialize()
    }

    func appearedAgain(){
        debug("再び表示されました")
        self.settingCheck()
        VariableStates.shared.initialize()
        self.action.appearedAgain()
    }

    fileprivate func registerResult(_ result: [Candidate]){
        self.resultModel.setResults(result)
    }

    func closeKeyboard(){
        VariableStates.shared.closeKeybaord()
        self.action.closeKeyboard()
    }
}

//MARK:Storeのキーボードへのアクション部門の動作を全て切り出したオブジェクト。外部から参照されるのがこれ。
final class KeyboardActionDepartment: ActionDepartment{
    fileprivate override init(){}
    
    private var inputManager = InputManager()
    private weak var delegate: KeyboardViewController!
    
    //即時変数
    private var timers: [(type: LongpressActionType, timer: Timer)] = []
    private var tempTextData: (left: String, center: String, right: String)!
    private var tempSavedSelectedText: String!

    fileprivate func initialize(){
        self.inputManager.closeKeyboard()
        self.timers.forEach{$0.timer.invalidate()}
        self.timers = []
    }

    fileprivate func closeKeyboard(){
        self.initialize()
    }

    fileprivate func appearedAgain(){
        self.sendToDicDataStore(.reloadUserDict)
    }

    func setTextDocumentProxy(_ proxy: UITextDocumentProxy){
        self.inputManager.setTextDocumentProxy(proxy)
    }

    enum DicDataStoreNotification{
        case notifyLearningType(LearningType)
        case importOSUserDict(OSUserDict)
        case notifyAppearAgain
        case reloadUserDict
        case closeKeyboard
        case resetMemory
    }

    func sendToDicDataStore(_ data: DicDataStoreNotification){
        self.inputManager.sendToDicDataStore(data)
    }

    func setDelegateViewController(_ controller: KeyboardViewController){
        self.delegate = controller
    }

    override func makeChangeKeyboardButtonView(theme: ThemeData) -> ChangeKeyboardButtonView {
        delegate.makeChangeKeyboardButtonView(size: Design.fonts.iconFontSize, theme: theme)
    }
    
    ///変換を確定した場合に呼ばれる。
    /// - Parameters:
    ///   - text: String。確定された文字列。
    ///   - count: Int。確定された文字数。例えば「検証」を確定した場合5。
    override func notifyComplete(_ candidate: ResultViewItemData){
        guard let candidate = candidate as? Candidate else {
            debug("確定できません")
            return
        }
        self.inputManager.complete(candidate: candidate)
        candidate.actions.forEach{
            self.doAction($0)
        }
    }

    private func showResultView(){
        VariableStates.shared.showTabBar = false
        VariableStates.shared.showMoveCursorBar = false
    }

    private func doAction(_ action: ActionType){
        switch action{
        case let .input(text):
            self.showResultView()
            if VariableStates.shared.aAKeyState == .capslock && [.english, .greek].contains(VariableStates.shared.keyboardLanguage){
                let input = text.uppercased()
                self.inputManager.input(text: input)
            }else{
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
            switch item.direction{
            case .forward:
                self.inputManager.smoothDelete(to: item.targets.map{Character($0)})
            case .backward:
                self.inputManager.smoothDelete(to: item.targets.map{Character($0)})
            }
        case .deselectAndUseAsInputting:
            self.inputManager.edit()

        case .saveSelectedTextIfNeeded:
            if self.inputManager.isSelected{
                self.tempSavedSelectedText = self.inputManager.inputtedText
            }
        case .restoreSelectedTextIfNeeded:
            if let tmp = self.tempSavedSelectedText{
                self.inputManager.input(text: tmp)
                self.tempSavedSelectedText = nil
            }
        case let .moveCursor(count):
            self.inputManager.moveCursor(count: count)
        case let .smartMoveCursor(item):
            switch item.direction {
            case .forward:
                self.inputManager.smartMoveCursorForward(to: item.targets.map{Character($0)})
            case .backward:
                self.inputManager.smartMoveCursorBackward(to: item.targets.map{Character($0)})
            }
        case let .changeCapsLockState(state):
            VariableStates.shared.aAKeyState = state
        case .toggleShowMoveCursorView:
            VariableStates.shared.showTabBar = false
            VariableStates.shared.showMoveCursorBar.toggle()
        case .enter:
            self.showResultView()
            let actions = self.inputManager.enter()
            actions.forEach{
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
            
        case .hideLearningMemory:
            self.hideLearningMemory()

        case .dismissKeyboard:
            self.delegate.dismissKeyboard()

        case let .openApp(scheme):
            delegate.openApp(scheme: scheme)

        #if DEBUG
        //MARK: デバッグ用
        case .DEBUG_DATA_INPUT:
            self.inputManager.isDebugMode.toggle()
            if self.inputManager.isDebugMode{
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
                if right.isEmpty{
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
    
    ///押した場合に行われる。
    /// - Parameters:
    ///   - action: 行われた動作。
    override func registerAction(_ action: ActionType){
        self.doAction(action)
    }
    
    ///長押しを予約する関数。
    /// - Parameters:
    ///   - action: 長押しで起こる動作のタイプ。
    override func reserveLongPressAction(_ action: LongpressActionType){
        if timers.contains(where: {$0.type == action}){
            return
        }
        let startTime = Date()

        let startTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {[weak self] (timer) in
            let span: TimeInterval = timer.fireDate.timeIntervalSince(startTime)
            if span > 0.4 {
                action.repeat.first?.sound()
                action.repeat.forEach{
                    self?.doAction($0)
                }
            }
        })
        self.timers.append((type: action, timer: startTimer))

        let repeatTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: {[weak self] _ in
            action.start.first?.sound()
            action.start.forEach{
                self?.doAction($0)
            }
        })
        self.timers.append((type: action, timer: repeatTimer))
    }
    
    ///長押しを終了する関数。継続的な動作、例えば連続的な文字削除を行っていたタイマーを停止する。
    /// - Parameters:
    ///   - action: どの動作を終了するか判定するために用いる。
    override func registerLongPressActionEnd(_ action: LongpressActionType){
        timers = timers.compactMap{timer in
            if timer.type == action {
                timer.timer.invalidate()
                return nil
            }
            return timer
        }
    }
    
    ///何かが変化する前に状態の保存を行う関数。
    override func notifySomethingWillChange(left: String, center: String, right: String){
        self.tempTextData = (left: left, center: center, right: right)
    }
    //MARK: left/center/rightとして得られる情報は以下の通り
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
    
    ///何かが変化した後に状態を比較し、どのような変化が起こったのか判断する関数。
    override func notifySomethingDidChange(a_left: String, a_center: String, a_right: String){
        if self.inputManager.isAfterAdjusted(){
            return
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

        if isSelected{
            self.inputManager.userSelectedText(text: a_center)
            return
        }
        
        //全体としてテキストが変化せず、選択範囲が存在している場合→新たに選択した、または選択範囲を変更した
        if !isWholeTextChanged{
            //全体としてテキストが変化せず、選択範囲が無くなっている場合→選択を解除した
            if wasSelected && !isSelected{
                self.inputManager.userDeselectedText()
                debug("user operation id: 1")
                return
            }

            //全体としてテキストが変化せず、選択範囲は前後ともになく、左側(右側)の文字列だけが変わっていた場合→カーソルを移動した
            if !wasSelected && !isSelected && b_left != a_left{
                debug("user operation id: 2", b_left, a_left)
                let offset = a_left.count - b_left.count
                self.inputManager.userMovedCursor(count: offset)
                return
            }
            //ただタップしただけ、などの場合ここにくる事がある。
            debug("user operation id: 3")
            return
        }
        //以降isWholeTextChangedは常にtrue
        //全体としてテキストが変化しており、前は左は改行コードになっていて選択範囲が存在し、かつ前の選択範囲と後の全体が一致する場合→行全体の選択が解除された
        //行全体を選択している場合は改行コードが含まれる。
        if b_left == "\n" && b_center == a_wholeText{
            debug("user operation id: 5")
            self.inputManager.userDeselectedText()
            return
        }

        //全体としてテキストが変化しており、左右の文字列を合わせたものが不変である場合→カットしたのではないか？
        if b_left + b_right == a_left + a_right{
            debug("user operation id: 6")
            self.inputManager.userCutText(text: b_center)
            return
        }
        
        //全体としてテキストが変化しており、右側の文字列が不変であった場合→ペーストしたのではないか？
        if b_right == a_right{
            //もしクリップボードに文字列がコピーされており、かつ、前の左側文字列にその文字列を加えた文字列が後の左側の文字列に一致した場合→確実にペースト
            if let pastedText = UIPasteboard.general.string, a_left.hasSuffix(pastedText){
                if wasSelected{
                    debug("user operation id: 7")
                    self.inputManager.userReplacedSelectedText(text: pastedText)
                }else{
                    debug("user operation id: 8")
                    self.inputManager.userPastedText(text: pastedText)
                }
                return
            }
        }
        
        if a_left == "\n" && b_left.isEmpty && a_right == b_right{
            debug("user operation id: 9")
            return
        }
        
        //上記のどれにも引っかからず、なおかつテキスト全体が変更された場合
        debug("user operation id: 10, \((a_left,a_center,a_right)), \((b_left, b_center, b_right))")
        self.inputManager.clear()
    }

    private func hideLearningMemory(){
        SettingData.shared.writeLearningTypeSetting(to: .nothing)
        self.sendToDicDataStore(.notifyLearningType(.nothing))
    }

    #if DEBUG
    func setDebugPrint(_ text: String){
        self.inputManager.setDebugResult(text: text)
    }
    #endif
}

//ActionDepartmentの状態を保存する部分
private final class InputManager{
    fileprivate var proxy: UITextDocumentProxy!
    
    //現在入力中の文字
    fileprivate var inputtedText: String = ""
    private var kanaRomanStateHolder = KanaRomanStateHolder()
    //セレクトされているか否か、現在入力中の文字全体がセレクトされているかどうかである。
    fileprivate var isSelected = false
    //現在のカーソル位置。カーソル左側の文字数に等しい
    private var cursorPosition = 0
    //カーソルの取りうる最小位置。
    private let cursorMinimumPosition: Int = 0
    ///カーソルの動ける最大範囲。`inputtedText`の文字数に等しい。
    private var cursorMaximumPosition: Int {
        return inputtedText.count
    }
    private var afterAdjusted: Bool = false

    private typealias RomanConverter = KanaKanjiConverter<RomanInputData, RomanLatticeNode>
    private typealias DirectConverter = KanaKanjiConverter<DirectInputData, DirectLatticeNode>
    ///かな漢字変換を受け持つ変換器。
    private var _romanConverter: RomanConverter?
    private var _directConverter: DirectConverter?

    private var romanConverter: RomanConverter {
        self._directConverter = nil
        if let romanConverter = self._romanConverter{
            return romanConverter
        }
        self._romanConverter = RomanConverter()
        return self._romanConverter!
    }

    private var directConverter: DirectConverter {
        self._romanConverter = nil
        if let flickConverter = self._directConverter{
            return flickConverter
        }
        self._directConverter = DirectConverter()
        return self._directConverter!
    }

    func changeInputStyle(from beforeStyle: InputStyle, to afterStyle: InputStyle) {
        switch (beforeStyle, afterStyle){
        case (.direct, .roman):
            let stateHolder = KanaRomanStateHolder(components: [KanaComponent(internalText: self.inputtedText, kana: self.inputtedText, isFreezed: true, escapeRomanKanaConverting: true)])
            self.kanaRomanStateHolder = stateHolder
            let converter = RomanConverter()
            converter.translated(from: self.directConverter)
            self._romanConverter = converter
            self._directConverter = nil
        case (.roman, .direct):
            let converter = DirectConverter()
            converter.translated(from: self.romanConverter)
            self._directConverter = converter
            self._romanConverter = nil
        default:
            return
        }
    }

    func sendToDicDataStore(_ data: KeyboardActionDepartment.DicDataStoreNotification){
        self._romanConverter?.sendToDicDataStore(data)
        self._directConverter?.sendToDicDataStore(data)
    }

    fileprivate func setTextDocumentProxy(_ proxy: UITextDocumentProxy){
        self.proxy = proxy
    }

    private var isRomanKanaInputMode: Bool {
        switch VariableStates.shared.inputStyle{
        case .direct:
            return false
        case .roman:
            return true
        }
    }

    func isAfterAdjusted() -> Bool {
        if self.afterAdjusted{
            self.afterAdjusted = false
            return true
        }
        return false
    }

    ///変換を選択した場合に呼ばれる
    fileprivate func complete(candidate: Candidate){
        //入力部分を削除する
        let leftsideInputedText = self.inputtedText.prefix(self.cursorPosition)
        if !self.isSelected{
            (0..<self.cursorPosition).forEach{_ in
                self.proxy.deleteBackward()
            }
        }
        self.isSelected = false

        switch VariableStates.shared.inputStyle{
        case .direct:
            self.directConverter.updateLearningData(candidate)
            self.proxy.insertText(candidate.text + leftsideInputedText.dropFirst(candidate.correspondingCount))
            if candidate.correspondingCount == inputtedText.count{
                self.clear()
                VariableStates.shared.setEnterKeyState(.return)
                return
            }
            self.cursorPosition -= candidate.correspondingCount
            self.inputtedText = String(self.inputtedText.dropFirst(candidate.correspondingCount))
            self.directConverter.setCompletedData(candidate)

        case .roman:
            self.romanConverter.updateLearningData(candidate)
            let displayedTextCount = self.kanaRomanStateHolder.complete(candidate.correspondingCount)
            self.proxy.insertText(candidate.text + leftsideInputedText.dropFirst(displayedTextCount))
            if self.kanaRomanStateHolder.components.isEmpty{
                self.clear()
                VariableStates.shared.setEnterKeyState(.return)
                return
            }
            self.cursorPosition -= displayedTextCount
            self.inputtedText = String(self.inputtedText.dropFirst(displayedTextCount))
            self.romanConverter.setCompletedData(candidate)
        }
        if self.cursorPosition == 0{
            self.cursorPosition = self.cursorMaximumPosition
            //入力の直後、documentContextAfterInputは間違っていることがあるため、ここではoffsetをinputtedTextから直接計算する。
            let offset = inputtedText.utf16.count
            self.proxy.adjustTextPosition(byCharacterOffset: offset)
            self.afterAdjusted = true
        }
        self.setResult()
    }
    
    fileprivate func clear(){
        debug("クリアしました")
        self.inputtedText = ""
        self.cursorPosition = self.cursorMinimumPosition
        self.isSelected = false

        self.setResult()
        self.kanaRomanStateHolder = KanaRomanStateHolder()
        self._romanConverter?.clear()
        self._directConverter?.clear()
        VariableStates.shared.setEnterKeyState(.return)
    }

    fileprivate func closeKeyboard(){
        debug("キーボードを閉じます")
        self.sendToDicDataStore(.closeKeyboard)
        self._romanConverter = nil
        self._directConverter = nil
        self.clear()
    }

    //単純に確定した場合のデータ
    fileprivate func enter() -> [ActionType] {
        let _candidate = Candidate(
            text: self.inputtedText,
            value: -18,
            correspondingCount: self.inputtedText.count,
            lastMid: 501,
            data: [
                LRE_SRE_DicDataElement(ruby: self.inputtedText, cid: 1298, mid: 501, value: -18)
            ]
        )
        let actions: [ActionType]
        switch VariableStates.shared.inputStyle{
        case .direct:
            actions = self.directConverter.getApporopriateActions(_candidate)
            let candidate = _candidate.withActions(actions)
            self.directConverter.updateLearningData(candidate)
        case .roman:
            actions = self.romanConverter.getApporopriateActions(_candidate)

            let candidate = _candidate.withActions(actions)
            self.romanConverter.updateLearningData(candidate)
        }
        self.clear()
        return actions
    }
    
    //MARK: キーボード経由での操作。
    fileprivate func input(text: String){
        if self.isSelected{
            //選択は解除される
            self.isSelected = false

            self.inputtedText = text
            self.kanaRomanStateHolder = KanaRomanStateHolder()
            switch VariableStates.shared.inputStyle{
            case .direct:
                break
            case .roman:
                if isRomanKanaInputMode{
                    kanaRomanStateHolder.insert(text, leftSideText: "")
                }else{
                    kanaRomanStateHolder.insert(text, leftSideText: "", isFreezed: true)
                }
            }

            self.cursorPosition = self.cursorMaximumPosition
            //実際に入力する
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
        //スペースだった場合
        if text == " " || text == "　" || text == "\t" || text == "\0"{
            self.proxy.insertText(text)
            self.clear()
            return
        }

        if VariableStates.shared.keyboardLanguage == .none{
            self.proxy.insertText(text)
            self.clear()
            return
        }

        //選択されていない場合
        
        let leftSideText = inputtedText.prefix(cursorPosition)
        let rightSideText = inputtedText.dropFirst(cursorPosition)
        
        switch VariableStates.shared.inputStyle{
        case .direct:
            self.inputtedText = leftSideText + text + rightSideText
            self.proxy.insertText(text)
            self.cursorPosition += text.count

        case .roman:
            if isRomanKanaInputMode{
                let roman2hiragana = kanaRomanStateHolder.insert(text, leftSideText: leftSideText)
                self.inputtedText = roman2hiragana.result + rightSideText
                (0..<max(0, roman2hiragana.delete)).forEach{_ in
                    self.proxy.deleteBackward()
                }
                self.proxy.insertText(roman2hiragana.input)
                self.cursorPosition += roman2hiragana.input.count - roman2hiragana.delete
            }else{
                kanaRomanStateHolder.insert(text, leftSideText: leftSideText, isFreezed: true)
                self.inputtedText = leftSideText + text + rightSideText
                self.proxy.insertText(text)
                self.cursorPosition += text.count
            }
        }
        
        VariableStates.shared.setEnterKeyState(.complete)

        setResult()
    }

    fileprivate func deleteForward(count: Int, requireSetResult: Bool = true){
        if count < 0{
            return
        }

        if self.inputtedText.isEmpty{
            self.proxy.deleteForward(count: count)
            return
        }

        //一番右端にいるときは削除させない
        if !self.inputtedText.isEmpty && self.cursorPosition == self.cursorMaximumPosition{
            return
        }
        //削除を実行する
        self.proxy.deleteForward(count: count)
        if VariableStates.shared.inputStyle == .roman{
            //ステートホルダーを調整する
            self.kanaRomanStateHolder.delete(kanaCount: count, leftSideText: self.inputtedText.prefix(self.cursorPosition+count))
        }
        let leftSideText = self.inputtedText.prefix(max(0,self.cursorPosition))
        let rightSideText = self.inputtedText.suffix(self.cursorMaximumPosition - self.cursorPosition - count)
        self.inputtedText = String(leftSideText + rightSideText)

        if requireSetResult{
            setResult()
        }

        if self.inputtedText.isEmpty{
            VariableStates.shared.setEnterKeyState(.return)
        }
    }

    fileprivate func deleteBackward(count: Int, requireSetResult: Bool = true){
        if count == 0{
            return
        }
        //選択状態ではオール削除になる
        if self.isSelected{
            self.proxy.deleteBackward()
            self.clear()
            return
        }
        //条件
        if count < 0 {
            self.deleteForward(count: abs(count), requireSetResult: requireSetResult)
            return
        }
        //一番左端にいるときは削除させない
        if !self.inputtedText.isEmpty && self.cursorPosition == self.cursorMinimumPosition{
            return
        }
        //削除を実行する
        self.proxy.deleteBackward(count: count)
        if VariableStates.shared.inputStyle == .roman{
            //ステートホルダーを調整する
            self.kanaRomanStateHolder.delete(kanaCount: count, leftSideText: self.inputtedText.prefix(self.cursorPosition))
        }
        let leftSideText = self.inputtedText.prefix(max(0,self.cursorPosition-count))
        let rightSideText = self.inputtedText.suffix(self.cursorMaximumPosition - self.cursorPosition)
        self.inputtedText = String(leftSideText + rightSideText)
        //消せる文字がなかった場合、0未満になってしまうので
        self.cursorPosition = max(self.cursorMinimumPosition, self.cursorPosition - count)
        if requireSetResult{
            setResult()
        }

        if self.inputtedText.isEmpty{
            VariableStates.shared.setEnterKeyState(.return)
        }
    }

    fileprivate func smoothDelete(to nexts: [Character] = ["、","。","！","？",".",",","．","，", "\n"]){
        //選択状態ではオール削除になる
        if self.isSelected{
            self.proxy.deleteBackward()
            self.clear()
            return
        }
        //入力中の場合
        if !self.inputtedText.isEmpty{
            let leftSideText = self.inputtedText.prefix(self.cursorPosition)
            self.inputtedText.removeFirst(self.cursorPosition)
            self.cursorPosition = 0
            self.kanaRomanStateHolder.delete(kanaCount: leftSideText.count, leftSideText: leftSideText)
            //削除を実行する
            self.proxy.deleteBackward(count: leftSideText.count)
            self.moveCursor(count: self.cursorMaximumPosition)
            //文字がもうなかった場合
            if self.inputtedText.isEmpty{
                self.clear()
                return
            }
            setResult()
            return
        }

        var deletedCount = 0
        while let last = self.proxy.documentContextBeforeInput?.last{
            if nexts.contains(last){
                break
            }else{
                self.proxy.deleteBackward()
                deletedCount += 1
            }
        }
        if deletedCount == 0{
            self.proxy.deleteBackward()
        }
    }

    fileprivate func smoothDeleteForward(to nexts: [Character] = ["、","。","！","？",".",",","．","，", "\n"]){
        //選択状態ではオール削除になる
        if self.isSelected{
            self.proxy.deleteBackward()
            self.clear()
            return
        }
        //入力中の場合
        if !self.inputtedText.isEmpty{
            let count = cursorMaximumPosition - cursorPosition
            self.inputtedText.removeLast(count)
            self.proxy.moveCursor(count: count)
            self.proxy.deleteBackward(count: count)
            //文字がもうなかった場合
            if inputtedText.isEmpty{
                clear()
                setResult()
            }
            return
        }

        var deletedCount = 0
        while let first = self.proxy.documentContextAfterInput?.first{
            if nexts.contains(first){
                break
            }else{
                self.proxy.deleteForward()
                deletedCount += 1
            }
        }
        if deletedCount == 0{
            self.proxy.deleteForward()
        }
    }

    fileprivate func smartMoveCursorBackward(to nexts: [Character] = ["、","。","！","？",".",",","．","，", "\n"]){
        //選択状態では最も左にカーソルを移動
        if isSelected{
            let count = cursorPosition
            deselect()
            moveCursor(count: -count)
            setResult()
            return
        }
        //入力中の場合
        if !inputtedText.isEmpty{
            moveCursor(count: -cursorPosition)
            setResult()
            return
        }

        var movedCount = 0
        while let last = proxy.documentContextBeforeInput?.last{
            if nexts.contains(last){
                break
            }else{
                proxy.moveCursor(count: -1)
                movedCount += 1
            }
        }
        if movedCount == 0{
            proxy.moveCursor(count: -1)
        }
    }

    fileprivate func smartMoveCursorForward(to nexts: [Character] = ["、","。","！","？",".",",","．","，", "\n"]){
        //選択状態では最も左にカーソルを移動
        if isSelected{
            deselect()
            moveCursor(count: cursorMaximumPosition - cursorPosition)
            setResult()
            return
        }
        //入力中の場合
        if !inputtedText.isEmpty{
            moveCursor(count: cursorMaximumPosition - cursorPosition)
            setResult()
            return
        }

        var movedCount = 0
        while let first = proxy.documentContextAfterInput?.first{
            if nexts.contains(first){
                break
            }else{
                proxy.moveCursor(count: 1)
                movedCount += 1
            }
        }
        if movedCount == 0{
            proxy.moveCursor(count: 1)
        }
    }

    fileprivate func deselect(){
        if isSelected{
            clear()
            VariableStates.shared.setEnterKeyState(.return)
        }
    }

    fileprivate func edit(){
        if isSelected{
            let selectedText = inputtedText
            deleteBackward(count: 1)
            input(text: selectedText)
            VariableStates.shared.setEnterKeyState(.complete)
        }
    }

    fileprivate func replaceLastCharacters(table: [String: String]){
        if isSelected{
            return
        }
        let counts: (max: Int, min: Int) = table.keys.reduce(into: (max: 0, min: .max)){
            $0.max = max($0.max, $1.count)
            $0.min = min($0.min, $1.count)
        }
        let leftside = inputtedText.prefix(cursorPosition)
        for count in (counts.min...counts.max).reversed() where count <= cursorPosition {
            if let replace = table[String(leftside.suffix(count))]{
                self.deleteBackward(count: count, requireSetResult: false)
                self.input(text: replace)
                break
            }
        }
    }
    
    fileprivate func changeCharacter(){
        if self.isSelected{
            return
        }
        let char = self.inputtedText.prefix(self.cursorPosition).last ?? "\0"
        let changed = char.requestChange()
        if Character(changed) == char{
            return
        }
        self.deleteBackward(count: 1, requireSetResult: false)
        self.input(text: changed)
    }

    ///キーボード経由でのカーソル移動
    fileprivate func moveCursor(count: Int){
        if count == 0 {
            return
        }
        afterAdjusted = true
        if inputtedText.isEmpty{
            proxy.moveCursor(count: count)
            return
        }
        debug("moveCursor, cursorPosition:", cursorPosition, count)
        //カーソル位置の正規化
        if cursorPosition + count > cursorMaximumPosition{
            proxy.moveCursor(count: cursorMaximumPosition - cursorPosition)
            cursorPosition = cursorMaximumPosition
            setResult()
            return
        }
        if  cursorPosition + count < cursorMinimumPosition{
            proxy.moveCursor(count: cursorMinimumPosition - cursorPosition)
            cursorPosition = cursorMinimumPosition
            setResult()
            return
        }
        
        proxy.moveCursor(count: count)
        cursorPosition += count
        setResult()
    }
    
    //MARK: userが勝手にカーソルを何かした場合の後処理
    fileprivate func userMovedCursor(count: Int){
        debug("userによるカーソル移動を検知、今の位置は\(cursorPosition)、動かしたオフセットは\(count)")
        if inputtedText.isEmpty{
            //入力がない場合はreturnしておかないと、入力していない時にカーソルを動かせなくなってしまう。
            return
        }
        
        cursorPosition += count

        if cursorPosition > cursorMaximumPosition{
            proxy.moveCursor(count: cursorMaximumPosition - cursorPosition)
            cursorPosition = cursorMaximumPosition
            setResult()
            afterAdjusted = true
            return
        }
        if cursorPosition < cursorMinimumPosition{
            proxy.moveCursor(count: cursorMinimumPosition - cursorPosition)
            cursorPosition = cursorMinimumPosition
            setResult()
            afterAdjusted = true
            return
        }
        setResult()
    }

    fileprivate func userPastedText(text: String){
        //入力された分を反映する
        inputtedText = text
        cursorPosition = cursorMaximumPosition
        isSelected = false
        setResult()
        VariableStates.shared.setEnterKeyState(.complete)
    }
    
    fileprivate func userCutText(text: String){
        inputtedText = ""
        cursorPosition = .zero
        isSelected = false
        setResult()
        VariableStates.shared.setEnterKeyState(.return)
    }
    
    fileprivate func userReplacedSelectedText(text: String){
        //新たな入力を反映
        inputtedText = text
        cursorPosition = cursorMaximumPosition
        isSelected = false
        
        setResult()
        VariableStates.shared.setEnterKeyState(.complete)
    }
    
    //ユーザが文章を選択した場合、その部分を入力中であるとみなす
    fileprivate func userSelectedText(text: String){
        if text.isEmpty{
            return
        }
        inputtedText = text
        kanaRomanStateHolder.components = text.map{KanaComponent(internalText: String($0), kana: String($0), isFreezed: true, escapeRomanKanaConverting: true)}
        cursorPosition = cursorMaximumPosition
        isSelected = true
        if text.split(separator: " ", omittingEmptySubsequences: false).count > 1 || text.components(separatedBy: .newlines).count > 1{
            //FIXME: textDocumentProxy.selectedTextの不具合により、機能を制限している。
            //参照: https://qiita.com/ensan_hcl/items/476ffb665cd37cb312da
            //self.setResult(options: [.mojiCount, .wordCount])
            setResult(options: [])
        }else{
            //FIXME: textDocumentProxy.selectedTextの不具合により、機能を制限している。
            //参照: https://qiita.com/ensan_hcl/items/476ffb665cd37cb312da
            setResult(options: [.convertInput])
        }
        VariableStates.shared.setEnterKeyState(.edit)
    }
    
    //選択を解除した場合、clearとみなす
    fileprivate func userDeselectedText(){
        self.clear()
        VariableStates.shared.setEnterKeyState(.return)
    }

    fileprivate enum ResultOptions{
        case convertInput
        case mojiCount
        case wordCount
    }

    fileprivate func setResult(options: [ResultOptions] = [.convertInput]){
        var results = [Candidate]()
        options.forEach{option in
            switch option{
            case .convertInput:
                let input_hira = self.inputtedText.prefix(self.cursorPosition)
                let result: [Candidate]
                switch VariableStates.shared.inputStyle{
                case .direct:
                    let inputData = DirectInputData(String(input_hira))
                    result = self.directConverter.requestCandidates(inputData, N_best: 10)
                case .roman:
                    let inputData = RomanInputData(String(input_hira), history: self.kanaRomanStateHolder)
                    let requireJapanesePrediction = VariableStates.shared.keyboardLanguage == .japanese
                    let requireEnglishPrediction = VariableStates.shared.keyboardLanguage == .english

                    result = self.romanConverter.requestCandidates(inputData, N_best: 10, requirePrediction: requireJapanesePrediction, requireEnglishPrediction: requireEnglishPrediction)
                }
                results.append(contentsOf: result)
                //Storeに通知し、ResultViewに表示する。
            case .mojiCount:
                let input = self.inputtedText.prefix(self.cursorPosition)
                let count = input.filter{!$0.isNewline}.count
                let mojisu = Candidate(
                    text: "文字数:\(count)",
                    value: 0,
                    correspondingCount: 0,
                    lastMid: 0,
                    data: [],
                    inputable: false
                )
                results.append(mojisu)
            case .wordCount:
                let input = self.inputtedText.prefix(self.cursorPosition)
                if input.isEnglishSentence{
                    let count = input.components(separatedBy: .newlines).map{$0.split(separator: " ").count}.reduce(0, +)
                    results.append(
                        Candidate(
                            text: "単語数:\(count)",
                            value: 0,
                            correspondingCount: 0,
                            lastMid: 0,
                            data: [],
                            inputable: false
                        )
                    )
                }
            }
        }
        Store.shared.registerResult(results)
    }
    #if DEBUG
    //debug中であることを示す。
    fileprivate var isDebugMode: Bool = false
    #endif
    
    fileprivate func setDebugResult(text: String){
        #if DEBUG
        if !isDebugMode{
            return
        }

        Store.shared.registerResult([Candidate(text: text, value: .zero, correspondingCount: 0, lastMid: 500, data: [])])
        isDebugMode = true
        #endif
    }
}

extension UITextDocumentProxy{
    private func getActualOffset(count: Int) -> Int {
        if count == 0{
            return 0
        }
        else if count>0{
            if let after = self.documentContextAfterInput{
                //改行があって右端の場合ここに来る。
                if after.isEmpty{
                    return 1
                }
                let suf = after.prefix(count)
                debug("あとの文字は、",suf,-suf.utf16.count)
                return suf.utf16.count
            }else{
                return 1
            }
        }
        else {
            if let before = self.documentContextBeforeInput{
                let pre = before.suffix(-count)
                debug("前の文字は、",pre,-pre.utf16.count)

                return -pre.utf16.count

            }else{
                return -1
            }
        }
    }

    func moveCursor(count: Int) {
        let offset = self.getActualOffset(count: count)
        self.adjustTextPosition(byCharacterOffset: offset)
    }

    func deleteBackward(count: Int) {
        if count == 0{
            return
        }
        if count < 0{
            self.deleteForward(count: abs(count))
            return
        }
        (0..<count).forEach{ _ in
            self.deleteBackward()
        }
    }

    func deleteForward(count: Int = 1) {
        if count == 0{
            return
        }
        if count < 0{
            self.deleteBackward(count: abs(count))
            return
        }
        (0..<count).forEach{ _ in
            if self.documentContextAfterInput == nil {
                return
            }
            self.moveCursor(count: 1)
            self.deleteBackward()
        }
    }

}
