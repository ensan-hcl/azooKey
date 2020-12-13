//
//  Store.swift
//  Calculator-Keyboard
//
//  Created by β α on 2020/04/10.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

///アプリケーション全体で共有すべき情報を集約するクラス。
final class Store{
    static let shared = Store()
    var keyboardType: KeyboardType = .roman
    fileprivate var orientation: KeyboardOrientation = .vertical
    private var enterKeyType: UIReturnKeyType = .default
    private var enterKeyState: EnterKeyState = .return(.default)
    fileprivate var aAKeyState: AaKeyState = .normal

    ///Storeのキーボードへのアクション部門の動作を全て切り出したオブジェクト。
    var action = ActionDepartment()
    ///Storeのデザイン部門の動作を全て切り出したオブジェクト。
    var design = DesignDepartment()
    ///Storeの記述部門を全て切り出したオブジェクト。
    var languageDepartment = LanguageDepartment()
    ///Storeの記述部門を全て切り出したオブジェクト。
    var userSetting = UserSettingDepartment()

    let feedbackGenerator = UINotificationFeedbackGenerator()
    
    fileprivate var lastVerticalTabState: TabState? = nil


    private(set) var needsInputModeSwitchKey = true   //ビューに関わる部分
    private(set) var keyboardModelVariableSection = KeyboardModelVariableSection()   //ビューに関わる部分
    private(set) var keyboardModel: KeyboardModelProtocol = VerticalFlickKeyboardModel()
    private init(){
    }
    
    func initialize(){
        self.action.initialize()
        self.refreshKeyboardModel()
        self.registerKeyboardType()
        if let lastTabState = self.lastVerticalTabState{
            self.setTabState(lastTabState)
            lastVerticalTabState = nil
        }
        self.userSetting.refresh()
    }

    func appearedAgain(){
        self.action.appearedAgain()
        self.userSetting.refresh()
    }

    func setNeedsInputModeSwitchKeyMode(_ bool: Bool){
        self.needsInputModeSwitchKey = bool
    }

    enum DicDataStoreNotification{
        case notifyLearningType(LearningType)
        case notifyAppearAgain
        case reloadUserDict
        case closeKeyboard
        case resetMemory
    }

    func sendToDicDataStore(_ data: DicDataStoreNotification){
        self.action.sendToDicDataStore(data)
    }

    func saveTextFile(contents: String, to fileName: String, for ex: String = "txt"){
        do {
            let fileManager = FileManager.default
            let library = try fileManager.url(for: .libraryDirectory,
                                              in: .userDomainMask,
                                              appropriateFor: nil, create: false)
            let path = library.appendingPathComponent("\(fileName).\(ex)")
            guard let data = contents.data(using: .utf8) else {
                print("ファイルをutf8で保存できません")
                return
            }
            fileManager.createFile(atPath: path.path, contents: data, attributes: nil)
        } catch {
            print(error)
        }
    }

    func readTextFile(to fileName: String, for ex: String = "txt") -> String {
        do {
            let fileManager = FileManager.default
            let library = try fileManager.url(for: .libraryDirectory,
                                              in: .userDomainMask,
                                              appropriateFor: nil, create: false)
            let path = library.appendingPathComponent("\(fileName).\(ex)")
            let contents = try String.init(contentsOfFile: path.path)
            return contents
        } catch {
            print(error)
        }
        return ""
    }

    func removeTextFile(to fileName: String, for ex: String = "txt"){
        do {
            let fileManager = FileManager.default
            let library = try fileManager.url(for: .libraryDirectory,
                                              in: .userDomainMask,
                                              appropriateFor: nil, create: false)
            let path = library.appendingPathComponent("\(fileName).\(ex)")
            try fileManager.removeItem(atPath: path.path)
        } catch {
            print(error)
        }
    }

    fileprivate func refreshKeyboardModel(absolutely: Bool = false){
        switch (self.keyboardType, self.orientation){
        case (.flick, .vertical):
            if absolutely || !(self.keyboardModel is VerticalFlickKeyboardModel){
                self.keyboardModel = VerticalFlickKeyboardModel()
            }
        case (.flick, .horizontal):
            if absolutely || !(self.keyboardModel is HorizontalFlickKeyboardModel){
                self.keyboardModel = HorizontalFlickKeyboardModel()
            }
        case (.roman, .vertical):
            if absolutely || !(self.keyboardModel is VerticalRomanKeyboardModel){
                self.keyboardModel = VerticalRomanKeyboardModel()
            }
        case (.roman, .horizontal):
            if absolutely || !(self.keyboardModel is HorizontalRomanKeyboardModel){
                self.keyboardModel = HorizontalRomanKeyboardModel()
            }
        }
    }
    
    fileprivate func showMoveCursorView(_ bool: Bool){
        self.keyboardModel.resultModel.showMoveCursorView(bool)
    }
    
    fileprivate func toggleShowMoveCursorView(){
        self.keyboardModel.resultModel.toggleShowMoveCursorView()
    }

    fileprivate func registerResult(_ result: [Candidate]){
        self.keyboardModel.resultModel.setResults(result)
    }
    
    func expandResult(results: [ResultData]){
        self.keyboardModel.expandResultView(results)
    }
    
    func collapseResult(){
        self.keyboardModel.collapseResultView()
    }

    func registerMagnifyingText(_ text: String){
        self.keyboardModelVariableSection.magnifyingText = text
        self.keyboardModelVariableSection.isTextMagnifying = true
    }

