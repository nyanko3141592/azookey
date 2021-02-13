//
//  ThemeEditView.swift
//  KanaKanjier
//
//  Created by β α on 2021/02/07.
//  Copyright © 2021 DevEn3. All rights reserved.
//

import Foundation
import SwiftUI
import PhotosUI

struct ThemeEditView: View {
    @State private var theme = ThemeData.base
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var selectFontRowValue: Double = 4
    @Binding private var manager: ThemeIndexManager

    @State private var trimmedImage: UIImage? = nil
    @State private var isTrimmingViewPresented = false
    @State private var pickedImage: UIImage? = nil
    @State private var isSheetPresented = false
    @State private var viewType = ViewType.editor

    private enum ViewType{
        case editor
        case themeShareView
    }

    private let title: String

    init(index: Int?, manager: Binding<ThemeIndexManager>){
        VariableStates.shared.keyboardLayout = SettingData.shared.keyboardLayout(for: .japaneseKeyboardLayout)

        self._manager = manager
        if let index = index{
            do{
                var theme = try manager.wrappedValue.theme(at: index)
                theme.id = index
                self._theme = State(initialValue: theme)
            } catch {
                debug(error)
            }
            self.title = "着せ替えを編集"
        }else{
            self.title = "着せ替えを作成"
        }
        self.theme.suggestKeyFillColor = .color(Color.init(white: 1))
    }

    @State private var normalKeyColor = ThemeData.base.normalKeyFillColor.color
    @State private var specialKeyColor = ThemeData.base.specialKeyFillColor.color
    @State private var backGroundColor = ThemeData.base.backgroundColor.color
    @State private var borderColor = ThemeData.base.borderColor.color
    @State private var keyLabelColor = ThemeData.base.textColor.color
    @State private var resultTextColor = ThemeData.base.resultTextColor.color

    private var shareImage = ShareImage()

    // PHPickerの設定
    private var config: PHPickerConfiguration {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images
        config.selectionLimit = 1
        return config
    }

    @State private var refresh = false

