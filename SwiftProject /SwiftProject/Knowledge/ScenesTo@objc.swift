//
//  ScenesTo@objc.swift
//  SwiftProject
//
//  Created by kaki Yen on 2021/12/29.
//

import Foundation
import SwiftFramework

var tmpCallTraceManager: CallTraceManager?

class CallTraceManager: NSObject {
    deinit {
        print("CallTraceManager : \(#function)")
    }
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(CallTraceManager.notificationAction(_:)), name: .CallTraceDidFinishNotification, runloop: RunLoop.current, object: nil)
    }
    
    @objc func notificationAction(_ notification: Notification) {
        print("Receive Current Thread : \(Thread.current)")
        let tmpString: String? = notification.userInfo?[CallTraceKey.userInfo] as? String
        print("\(tmpString ?? "")")
    }
}

@objc extension CallTraceManager {
    class func callTrace() {
        tmpCallTraceManager = CallTraceManager()
        DispatchQueue(label: "com.kaki.thread").async {
            CallTrace()
        }
    }
}
