//
//  ResizingRect.swift
//  SwiftUI-Playground
//
//  Created by β α on 2021/03/11.
//

import Foundation
import SwiftUI

struct ResizingRect: View {
    @State private var top_left_edge: CGPoint = .zero
    @State private var initial_top_left_edge: CGPoint = .zero
    @State private var bottom_right_edge: CGPoint
    @State private var initial_bottom_right_edge: CGPoint

    private let lineWidth: CGFloat = 6
    private let edgeRatio: CGFloat = 1/5
    private let edgeColor: Color = .blue

    @State private var translation: CGPoint = .zero
    @State private var initialPosition: CGPoint = .zero

    @Binding private var width: CGFloat
    @Binding private var height: CGFloat
    @Binding private var position: CGPoint
    @Binding private var enabled: Bool

    private let initialSize: CGSize

    init(width: Binding<CGFloat>, height: Binding<CGFloat>, position: Binding<CGPoint>, initialSize: CGSize, enabled: Binding<Bool>){
        debug(initialSize)
        self._width = width
        self._height = height
        self._position = position
        self._bottom_right_edge = .init(initialValue: .init(x: width.wrappedValue, y: height.wrappedValue))
        self._initial_bottom_right_edge = .init(initialValue: .init(x: width.wrappedValue, y: height.wrappedValue))
        self.initialSize = initialSize
        self._enabled = enabled
    }

    func gesture(x: KeyPath<Self, Binding<CGFloat>>, y: KeyPath<Self, Binding<CGFloat>>, top: Bool = true, left: Bool = true) -> some Gesture {
        let rx: CGFloat = left ? 1 : -1
        let ry: CGFloat = top ? 1 : -1
        return DragGesture(minimumDistance: .zero, coordinateSpace: .global)
            .onChanged{value in
                translation.x = value.location.x - value.startLocation.x
                translation.y = value.location.y - value.startLocation.y
                self.width = abs(bottom_right_edge.x - top_left_edge.x - rx * translation.x)
                self.height = abs(bottom_right_edge.y - top_left_edge.y - ry * translation.y)
                position.x = (top_left_edge.x + bottom_right_edge.x + translation.x - initialSize.width) / 2
                position.y = (top_left_edge.y + bottom_right_edge.y + translation.y - initialSize.height) / 2
            }
            .onEnded{value in
                self[keyPath: x].wrappedValue += translation.x
                self[keyPath: y].wrappedValue += translation.y

                //left < right, top < bottomとなるように修正
                let (left, right) = (self.top_left_edge.x, self.bottom_right_edge.x)
                (self.top_left_edge.x, self.bottom_right_edge.x) = (min(left, right), max(left, right))
                let (top, bottom) = (self.top_left_edge.y, self.bottom_right_edge.y)
                (self.top_left_edge.y, self.bottom_right_edge.y) = (min(top, bottom), max(top, bottom))

                self.initialPosition = self.position
                self.initial_top_left_edge = self.top_left_edge
                self.initial_bottom_right_edge = self.bottom_right_edge

                translation = .zero
            }
    }

    func xGesture(x: KeyPath<Self, Binding<CGFloat>>, left: Bool = true) -> some Gesture {
        let r: CGFloat = left ? 1 : -1
        return DragGesture(minimumDistance: .zero, coordinateSpace: .global)
            .onChanged{value in
                translation.x = value.location.x - value.startLocation.x
                self.width = abs(bottom_right_edge.x - top_left_edge.x - r * translation.x)
                position.x = (top_left_edge.x + bottom_right_edge.x + translation.x - initialSize.width) / 2
            }
            .onEnded{value in
                self[keyPath: x].wrappedValue += translation.x
                //left < right, top < bottomとなるように修正
                let (left, right) = (self.top_left_edge.x, self.bottom_right_edge.x)
                (self.top_left_edge.x, self.bottom_right_edge.x) = (min(left, right), max(left, right))

                self.initialPosition = self.position
                self.initial_top_left_edge = self.top_left_edge
                self.initial_bottom_right_edge = self.bottom_right_edge
                translation = .zero
            }
    }

