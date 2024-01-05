//
//  ScenesTo@objc.swift
//  SwiftProject
//
//  Created by kaki Yen on 2021/12/29.
//

import Foundation
import SwiftFramework

let tmpCallTraceManager: CallTraceManager = CallTraceManager()

class CallTraceManager: NSObject {
    deinit {
        print("CallTraceManager : \(#function)")
    }
    
    func addNotifity() {
        NotificationCenter.default.addObserver(self, selector: #selector(CallTraceManager.notificationAction(_:)), name: .CallTraceDidFinishNotification, runloop: .main, object: nil)
    }
    
    @objc func notificationAction(_ notification: Notification) {
        print("Receive Current Thread : \(Thread.current)")
        let tmpString: String? = notification.userInfo?[CallTraceKey.userInfo] as? String
        print("\(tmpString ?? "")")
    }
}

@objc extension CallTraceManager {
    class func callTrace() {
        tmpCallTraceManager.addNotifity()
        DispatchQueue(label: "com.kaki.thread").async {
            CallTrace()
        }
    }
}
