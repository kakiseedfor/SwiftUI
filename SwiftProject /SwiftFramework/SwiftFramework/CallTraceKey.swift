//
//  CallTraceKey.swift
//  SwiftFramework
//
//  Created by kaki Yen on 2022/11/22.
//

import Foundation

public struct CallTraceKey: RawRepresentable, Hashable {
    public typealias RawValue = String
    public var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension CallTraceKey {
    static var notificationController: CallTraceKey = CallTraceKey(rawValue: "notificationController")
    static var notification: CallTraceKey = CallTraceKey(rawValue: "notification")
    public static let userInfo: CallTraceKey = CallTraceKey(rawValue: "userInfo")
}
