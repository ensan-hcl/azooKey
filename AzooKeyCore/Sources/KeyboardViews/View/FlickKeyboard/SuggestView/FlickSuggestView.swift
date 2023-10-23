//
//  FlickSuggestView.swift
//  KeyboardViews
//
//  Created by ensan on 2020/04/10.
//  Copyright © 2020 ensan. All rights reserved.
//

import CustardKit
import Foundation
import SwiftUI

@MainActor
struct FlickSuggestView<Extension: ApplicationSpecificKeyboardViewExtension>: View {
    @EnvironmentObject private var variableStates: VariableStates
    @Environment(Extension.Theme.self) private var theme
    @Environment(\.colorScheme) private var colorScheme
    private let model: any FlickKeyModelProtocol
    private let suggestType: FlickSuggestType
    private let tabDesign: TabDependentDesign
    private let size: CGSize

    init(model: any FlickKeyModelProtocol, tabDesign: TabDependentDesign, size: CGSize, suggestType: FlickSuggestType) {
        self.model = model
        self.tabDesign = tabDesign
        self.size = size
        self.suggestType = suggestType
    }

    @ViewBuilder
    private func keyLabel(for direction: FlickDirection, textColor: Color? = nil, textSize: Design.Fonts.LabelFontSizeStrategy = .xlarge) -> some View {
        if let model = self.model.flickKeys(variableStates: variableStates)[direction] {
            KeyLabel<Extension>(model.labelType, width: size.width, textSize: textSize, textColor: textColor)
        } else {
            EmptyView()
        }
    }
    private func getSuggestView(direction: FlickDirection, isHidden: Bool, isPointed: Bool) -> some View {
        // ポインテッド時の色を定義
        var pointedColor: Color {
            if colorScheme == .light || theme != Extension.ThemeExtension.default(layout: .flick) {
                .white
            } else {
                .systemGray4
            }
        }
        // ポインテッドでない時の色を定義
        var unpointedColor: Color {
            theme != Extension.ThemeExtension.default(layout: .flick) ? .white : .systemGray5
        }
        var shadowColor: Color {
            if colorScheme == .dark || theme != Extension.ThemeExtension.default(layout: .flick) {
                .clear
            } else {
                .gray
            }
        }
        // 現在の状態に基づいて色を選択
        let color = isPointed ? pointedColor : unpointedColor
        let shape: any Shape
        let paddings: [CGFloat]
        let sizeTimes: [CGFloat]

        switch direction {
        case .top:
            shape = RoundedPentagonTop()
            paddings = [0, 0, 0.3, 0]
            sizeTimes = [1.2, 1.5]
        case .left:
            shape = RoundedPentagonLeft()
            paddings = [0, 0, 0, 0.3]
            sizeTimes = [1.5, 1.2]
        case .right:
            shape = RoundedPentagonRight()
            paddings = [0, 0.3, 0, 0]
            sizeTimes = [1.5, 1.2]
        case .bottom:
            shape = RoundedPentagonBottom()
            paddings = [0.3, 0, 0, 0]
            sizeTimes = [1.2, 1.5]
        }

        return AnyView(shape.strokeAndFill(fillContent: color, strokeContent: theme.borderColor.color, lineWidth: theme.borderWidth))
            .frame(width: size.width * sizeTimes[0], height: size.height * sizeTimes[1])
            .shadow(color: shadowColor, radius: 10, y: 5)
            .overlay {
                self.keyLabel(for: direction, textColor: theme.suggestLabelTextColor?.color)
                    .padding(EdgeInsets(
                        top: size.height * paddings[0],
                        leading: size.width * paddings[1],
                        bottom: size.height * paddings[2],
                        trailing: size.width * paddings[3]
                    ))
            }
            .allowsHitTesting(false)
            .opacity(isHidden ? 0 : 1)
    }
    /// その方向にViewの表示が必要な場合はサジェストのViewを、不要な場合は透明なViewを返す。
    @ViewBuilder
    private func getPointedSuggestViewIfNecessary(direction: FlickDirection, targetDirection: FlickDirection) -> some View {
        if targetDirection == direction {
            getSuggestView(direction: direction, isHidden: false, isPointed: true)
        } else {
            getSuggestView(direction: direction, isHidden: true, isPointed: false)
        }
    }