    var body: some View {
        switch viewType{
        case .editor:
            VStack{
                Form{
                    Section(header: Text("背景")){
                        if let _ = trimmedImage{
                            Button{
                                self.isSheetPresented = true
                            } label: {
                                HStack{
                                    Text("\(systemImage: "photo")画像を選び直す")
                                }
                            }
                            Button{
                                pickedImage = nil
                                trimmedImage = nil
                            } label: {
                                HStack{
                                    Text("画像を削除")
                                        .foregroundColor(.red)
                                }
                            }
                        } else {
                            Button{
                                self.isSheetPresented = true
                            } label: {
                                HStack{
                                    Text("\(systemImage: "photo")画像を選ぶ")
                                }
                            }
                            ColorPicker("背景の色", selection: $backGroundColor)
                        }
                    }
                    Section(header: Text("文字")){
                        HStack{
                            Text("文字の太さ")
                            Slider(value: $selectFontRowValue, in: 1...9.9){editing in
                                theme.textFont = ThemeFontWeight.init(rawValue: Int(selectFontRowValue)) ?? .regular
                            }
                        }
                    }

                    Section(header: Text("変換候補")){
                        ColorPicker("変換候補の文字の色", selection: $resultTextColor)
                    }

                    Section(header: Text("キー")){
                        ColorPicker("キーの文字の色", selection: $keyLabelColor)

                        ColorPicker("通常キーの背景色", selection: $normalKeyColor)
                        ColorPicker("特殊キーの背景色", selection: $specialKeyColor)

                        ColorPicker("枠線の色", selection: $borderColor)
                        HStack{
                            Text("枠線の太さ")
                            Slider(value: $theme.borderWidth, in: 0...10)
                        }
                    }

                    Section{
                        Button{
                            self.pickedImage = nil
                            self.trimmedImage = nil
                            self.normalKeyColor = ThemeData.base.normalKeyFillColor.color
                            self.specialKeyColor = ThemeData.base.specialKeyFillColor.color
                            self.backGroundColor = ThemeData.base.backgroundColor.color
                            self.borderColor = ThemeData.base.borderColor.color
                            self.keyLabelColor = ThemeData.base.textColor.color
                            self.resultTextColor = ThemeData.base.resultTextColor.color
                            self.selectFontRowValue = 4
                            self.theme = ThemeData.base
                        } label: {
                            Text("リセットする")
                                .foregroundColor(.red)
                        }
                    }

                }
                KeyboardPreview(theme: self.theme)
                NavigationLink(destination: Group{
                    if let image = pickedImage{
                        TrimmingView(
                            uiImage: image,
                            resultImage: $trimmedImage,
                            maxSize: CGSize(width: 1280, height: 720),
                            aspectRatio: CGSize(width: Design.shared.keyboardWidth, height: Design.shared.keyboardScreenHeight)
                        )}
                }, isActive: $isTrimmingViewPresented){
                    EmptyView()
                }

            }
            .background(viewBackgroundColor)
            .onChange(of: pickedImage){value in
                if let _ = value{
                    self.isTrimmingViewPresented = true
                }else{
                    self.theme.picture = .none
                }
            }
            .onChange(of: trimmedImage){value in
                if let value = value{
                    self.theme.picture = .uiImage(value)
                    backGroundColor = Color.white.opacity(0)
                    self.theme.backgroundColor = .color(Color.white.opacity(0))
                }else{
                    self.theme.picture = .none
                }
            }
            .onChange(of: normalKeyColor){value in
                if let normalKeyColor = ColorTools.rgba(value, process: {r, g, b, opacity in
                    return Color(red: r, green: g, blue: b, opacity: max(0.001, opacity))
                }){
                    self.theme.normalKeyFillColor = .color(normalKeyColor)
                }
                if let pushedKeyColor = ColorTools.hsv(value, process: {h, s, v, opacity in
                    let base = (floor(v-0.5) + 0.5)*2
                    return Color(hue: h, saturation: s, brightness: v - base * 0.1, opacity: max(0.05, sqrt(opacity)))
                }){
                    self.theme.pushedKeyFillColor = .color(pushedKeyColor)
                }
            }
            .onChange(of: specialKeyColor){value in
                if let specialKeyColor = ColorTools.rgba(value, process: {r, g, b, opacity in
                    return Color(red: r, green: g, blue: b, opacity: max(0.005, opacity))
                }){
                    self.theme.specialKeyFillColor = .color(specialKeyColor)
                }
            }
            .onChange(of: backGroundColor){value in
                self.theme.backgroundColor = .color(value)
            }
            .onChange(of: borderColor){value in
                self.theme.borderColor = .color(value)
            }
            .onChange(of: keyLabelColor){value in
                self.theme.textColor = .color(value)
            }
            .onChange(of: resultTextColor){value in
                self.theme.resultTextColor = .color(value)
            }
            .sheet(isPresented: $isSheetPresented){
                PhotoPicker(configuration: self.config,
                            pickerResult: $pickedImage,
                            isPresented: $isSheetPresented)
            }
            .navigationBarTitle(Text(self.title), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button{
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("キャンセル")
                },
                trailing: Button{
                    do{
                        try self.save()
                    }catch{
                        debug(error)
                    }
                    //presentationMode.wrappedValue.dismiss()
                    self.viewType = .themeShareView
                }label: {
                    Text("完了")
                })
        case .themeShareView:
            ThemeShareView(theme: self.theme, shareImage: shareImage){
                presentationMode.wrappedValue.dismiss()
            }
            .navigationBarTitle(Text("完了"), displayMode: .inline)
            .navigationBarItems(leading: EmptyView(), trailing: EmptyView())
        }
    }

    private var viewBackgroundColor: Color {
        switch colorScheme{
        case .light:
            return Color.systemGray6
        case .dark:
            return Color.black
        @unknown default:
            return Color.systemGray6
        }
    }

    private func save() throws {
        //テーマを保存する
        let id = try manager.saveTheme(theme: self.theme)
        self.theme.id = id
        manager.select(at: id)
    }
}
