//
//  TouchDownAndTouchUpGesture.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/20.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

struct TouchDownAndTouchUpGestureView: UIViewRepresentable {
    let touchDownCallBack: (() -> Void)
    let touchMovedCallBack: (() -> Void)
    let touchUpCallBack: (() -> Void)

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIViewType {
        let view = UIView(frame: .zero)
        let touchDown = SingleTouchDownGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.touchDown))
        touchDown.delegate = context.coordinator
        view.addGestureRecognizer(touchDown)
        let touchUp = SingleTouchUpGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.touchUp))
        touchUp.delegate = context.coordinator
        view.addGestureRecognizer(touchUp)
        let touchMoved = SingleTouchMovedGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.touchMoved))
        touchMoved.delegate = context.coordinator
        view.addGestureRecognizer(touchMoved)
        return view
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var touchDownCallback: (() -> Void)
        var touchMovedCallBack: (() -> Void)
        var touchUpCallback: (() -> Void)

        init(touchDownCallback: @escaping (() -> Void), touchMovedCallBack: @escaping (() -> Void), touchUpCallback: @escaping (() -> Void)) {
            self.touchDownCallback = touchDownCallback
            self.touchMovedCallBack = touchMovedCallBack
            self.touchUpCallback = touchUpCallback
        }

        @objc func touchDown(gesture: UITapGestureRecognizer) {
            self.touchDownCallback()
        }

        @objc func touchUp(gesture: UITapGestureRecognizer) {
            self.touchUpCallback()
        }

        @objc func touchMoved(gesture: UITapGestureRecognizer) {
            self.touchMovedCallBack()
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(touchDownCallback: touchDownCallBack, touchMovedCallBack: touchMovedCallBack, touchUpCallback: touchUpCallBack)
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {}
}

class SingleTouchDownGestureRecognizer: UIGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .possible {
            self.state = .recognized
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .failed
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .failed
    }
}


class SingleTouchUpGestureRecognizer: UIGestureRecognizer {
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .possible {
            self.state = .failed
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .possible {
            self.state = .recognized
        }
    }
}

class SingleTouchMovedGestureRecognizer: UIGestureRecognizer {
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .possible {
            self.state = .recognized
        }
    }
}
