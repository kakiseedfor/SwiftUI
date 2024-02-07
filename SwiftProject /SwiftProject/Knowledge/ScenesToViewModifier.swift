//
//  ScenesToViewModifier.swift
//  SwiftProject
//
//  Created by kaki Yen on 2021/12/28.
//

import SwiftUI

extension View {
    func readSize(_ size: Binding<CGSize>) -> some View {
        modifier(ViewSizeModifiers(size: size))
    }
    
    func readScrollOffset(_ scrollOffset: Binding<CGRect>) -> some View {
        coordinateSpace(name: ScrollOffsetModifiers.nameSpace)
            .modifier(ScrollOffsetModifiers(scrollOffset: scrollOffset))
    }
    
    func colorFromHex(_ hex: String) -> Color {
        colorFromHex(Int(hex) ?? 0x000000)
    }
    
    func colorFromHex(_ hex: Int) -> Color {
        Color(.sRGB,
              red: Double((hex & 0xFF0000) >> 16) / 255.0,
              green: Double((hex & 0xFF00) >> 8) / 255.0,
              blue: Double(hex & 0xFF) / 255.0,
              opacity: 1.0)
    }
    
    func onceOnAppear(perform action: (() -> Void)? = nil) -> some View {
        modifier(ViewAppearModifiers(action ?? {}))
    }
}

private struct ViewSizeModifiers: ViewModifier {
    @Binding var size: CGSize
    
    init(size tmpSize: Binding<CGSize> = .constant(.zero)) {
        _size = tmpSize
    }
    
    func body(content: Content) -> some View {
        content.background {
            GeometryReader { geometryProxy in
                Color.clear.onAppear {
                    size = geometryProxy.size
                }
            }
        }
    }
}

private struct ViewAppearModifiers: ViewModifier {
    @State private var onceAppear: Bool = false
    @State var action: (() -> Void)
    
    init(_ action: @escaping () -> Void) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content.onAppear {
            if onceAppear {
                return
            }
            onceAppear = true
            
            action()
        }
    }
}

struct ScrollOffsetModifiers: ViewModifier {
    @Binding var scrollOffset: CGRect
    static var nameSpace = "SCROLLOFFSET"
    
    init(scrollOffset tmpScrollOffset: Binding<CGRect> = .constant(.zero)) {
        _scrollOffset = tmpScrollOffset
    }
    
    func body(content: Content) -> some View {
        content.background {
            GeometryReader { geometryProxy in
                readScrollOffset(geometryProxy)
            }
        }
    }
    
    func readScrollOffset(_ geometryProxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            scrollOffset = geometryProxy.frame(in: .named(Self.nameSpace))
        }
        return Color.clear
    }
}