    fileprivate enum RoughEnterKeyState{
        case `return`
        case edit
        case complete
    }

    fileprivate func registerAaKeyState(_ state: AaKeyState){
        self.keyboardModel.aAKeyModel.setKeyState(new: state)
        self.aAKeyState = state
    }
    
    fileprivate func registerEnterKeyState(_ state: RoughEnterKeyState){
        switch state{
        case .return:
            self.keyboardModel.enterKeyModel.setKeyState(new: .return(self.enterKeyType))
            self.enterKeyState = .return(self.enterKeyType)
        case .edit:
            self.keyboardModel.enterKeyModel.setKeyState(new: .edit)
            self.enterKeyState = .edit
        case .complete:
            self.keyboardModel.enterKeyModel.setKeyState(new: .complete)
            self.enterKeyState = .complete
        }
    }
    
    fileprivate func setTabState(_ state: TabState){
        self.keyboardModel.setTabState(state: state)
    }

    ///workarounds
    ///* 1回目に値を保存してしまう
    ///* if bool {} else{}にしてboolをvariableSectionに持たせてtoggleする。←これを採用した。

    fileprivate func setOrientation(_ orientation: KeyboardOrientation){
        if self.orientation == orientation{
            self.refreshKeyboardModel()
            self.keyboardModelVariableSection.keyboardOrientation = orientation
            self.keyboardModelVariableSection.refreshView()
            return
        }
        self.orientation = orientation
        self.refreshKeyboardModel()
        self.keyboardModelVariableSection.keyboardOrientation = orientation
    }

    func registerUIReturnKeyType(type: UIReturnKeyType){
        self.enterKeyType = type
        if case let .return(prev) = self.enterKeyState{
            if prev != type{
                self.registerEnterKeyState(.return)
            }
        }
    }
    
    func registerKeyboardType(){
        let userDefaults = UserDefaults(suiteName: SharedStore.appGroupKey)!
        let key = "keyboard_type"
        if let string = userDefaults.string(forKey: key), let type = KeyboardType.get(string){
            self.keyboardType = type
        }else{
            userDefaults.set("flick", forKey: key)
        }
    }

    func closeKeyboard(){
        self.action.closeKeyboard()
    }
}

//MARK:Storeのデザイン部門の動作を全て切り出したオブジェクト。外部から参照されるのがこれ。
final class DesignDepartment{
    fileprivate init(){}

    private(set) var screenWidth: CGFloat = .zero

    private var keyboardType: KeyboardType {
        Store.shared.keyboardType
    }

    private var orientation: KeyboardOrientation {
        Store.shared.orientation
    }

    var keyboardWidth: CGFloat {
        return self.keyViewSize.width * CGFloat(self.horizontalKeyCount) + self.keyViewHorizontalSpacing * CGFloat(self.horizontalKeyCount-1)
    }

    var keyboardHeight: CGFloat {
        let keyheight = Store.shared.design.keyViewSize.height * CGFloat(Store.shared.design.verticalKeyCount + 1)
        switch keyboardType{
        case .flick:
            let spaceheight = Store.shared.design.keyViewVerticalSpacing * CGFloat(Store.shared.design.verticalKeyCount - 1) + 6.0
            return keyheight + spaceheight
        case .roman:
            //resultViewがspacing*2+keyHeightを持っているので、-1+1となる。
            let spaceheight = Store.shared.design.keyViewVerticalSpacing * CGFloat(Store.shared.design.verticalKeyCount) + 12.0
            return keyheight + spaceheight
        }
    }

    var verticalKeyCount: Int {
        switch keyboardType{
        case .flick:
            return 4
        case .roman:
            return 4
        }
    }

    var horizontalKeyCount: Int {
        switch keyboardType{
        case .flick:
            return 5
        case .roman:
            return 10
        }
    }

    ///KeyViewのサイズを自動で計算して返す。
    var keyViewSize: CGSize {
        switch keyboardType{
        case .flick:
            if orientation == .vertical{
                return CGSize(width: screenWidth/5.6, height: screenWidth/8)
            }else{
                return CGSize(width: screenWidth/9, height: screenWidth/18)
            }
        case .roman:
            if orientation == .vertical{
                return CGSize(width: screenWidth/12.2, height: screenWidth/9)
            }else{
                return CGSize(width: screenWidth/13, height: screenWidth/20)
            }
        }
    }
    
    var keyViewVerticalSpacing: CGFloat {
        switch keyboardType{
        case .flick:
            if orientation == .vertical{
                return keyViewHorizontalSpacing
            }else{
                return keyViewHorizontalSpacing/2
            }

        case .roman:
            if orientation == .vertical{
                return keyViewSize.width/3
            }else{
                return keyViewSize.width/5
            }
        }
    }
    
    var keyViewHorizontalSpacing: CGFloat {
        switch keyboardType{
        case .flick:
            if orientation == .vertical{
                return (screenWidth - keyViewSize.width * 5)/5
            }else{
                return (screenWidth - screenWidth*10/13)/12 - 0.5
            }

        case .roman:
            if orientation == .vertical{
                //9だとself.horizontalKeyCount-1で画面ぴったりになるが、それだとあまりにピシピシなので0.1を加えて調整する。
                return (screenWidth - keyViewSize.width * CGFloat(self.horizontalKeyCount))/(9+0.5)
            }else{
                return (screenWidth - keyViewSize.width * CGFloat(self.horizontalKeyCount))/10
            }
        }
    }

