//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by β α on 2020/04/06.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import UIKit
import SwiftUI
import ObjectiveC
final private class KeyboardHostingController<Content: View>: UIHostingController<Content> {
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return .bottom
    }
}

extension UIInputView: UIInputViewAudioFeedback {
    open var enableInputClicksWhenVisible: Bool {
        return true
    }
}

final class KeyboardViewController: UIInputViewController {
    private var keyboardViewHost: KeyboardHostingController<Keyboard>! = nil

    struct Keyboard: View {
        let theme: ThemeData
        var body: some View {
            KeyboardView<Candidate>(resultModel: Store.shared.resultModel)
                .environment(\.themeEnvironment, theme)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 初期化の順序としてこの位置に置くこと
        Store.shared.initialize()
        let indexManager = ThemeIndexManager.load()
        let theme = (try? indexManager.theme(at: indexManager.selectedIndex)) ?? .default
        self.keyboardViewHost = KeyboardHostingController(rootView: Keyboard(theme: theme))
        // コントロールセンターを出しにくくする。
        keyboardViewHost.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()

        keyboardViewHost.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(keyboardViewHost)
        self.view.addSubview(keyboardViewHost.view)
        keyboardViewHost.didMove(toParent: self)

        keyboardViewHost.view.translatesAutoresizingMaskIntoConstraints = false
        keyboardViewHost.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        keyboardViewHost.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        keyboardViewHost.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        keyboardViewHost.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        Store.shared.action.setTextDocumentProxy(self.textDocumentProxy)
        Store.shared.action.setDelegateViewController(self)
        SemiStaticStates.shared.setScreenSize(size: UIScreen.main.bounds.size)
    }

    override func viewDidAppear(_ animated: Bool) {
        self.registerScreenActualSize()
        super.viewDidAppear(animated)
        let window = self.view.window!
        let gr0 = window.gestureRecognizers![0] as UIGestureRecognizer
        let gr1 = window.gestureRecognizers![1] as UIGestureRecognizer
        gr0.delaysTouchesBegan = false
        gr1.delaysTouchesBegan = false

        self.view.becomeFirstResponder()
        SemiStaticStates.shared.setNeedsInputModeSwitchKeyMode(self.needsInputModeSwitchKey)

        if SettingData.shared.bool(for: .useOSuserDict) {
            let osuserdict = OSUserDict()
            self.requestSupplementaryLexicon {[unowned osuserdict] in
                osuserdict.dict = $0.entries.map {entry in DicdataElement(word: entry.documentText, ruby: entry.userInput.applyingTransform(.hiraganaToKatakana, reverse: false)!, cid: 1288, mid: 501, value: -6)}
            }
            Store.shared.action.sendToDicDataStore(.importOSUserDict(osuserdict))
        }

        Store.shared.appearedAgain()
    }

    func registerScreenActualSize() {
        if let bounds = keyboardViewHost.view.safeAreaLayoutGuide.owningView?.bounds {
            let size = CGSize(width: bounds.width, height: UIScreen.main.bounds.height)
            SemiStaticStates.shared.setScreenSize(size: size)
        }
    }

    func makeChangeKeyboardButtonView(size: CGFloat, theme: ThemeData) -> ChangeKeyboardButtonView {
        let selector = #selector(self.handleInputModeList(from:with:))
        let view = ChangeKeyboardButtonView(selector: selector, size: size, theme: theme)
        return view
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Store.shared.closeKeyboard()
        debug("キーボードが閉じられました")
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if let bounds = keyboardViewHost.view.safeAreaLayoutGuide.owningView?.bounds {
            let size = CGSize(width: bounds.width, height: UIScreen.main.bounds.height)
            SemiStaticStates.shared.setScreenSize(size: size)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.registerScreenActualSize()
        debug("描画終わり", self.view.frame.size)
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
    override func textWillChange(_ textInput: UITextInput?) {
        super.textWillChange(textInput)

        VariableStates.shared.setUIReturnKeyType(type: self.textDocumentProxy.returnKeyType ?? .default)
        let left = self.textDocumentProxy.documentContextBeforeInput ?? ""
        let center = self.textDocumentProxy.selectedText ?? ""
        let right = self.textDocumentProxy.documentContextAfterInput ?? ""

        debug(left, center, right)
        VariableStates.shared.action.notifySomethingWillChange(left: left, center: center, right: right)
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)

        let left = self.textDocumentProxy.documentContextBeforeInput ?? ""
        let center = self.textDocumentProxy.selectedText ?? ""
        let right = self.textDocumentProxy.documentContextAfterInput ?? ""

        debug(left, center, right)
        VariableStates.shared.action.notifySomethingDidChange(a_left: left, a_center: center, a_right: right)
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
        guard let url = URL(string: scheme) else {
            debug("無効なschemeです")
            return
        }
        self.openUrl(url: url)
    }
}