    func yGesture(y: KeyPath<Self, Binding<CGFloat>>, top: Bool = true) -> some Gesture {
        let r: CGFloat = top ? 1 : -1
        return DragGesture(minimumDistance: .zero, coordinateSpace: .global)
            .onChanged{value in
                translation.y = value.location.y - value.startLocation.y
                self.height = abs(bottom_right_edge.y - top_left_edge.y - r * translation.y)
                position.y = (top_left_edge.y + bottom_right_edge.y + translation.y - initialSize.height) / 2
            }
            .onEnded{value in
                self[keyPath: y].wrappedValue += translation.y
                //left < right, top < bottomとなるように修正
                let (top, bottom) = (self.top_left_edge.y, self.bottom_right_edge.y)
                (self.top_left_edge.y, self.bottom_right_edge.y) = (min(top, bottom), max(top, bottom))

                self.initialPosition = self.position
                self.initial_top_left_edge = self.top_left_edge
                self.initial_bottom_right_edge = self.bottom_right_edge

                translation = .zero
            }
    }

    var moveGesture: some Gesture {
        return DragGesture(minimumDistance: .zero, coordinateSpace: .global)
            .onChanged{value in
                let dx = value.location.x - value.startLocation.x
                let dy = value.location.y - value.startLocation.y
                withAnimation(.interactiveSpring()){
                    self.position.x = self.initialPosition.x + dx
                    self.position.y = self.initialPosition.y + dy
                    self.top_left_edge.x = self.initial_top_left_edge.x + dx
                    self.top_left_edge.y = self.initial_top_left_edge.y + dy
                    self.bottom_right_edge.x = self.initial_bottom_right_edge.x + dx
                    self.bottom_right_edge.y = self.initial_bottom_right_edge.y + dy
                }
            }
            .onEnded{value in
                self.initialPosition = self.position
                self.initial_top_left_edge = self.top_left_edge
                self.initial_bottom_right_edge = self.bottom_right_edge
            }
    }

