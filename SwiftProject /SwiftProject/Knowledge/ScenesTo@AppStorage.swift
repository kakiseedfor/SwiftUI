//
//  ScenesTo@AppStorage.swift
//  SwiftProject
//
//  Created by kaki Yen on 2021/12/28.
//

import SwiftUI

var appStorages = AppStorages()

struct AppStorages {
    @AppStorage("TabSelection") var tabSelection: Int = 0
}
