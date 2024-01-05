//
//  NotificationController.swift
//  SwiftFramework
//
//  Created by kaki Yen on 2022/11/18.
//

import Foundation

extension NSMachPort {
    var notification: Notification? {
        get { objc_getAssociatedObject(self, &CallTraceKey.notification) as? Notification }
        set { objc_setAssociatedObject(self, &CallTraceKey.notification, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN) }
    }
}

extension NSMachPortDelegate {
    func handleMachMessage(_ notification: Notification?) {}
}

class NotificationMatch<T>: NSObject, NSMachPortDelegate where T: NotificationPortController {
    var runloop: RunLoop
    var targetProt: NSMachPort
    weak var delegate: T?
    
    deinit {
        print("NotificationMatch : \(#function)")
        runloop.remove(targetProt, forMode: .common)
    }
    
    init?(_ aRunloop: RunLoop?, _ adelegate: T) {
        if aRunloop == nil {
            return nil
        }
        
        targetProt = NSMachPort()
        delegate = adelegate
        runloop = aRunloop!
        
        super.init()
        targetProt.setDelegate(self)
        targetProt.schedule(in: runloop, forMode: .common)
    }
    
    func sendPort(_ notification: Notification) {
        targetProt.notification = notification
        targetProt.send(before: Date.now, components: nil, from: nil, reserved: 0)
    }
    
    func handleMachMessage(_ msg: UnsafeMutableRawPointer) {
        delegate?.handleMachMessage(targetProt.notification!)
    }
}

class NotificationPortController: NSObject {
    weak var observer: AnyObject?
    weak var controller: AnyObject?
    var targetMatch: NotificationMatch<NotificationPortController>?
    var selector: Selector?
    var object: Any?
    var name: NSNotification.Name?
    
    deinit {
        print("NotificationPortController : \(#function)")
    }
    
    convenience init(_ aController: AnyObject?) {
        self.init()
        controller = aController
    }
    
    func addObserver(_ aObserver: AnyObject, selector aSelector: Selector, name aName: NSNotification.Name?, runloop aRunloop: RunLoop?, object anObject: Any?){
        NotificationCenter.default.removeObserver(self, name: aName, object: anObject)
        
        targetMatch = NotificationMatch<NotificationPortController>(aRunloop, self)
        observer = aObserver
        selector = aSelector
        object = anObject
        name = aName
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCallback(_:)), name: aName, object: anObject)
    }
    
    func handleMachMessage(_ notification: Notification) {
        notificationCallback(notification)
    }
    
    @objc func notificationCallback(_ notification: Notification) {
        guard observer != nil else {    /// 观察对象已释放
            let _ = controller?.perform(#selector(NotificationController.removeObserver(_:)), with: self)
            NotificationCenter.default.removeObserver(self, name: name, object: object)
            return
        }
        
        if targetMatch?.runloop == RunLoop.current {   /// 说明是在指定的线程上调用
            let _ = observer?.perform(selector, with: notification)
            return
        }
        
        if targetMatch != nil {  /// 未在指定的线程上调用
            targetMatch?.sendPort(notification)    /// 发送指令到指定的线程上
            return
        }
        
        /// 没有指定的线程，直接回调
        let _ = observer?.perform(selector, with: notification)
    }
}

class NotificationController {
    var notificationPortController: [NotificationPortController] = [NotificationPortController]()
    
    func addObserver(_ aObserver: AnyObject, selector aSelector: Selector, name aName: NSNotification.Name?, runloop aRunloop: RunLoop?, object anObject: Any?) {
        let controllers: [NotificationPortController]? = matchController(aObserver, name: aName)
        var tmpController: NotificationPortController? = controllers?.first
        if tmpController == nil {
            tmpController = NotificationPortController(self)
            appendController(tmpController!)
        }
        tmpController!.addObserver(aObserver, selector: aSelector, name: aName, runloop: aRunloop, object: anObject)
    }
    
    @objc func removeObserver(_ portController: NotificationPortController) {
        if let index: Int = notificationPortController.firstIndex(of: portController) {
            notificationPortController.remove(at: index)
        }
    }
    
    /// 实际只会返回1个
    func matchController(_ aObserver: AnyObject, name aName: NSNotification.Name?) -> [NotificationPortController]? {
        notificationPortController.filter {
            return $0.observer != nil
        }.compactMap{
            if ObjectIdentifier(aObserver) == ObjectIdentifier($0.observer!) && $0.name == aName {
                return $0
            }
            return nil
        }
    }
    
    func appendController(_ aController: NotificationPortController) {
        notificationPortController.append(aController)
    }
}

extension NotificationCenter {
    var notificationController: NotificationController {
        get {
            var tmpController: NotificationController? = objc_getAssociatedObject(self, &CallTraceKey.notificationController) as? NotificationController
            if tmpController == nil {
                objc_setAssociatedObject(self, &CallTraceKey.notificationController, NotificationController(), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
                tmpController = objc_getAssociatedObject(self, &CallTraceKey.notificationController) as? NotificationController
            }
            return tmpController!
        }
    }
    
    public func addObserver(_ aObserver: AnyObject, selector aSelector: Selector, name aName: NSNotification.Name?, runloop aRunloop: RunLoop?, object anObject: Any?)
    {
        notificationController.addObserver(aObserver, selector: aSelector, name: aName, runloop: aRunloop, object: anObject)
    }
}
