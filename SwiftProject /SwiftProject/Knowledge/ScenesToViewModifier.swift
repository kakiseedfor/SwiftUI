//
//  ScenesToViewModifier.swift
//  SwiftProject
//
//  Created by kaki Yen on 2021/12/28.
//

import SwiftUI

extension View {
    func readSize(_ size: Binding<CGSize>) -> some View {
        modifier(ViewModifiers(size: size))
    }
    
    func readScrollOffset(_ scrollOffset: Binding<CGRect>) -> some View {
        coordinateSpace(name: ScrollViewModifiers.nameSpace)
            .modifier(ScrollViewModifiers(scrollOffset: scrollOffset))
    }
    
    func colorFromHex(_ hex: String) -> some View {
        colorFromHex(Int(hex) ?? 0x000000)
    }
    
    func colorFromHex(_ hex: Int) -> some View {
        Color(.sRGB,
              red: Double((hex & 0xFF0000) >> 16) / 255.0,
              green: Double((hex & 0xFF00) >> 8) / 255.0,
              blue: Double(hex & 0xFF) / 255.0,
              opacity: 1.0)
    }
}

private struct ViewModifiers: ViewModifier {
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

struct ScrollViewModifiers: ViewModifier {
    @Binding var scrollOffset: CGRect
    static var nameSpace = "SCROLLVIEW"
    
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
