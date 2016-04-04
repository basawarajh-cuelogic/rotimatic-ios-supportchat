//
//  Message.swift
//  FireChat-Swift
//
//  Created by Katherine Fang on 8/20/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

import Foundation

class Message : NSObject, JSQMessageData {
    
    var text_: String
    var sender_: String
    var date_: NSDate
    var imageUrl_: String?
    var isMediaMessage_: Bool?
    var messageHash_: UInt = UInt()
    var senderDisplayName_: String?
    
    convenience init(text: String?, sender: String?, isMedia: Bool) {
        self.init(text: text, sender: sender, imageUrl: nil, isMedia: isMedia)
    }
    
    init(text: String?, sender: String?, imageUrl: String?, isMedia: Bool) {
        self.text_ = text!
        self.sender_ = sender!
        self.date_ = NSDate()
        self.imageUrl_ = imageUrl
        self.isMediaMessage_ = isMedia
    }
    
    func text() -> String! {
        return text_;
    }
    
    func date() -> NSDate! {
        return date_;
    }
    
    func imageUrl() -> String? {
        return imageUrl_;
    }
    
    func senderId() -> String! {
        return sender_;
    }
    
    func isMediaMessage() -> Bool {
        return isMediaMessage_!;
    }
    
    func messageHash() -> UInt {
        return messageHash_;
    }
    
    func senderDisplayName() -> String! {
        return senderDisplayName_;
    }
    
}