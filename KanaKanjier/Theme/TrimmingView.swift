//
//  TrimmingView.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/10.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI

private final class TrimmingViewModel{
    var initialScale: CGFloat = 1
    var frameSize: CGSize = .zero
}

struct TrimmingView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    let maxSize: CGSize
    let aspectRatio: CGSize

    @State private var magnify: CGFloat = 1
    @State private var lastMagnify: CGFloat = 1
    @State private var angle: Angle = .degrees(.zero)
    @State private var lastAngle: Angle = .degrees(.zero)
    @State private var position: CGPoint = .zero
    @State private var lastPosition: CGPoint = .zero

    private let cgImage: CGImage?
    private let imageSize: CGSize
    private let imageAspectRatio: CGFloat

    @Binding private var resultImage: UIImage?

    private let model = TrimmingViewModel()

    init(uiImage: UIImage, resultImage: Binding<UIImage?>, maxSize: CGSize, aspectRatio: CGSize){
        self.maxSize = maxSize
        self.aspectRatio = aspectRatio
        self._resultImage = resultImage
        self.cgImage = uiImage.fixedOrientation()?.cgImage
        self.imageSize = cgImage.flatMap{CGSize(width: $0.width, height: $0.height)} ?? CGSize(width: uiImage.size.width * uiImage.scale, height: uiImage.size.height * uiImage.scale)
        self.imageAspectRatio = imageSize.width / imageSize.height
    }

    func fitratio(screenSize: CGSize) -> CGFloat {
        if self.imageAspectRatio < screenSize.width / screenSize.height {
            return screenSize.height / imageSize.height
        }else{
            return screenSize.width / imageSize.width
        }
    }

    func frameSize(screenSize: CGSize) -> CGSize {
        let ratio: CGFloat = 1
        let height = screenSize.width * aspectRatio.height / aspectRatio.width
        if height > screenSize.height{
            let width = screenSize.height * aspectRatio.width / aspectRatio.height
            model.frameSize = CGSize(width: width * ratio, height: screenSize.height * ratio)
        }else{
            model.frameSize = CGSize(width: screenSize.width * ratio, height: height * ratio)
        }

        if self.imageAspectRatio <= self.aspectRatio.width / self.aspectRatio.height{
            model.initialScale = model.frameSize.width / imageSize.width
        }else{
            model.initialScale = model.frameSize.height / imageSize.height
        }

        return model.frameSize
    }

    func updateResult() {
        guard let cgImage = self.cgImage else {
            return
        }
        let scale = model.initialScale * magnify
        let size = CGSize(
            width: model.frameSize.width / scale,
            height: model.frameSize.height / scale
        )
        let originPosition = CGPoint(
            x: imageSize.width / 2 - (size.width / 2 + position.x / scale),
            y: imageSize.height / 2 - (size.height / 2 + position.y / scale)
        )
        if let crop = cgImage.cropping(to: CGRect(origin: originPosition, size: size)),
           let result = UIImage(cgImage: crop).scaled(fit: self.maxSize) {
            self.resultImage = result
        }
    }

    var body: some View {
        VStack{[unowned cgImage] in
            ZStack{
                GeometryReader{geometry in
                    Color.black
                    let ratio = fitratio(screenSize: geometry.size) //scaledToFitによる縮小比
                    let size = frameSize(screenSize: geometry.size) //フレームのサイズ
                    if let cgImage = cgImage{
                            Group{
                                //画像の縦に対する横の長さが、フレームの縦に対する横の長さよりも小さい場合
                                if self.imageAspectRatio <= self.aspectRatio.width / self.aspectRatio.height{
                                    Image(uiImage: UIImage(cgImage: cgImage))
                                        .resizable()
                                        .scaledToFit()
                                        .scaleEffect(size.width / (imageSize.width * ratio))
                                }else{
                                    Image(uiImage: UIImage(cgImage: cgImage))
                                        .resizable()
                                        .scaledToFit()
                                        .scaleEffect(size.height / (imageSize.height * ratio))
                                }
                            }
                            .scaleEffect(self.magnify)
                            .rotationEffect(self.angle)
                            .position(x: self.position.x + geometry.size.width / 2, y: self.position.y + geometry.size.height / 2)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged{ v in
                                        let newValue = self.lastMagnify * v
                                        if 1 <= newValue && newValue <= 10{
                                            self.magnify = newValue
                                        }
                                    }
                                    .onEnded{ v in
                                        self.lastMagnify = self.magnify
                                    }
                            )
                            .simultaneousGesture(
                                DragGesture()
                                    .onChanged{ v in
                                        self.position = CGPoint(
                                            x: self.lastPosition.x + v.translation.width,
                                            y: self.lastPosition.y + v.translation.height
                                        )
                                    }
                                    .onEnded{ v in
                                        self.lastPosition = self.position
                                    }
                            )
                    }
                    Path{path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                        path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                        path.addLine(to: CGPoint(x: 0, y: 0))

                        let dx = geometry.size.width / 2
                        let dy = geometry.size.height / 2
                        path.move(to: CGPoint(x: -size.width / 2 + dx, y: -size.height / 2 + dy))
                        path.addLine(to: CGPoint(x: -size.width / 2 + dx, y: size.height / 2 + dy))
                        path.addLine(to: CGPoint(x: size.width / 2 + dx, y: size.height / 2 + dy))
                        path.addLine(to: CGPoint(x: size.width / 2 + dx, y: -size.height / 2 + dy))
                        path.addLine(to: CGPoint(x: -size.width / 2 + dx, y: -size.height / 2 + dy))
                    }.fill(Color.black.opacity(0.5)).allowsHitTesting(false)

                    Rectangle()
                        .stroke(Color.white, lineWidth: 1.5)
                        .frame(width: size.width, height: size.height)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
        }
        .onChange(of: magnify){value in
            validation(magnifyValue: value, positionValue: position)
        }
        .onChange(of: position){value in
            validation(magnifyValue: magnify, positionValue: value)
        }
        .navigationBarTitle(Text("画像をトリミング"), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(trailing: Button{
            updateResult()
            presentationMode.wrappedValue.dismiss()
        }label: {
            Text("完了")
        })

    }

    func validation(magnifyValue: CGFloat, positionValue: CGPoint){
        //最も基本的な状態
        let scale = model.initialScale * magnify

        var change_x: CGFloat? = nil
        var change_y: CGFloat? = nil

        //左のはみ出し
        if positionValue.x > (imageSize.width * scale - model.frameSize.width) / 2{
            change_x = (imageSize.width * scale - model.frameSize.width) / 2
        }
        //左のはみ出し
        if positionValue.y > (imageSize.height * scale - model.frameSize.height) / 2{
            change_y = (imageSize.height * scale - model.frameSize.height) / 2
        }

        //→のはみ出し
        if positionValue.x < (-imageSize.width * scale + model.frameSize.width) / 2{
            change_x = (-imageSize.width * scale + model.frameSize.width) / 2
        }
        //→のはみ出し
        if positionValue.y < (-imageSize.height * scale + model.frameSize.height) / 2{
            change_y = (-imageSize.height * scale + model.frameSize.height) / 2
        }
        if let x = change_x,
           let y = change_y{
            position = CGPoint(x: x, y: y)
        }else if let x = change_x{
            position.x = x
        }else if let y = change_y{
            position.y = y
        }

    }

}

extension UIImage {
    func fixedOrientation() -> UIImage? {
        if self.imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func scaled(fit maxSize: CGSize) -> UIImage? {
        if size.width < maxSize.width && size.height < maxSize.height{ return self }
        let r_w = size.width / maxSize.width
        let r_h = size.height / maxSize.height
        let r = max(r_w, r_h)
        let canvasSize = CGSize(width: size.width / r, height: size.height / r)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        self.draw(in: CGRect(origin: .zero, size: canvasSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


extension UIImage.Orientation: CustomStringConvertible {
    public var description: String {
        switch self{
        case .down: return "down"
        case .downMirrored: return "downMirrored"
        case .left: return "left"
        case .leftMirrored: return "leftMirrored"
        case .right: return "right"
        case .rightMirrored: return "rightMirrored"
        case .up: return "up"
        case .upMirrored: return "upMirrored"
        @unknown default: return "unknown"
        }
    }
}