    var resultViewHeight: CGFloat {
        switch keyboardType{
        case .flick:
            return keyViewSize.height
        case.roman:
            return keyViewSize.height + keyViewVerticalSpacing
        }
    }

    var flickEnterKeySize: CGSize {
        let size = keyViewSize
        return CGSize(width: size.width, height: size.height*2 + keyViewVerticalSpacing)
    }

    var romanSpaceKeyWidth: CGFloat {
        return keyViewSize.width*5
    }

    var romanEnterKeyWidth: CGFloat {
        return keyViewSize.width*3
    }

    func romanScaledKeyWidth(normal: Int, for count: Int) -> CGFloat {
        let width = keyViewSize.width * CGFloat(normal) + keyViewHorizontalSpacing * CGFloat(normal - 1)
        let spacing = keyViewHorizontalSpacing * CGFloat(count - 1)
        return (width - spacing) / CGFloat(count)
    }

    func romanFunctionalKeyWidth(normal: Int, functional: Int, enter: Int = 0, space: Int = 0) -> CGFloat {
        let maxWidth = keyboardWidth
        let spacing = keyViewHorizontalSpacing * CGFloat(normal + functional + space + enter - 1)
        let normalKeyWidth = keyViewSize.width * CGFloat(normal)
        let spaceKeyWidth = romanSpaceKeyWidth * CGFloat(space)
        let enterKeyWidth = romanEnterKeyWidth * CGFloat(enter)
        return (maxWidth - (spacing + normalKeyWidth + spaceKeyWidth + enterKeyWidth)) / CGFloat(functional)
    }
    
    func getMaximumTextSize(_ text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 10)
        let size = text.size(withAttributes: [.font: font])
        return (keyViewSize.height*4 + keyViewVerticalSpacing*4)/size.height * 10
    }
    
    func isOverScreenWidth(_ value: CGFloat) -> Bool {
        return screenWidth < value
    }

    func registerScreenWidth(width: CGFloat){
        self.screenWidth = width
    }

    func registerScreenSize(size: CGSize){
        if self.screenWidth == size.width{
            return
        }
        self.registerScreenWidth(width: size.width)
        if size.width<size.height{
            Store.shared.setOrientation(.vertical)
        }else{
            Store.shared.setOrientation(.horizontal)
        }
    }

    let colors = Colors.default
    let fonts = Fonts.default

    enum Fonts{
        case `default`

        var iconFontSize: CGFloat {
            let userDecidedSize = Store.shared.userSetting.keyViewFontSize
            if userDecidedSize != -1{
                return UIFontMetrics.default.scaledValue(for: CGFloat(userDecidedSize))
            }
            return UIFontMetrics.default.scaledValue(for: 20)
        }

        var iconImageFont: Font {
            let size = self.iconFontSize
            return Font.system(size: size, weight: .regular)
        }

        var resultViewFontSize: CGFloat {
            let size = Store.shared.userSetting.resultViewFontSize
            return CGFloat(size == -1 ? 18: size)
        }

        var resultViewFont: Font {
            .system(size: resultViewFontSize)
        }

        func keyLabelFont(text: String, width: CGFloat, scale: CGFloat) -> Font {
            let userDecidedSize = Store.shared.userSetting.keyViewFontSize
            if userDecidedSize != -1 {
                return .system(size: CGFloat(userDecidedSize) * scale, weight: .regular, design: .default)
            }
            let maxFontSize: Int
            switch Store.shared.keyboardType{
            case .flick:
                maxFontSize = Int(21*scale)
            case .roman:
                maxFontSize = Int(25*scale)
            }
            //段階的フォールバック
            for fontsize in (10...maxFontSize).reversed(){
                let size = UIFontMetrics.default.scaledValue(for: CGFloat(fontsize))
                let font = UIFont.systemFont(ofSize: size, weight: .regular)
                let title_size = text.size(withAttributes: [.font: font])
                if title_size.width < width*0.95{
                    return Font.system(size: size, weight: .regular, design: .default)
                }
            }
            let size = UIFontMetrics.default.scaledValue(for: 9)
            return Font.system(size: size, weight: .regular, design: .default)
        }
    }

    enum Colors{
        case `default`
        var backGroundColor: Color {
            return Color("BackGroundColor")
        }
        var specialEnterKeyColor: Color {
            return Color("OpenKeyColor")
        }
        var normalKeyColor: Color {
            switch Store.shared.keyboardType{
            case .flick:
                return Color("NormalKeyColor")
            case .roman:
                return Color("RomanKeyColor")
            }
        }
        var specialKeyColor: Color {
            switch Store.shared.keyboardType{
            case .flick:
                return Color("TabKeyColor")
            case .roman:
                return Color("TabKeyColor")
            }
        }
        var highlightedKeyColor: Color {
            switch Store.shared.keyboardType{
            case .flick:
                return Color("HighlightedKeyColor")
            case .roman:
                return Color("RomanHighlightedKeyColor")
            }
        }
    }

}

struct KeyFlickSetting{
    typealias SaveValue = [String: String]
    var saveValue: [String: String] {
        return [
            "identifier": targetKeyIdentifier,
            "left": left,
            "top": top,
            "right": right,
            "bottom": bottom
        ]
    }

