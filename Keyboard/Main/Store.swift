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
        self.settingCheck()
    }

    func settingCheck(){
        if SettingData.checkResetSetting(){
            self.action.sendToDicDataStore(.resetMemory)
        }
        action.sendToDicDataStore(.notifyLearningType(SettingData.shared.learningType))
    }
    
    func initialize(){
        SettingData.shared.reload()
        self.settingCheck()
        VariableStates.shared.initialize()
        self.action.initialize()
    }

    func appearedAgain(){
        SettingData.shared.reload()
        self.settingCheck()
        self.action.appearedAgain()
    }

    private func sendToDicDataStore(_ data: KeyboardActionDepartment.DicDataStoreNotification){
        self.action.sendToDicDataStore(data)
    }

    fileprivate func registerResult(_ result: [Candidate]){
        self.resultModel.setResults(result)
    }

    func closeKeyboard(){
        self.action.closeKeyboard()
    }
}

//MARK:Storeのキーボードへのアクション部門の動作を全て切り出したオブジェクト。外部から参照されるのがこれ。
final class KeyboardActionDepartment: ActionDepartment{
    fileprivate override init(){}
    
    private var inputManager = InputManager()
    private weak var delegate: KeyboardViewController!
    
    //即時変数
    private var timers: [(type: KeyLongPressActionType, timer: Timer)] = []
    private var tempTextData: (left: String, center: String, right: String)!
    private var tempSavedSelectedText: String!

    func initialize(){
        self.inputManager.closeKeyboard()
        self.timers.forEach{$0.timer.invalidate()}
        self.timers = []
    }

    func closeKeyboard(){
        self.initialize()
    }

    func appearedAgain(){
        debug("再び表示されました")
        self.sendToDicDataStore(.reloadUserDict)
    }

