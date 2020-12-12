//
//  EnterKeyChangableTextField.swift
//  KanaKanjier
//
//  Created by β α on 2020/12/12.
//  Copyright © 2020 DevEn3. All rights reserved.
//

import SwiftUI

// MARK: Custom TextField
struct CustomTextField: UIViewRepresentable {
    let keyboardType: UIKeyboardType
    let returnVal: UIReturnKeyType
    let tag: Int
    @Binding var text: String
    //@Binding var isfocusAble: [Bool]

    init(text: Binding<String>, keyboardType: UIKeyboardType = .default, returnKeyType: UIReturnKeyType = .default , tag: Int = 0){
        self.keyboardType = keyboardType
        self.returnVal = returnKeyType
        self.tag = tag
        self._text = text
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.keyboardType = self.keyboardType
        textField.returnKeyType = self.returnVal
        textField.tag = self.tag
        textField.delegate = context.coordinator
        textField.autocorrectionType = .no

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.becomeFirstResponder()
        /*
        if isfocusAble[tag] {
            uiView.becomeFirstResponder()
        } else {
            uiView.resignFirstResponder()
        }*/
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextField

        init(_ textField: CustomTextField) {
            self.parent = textField
        }

        func updatefocus(textfield: UITextField) {
            textfield.becomeFirstResponder()
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {

            if parent.tag == 0 {
                //parent.isfocusAble = [false, true]
                parent.text = textField.text ?? ""
            } else if parent.tag == 1 {
               // parent.isfocusAble = [false, false]
                parent.text = textField.text ?? ""
            }
            return true
        }

    }
}
