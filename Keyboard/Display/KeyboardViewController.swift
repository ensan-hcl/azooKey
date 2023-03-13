//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by ensan on 2020/04/06.
//  Copyright © 2020 ensan. All rights reserved.
//

import SwiftUI
import UIKit

extension Candidate: ResultViewItemData {}

final private class KeyboardHostingController<Content: View>: UIHostingController<Content> {
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        .bottom
    }
}

extension UIInputView: UIInputViewAudioFeedback {
    open var enableInputClicksWhenVisible: Bool {
        true
    }
}

extension UIKeyboardType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .URL: return ".URL"
        case .asciiCapable: return ".asciiCapable"
        case .asciiCapableNumberPad: return ".asciiCapableNumberPad"
        case .decimalPad: return ".decimalPad"
        case .default: return ".default"
        case .emailAddress: return ".emailAddress"
        case .namePhonePad: return ".namePhonePad"
        case .numberPad: return ".numberPad"
        case .numbersAndPunctuation: return ".numbersAndPunctuation"
        case .phonePad: return ".phonePad"
        case .twitter: return ".twitter"
        case .webSearch: return ".webSearch"
        @unknown default:
            return "unknown value: \(self.rawValue)"
        }
    }
}

extension UIView {
    func clearAllView() {
        self.subviews.forEach {
            $0.clearAllView()
        }
        self.removeFromSuperview()
    }
}

final class KeyboardViewController: UIInputViewController {
    private static var keyboardViewHost: KeyboardHostingController<Keyboard>?
    private static var loadedInstanceCount: Int = 0
    private static let resultModelVariableSection = ResultModelVariableSection<Candidate>()
    private static let action = KeyboardActionManager()
    private static let notificationCenter = NotificationCenter.default

    deinit {
        KeyboardViewController.keyboardViewHost = nil
        self.view.clearAllView()
        self.removeFromParent()
    }

    struct Keyboard: View {
        let theme: ThemeData
        var body: some View {
            KeyboardView<Candidate>(resultModelVariableSection: KeyboardViewController.resultModelVariableSection)
                .environment(\.themeEnvironment, theme)
                .environment(\.userActionManager, KeyboardViewController.action)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        debug("viewDidLoad, loadedInstanceCount:", KeyboardViewController.loadedInstanceCount)
        KeyboardViewController.loadedInstanceCount += 1

        // 初期化の順序としてこの位置に置くこと
        VariableStates.shared.initialize()

        // 高さの設定を反映する
        @KeyboardSetting(.keyboardHeightScale) var keyboardHeightScale: Double
        SemiStaticStates.shared.setKeyboardHeightScale(keyboardHeightScale)

        let indexManager = ThemeIndexManager.load()
        let theme: ThemeData
        switch traitCollection.userInterfaceStyle {
        case .unspecified, .light:
            theme = (try? indexManager.theme(at: indexManager.selectedIndex)) ?? .default
        case .dark:
            theme = (try? indexManager.theme(at: indexManager.selectedIndexInDarkMode)) ?? .default
        @unknown default:
            theme = (try? indexManager.theme(at: indexManager.selectedIndex)) ?? .default
        }
        let host = KeyboardViewController.keyboardViewHost ?? KeyboardHostingController(rootView: Keyboard(theme: theme))
        // コントロールセンターを出しにくくする。
        host.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()

        host.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(host)
        self.view.addSubview(host.view)
        host.didMove(toParent: self)

        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        host.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        host.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        host.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        KeyboardViewController.keyboardViewHost = host
        KeyboardViewController.action.setDelegateViewController(self)

        debug("viewDidLoad", self.isViewLoaded, UIScreen.main.bounds.size, UIScreen.main.currentMode?.size, self.view.window?.bounds)
    }

    override func viewDidAppear(_ animated: Bool) {
        debug("viewDidAppear")
        // キーボードタイプはviewDidAppearのタイミングで取得できる
        VariableStates.shared.setKeyboardType(self.textDocumentProxy.keyboardType)
        // フルアクセスの状態を反映する
        VariableStates.shared.boolStates.hasFullAccess = self.hasFullAccess
        // クリップボード履歴を更新する
        VariableStates.shared.clipboardHistoryManager.reload()
        VariableStates.shared.clipboardHistoryManager.checkUpdate()
        // ロード済みのインスタンスの数が増えすぎるとパフォーマンスに悪影響があるので、適当なところで強制終了する
        // viewDidAppearで強制終了すると再ロードが自然な形で実行される
        if KeyboardViewController.loadedInstanceCount > 15 {
            fatalError("Too many instance of KeyboardViewController was created")
        }

        self.registerScreenActualSize()
        KeyboardViewController.action.setDelegateViewController(self)

        super.viewDidAppear(animated)
        let window = self.view.window!
        let gr0 = window.gestureRecognizers![0] as UIGestureRecognizer
        let gr1 = window.gestureRecognizers![1] as UIGestureRecognizer
        gr0.delaysTouchesBegan = false
        gr1.delaysTouchesBegan = false

        self.view.becomeFirstResponder()
        self.updateViewConstraints()

        SemiStaticStates.shared.setNeedsInputModeSwitchKeyMode(self.needsInputModeSwitchKey)

        @KeyboardSetting(.useOSUserDict) var useOSUserDict
        if useOSUserDict {
            Task {
                let lexicon = await self.requestSupplementaryLexicon()
                let dict = lexicon.entries.map {entry in DicdataElement(word: entry.documentText, ruby: entry.userInput.toKatakana(), cid: CIDData.固有名詞.cid, mid: MIDData.一般.mid, value: -6)}
                KeyboardViewController.action.sendToDicdataStore(.importOSUserDict(dict))
            }
        } else {
            KeyboardViewController.action.sendToDicdataStore(.importOSUserDict([]))
        }
    }

