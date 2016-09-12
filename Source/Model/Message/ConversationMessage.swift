//
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
// 


import Foundation

@objc
public enum ZMDeliveryState : UInt {
    case invalid = 0
    case pending = 1
    case sent = 2
    case delivered = 3
    case failedToSend = 4
}

@objc
public protocol ZMConversationMessage : NSObjectProtocol {
    
    /// Whether the message was received in its encrypted form.
    /// In the transition period, a message can be both encrypted and plaintext.
    var isEncrypted: Bool { get }
    
    /// Whether the message was received in its plain-text form.
    /// In the transition period, a message can be both encrypted and plaintext.
    var isPlainText: Bool { get }
    
    /// The user who sent the message
    var sender: ZMUser? { get }
    
    /// The timestamp as received by the server
    var serverTimestamp: Date? { get }
    
    /// The conversation this message belongs to
    var conversation: ZMConversation? { get }
    
    /// The current delivery state of this message. It makes sense only for
    /// messages sent from this device. In any other case, it will be
    /// ZMDeliveryStateDelivered
    var deliveryState: ZMDeliveryState { get }
    
    /// The textMessageData of the message which also contains potential link previews. If the message has no text, it will be nil
    var textMessageData : ZMTextMessageData? { get }
    
    /// The image data associated with the message. If the message has no image, it will be nil
    var imageMessageData: ZMImageMessageData? { get }
    
    /// The system message data associated with the message. If the message is not a system message data associated, it will be nil
    var systemMessageData: ZMSystemMessageData? { get }
    
    /// The knock message data associated with the message. If the message is not a knock, it will be nil
    var knockMessageData: ZMKnockMessageData? { get }
    
    /// The file transfer data associated with the message. If the message is not the file transfer, it will be nil
    var fileMessageData: ZMFileMessageData? { get }
    
    /// The location message data associated with the message. If the message is not a location message, it will be nil
    var locationMessageData: ZMLocationMessageData? { get }
    
    var usersReaction : Dictionary<String, [ZMUser]> { get }
    
    /// Request the download of the file if not already present.
    /// The download will be executed asynchronously. The caller can be notified by observing the message window.
    /// This method can safely be called multiple times, even if the content is already available locally
    func requestFileDownload()
    
    /// Request the download of the image if not already present.
    /// The download will be executed asynchronously. The caller can be notified by observing the message window.
    /// This method can safely be called multiple times, even if the content is already available locally
    func requestImageDownload()
    
    /// In case this message failed to deliver, this will resend it
    func resend()
    
    /// tell whether or not the message can be deleted
    var canBeDeleted : Bool { get }
    
    /// True if the message has been deleted
    var hasBeenDeleted : Bool { get }
    
    var updatedAt : Date? { get }
}


// MARK:- Conversation managed properties
extension ZMMessage {
    
    @NSManaged public var visibleInConversation : ZMConversation?
    @NSManaged public var hiddenInConversation : ZMConversation?
    
    public var conversation : ZMConversation? {
        return self.visibleInConversation ?? self.hiddenInConversation
    }
}


// MARK:- Conversation Message protocol implementation

extension ZMMessage : ZMConversationMessage {
}

extension ZMMessage {
    
    @NSManaged public var isEncrypted : Bool
    @NSManaged public var isPlainText : Bool
    @NSManaged public var sender : ZMUser?
    @NSManaged public var serverTimestamp : Date?

    public var textMessageData : ZMTextMessageData? {
        return nil
    }
    
    public var imageMessageData : ZMImageMessageData? {
        return nil
    }
    
    public var knockMessageData : ZMKnockMessageData? {
        return nil
    }
    
    public var systemMessageData : ZMSystemMessageData? {
        return nil
    }
    
    public var fileMessageData : ZMFileMessageData? {
        return nil
    }
    
    public var locationMessageData: ZMLocationMessageData? {
        return nil
    }
    
    public var deliveryState : ZMDeliveryState {
        if self.confirmations.count > 0 {
            return .delivered
        }
        if self.eventID != nil {
            return .sent
        }
        if self.isExpired {
            return .failedToSend
        }
        return .pending
    }
    
    public func requestFileDownload() {}
    
    public func requestImageDownload() {}
    
    public var usersReaction : Dictionary<String, [ZMUser]> {
        var result = Dictionary<String, [ZMUser]>()
        for reaction in self.reactions {
            if reaction.users.count > 0 {
                result[reaction.unicodeValue!] = Array<ZMUser>(reaction.users)
            }
        }
        return result
    }
    
    
    public var canBeDeleted : Bool {
        return deliveryState == .delivered || deliveryState == .sent || deliveryState == .failedToSend
    }
    
    public var hasBeenDeleted: Bool {
        return visibleInConversation == nil && hiddenInConversation != nil;
    }
    
    public var updatedAt : Date? {
        return nil
    }
    
}