    let targetKeyIdentifier: String
    var left: String
    var top: String
    var right: String
    var bottom: String
    
    init(targetKeyIdentifier: String, left: String = "", top: String = "", right: String = "", bottom: String = "") {
        self.targetKeyIdentifier = targetKeyIdentifier
        self.top = top
        self.bottom = bottom
        self.left = left
        self.right = right
    }

    static func get(_ value: Any) -> KeyFlickSetting? {
        guard case let dict as SaveValue = value else{
            return nil
        }

        if let identifier = dict["identifier"],
           let left = dict["left"],
           let top = dict["top"],
           let right = dict["right"],
           let bottom = dict["bottom"]{
            return KeyFlickSetting(targetKeyIdentifier: identifier, left: left, top: top, right: right, bottom: bottom)
        }
        return nil
    }
}

struct UserSettingDepartment{
    static let userDefaults = UserDefaults(suiteName: SharedStore.appGroupKey)!
    
    mutating func refresh(){
        self.kogakiFlickSetting = Self.getKogakiFlickSetting()
        self.unicodeCandidateSetting = Self.getBoolSetting(.unicodeCandidate)
        self.westerJapaneseCalenderSetting = Self.getBoolSetting(.wesJapCalender)
        self.halfWidthKatakanaSetting = Self.getBoolSetting(.halfKana)
        self.typographyLettersSetting = Self.getBoolSetting(.typographyLetter)
        self.soundSetting = Self.getBoolSetting(.enableSound)

        self.learningType = Self.learningTypeSetting(.inputAndOutput)

        self.resultViewFontSize = Self.getDoubleSetting(.resultViewFontSize) ?? -1
        self.keyViewFontSize = Self.getDoubleSetting(.keyViewFontSize) ?? -1

        if Self.checkResetSetting(){
            Store.shared.sendToDicDataStore(.resetMemory)
        }
    }

    static func getKogakiFlickSetting() -> [FlickDirection: FlickedKeyModel] {
        let value = Self.userDefaults.value(forKey: "kogana_flicks")
        let setting: KeyFlickSetting
        if let value = value, let data = KeyFlickSetting.get(value){
            setting = data
        }else{
            setting = KeyFlickSetting(targetKeyIdentifier: "kogana")
        }
        
        var dict: [FlickDirection: FlickedKeyModel] = [:]
        if let left = setting.left == "" ? nil:FlickedKeyModel(labelType: .text(setting.left), pressActions: [.input(setting.left)]){
            dict[.left] = left
        }
        if let top = setting.top == "" ? nil:FlickedKeyModel(labelType: .text(setting.top), pressActions: [.input(setting.top)]){
            dict[.top] = top
        }
        if let right = setting.right == "" ? nil:FlickedKeyModel(labelType: .text(setting.right), pressActions: [.input(setting.right)]){
            dict[.right] = right
        }
        if let bottom = setting.bottom == "" ? nil:FlickedKeyModel(labelType: .text(setting.bottom), pressActions: [.input(setting.bottom)]){
            dict[.bottom] = bottom
        }
        return dict

    }
    var kogakiFlickSetting: [FlickDirection: FlickedKeyModel] = Self.getKogakiFlickSetting()

    var unicodeCandidateSetting: Bool = Self.getBoolSetting(.unicodeCandidate)
    var westerJapaneseCalenderSetting: Bool = Self.getBoolSetting(.wesJapCalender)
    var halfWidthKatakanaSetting: Bool = Self.getBoolSetting(.halfKana)
    var typographyLettersSetting: Bool = Self.getBoolSetting(.typographyLetter)
    var soundSetting: Bool = Self.getBoolSetting(.enableSound)
    var learningType: LearningType = Self.learningTypeSetting(.inputAndOutput, initialize: true)

    var resultViewFontSize = Self.getDoubleSetting(.resultViewFontSize) ?? -1
    var keyViewFontSize = Self.getDoubleSetting(.keyViewFontSize) ?? -1

    static func getBoolSetting(_ setting: Setting) -> Bool {
        if let object = Self.userDefaults.object(forKey: setting.key), let bool = object as? Bool{
            return bool
        }else if let bool = DefaultSetting.shared.getBoolDefaultSetting(setting){
            return bool
        }
        return false
    }

    static func getDoubleSetting(_ setting: Setting) -> Double? {
        if let object = Self.userDefaults.object(forKey: setting.key), let value = object as? Double{
            return value
        }else if let value = DefaultSetting.shared.getDoubleSetting(setting){
            return value
        }
        return nil
    }

    static func learningTypeSetting(_ current: LearningType, initialize: Bool = false) -> LearningType {
        let result: LearningType
        if let object = Self.userDefaults.object(forKey: Setting.learningType.key),
           let value = LearningType.get(object){
            result = value
        }else{
            result = DefaultSetting.shared.memorySettingDefault
        }
        if !initialize{
            Store.shared.sendToDicDataStore(.notifyLearningType(result))
        }
        return result
    }

    static func checkResetSetting() -> Bool {
        if let object = Self.userDefaults.object(forKey: Setting.memoryReset.key),
           let identifier = MemoryResetCondition.identifier(object){
            if let finished = UserDefaults.standard.string(forKey: "finished_reset"), finished == identifier{
                return false
            }
            UserDefaults.standard.set(identifier, forKey: "finished_reset")
            return true
        }
        return false
    }

