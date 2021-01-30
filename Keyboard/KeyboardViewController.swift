//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by β α on 2020/04/06.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import UIKit
import SwiftUI

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
    private var keyboardViewHost: KeyboardHostingController<KeyboardView>! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        //初期化の順序としてこの位置に置くこと
        Store.shared.initialize()
        self.keyboardViewHost = KeyboardHostingController(rootView: KeyboardView())
        //コントロールセンターを出しにくくする。
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
        Design.shared.setScreenSize(size: UIScreen.main.bounds.size)
        var entries: [UILexiconEntry] = []
        self.requestSupplementaryLexicon(completion: {
            $0.entries.forEach{entry in
                debug(entry.userInput, entry.documentText)
            }
            entries.append(contentsOf: $0.entries)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.registerScreenActualSize()
        super.viewDidAppear(animated)
        let window = self.view.window!
        let gr0 = window.gestureRecognizers![0] as UIGestureRecognizer
        let gr1 = window.gestureRecognizers![1] as UIGestureRecognizer
        gr0.delaysTouchesBegan = false
        gr1.delaysTouchesBegan = false

        Store.shared.setNeedsInputModeSwitchKeyMode(self.needsInputModeSwitchKey)
        Store.shared.action.appearedAgain()
    }

    func registerScreenActualSize(){
        if let bounds = keyboardViewHost.view.safeAreaLayoutGuide.owningView?.bounds{
            let size = CGSize(width: bounds.width, height: UIScreen.main.bounds.height)
            Design.shared.setScreenSize(size: size)
        }
    }

    func makeChangeKeyboardButtonView(size: CGFloat) -> ChangeKeyboardButtonView {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(self.handleInputModeList(from:with:)), for: .allTouchEvents)
        let largeConfig = UIImage.SymbolConfiguration(pointSize: size, weight: .light, scale: .default)
        let largeBoldDoc = UIImage(systemName: "globe", withConfiguration: largeConfig)
        button.setImage(largeBoldDoc, for: .normal)
        button.setTitleColor(.label, for: [.normal, .highlighted])
        button.tintColor = .label
        let view = ChangeKeyboardButtonView(button)
        return view
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Store.shared.closeKeyboard()
        debug("キーボードが閉じられました")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if let bounds = keyboardViewHost.view.safeAreaLayoutGuide.owningView?.bounds{
            let size = CGSize(width: bounds.width, height: UIScreen.main.bounds.height)
            Design.shared.setScreenSize(size: size)
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

        Store.shared.setUIReturnKeyType(type: self.textDocumentProxy.returnKeyType ?? .default)
        let left = self.textDocumentProxy.documentContextBeforeInput ?? ""
        let center = self.textDocumentProxy.selectedText ?? ""
        let right = self.textDocumentProxy.documentContextAfterInput ?? ""

        debug(left, center, right)
        Store.shared.action.notifySomethingWillChange(left: left, center: center, right: right)
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)

        let left = self.textDocumentProxy.documentContextBeforeInput ?? ""
        let center = self.textDocumentProxy.selectedText ?? ""
        let right = self.textDocumentProxy.documentContextAfterInput ?? ""

        debug(left, center, right)
        Store.shared.action.notifySomethingDidChange(a_left: left, a_center: center, a_right: right)
    }

    @objc func openURL(_ url: URL) {}
    //https://stackoverflow.com/questions/40019521/open-my-application-from-my-keyboard-extension-in-swift-3-0より
    func openUrl(url: URL?) {
        let selector = #selector(openURL(_:))
        var responder = (self as UIResponder).next
        while let r = responder, !r.responds(to: selector) {
            responder = r.next
        }
        //debug(responder)
        _ = responder?.perform(selector, with: url)
    }

    func openApp(scheme: String){
        guard let url = URL(string: scheme) else{
            debug("無効なschemeです")
            return
        }
        self.openUrl(url: url)
    }
}

struct ChangeKeyboardButtonView: UIViewRepresentable {
    private var button: UIButton
    init(_ button: UIButton){
        self.button = button
    }
    func makeUIView(context: Context) -> UIButton {
        return button
    }

    func updateUIView(_ uiView: UIButton, context: Context) {
        return
    }
}
