//
//  ThemeTab.swift
//  MainApp
//
//  Created by ensan on 2021/02/04.
//  Copyright © 2021 ensan. All rights reserved.
//

import AzooKeyUtils
import KeyboardViews
import SwiftUI
import SwiftUIUtils
import SwiftUtils

struct ThemeTabView: View {
    @Namespace private var namespace
    @EnvironmentObject private var appStates: MainAppStates
    @State private var manager = ThemeIndexManager.load()

    @State private var editViewIndex: Int?
    @State private var editViewEnabled = false

    private func theme(at index: Int) -> AzooKeyTheme? {
        do {
            return try manager.theme(at: index)
        } catch {
            debug(error)
            return nil
        }
    }

    @MainActor
    private func circle(geometry: GeometryProxy, systemName: String, color: Color) -> some View {
        let width = min(min(geometry.size.width / 1.5, 180), geometry.size.height / 2.5) // 高さに2つ入るサイズを超えないように設定
        return Circle()
            .fill(color)
            .frame(width: width, height: width)
            .overlay(
                Image(systemName: systemName)
                    .font(Font.system(size: width / 2).weight(.bold))
                    .foregroundStyle(.white)
            )
    }

    @MainActor
    private func selectButton(_ index: Int) -> some View {
        GeometryReader {geometry in
            if manager.selectedIndex == manager.selectedIndexInDarkMode {
                CenterAlignedView {
                    VStack {
                        Spacer()
                        circle(geometry: geometry, systemName: "checkmark", color: manager.selectedIndex == index ? Color.blue : Color.systemGray4)
                            .matchedGeometryEffect(id: "ThemeLightButton\(index)", in: namespace)
                            .matchedGeometryEffect(id: "ThemeDarkButton\(index)", in: namespace)
                        Spacer()
                    }
                    .onTapGesture {
                        manager.select(at: index)
                    }
                }
            } else {
                CenterAlignedView {
                    VStack {
                        Spacer()
                        circle(geometry: geometry, systemName: "sun.max.fill", color: manager.selectedIndex == index ? Color.blue : Color.systemGray4)
                            .matchedGeometryEffect(id: "ThemeLightButton\(index)", in: namespace)
                            .onTapGesture {
                                manager.selectForLightMode(at: index)
                            }
                        Spacer(minLength: 10)
                        circle(geometry: geometry, systemName: "moon.fill", color: manager.selectedIndexInDarkMode == index ? Color.blue : Color.systemGray4)
                            .matchedGeometryEffect(id: "ThemeDarkButton\(index)", in: namespace)
                            .onTapGesture {
                                manager.selectForDarkMode(at: index)
                            }
                        Spacer()
                    }
                }
            }
        }
        .animation(.easeIn(duration: 0.2), value: manager.selectedIndex == manager.selectedIndexInDarkMode)
    }

    private var tab: Tab.ExistentialTab {
        switch appStates.japaneseLayout {
        case .flick:
            return .flick_hira
        case .qwerty:
            return .qwerty_hira
        case let .custard(identifier):
            return .custard((try? CustardManager.load().custard(identifier: identifier)) ?? .errorMessage)
        }
    }

    @MainActor @ViewBuilder
    private var listSection: some View {
        let tab = tab
        ForEach(manager.indices.reversed(), id: \.self) { index in
            if let theme = theme(at: index) {
                HStack {
                    KeyboardPreview(theme: theme, scale: 0.6, defaultTab: tab)
                        .disabled(true)
                    selectButton(index)
                    if editViewIndex == index {
                        NavigationLink(destination: ThemeEditView(index: editViewIndex, manager: $manager), isActive: $editViewEnabled) {
                            EmptyView()
                        }.frame(maxWidth: 1)
                    }
                }
                .contextMenu {
                    if self.manager.selectedIndex == self.manager.selectedIndexInDarkMode {
                        Button {
                            manager.selectForLightMode(at: index)
                        } label: {
                            Image(systemName: "sun.max.fill")
                            Text("ライトモードで使用")
                        }
                        Button {
                            manager.selectForDarkMode(at: index)
                        } label: {
                            Image(systemName: "moon.fill")
                            Text("ダークモードで使用")
                        }
                    }
                    Button {
                        editViewIndex = index
                        editViewEnabled = true
                    } label: {
                        Image(systemName: "pencil")
                        Text("編集する")
                    }.disabled(index == 0)
                    Button(role: .destructive) {
                        manager.remove(index: index)
                    } label: {
                        Label("削除する", systemImage: "trash")
                            .foregroundStyle(.red)
                    }
                    .disabled(index == 0)
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("作る")) {
                    HStack {
                        Button("着せ替えを作成") {
                            editViewIndex = nil
                            editViewEnabled = true
                        }
                        .foregroundStyle(.primary)
                        if editViewIndex == nil {
                            NavigationLink(destination: ThemeEditView(index: editViewIndex, manager: $manager), isActive: $editViewEnabled) {
                                EmptyView()
                            }
                        }
                    }
                }
                Section(header: Text("選ぶ")) {
                    listSection
                }
            }
            .navigationBarTitle(Text("着せ替え"), displayMode: .large)
        }
        .navigationViewStyle(.stack)
    }
}