    mutating func writeLearningTypeSetting(to type: LearningType) {
        Self.userDefaults.set(type.saveValue, forKey: Setting.learningType.key)
        self.learningType = type
        Store.shared.sendToDicDataStore(.notifyLearningType(type))
    }

    var romanNumberTabKeySetting: [RomanKeyModel] {
        let customKeys: RomanCustomKeysValue
        if let value = Self.userDefaults.value(forKey: Setting.numberTabCustomKeys.key), let keys = RomanCustomKeysValue.get(value){
            customKeys = keys
        }else if let defaultValue = DefaultSetting.shared.romanCustomKeyDefaultSetting(.numberTabCustomKeys){
            customKeys = defaultValue
        }else{
            return []
        }
        let keys = customKeys.keys
        let count = keys.count
        let scale = (7, count)
        return keys.map{key in
            RomanKeyModel(
                labelType: .text(key.name),
                pressActions: [.input(key.input)],
                variationsModel: VariationsModel(
                    key.longpresses.map{item in
                        (label: .text(item.name), actions: [.input(item.input)])
                    }
                ),
                for: scale
            )
        }
    }
}

//MARK:Storeの記述部門の動作を全て切り出したオブジェクト。外部から参照されるのがこれ。
struct LanguageDepartment{
    fileprivate init(){}

    func getEnterKeyText(_ state: EnterKeyState) -> String {
        switch state {
        case .complete:
            return "確定"
        case let .return(type):
            switch type{
            case .default:
                return "改行"
            case .go:
                return "開く"
            case .google:
                return "ググる"
            case .join:
                return "参加"
            case .next:
                return "次へ"
            case .route:
                return "経路"
            case .search:
                return "検索"
            case .send:
                return "送信"
            case .yahoo:
                return "Yahoo!"
            case .done:
                return "完了"
            case .emergencyCall:
                return "緊急連絡"
            case .continue:
                return "続行"
            @unknown default:
                return "改行"
            }
        case .edit:
            return "編集"
        }
    }
}


//MARK:Storeのキーボードへのアクション部門の動作を全て切り出したオブジェクト。外部から参照されるのがこれ。
final class ActionDepartment{
    fileprivate init(){}
    
    private var inputStateHolder = InputStateHolder()
    private weak var delegate: KeyboardViewController!
    
    //即時変数
    private var timers: [(type: KeyLongPressActionType, timer: Timer)] = []
    private var tempTextData: (left: String, center: String, right: String)!
    private var tempSavedSelectedText: String!

    func initialize(){
        self.inputStateHolder.closeKeyboard()
        self.timers.forEach{$0.timer.invalidate()}
        self.timers = []
    }

    func closeKeyboard(){
        self.initialize()
    }

    func appearedAgain(){
        print("再び表示されました")
        self.sendToDicDataStore(.reloadUserDict)
    }

    func registerProxy(_ proxy: UITextDocumentProxy){
        self.inputStateHolder.registerProxy(proxy)
    }

    func sendToDicDataStore(_ data: Store.DicDataStoreNotification){
        self.inputStateHolder.sendToDicDataStore(data)
    }

    func registerDelegate(_ controller: KeyboardViewController){
        self.delegate = controller
    }

    func makeChangeKeyboardButtonView() -> ChangeKeyboardButtonView{
        return delegate.makeChangeKeyboardButtonView(size: Store.shared.design.fonts.iconFontSize)
    }
    
    ///変換を確定した場合に呼ばれる。
    /// - Parameters:
    ///   - text: String。確定された文字列。
    ///   - count: Int。確定された文字数。例えば「検証」を確定した場合5。
    func registerComplete(_ candidate: Candidate){
        self.inputStateHolder.complete(candidate: candidate)
        candidate.actions.forEach{
            self.doAction($0)
        }
    }

    private func doAction(_ action: ActionType){
        switch action{
        case let .input(text):
            Store.shared.showMoveCursorView(false)
            if Store.shared.keyboardModel.tabState == .abc && Store.shared.aAKeyState == .capslock{
                let input = text.uppercased()
                self.inputStateHolder.input(text: input)
            }else{
                self.inputStateHolder.input(text: text)
            }
        case let .delete(count):
            Store.shared.showMoveCursorView(false)
            self.inputStateHolder.delete(count: count)

        case .smoothDelete:
            SoundTools.smoothDelete()
            Store.shared.showMoveCursorView(false)
            self.inputStateHolder.smoothDelete()

        case .deselectAndUseAsInputting:
            self.inputStateHolder.edit()

        case .saveSelectedTextIfNeeded:
            if self.inputStateHolder.isSelected{
                self.tempSavedSelectedText = self.inputStateHolder.inputtedText
            }
        case .restoreSelectedTextIfNeeded:
            if let tmp = self.tempSavedSelectedText{
                self.inputStateHolder.input(text: tmp)
                self.tempSavedSelectedText = nil
            }
        case let .moveCursor(count):
            self.inputStateHolder.moveCursor(count: count)
        case let .changeCapsLockState(state):
            Store.shared.registerAaKeyState(state)
        case .toggleShowMoveCursorView:
            Store.shared.toggleShowMoveCursorView()

        case .enter:
            Store.shared.showMoveCursorView(false)
            let actions = self.inputStateHolder.enter()
            actions.forEach{
                self.doAction($0)
            }

        case .changeCharacterType:
            Store.shared.showMoveCursorView(false)
            self.inputStateHolder.changeCharacter()

        case let .moveTab(type):
            Store.shared.setTabState(type)
            Store.shared.lastVerticalTabState = type

        case .hideLearningMemory:
            self.hideLearningMemory()

        //MARK: デバッグ用
        case .DEBUG_DATA_INPUT:
            self.inputStateHolder.isDebugMode.toggle()
            if self.inputStateHolder.isDebugMode{
                var left = self.inputStateHolder.proxy.documentContextBeforeInput ?? "nil"
                if left == "\n"{
                    left = "↩︎"
                }

                var center = self.inputStateHolder.proxy.selectedText ?? "nil"
                center = center.replacingOccurrences(of: "\n", with: "↩︎")

                var right = self.inputStateHolder.proxy.documentContextAfterInput ?? "nil"
                if right == "\n"{
                    right = "↩︎"
                }
                if right.isEmpty{
                    right = "empty"
                }

                self.registerDebugPrint("left:\(Array(left.unicodeScalars))/center:\(Array(center.unicodeScalars))/right:\(Array(right.unicodeScalars))")
            }
        }
    }

