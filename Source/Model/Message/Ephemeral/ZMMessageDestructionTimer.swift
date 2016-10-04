//
//  ZMMessageDestructionTimer.swift
//  ZMCDataModel
//
//  Created by Sabine Geithner on 28/09/16.
//  Copyright © 2016 Wire Swiss GmbH. All rights reserved.
//

import Foundation


let MessageDeletionTimerKey = "MessageDeletionTimer"
let MessageObfuscationTimerKey = "MessageObfuscationTimer"

public extension NSManagedObjectContext {
    
    public var zm_messageDeletionTimer : ZMMessageDestructionTimer {
        if !zm_isUserInterfaceContext {
            preconditionFailure("MessageDeletionTimerKey should be started only on the uiContext")
        }
        if let timer = persistentStoreMetadata(forKey: MessageDeletionTimerKey) as? ZMMessageDestructionTimer {
            return timer
        }
        let timer = ZMMessageDestructionTimer(managedObjectContext: self)
        setPersistentStoreMetadata(timer, forKey: MessageDeletionTimerKey)
        return timer
    }
    
    public var zm_messageObfuscationTimer : ZMMessageDestructionTimer {
        if !zm_isSyncContext {
            preconditionFailure("MessageObfuscationTimer should be started only on the syncContext")
        }
        if let timer = persistentStoreMetadata(forKey: MessageObfuscationTimerKey) as? ZMMessageDestructionTimer {
            return timer
        }
        let timer = ZMMessageDestructionTimer(managedObjectContext: self)
        setPersistentStoreMetadata(timer, forKey: MessageObfuscationTimerKey)
        return timer
    }
    
    /// Tears down zm_messageObfuscationTimer and zm_messageDeletionTimer
    /// Call inside a performGroupedBlock(AndWait) when calling it from another context
    public func zm_teardownMessageObfuscationTimer() {
        if let timer = persistentStoreMetadata(forKey: MessageObfuscationTimerKey) as? ZMMessageDestructionTimer {
            timer.tearDown()
            setPersistentStoreMetadata(nil, forKey: MessageObfuscationTimerKey)
        }
    }
    
    /// Tears down zm_messageDeletionTimer
    /// Call inside a performGroupedBlock(AndWait) when calling it from another context
    public func zm_teardownMessageDeletionTimer() {
        if let timer = persistentStoreMetadata(forKey: MessageDeletionTimerKey) as? ZMMessageDestructionTimer {
            timer.tearDown()
            setPersistentStoreMetadata(nil, forKey: MessageDeletionTimerKey)
        }
    }
}

enum MessageDestructionType : String {
    static let UserInfoKey = "destructionType"
    
    case obfuscation, deletion
}


public class ZMMessageDestructionTimer : ZMMessageTimer {

    init(managedObjectContext: NSManagedObjectContext!) {
        super.init(managedObjectContext: managedObjectContext) { (message, userInfo) in
            guard let message = message, !message.isZombieObject else { return }
            ZMMessageDestructionTimer.messageTimerDidFire(message: message, userInfo:userInfo)
        }
    }
    
    class func messageTimerDidFire(message: ZMMessage, userInfo: [AnyHashable: Any]?) {
        guard let userInfo = userInfo as? [String : Any],
              let type = userInfo[MessageDestructionType.UserInfoKey] as? String
        else { return }
        
        switch MessageDestructionType(rawValue:type) {
        case .some(.obfuscation):
            message.obfuscate()
        case .some(.deletion):
            ZMMessage.deleteForEveryone(message)
        default:
            return
        }
    }
    
    public func startObfuscationTimer(message: ZMMessage, timeout: TimeInterval) {
        let fireDate = Date().addingTimeInterval(timeout)
        start(forMessageIfNeeded: message,
              fire: fireDate,
              userInfo: [MessageDestructionType.UserInfoKey : MessageDestructionType.obfuscation.rawValue])
    }
    
    public func startDeletionTimer(message: ZMMessage, timeout: TimeInterval) {
        let fireDate = Date().addingTimeInterval(timeout)
        start(forMessageIfNeeded: message,
              fire: fireDate,
              userInfo: [MessageDestructionType.UserInfoKey : MessageDestructionType.deletion.rawValue])
    }

}