    func registerScreenActualSize() {
        if let bounds = KeyboardViewController.keyboardViewHost?.view.safeAreaLayoutGuide.owningView?.bounds {
            debug("registerScreenActualSize width: ", bounds.width)
            SemiStaticStates.shared.setScreenWidth(bounds.width)
        }
    }

    func updateResultView(_ candidates: [Candidate]) {
        KeyboardViewController.resultModelVariableSection.setResults(candidates)
    }

    func makeChangeKeyboardButtonView(size: CGFloat) -> ChangeKeyboardButtonView {
        let selector = #selector(self.handleInputModeList(from:with:))
        let view = ChangeKeyboardButtonView(selector: selector, size: size)
        return view
    }

    override func viewWillDisappear(_ animated: Bool) {
        KeyboardViewController.action.closeKeyboard()
        VariableStates.shared.closeKeyboard()
        KeyboardViewController.keyboardViewHost = nil
        KeyboardViewController.loadedInstanceCount -= 1
        debug("viewWillDisappear: キーボードが閉じられます")
        super.viewWillDisappear(animated)
        self.view.clearAllView()
        self.removeFromParent()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // この関数は「これから」向きが変わる場合に呼ばれるので、デバイスの向きによってwidthとheightが逆転するUIScreen.main.bounds.sizeを用いて向きを確かめることができる。
        // ただしこの時点でのUIScreen.mainの値はOSバージョンで変わる
        // なお、UIScreen.mainは非推奨である。これからデバイスの向きどうやってとったらええねん。
        debug("viewWillTransition", size, UIScreen.main.bounds.size)
        if #available(iOS 16, *) {
            SemiStaticStates.shared.setScreenWidth(size.width, orientation: UIScreen.main.bounds.width < UIScreen.main.bounds.height ? .horizontal : .vertical)
        } else {
            SemiStaticStates.shared.setScreenWidth(size.width, orientation: UIScreen.main.bounds.width < UIScreen.main.bounds.height ? .vertical : .horizontal)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        debug("viewDidLayoutSubviews", Design.keyboardHeight(screenWidth: SemiStaticStates.shared.screenWidth), SemiStaticStates.shared.screenWidth)
        self.view.frame.size.height = Design.keyboardScreenHeight
        self.updateViewConstraints()
        debug("viewDidLayoutSubviews", UIScreen.main.bounds, self.view.frame.size, KeyboardViewController.keyboardViewHost?.view.frame.size, self.view.window?.bounds, KeyboardViewController.keyboardViewHost?.view.window?.bounds, KeyboardViewController.keyboardViewHost?.view.window?.window?.bounds)
    }

    /*
     override func selectionWillChange(_ textInput: UITextInput?) {
     super.selectionWillChange(textInput)
     debug("selectionWillChange")
     }

     override func selectionDidChange(_ textInput: UITextInput?) {
     super.selectionDidChange(textInput)
     debug("selectionDidChange")
     }
     */
    /// 引数の`textInput`は常に`nil`
    override func textWillChange(_ textInput: UITextInput?) {
        super.textWillChange(textInput)

        let left = self.textDocumentProxy.documentContextBeforeInput ?? ""
        let center = self.textDocumentProxy.selectedText ?? ""
        let right = self.textDocumentProxy.documentContextAfterInput ?? ""
        debug("KeyboardViewController.textWillChange", left, center, right)

        Self.action.notifySomethingWillChange(left: left, center: center, right: right)
    }

    /// 引数の`textInput`は常に`nil`
    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)

        let left = self.textDocumentProxy.documentContextBeforeInput ?? ""
        let center = self.textDocumentProxy.selectedText ?? ""
        let right = self.textDocumentProxy.documentContextAfterInput ?? ""
        debug("KeyboardViewController.textDidChange", left, center, right)

        Self.action.notifySomethingDidChange(a_left: left, a_center: center, a_right: right)
        Self.action.setTextDocumentProxy(.preference(.main))
        // このタイミングでクリップボードを確認する
        VariableStates.shared.clipboardHistoryManager.checkUpdate()
        VariableStates.shared.setUIReturnKeyType(type: self.textDocumentProxy.returnKeyType ?? .default)
    }

    @objc func openURL(_ url: URL) {}
    //https://stackoverflow.com/questions/40019521/open-my-application-from-my-keyboard-extension-in-swift-3-0より
    func openUrl(url: URL?) {
        let selector = #selector(openURL(_:))
        var responder = (self as UIResponder).next
        while let r = responder, !r.responds(to: selector) {
            responder = r.next
        }
        // debug(responder)
        _ = responder?.perform(selector, with: url)
    }

    func openApp(scheme: String) {
        // 日本語のURLは使えないので、パーセントエンコーディングを適用する
        guard let encoded = scheme.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encoded) else {
            debug("無効なschemeです", scheme, scheme.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? scheme)
            return
        }
        self.openUrl(url: url)
    }
}