    ///押した場合に行われる。
    /// - Parameters:
    ///   - action: 行われた動作。
    func registerPressAction(_ action: ActionType){
        self.doAction(action)
    }
    
    ///長押しを予約する関数。
    /// - Parameters:
    ///   - action: 長押しで起こる動作のタイプ。
    func reserveLongPressAction(_ action: KeyLongPressActionType){
        timers.forEach{timer in
            if timer.type == action{
                //すでにあるので切り上げる
                return
            }
        }
        let deleteStartTime = Date()

        switch action{
        case .delete:
            let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {[weak self] (timer) in
                let span: TimeInterval = timer.fireDate.timeIntervalSince(deleteStartTime)
                if span > 0.4 {
                    SoundTools.delete()
                    self?.inputStateHolder.delete(count: 1)
                }
            })
            let tuple = (type: action, timer: timer)
            self.timers.append(tuple)
        case let .input(text):
            let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {[weak self] (timer) in
                let span: TimeInterval = timer.fireDate.timeIntervalSince(deleteStartTime)
                if span > 0.4 {
                    SoundTools.click()
                    self?.inputStateHolder.input(text: text)
                }
            })
            let tuple = (type: action, timer: timer)
            self.timers.append(tuple)
        case let .moveCursor(direction):
            let count = (direction == .right ? 1:-1)
            let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {[weak self] (timer) in
                let span: TimeInterval = timer.fireDate.timeIntervalSince(deleteStartTime)
                if span > 0.4 {
                    SoundTools.tabOrOtherKey()
                    self?.inputStateHolder.moveCursor(count: count)
                }
            })
            let tuple = (type: action, timer: timer)
            self.timers.append(tuple)
        case .toggleShowMoveCursorView:
            let timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: {_ in
                Store.shared.toggleShowMoveCursorView()
            })
            let tuple = (type: action, timer: timer)
            self.timers.append(tuple)
        case let .changeCapsLockState(state):
            let timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: {_ in
                Store.shared.registerAaKeyState(state)
            })
            let tuple = (type: action, timer: timer)
            self.timers.append(tuple)
        }

    }
    
    ///長押しを終了する関数。継続的な動作、例えば連続的な文字削除を行っていたタイマーを停止する。
    /// - Parameters:
    ///   - action: どの動作を終了するか判定するために用いる。
    func registerLongPressActionEnd(_ action: KeyLongPressActionType){
        for i in timers.indices{
            if timers[i].type == action{
                timers[i].timer.invalidate()
                timers.remove(at: i)
                break
            }
        }

    }
    
    ///何かが変化する前に状態の保存を行う関数。
    func registerSomethingWillChange(left: String, center: String, right: String){
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
    func registerSomethingDidChange(left: String, center: String, right: String){
        print("something did happen by user!")
        let b_left = self.tempTextData.left
        let b_center = self.tempTextData.center
        let b_right = self.tempTextData.right

        let a_wholeText = left + center + right
        let b_wholeText = b_left + b_center + b_right
        let isWholeTextChanged = a_wholeText != b_wholeText
        let wasSelected = !b_center.isEmpty
        let isSelected = !center.isEmpty

        if isSelected{
            print("select:", "left:", left.debugDescription, "right:", right.debugDescription, "center:", center.debugDescription)
            self.inputStateHolder.userSelectedText(text: center)
            print("user operation id: select")
            return
        }
        
        //全体としてテキストが変化せず、選択範囲が存在している場合→新たに選択した、または選択範囲を変更した
        if !isWholeTextChanged{
            //全体としてテキストが変化せず、選択範囲が無くなっている場合→選択を解除した
            if wasSelected && !isSelected{
                self.inputStateHolder.userDeselectedText()
                print("user operation id: 1")
                return
            }

            //全体としてテキストが変化せず、選択範囲は前後ともになく、左側(右側)の文字列だけが変わっていた場合→カーソルを移動した
            if !wasSelected && !isSelected && b_left != left{
                let offset = left.count - b_left.count
                print("user operation id: 2")

                self.inputStateHolder.userMovedCursor(count: offset)
                return
            }
            //ただタップしただけ、などの場合ここにくる事がある。
            print("user operation id: 3")
            return
        }
        //以降isWholeTextChangedは常にtrue
        //全体としてテキストが変化しており、前は左は改行コードになっていて選択範囲が存在し、かつ前の選択範囲と後の全体が一致する場合→行全体の選択が解除された
        //行全体を選択している場合は改行コードが含まれる。
        if b_left == "\n" && b_center == a_wholeText{
            print("user operation id: 5")
            self.inputStateHolder.userDeselectedText()
            return
        }

        //全体としてテキストが変化しており、左右の文字列を合わせたものが不変である場合→カットしたのではないか？
        if b_left + b_right == left + right{
            print("user operation id: 6")
            self.inputStateHolder.userCutText(text: b_center)
            return
        }
        
        //全体としてテキストが変化しており、右側の文字列が不変であった場合→ペーストしたのではないか？
        if b_right == right{
            //もしクリップボードに文字列がコピーされており、かつ、前の左側文字列にその文字列を加えた文字列が後の左側の文字列に一致した場合→確実にペースト
            if let pastedText = UIPasteboard.general.string, left.hasSuffix(pastedText){
                if wasSelected{
                    print("user operation id: 7")
                    self.inputStateHolder.userReplacedSelectedText(text: pastedText)
                }else{
                    print("user operation id: 8")
                    self.inputStateHolder.userPastedText(text: pastedText)
                }
                return
            }
        }
        
        if left == "\n" && b_left.isEmpty && right == b_right{
            print("user operation id: 9")
            return
        }
        
        //上記のどれにも引っかからず、なおかつテキスト全体が変更された場合
        print("user operation id: 10, \((left,center,right)), \((b_left, b_center, b_right))")
        self.inputStateHolder.clear()
    }

    private func hideLearningMemory(){
        Store.shared.userSetting.writeLearningTypeSetting(to: .nothing)
    }

    func registerDebugPrint(_ text: String){
        self.inputStateHolder.setDebugResult(text: text)
    }
}