    func setResult(){
        self.inputManager.setResult()
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

    private func doAction(_ action: ActionType){
        switch action{
        case let .input(text):
            VariableStates.shared.showMoveCursorView = false
            if VariableStates.shared.tabState == .abc && VariableStates.shared.aAKeyState == .capslock{
                let input = text.uppercased()
                self.inputManager.input(text: input)
            }else{
                self.inputManager.input(text: text)
            }
        case let .delete(count):
            VariableStates.shared.showMoveCursorView = false
            self.inputManager.delete(count: count)

        case .smoothDelete:
            Sound.smoothDelete()
            VariableStates.shared.showMoveCursorView = false
            self.inputManager.smoothDelete()

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
        case let .changeCapsLockState(state):
            VariableStates.shared.aAKeyState = state
        case .toggleShowMoveCursorView:
            VariableStates.shared.showMoveCursorView.toggle()
        case .enter:
            VariableStates.shared.showMoveCursorView = false
            let actions = self.inputManager.enter()
            actions.forEach{
                self.doAction($0)
            }

        case .changeCharacterType:
            VariableStates.shared.showMoveCursorView = false
            self.inputManager.changeCharacter()

        case let .moveTab(type):
            VariableStates.shared.setTabState(type)
        case .hideLearningMemory:
            self.hideLearningMemory()

        case let .openApp(scheme):
            delegate.openApp(scheme: scheme)
        //MARK: デバッグ用
        case .DEBUG_DATA_INPUT:
            #if DEBUG
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

    ///押した場合に行われる。
    /// - Parameters:
    ///   - action: 行われた動作。
    override func registerAction(_ action: ActionType){
        self.doAction(action)
    }
    
    ///長押しを予約する関数。
    /// - Parameters:
    ///   - action: 長押しで起こる動作のタイプ。
    override func reserveLongPressAction(_ action: KeyLongPressActionType){
        if timers.contains{$0.type == action}{
            return
        }
        let startTime = Date()

        switch action{
        case .delete:
            let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {[weak self] (timer) in
                let span: TimeInterval = timer.fireDate.timeIntervalSince(startTime)
                if span > 0.4 {
                    Sound.delete()
                    self?.inputManager.delete(count: 1)
                }
            })
            let tuple = (type: action, timer: timer)
            self.timers.append(tuple)
        case let .input(text):
            let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {[weak self] (timer) in
                let span: TimeInterval = timer.fireDate.timeIntervalSince(startTime)
                if span > 0.4 {
                    Sound.click()
                    self?.inputManager.input(text: text)
                }
            })
            let tuple = (type: action, timer: timer)
            self.timers.append(tuple)
        case let .moveCursor(direction):
            let count = (direction == .right ? 1:-1)
            let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {[weak self] (timer) in
                let span: TimeInterval = timer.fireDate.timeIntervalSince(startTime)
                if span > 0.4 {
                    Sound.tabOrOtherKey()
                    self?.inputManager.moveCursor(count: count)
                }
            })
            let tuple = (type: action, timer: timer)
            self.timers.append(tuple)
        case .toggleShowMoveCursorView:
            let timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: {_ in
                VariableStates.shared.showMoveCursorView.toggle()
            })
            let tuple = (type: action, timer: timer)
            self.timers.append(tuple)
        case let .changeCapsLockState(state):
            let timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: {_ in
                VariableStates.shared.aAKeyState = state
            })
            let tuple = (type: action, timer: timer)
            self.timers.append(tuple)
        }

    }
    
    ///長押しを終了する関数。継続的な動作、例えば連続的な文字削除を行っていたタイマーを停止する。
    /// - Parameters:
    ///   - action: どの動作を終了するか判定するために用いる。
    override func registerLongPressActionEnd(_ action: KeyLongPressActionType){
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
            return VariableStates.shared.tabState == .hira
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

    fileprivate func delete(count: Int, requireSetResult: Bool = true){
        //選択状態ではオール削除になる
        if self.isSelected{
            self.proxy.deleteBackward()
            self.clear()
            return
        }
        //一番左端にいるときは削除させない
        if !self.inputtedText.isEmpty && self.cursorPosition == self.cursorMinimumPosition{
            return
        }
        //削除を実行する
        (0..<count).forEach{_ in
            self.proxy.deleteBackward()
        }
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

    fileprivate func smoothDelete(){
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
            (0..<leftSideText.count).forEach{_ in
                self.proxy.deleteBackward()
            }

            if self.inputtedText.isEmpty{
                self.clear()
                return
            }
            setResult()

            return
        }
        var leftSideText = self.proxy.documentContextBeforeInput ?? ""
        var count = 0
        while let last = leftSideText.last{
            if ["、","。","！","？",".",",","．","，"].contains(last){
                if count == 0{
                    count = 1
                }
                break
            }
            leftSideText.removeLast()
            count += 1
        }
        //削除を実行する
        (0..<count).forEach{_ in
            self.proxy.deleteBackward()
        }
    }
    
    fileprivate func edit(){
        if self.isSelected{
            let selectedText = self.inputtedText
            self.delete(count: 1)
            self.input(text: selectedText)
            VariableStates.shared.setEnterKeyState(.complete)
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
        self.delete(count: 1, requireSetResult: false)
        self.input(text: changed)
    }

    ///self.cursorPositionが正確である必要あり。
    fileprivate func getActualOffset(count: Int) -> Int {
        if count == 0{
            return 0
        }
        else if count>0{
            if let after = self.proxy.documentContextAfterInput{
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
            if let before = self.proxy.documentContextBeforeInput{
                let pre = before.suffix(-count)
                debug("前の文字は、",pre,-pre.utf16.count)

                return -pre.utf16.count

            }else{
                return -1
            }
        }
    }

    ///キーボード経由でのカーソル移動
    fileprivate func moveCursor(count: Int){
        self.afterAdjusted = true
        if inputtedText.isEmpty{
            let offset = self.getActualOffset(count: count)
            self.proxy.adjustTextPosition(byCharacterOffset: offset)
            return
        }
        debug("moveCursor, cursorPosition:", cursorPosition, count)
        //カーソル位置の正規化
        if cursorPosition + count > self.cursorMaximumPosition{
            let offset = self.getActualOffset(count: self.cursorMaximumPosition - self.cursorPosition)
            self.proxy.adjustTextPosition(byCharacterOffset: offset)
            self.cursorPosition = self.cursorMaximumPosition
            setResult()
            return
        }
        if  cursorPosition + count < self.cursorMinimumPosition{
            let offset = self.getActualOffset(count: self.cursorMinimumPosition - self.cursorPosition)
            self.proxy.adjustTextPosition(byCharacterOffset: offset)
            self.cursorPosition = self.cursorMinimumPosition
            setResult()
            return
        }
        
        let offset = self.getActualOffset(count: count)
        self.proxy.adjustTextPosition(byCharacterOffset: offset)
        self.cursorPosition += count
        setResult()
    }
    
    //MARK: userが勝手にカーソルを何かした場合の後処理
    fileprivate func userMovedCursor(count: Int){
        debug("userによるカーソル移動を検知、今の位置は\(self.cursorPosition)、動かしたオフセットは\(count)")
        if self.inputtedText.isEmpty{
            //入力がない場合はreturnしておかないと、入力していない時にカーソルを動かせなくなってしまう。
            return
        }
        
        self.cursorPosition += count

        if self.cursorPosition > self.cursorMaximumPosition{
            let offset = self.getActualOffset(count: self.cursorMaximumPosition - self.cursorPosition)
            self.proxy.adjustTextPosition(byCharacterOffset: offset)
            debug("右にはみ出したので\(self.cursorMaximumPosition - self.cursorPosition)(\(offset))分正規化しました。動いた位置は\(self.cursorPosition)")
            self.cursorPosition = self.cursorMaximumPosition
            setResult()
            self.afterAdjusted = true
            return
        }
        if self.cursorPosition < self.cursorMinimumPosition{
            let offset = self.getActualOffset(count: self.cursorMinimumPosition - self.cursorPosition)
            //let offset = self.cursorMinimumPosition - self.cursorPosition
            self.proxy.adjustTextPosition(byCharacterOffset: offset)
            debug("左にはみ出したので\(self.cursorMinimumPosition - self.cursorPosition)(\(offset))分正規化しました。動いた位置は\(self.cursorPosition)")
            self.cursorPosition = self.cursorMinimumPosition
            setResult()
            self.afterAdjusted = true
            return
        }
        setResult()
    }

    fileprivate func userPastedText(text: String){
        //入力された分を反映する
        self.inputtedText = text
        self.cursorPosition = self.cursorMaximumPosition
        self.isSelected = false
        setResult()
        VariableStates.shared.setEnterKeyState(.complete)
    }
    
    fileprivate func userCutText(text: String){
        self.inputtedText = ""
        self.cursorPosition = .zero
        self.isSelected = false
        self.setResult()
        VariableStates.shared.setEnterKeyState(.return)
    }
    
    fileprivate func userReplacedSelectedText(text: String){
        //新たな入力を反映
        self.inputtedText = text
        self.cursorPosition = self.cursorMaximumPosition
        self.isSelected = false
        
        setResult()
        VariableStates.shared.setEnterKeyState(.complete)
    }
    
    //ユーザが文章を選択した場合、その部分を入力中であるとみなす
    fileprivate func userSelectedText(text: String){
        if text.isEmpty{
            return
        }
        self.inputtedText = text
        self.kanaRomanStateHolder.components = text.map{KanaComponent(internalText: String($0), kana: String($0), isFreezed: true, escapeRomanKanaConverting: true)}
        self.cursorPosition = self.cursorMaximumPosition
        self.isSelected = true
        if text.split(separator: " ", omittingEmptySubsequences: false).count > 1 || text.components(separatedBy: .newlines).count > 1{
            //FIXME: textDocumentProxy.selectedTextの不具合により、機能を制限している。
            //参照: https://qiita.com/En3_HCl/items/476ffb665cd37cb312da
            //self.setResult(options: [.mojiCount, .wordCount])
            self.setResult(options: [])
        }else{
            //FIXME: textDocumentProxy.selectedTextの不具合により、機能を制限している。
            //参照: https://qiita.com/En3_HCl/items/476ffb665cd37cb312da
            self.setResult(options: [.convertInput])
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
                    let requirePrediction = VariableStates.shared.tabState == .hira
                    let requireEnglishPrediction = VariableStates.shared.tabState != .hira

                    result = self.romanConverter.requestCandidates(inputData, N_best: 10, requirePrediction: requirePrediction, requireEnglishPrediction: requireEnglishPrediction)
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
