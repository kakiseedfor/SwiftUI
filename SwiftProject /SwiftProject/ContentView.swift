//
//  ContentView.swift
//  SwiftProject
//
//  Created by kaki Yen on 2021/12/28.
//

import SwiftUI

struct ContentView: View {
    static var source: DispatchSourceSignal = {
        let source: DispatchSourceSignal = DispatchSource.makeSignalSource(signal: SIGABRT)
        source.setEventHandler(handler: DispatchWorkItem {
            ScenesToCall.callTrace()
        })
        return source
    }()
    
    var body: some View {
        NavigationStack {
            LandMarkTabView().onceOnAppear {
                Self.source.activate()
            }
            .toolbarBackground(colorFromHex(0xFFFFFF))
            .toolbarBackground(.visible)
        }
    }
}