//ActionDepartmentの状態を保存する部分
private final class InputStateHolder{
    fileprivate var proxy: UITextDocumentProxy!
    
    //現在入力中の文字
    fileprivate var inputtedText: String = ""
    private var kanaRomanStateHolder = KanaRomanStateHolder()
    //セレクトされているか否か、現在入力中の文字全体がセレクトされているかどうかである。
    fileprivate var isSelected = false
    private var cursorPosition = 0
    private let cursorMinimumPosition: Int = 0
    ///カーソルの動ける最大範囲。`inputtedText`の文字数に等しい。
    private var cursorMaximumPosition: Int {
        return inputtedText.count
    }

    typealias RomanConverter = KanaKanjiConverter<RomanInputData, RomanLatticeNode>
    typealias FlickConverter = KanaKanjiConverter<FlickInputData, FlickLatticeNode>
    ///かな漢字変換を受け持つ変換器。
    private var _romanConverter: RomanConverter?
    private var _flickConverter: FlickConverter?

    private var romanConverter: RomanConverter {
        self._flickConverter = nil
        if let romanConverter = self._romanConverter{
            return romanConverter
        }
        self._romanConverter = RomanConverter()
        return self._romanConverter!
    }

    private var flickConverter: FlickConverter {
        self._romanConverter = nil
        if let flickConverter = self._flickConverter{
            return flickConverter
        }
        self._flickConverter = FlickConverter()
        return self._flickConverter!
    }

    func sendToDicDataStore(_ data: Store.DicDataStoreNotification){
        self._romanConverter?.sendToDicDataStore(data)
        self._flickConverter?.sendToDicDataStore(data)
    }

    fileprivate func registerProxy(_ proxy: UITextDocumentProxy){
        self.proxy = proxy
    }

    private var isRomanKanaInputMode: Bool {
        switch Store.shared.keyboardType{
        case .flick:
            return false
        case .roman:
            return Store.shared.keyboardModel.tabState == .hira
        }
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

        switch Store.shared.keyboardType{
        case .flick:
            self.flickConverter.updateLearningData(candidate)
            self.proxy.insertText(candidate.text + leftsideInputedText.dropFirst(candidate.correspondingCount))
            if candidate.correspondingCount == inputtedText.count{
                self.clear()
                Store.shared.registerEnterKeyState(.return)
                return
            }
            self.inputtedText = String(self.inputtedText.dropFirst(candidate.correspondingCount))
            self.flickConverter.setCompletedData(candidate)

        case .roman:
            self.romanConverter.updateLearningData(candidate)
            self.kanaRomanStateHolder.complete(candidate.correspondingCount)    //characterでいう確定分
            let displayedText = self.kanaRomanStateHolder.components.map{$0.displayedText}.joined()
            self.proxy.insertText(candidate.text + displayedText)
            if self.kanaRomanStateHolder.components.isEmpty{
                self.clear()
                Store.shared.registerEnterKeyState(.return)
                return
            }
            self.inputtedText = displayedText
            self.romanConverter.setCompletedData(candidate)
        }
        self.cursorPosition = self.cursorMaximumPosition
        self.setResult()
    }
    
    fileprivate func clear(){
        print("クリアしました")
        self.inputtedText = ""
        self.cursorPosition = self.cursorMinimumPosition
        self.isSelected = false

        self.setResult()
        self.kanaRomanStateHolder = KanaRomanStateHolder()
        self._romanConverter?.clear()
        self._flickConverter?.clear()
        Store.shared.collapseResult()
        Store.shared.registerEnterKeyState(.return)
    }