    var body: some View {
        ZStack{
            /*
            Path{path in
                path.move(to: CGPoint(x: 0, y: height * edgeRatio))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: width * edgeRatio, y: 0))
            }.stroke(edgeColor, lineWidth: lineWidth)
            .gesture(gesture(x: \.$top_left_edge.x, y: \.$top_left_edge.y))
            Path{path in
                path.move(to: CGPoint(x: width, y: height * edgeRatio))
                path.addLine(to: CGPoint(x: width, y: 0))
                path.addLine(to: CGPoint(x: width * (1-edgeRatio), y: 0))
            }.stroke(edgeColor, lineWidth: lineWidth)
            .gesture(gesture(x: \.$bottom_right_edge.x, y: \.$top_left_edge.y, left: false))
            Path{path in
                path.move(to: CGPoint(x: 0, y: height * (1-edgeRatio)))
                path.addLine(to: CGPoint(x: 0, y: height))
                path.addLine(to: CGPoint(x: width * edgeRatio, y: height))
            }.stroke(edgeColor, lineWidth: lineWidth)
            .gesture(gesture(x: \.$top_left_edge.x, y: \.$bottom_right_edge.y, top: false))
            Path{path in
                path.move(to: CGPoint(x: width, y: height * (1-edgeRatio)))
                path.addLine(to: CGPoint(x: width, y: height))
                path.addLine(to: CGPoint(x: width * (1-edgeRatio), y: height))
            }.stroke(edgeColor, lineWidth: lineWidth)
            .gesture(gesture(x: \.$bottom_right_edge.x, y: \.$bottom_right_edge.y, top: false, left: false))
            */
            Path{path in
                for i in 0..<4{
                    let x = width / 24 * CGFloat(i)
                    let ratio = (1 - CGFloat(i) / 4) * 0.8
                    path.move(to: CGPoint(x: x, y: height / 2 - height * edgeRatio * ratio))
                    path.addLine(to: CGPoint(x: x, y: height / 2 + height * edgeRatio * ratio))
                }
            }.stroke(Color.white, lineWidth: 3)
            .gesture(xGesture(x: \.$top_left_edge.x, left: true))
            /*
            Path{path in
                for i in 0..<4{
                    let y = height / 24 * CGFloat(i)
                    let ratio = (1 - CGFloat(i) / 4) * 0.8
                    path.move(to: CGPoint(x: width / 2 - width * edgeRatio * ratio, y: y))
                    path.addLine(to: CGPoint(x: width / 2 + width * edgeRatio * ratio, y: y))
                }
            }.stroke(Color.white, lineWidth: 3)
            .gesture(yGesture(y: \.$top_left_edge.y, top: true))
            */
            Path{path in
                for i in 0..<4{
                    let x = width - width / 24 * CGFloat(i)
                    let ratio = (1 - CGFloat(i) / 4) * 0.8
                    path.move(to: CGPoint(x: x, y: height / 2 - height * edgeRatio * ratio))
                    path.addLine(to: CGPoint(x: x, y: height / 2 + height * edgeRatio * ratio))
                }
            }.stroke(Color.white, lineWidth: 3)
            .gesture(xGesture(x: \.$bottom_right_edge.x, left: false))
            /*
            Path{path in
                for i in 0..<4{
                    let y = height - height / 24 * CGFloat(i)
                    let ratio = (1 - CGFloat(i) / 4) * 0.8
                    path.move(to: CGPoint(x: width / 2 - width * edgeRatio * ratio, y: y))
                    path.addLine(to: CGPoint(x: width / 2 + width * edgeRatio * ratio, y: y))
                }
            }.stroke(Color.white, lineWidth: 3)
            .gesture(yGesture(y: \.$bottom_right_edge.y, top: false))
            */
            HStack{
                let cur = min(width, height) * 0.22
                let max = min(initialSize.width, initialSize.height) * 0.22
                let r = min(cur, max)
                Circle()
                    .fill(Color.blue)
                    .frame(width: r, height: r)
                    .overlay(
                        Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                            .foregroundColor(.white)
                            .font(Font.system(size: r*0.5))
                    )
                    .gesture(moveGesture)
                Button{
                    withAnimation(.interactiveSpring()){
                        self.position = .zero
                        self.width = initialSize.width
                        self.height = initialSize.height
                    }
                    self.top_left_edge = .zero
                    self.bottom_right_edge = .init(x: initialSize.width, y: initialSize.height)
                    self.initial_top_left_edge = .zero
                    self.initial_bottom_right_edge = .init(x: initialSize.width, y: initialSize.height)
                    self.translation = .zero
                    self.initialPosition = .zero

                }label: {
                    Circle()
                        .fill(Color.red)
                        .frame(width: r, height: r)
                        .overlay(
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundColor(.white)
                                .font(Font.system(size: r*0.5))
                        )
                }
                Button{
                    self.enabled = false
                }label: {
                    Circle()
                        .fill(Color.red)
                        .frame(width: r, height: r)
                        .overlay(
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .font(Font.system(size: r*0.5))
                        )
                }

            }
        }
    }
}

struct ResizingBindingFrame: ViewModifier {
    private let initialSize: CGSize
    @Binding private var position: CGPoint
    @Binding private var width: CGFloat
    @Binding private var height: CGFloat
    @Binding private var enabled: Bool

    init(width: Binding<CGFloat>, height: Binding<CGFloat>, position: Binding<CGPoint>, initialSize: CGSize, enabled: Binding<Bool>){
        self.initialSize = initialSize
        self._width = width
        self._height = height
        self._position = position
        self._enabled = enabled
    }

    @ViewBuilder func body(content: Content) -> some View {
        if enabled{
            ZStack{
                content
                Rectangle()
                    .fill(Color.black.opacity(0.2))
                    .frame(width: width, height: height)
            }
            .disabled(true)
            .overlay(ResizingRect(width: $width, height: $height, position: $position, initialSize: initialSize, enabled: $enabled))
            .frame(width: width, height: height)
            .offset(x: position.x, y: position.y)

        }else{
            content
                .frame(width: width, height: height)
                .offset(x: position.x, y: position.y)
        }
    }
}

extension View {
    func resizingFrame(width: Binding<CGFloat>, height: Binding<CGFloat>, position: Binding<CGPoint>, initialSize: CGSize, enabled: Binding<Bool>) -> some View {
        self.modifier(ResizingBindingFrame(width: width, height: height, position: position, initialSize: initialSize, enabled: enabled))
    }
}