    @ViewBuilder
    private func roundedRectangleForAllSuggest(cornerRadius: CGFloat, direction: FlickDirection, sizeDiff: CGFloat = 2) -> some View {
        var color: Color {
            if colorScheme == .light || theme != Extension.ThemeExtension.default(layout: .flick) {
                .white
            } else {
                .systemGray4
            }
        }
        let widthDiff: CGFloat = switch direction {
        case .top, .bottom: tabDesign.horizontalSpacing
        case .left, .right: tabDesign.horizontalSpacing / 2 + cornerRadius + sizeDiff
        }
        let heightDiff: CGFloat = switch direction {
        case .top, .bottom: tabDesign.verticalSpacing / 2 + cornerRadius + sizeDiff
        case .left, .right: tabDesign.verticalSpacing
        }
        let isHidden = !self.model.isFlickAble(to: direction, variableStates: variableStates)
        RoundedRectangle(cornerRadius: cornerRadius)
            .strokeAndFill(fillContent: color, strokeContent: theme.borderColor.color, lineWidth: theme.borderWidth)
            .frame(width: size.width + widthDiff, height: size.height + heightDiff)
            .overlay {
                let offsetX: CGFloat = switch direction {
                case .bottom, .top: 0
                case .left: -cornerRadius + sizeDiff / 2
                case .right: cornerRadius - sizeDiff / 2
                }
                let offsetY: CGFloat = switch direction {
                case .left, .right: 0
                case .top: -cornerRadius + sizeDiff / 2
                case .bottom: cornerRadius - sizeDiff / 2
                }
                self.keyLabel(for: direction, textColor: theme.suggestLabelTextColor?.color)
                    .offset(x: offsetX, y: offsetY)
            }
            .opacity(isHidden ? 0 : 1)
    }

    var body: some View {
        switch self.suggestType {
        case .all:
            let cornerRadius = 5.0
            VStack(spacing: 0) {
                roundedRectangleForAllSuggest(cornerRadius: cornerRadius, direction: .top)
                    .offset(y: cornerRadius)
                    .zIndex(1)
                HStack(spacing: 0) {
                    roundedRectangleForAllSuggest(cornerRadius: cornerRadius, direction: .left)
                        .offset(x: cornerRadius)
                        .zIndex(1)
                    Rectangle()
                        .strokeAndFill(
                            fillContent: .blue,
                            strokeContent: .gray,
                            lineWidth: 0.5
                        )
                        .frame(
                            width: size.width + tabDesign.horizontalSpacing,
                            height: size.height + tabDesign.verticalSpacing
                        )
                        .zIndex(2)
                        .overlay {
                            (self.model.label(width: size.width, states: variableStates) as KeyLabel<Extension>)
                                .textColor(.white)
                                .textSize(.xlarge)
                        }
                    roundedRectangleForAllSuggest(cornerRadius: cornerRadius, direction: .right)
                        .offset(x: -cornerRadius)
                        .zIndex(1)
                }
                .zIndex(2)
                .frame(width: size.width + tabDesign.horizontalSpacing, height: size.height + tabDesign.verticalSpacing)
                roundedRectangleForAllSuggest(cornerRadius: cornerRadius, direction: .bottom)
                    .offset(y: -cornerRadius)
                    .zIndex(1)
            }
            .compositingGroup()
            .shadow(color: .gray, radius: 3)
            .frame(width: size.width, height: size.height)
            .allowsHitTesting(false)
        case .flick(let targetDirection):
            VStack(spacing: tabDesign.verticalSpacing) {
                self.getPointedSuggestViewIfNecessary(direction: .top, targetDirection: targetDirection)
                    .offset(y: size.height / 2)
                    .zIndex(1)
                HStack(spacing: tabDesign.horizontalSpacing) {
                    self.getPointedSuggestViewIfNecessary(direction: .left, targetDirection: targetDirection)
                        .offset(x: size.width / 2)
                        .zIndex(1)
                    RoundedRectangle(cornerRadius: 5.0)
                        .strokeAndFill(
                            fillContent: theme.specialKeyFillColor.color,
                            strokeContent: theme.borderColor.color,
                            lineWidth: theme.borderWidth
                        )
                        .frame(width: size.width, height: size.height)
                        .zIndex(0)
                    self.getPointedSuggestViewIfNecessary(direction: .right, targetDirection: targetDirection)
                        .offset(x: -size.width / 2)
                        .zIndex(1)
                }
                .frame(width: size.width, height: size.height)
                self.getPointedSuggestViewIfNecessary(direction: .bottom, targetDirection: targetDirection)
                    .offset(y: -size.height / 2)
                    .zIndex(1)
            }
            .frame(width: size.width, height: size.height)
            .allowsHitTesting(false)
        }
    }

}