    fileprivate func closeKeyboard(){
        print("キーボードを閉じます")
        self.sendToDicDataStore(.closeKeyboard)
        self._romanConverter = nil
        self._flickConverter = nil
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
        switch Store.shared.keyboardType{
        case .flick:
            actions = self.flickConverter.getApporopriateActions(_candidate)
            let candidate = _candidate.withActions(actions)
            self.flickConverter.updateLearningData(candidate)
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
            switch Store.shared.keyboardType{
            case .flick:
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
            
            Store.shared.registerEnterKeyState(.complete)
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
        
        switch Store.shared.keyboardType{
        case .flick:
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
        
        Store.shared.registerEnterKeyState(.complete)

        setResult()
    }

    fileprivate func delete(count: Int, requireSetResult: Bool = true){
        //選択状態ではオール削除になる
        if self.isSelected{
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
        if Store.shared.keyboardType == .roman{
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
            Store.shared.registerEnterKeyState(.return)
        }
    }

    fileprivate func smoothDelete(){
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
            if ["、","。","！","？",".",","].contains(last){
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
            Store.shared.registerEnterKeyState(.complete)
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
                print("あとの文字は、",suf,-suf.utf16.count)
                return suf.utf16.count
            }else{
                return 1
            }
        }
        else {
            if let before = self.proxy.documentContextBeforeInput{
                let pre = before.suffix(-count)
                print("前の文字は、",pre,-pre.utf16.count)

                return -pre.utf16.count

            }else{
                return -1
            }
        }
    }

    ///キーボード経由でのカーソル移動
    fileprivate func moveCursor(count: Int){
        if inputtedText.isEmpty{
            let offset = self.getActualOffset(count: count)
            self.proxy.adjustTextPosition(byCharacterOffset: offset)
        }
        print("moveCursor, cursorPosition:", cursorPosition, count)
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
        print("userによるカーソル移動を検知、今の位置は\(self.cursorPosition)、動かしたオフセットは\(count)")
        if self.inputtedText.isEmpty{
            //入力がない場合はreturnしておかないと、入力していない時にカーソルを動かせなくなってしまう。
            return
        }
        
        self.cursorPosition += count

        if self.cursorPosition > self.cursorMaximumPosition{
            let offset = self.getActualOffset(count: self.cursorMaximumPosition - self.cursorPosition)
            self.proxy.adjustTextPosition(byCharacterOffset: offset)
            print("右にはみ出したので\(self.cursorMaximumPosition - self.cursorPosition)(\(offset))分正規化しました。動いた位置は\(self.cursorPosition)")
            self.cursorPosition = self.cursorMaximumPosition
            setResult()
            return
        }
        if self.cursorPosition < self.cursorMinimumPosition{
            let offset = self.getActualOffset(count: self.cursorMinimumPosition - self.cursorPosition)
            //let offset = self.cursorMinimumPosition - self.cursorPosition
            self.proxy.adjustTextPosition(byCharacterOffset: offset)
            print("左にはみ出したので\(self.cursorMinimumPosition - self.cursorPosition)(\(offset))分正規化しました。動いた位置は\(self.cursorPosition)")
            self.cursorPosition = self.cursorMinimumPosition
            setResult()
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
        Store.shared.registerEnterKeyState(.complete)
    }
    
    fileprivate func userCutText(text: String){
        self.inputtedText = ""
        self.cursorPosition = .zero
        self.isSelected = false
        self.setResult()
        Store.shared.registerEnterKeyState(.return)
    }
    
    fileprivate func userReplacedSelectedText(text: String){
        //新たな入力を反映
        self.inputtedText = text
        self.cursorPosition = self.cursorMaximumPosition
        self.isSelected = false
        
        setResult()
        Store.shared.registerEnterKeyState(.complete)
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
            self.setResult(options: [.mojiCount, .wordCount, .convertInput])
        }
        Store.shared.registerEnterKeyState(.edit)
    }
    
    //選択を解除した場合、clearとみなす
    fileprivate func userDeselectedText(){
        self.clear()
        Store.shared.registerEnterKeyState(.return)
    }

    enum ResultOptions{
        case convertInput
        case mojiCount
        case wordCount
    }


    fileprivate func setResult(options: [ResultOptions] = [.convertInput]){
        if isDebugMode{
            return
        }
        var results = [Candidate]()
        options.forEach{option in
            switch option{
            case .convertInput:
                let input_hira = self.inputtedText.prefix(self.cursorPosition)
                let result: [Candidate]
                switch Store.shared.keyboardType{
                case .flick:
                    let inputData = FlickInputData(String(input_hira))
                    result = self.flickConverter.requestCandidates(inputData, N_best: 10)
                case .roman:
                    let inputData = RomanInputData(String(input_hira), history: self.kanaRomanStateHolder)
                    let requirePrediction = Store.shared.keyboardModel.tabState == .hira
                    let requireEnglishPrediction = Store.shared.keyboardModel.tabState != .hira

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
    
    //debug中であることを示す。
    fileprivate var isDebugMode: Bool = false
    
    fileprivate func setDebugResult(text: String){
        #if DEBUG
        if !isDebugMode{
            return
        }

        Store.shared.registerResult([Candidate(text: text, value: .zero, lastMid: 500, data: [])])
        isDebugMode = true
        #endif
    }
    
    fileprivate func openApp(apppath: String){}
    
}
