//
//  TouchDownAndTouchUpGesture.swift
//  azooKey
//
//  Created by ensan on 2021/02/20.
//  Copyright © 2021 ensan. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftUtils

public struct TouchDownAndTouchUpGestureView: UIViewRepresentable {
    public init(touchDownCallBack: @escaping () -> Void, touchMovedCallBack: @escaping (TouchDownAndTouchUpGestureView.GestureState) -> Void, touchUpCallBack: @escaping (TouchDownAndTouchUpGestureView.GestureState) -> Void) {
        self.touchDownCallBack = touchDownCallBack
        self.touchMovedCallBack = touchMovedCallBack
        self.touchUpCallBack = touchUpCallBack
    }

    let touchDownCallBack: () -> Void
    let touchMovedCallBack: (GestureState) -> Void
    let touchUpCallBack: (GestureState) -> Void

    public struct GestureState {
        public var distance: CGFloat
        public var time: CGFloat
    }

    public func makeUIView(context: UIViewRepresentableContext<Self>) -> Self.UIViewType {
        let view = UIView(frame: .zero)
        let tap = SingleScrollAndLongpressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tap))
        tap.delegate = context.coordinator
        view.addGestureRecognizer(tap)
        return view
    }

    public class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var touchDownCallback: () -> Void
        var touchMovedCallBack: (GestureState) -> Void
        var touchUpCallback: (GestureState) -> Void

        var touchStart: Date = Date()

        init(touchDownCallback: @escaping () -> Void, touchMovedCallBack: @escaping (GestureState) -> Void, touchUpCallback: @escaping (GestureState) -> Void) {
            self.touchDownCallback = touchDownCallback
            self.touchMovedCallBack = touchMovedCallBack
            self.touchUpCallback = touchUpCallback
        }

        @objc fileprivate func tap(gesture: SingleScrollAndLongpressGestureRecognizer) {
            switch gesture.state {
            case .began:
                self.touchStart = Date()
                self.touchDownCallback()
            case .changed:
                self.touchMovedCallBack(GestureState(distance: gesture.distance, time: Date().timeIntervalSince(self.touchStart)))
            case .ended:
                self.touchUpCallback(GestureState(distance: gesture.distance, time: Date().timeIntervalSince(self.touchStart)))
            case .possible, .cancelled, .failed:
                break
            @unknown default:
                debug("未知のケース", gesture.state)
            }
        }

        public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            true
        }

    }
    public func makeCoordinator() -> Coordinator {
        Coordinator(touchDownCallback: touchDownCallBack, touchMovedCallBack: touchMovedCallBack, touchUpCallback: touchUpCallBack)
    }

    public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
        context.coordinator.touchDownCallback = self.touchDownCallBack
        context.coordinator.touchMovedCallBack = self.touchMovedCallBack
        context.coordinator.touchUpCallback = self.touchUpCallBack
    }
}

fileprivate final class SingleScrollAndLongpressGestureRecognizer: UIGestureRecognizer {
    private var startLocation: CGPoint = .zero

    private var _distance: CGFloat = .zero
    var distance: CGFloat {
        get {
            let value = _distance
            _distance = .zero
            return value
        }
        set {
            self._distance = newValue
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .possible {
            self.startLocation = touches.first?.location(in: nil) ?? .zero
            self.state = .began
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .cancelled
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .changed
        let location = touches.first?.location(in: nil) ?? .zero
        let dx = startLocation.x - location.x
        let dy = startLocation.y - location.y
        self.distance = sqrt(dx * dx + dy * dy)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .ended
        let location = touches.first?.location(in: nil) ?? .zero
        let dx = startLocation.x - location.x
        let dy = startLocation.y - location.y
        self.distance = sqrt(dx * dx + dy * dy)
        self.startLocation = .zero
    }
}