private extension Path {
    mutating func addRoundedPentagon(using points: [CGPoint], cornerRadius: CGFloat = 5) {
        guard points.count == 5 else { return }

        for i in 0 ..< 5 {
            let currentPoint = points[i]
            let nextPoint = points[(i + 1) % 5]
            let prevPoint = i == 0 ? points.last! : points[i - 1]

            let directionFromPrev = CGVector(dx: currentPoint.x - prevPoint.x, dy: currentPoint.y - prevPoint.y).normalized
            let directionToNext = CGVector(dx: nextPoint.x - currentPoint.x, dy: nextPoint.y - currentPoint.y).normalized

            let offsetFromCurrent1 = CGVector(dx: directionFromPrev.dx * cornerRadius, dy: directionFromPrev.dy * cornerRadius)
            let offsetFromCurrent2 = CGVector(dx: directionToNext.dx * cornerRadius, dy: directionToNext.dy * cornerRadius)

            if i == 0 {
                move(to: CGPoint(x: currentPoint.x - offsetFromCurrent1.dx, y: currentPoint.y - offsetFromCurrent1.dy))
            } else {
                addLine(to: CGPoint(x: currentPoint.x - offsetFromCurrent1.dx, y: currentPoint.y - offsetFromCurrent1.dy))
            }

            addQuadCurve(to: CGPoint(x: currentPoint.x + offsetFromCurrent2.dx, y: currentPoint.y + offsetFromCurrent2.dy), control: currentPoint)
        }

        closeSubpath()
    }
}

private extension CGVector {
    var length: CGFloat {
        sqrt(dx * dx + dy * dy)
    }

    var normalized: CGVector {
        CGVector(dx: dx / length, dy: dy / length)
    }
}

private struct RoundedPentagonBottom: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let points = [
            CGPoint(x: rect.width / 2, y: 0),
            CGPoint(x: 0, y: rect.height / 3),
            CGPoint(x: 0, y: rect.height),
            CGPoint(x: rect.width, y: rect.height),
            CGPoint(x: rect.width, y: rect.height / 3)
        ]
        path.addRoundedPentagon(using: points)
        return path
    }
}

private struct RoundedPentagonLeft: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let points = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: rect.width * 2 / 3, y: 0),
            CGPoint(x: rect.width, y: rect.height / 2),
            CGPoint(x: rect.width * 2 / 3, y: rect.height),
            CGPoint(x: 0, y: rect.height)
        ]
        path.addRoundedPentagon(using: points)
        return path
    }
}

private struct RoundedPentagonRight: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let points = [
            CGPoint(x: rect.width / 3, y: 0),
            CGPoint(x: 0, y: rect.height / 2),
            CGPoint(x: rect.width / 3, y: rect.height),
            CGPoint(x: rect.width, y: rect.height),
            CGPoint(x: rect.width, y: 0)
        ]
        path.addRoundedPentagon(using: points)
        return path
    }
}

private struct RoundedPentagonTop: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let points = [
            CGPoint(x: rect.width / 2, y: rect.height),
            CGPoint(x: rect.width, y: 2 * rect.height / 3),
            CGPoint(x: rect.width, y: 0),
            CGPoint(x: 0, y: 0),
            CGPoint(x: 0, y: 2 * rect.height / 3)
        ]
        path.addRoundedPentagon(using: points)
        return path
    }
}
