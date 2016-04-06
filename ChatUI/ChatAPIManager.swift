//
//  ChatAPIManager.swift
//  ChatUI
//
//  Created by Basawaraj on 16/03/16.
//  Copyright © 2016 Basawaraj. All rights reserved.
//

import UIKit
//Chat API Account Info
//Zendsesk and Zopim:
//https://rotimatic1444384919.zendesk.com
//Username - devitinfra@zimplistic.com
//Password - rotimatic$1234

let kMediaImageType = "image/png"
let kMediaVideoType = "video/quicktime"

protocol ChatAPIManagerDelegate {
    
    func connectionStatus(status: ZDCConnectionStatus);
    func receivedMessagesEvent(messages: NSArray);
    func agentEventData(agentInfo: NSDictionary);
    func sessionTimeout();
    
}

class ChatAPIManager: NSObject {

    let kAccountKey = "3dWugd42eTnMPMdL64k0hY3g2nV4THby"
    var delegate: ChatAPIManagerDelegate?
    static let sharedManager = ChatAPIManager()
    
    var ticketId: String = String()
    
    override init() {
        super.init()
    }
    
    //Initial Configuration ZopimChatSDK
    func configureZopimChatSDK() {
        
        ZDCChat.configure { (configure) -> Void in
            configure.accountKey = self.kAccountKey
            configure.preChatDataRequirements.name = ZDCPreChatDataRequirement.Optional
            configure.preChatDataRequirements.email = ZDCPreChatDataRequirement.Optional
            configure.preChatDataRequirements.phone = ZDCPreChatDataRequirement.Optional
            configure.preChatDataRequirements.department = ZDCPreChatDataRequirement.Optional
            configure.preChatDataRequirements.message = ZDCPreChatDataRequirement.Optional
            
            ZDCChat.instance().session.connectWithConfig(configure)
            self.updateVisitor(UserName, email: UserEmail)

            self.addObservers()
            
            ZDCLog.enable(true)
    
        }
        
    }
    
    
    func updateVisitor(name: String?, email: String?) {
        
        ZDCChat.updateVisitor { (visitor) -> Void in
            
            visitor.name = name
            visitor.email = email
            
        }
        
    }
    
    func addObservers() {
        addObserverForConnectionEvent(self, selector: "connectionStatusUpdate")
        addObserverTimeOut(self, selector: "sessionTimeOut")
        addObserverChatLogEvents(self, selector: "chatEvent:")
        addObserverAgentEvents(self, selector: "agentEvent:")
    }
    
    func removeObservers() {
        removeObserverForConnectionEvents(self)
        removeObserverForChatLogEvents(self)
        removeObserverForConnectionEvents(self)
        removeObserverTimeOut(self)
    }
    
    
    func connectionStatusUpdate() {
        let status: ZDCConnectionStatus = ZDCChat.instance().session.connectionStatus()
        
        delegate?.connectionStatus(status)
    }
    
    func chatEvent(sender: AnyObject) {
        let events: NSArray = ZDCChat.instance().session.dataSource().livechatLog()
        
        //let newMessages: NSArray = insertChatMessagesInfoToDB(events)
        insertChatMessagesInfoToDB(events) { (chatInfoData) -> Void in
            self.delegate?.receivedMessagesEvent(self.parseData(chatInfoData))
        }
        
        
        
        /*fetchMessages { (chatInfoData) -> Void in
            self.delegate?.receivedMessagesEvent(chatInfoData)
        }*/
        
    }
    
    func agentEvent(sender: AnyObject) {
        let agents: NSDictionary = ZDCChat.instance().session.dataSource().agents()
        delegate?.agentEventData(agents)
    }
    
    func sessionTimeOut() {
        delegate?.sessionTimeout()
    }

    //MARK: Notify Tying
    func notifyTyping(isTyping: Bool) {
       
    }

    
    //MARK: Send Message
    func sendChatMessage(message: String) {
        ZDCChat.instance().session.sendChatMessage(message)
    }
    
    //MARK: Send Offline Message
    func sendOfflineChatMessage(message: String) {
        ZDCChat.instance().session.sendOfflineMessage(message)
    }
    
    //MARK: End Chat
    func endChat() {
        ZDCChat.instance().session.endChat()
        removeObservers()
    }
    
    //MARK: Resume Chat
    func resumeChat() {
        ZDCChat.instance().session.resumeChat()

    }
    
    //MARK: Data Upload
    func uploadImage(image: UIImage) {
        
        ZDCChat.instance().session.uploadImage(image, name: "image_uploaded.jpg" )
    }
    
    func uploadData(data: NSData) {
        
        ZDCChat.instance().session.uploadFileWithData(data, name: "image_uploaded.jpg")
        
    }
    
    //MARK: Chat Status
    func chatStatus() {
        
        let status = ZDCChat.instance().session.status()
    
        switch (status)
        {
        case .Inactive:
            break
        case .Connected:
            break
        case .Chatting:
            break
        case .TimedOut:
            break
        }
        
    }
    
    //MARK: Email Transcript
    func emailTranscript(emailId: String) {
        ZDCChat.instance().session.emailTranscript(emailId)
    }
    
    //MARK: Add Observers
    func addObserverForConnectionEvent(target: AnyObject!, selector: Selector) {
        ZDCChat.instance().session.addObserver(target, forConnectionEvents: selector)
    }
    
    func addObserverTimeOut(target: AnyObject!, selector: Selector) {
        ZDCChat.instance().session.addObserver(target, forTimeoutEvents: selector)
    }
    
    func addObserverChatLogEvents(target: AnyObject!, selector: Selector) {
        ZDCChat.instance().session.dataSource().addObserver(target, forChatLogEvents: selector)
    }
    
    func addObserverAgentEvents(target: AnyObject!, selector: Selector) {
        ZDCChat.instance().session.dataSource().addObserver(target, forAgentEvents: selector)
    }

    //MARK: Remove Observers
    func removeObserverForConnectionEvents(target: AnyObject!) {
        ZDCChat.instance().session.removeObserverForConnectionEvents(target)
    }
    
    func removeObserverTimeOut(target: AnyObject!) {
        ZDCChat.instance().session.removeObserverForTimeoutEvents(target)
    }

    func removeObserverForChatLogEvents(target: AnyObject!) {
        ZDCChat.instance().session.dataSource().removeObserverForChatLogEvents(target)
    }
    
    func removeObserverForAgentEvents(target: AnyObject!) {
        ZDCChat.instance().session.dataSource().removeObserverForAgentEvents(target)
    }

    //MARK: Insert Chat Info To DB
    func insertChatMessagesInfoToDB(messagesArr: NSArray, completionHandler: (chatInfoData: NSMutableArray) -> Void)  {
        
        let messages: NSMutableArray = NSMutableArray()
        
        for messageInfo in parseChatMessages(messagesArr) {
            
            let chatMessageInfo = messageInfo as! ChatMessage
            
            print("Message Description - \(messageInfo.description)")
            
            if chatMessageInfo.msgBody!.isUrl() {
                
                ChatInfoDataManager.sharedInstance.updateChatInfo(chatMessageInfo, mediaMsg: chatMessageInfo.msgBody! , failureHandler: { (messageId,error) -> Void in
                    
                    if error == nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            NSNotificationCenter.defaultCenter().postNotificationName("NotificationIdentifier", object: messageId)
                        })
                    }                   
                    
                })
                
            }
            else {
              
                ChatInfoDataManager.sharedInstance.insertChatInfo(messageInfo as! ChatMessage, failureHandler: { (chatInfo, error) -> Void in
                    messages.addObject(chatInfo)
                    completionHandler(chatInfoData: messages)
                })
                
            }
            
        }
        
    }
    
    //MARK: Parse Chat Messages
    func parseChatMessages(messagesArr: NSArray) -> NSMutableArray {
        
        let messages: NSMutableArray = NSMutableArray()
        
        for messageInfo in messagesArr {
            
            let info = messageInfo as! ZDCChatEvent
           
            if info.message != nil {
                
                let chatMessage: ChatMessage = ChatMessage()
                
                chatMessage.ticketId = ticketId
                chatMessage.senderId = info.nickname
                chatMessage.displayName = info.displayName
                chatMessage.msgId = info.eventId
                chatMessage.msgBody = info.message
                chatMessage.eventType = info.type.rawValue
                chatMessage.timeStamp = NSDate()
                chatMessage.avatarUrl = ""
                chatMessage.commentSync = false
                if info.message.isUrl() {
                    
                    chatMessage.isUploaded = true
                    
                    let fileType = info.message.MIMEType()
                    
                    if fileType == kMediaImageType {
                        chatMessage.msgType = MessageType.Image.rawValue
                    }
                    else if fileType == kMediaVideoType {
                        chatMessage.msgType = MessageType.Video.rawValue
                    }
                    
                }
                messages.addObject(chatMessage)
            }
            
        }
        
        return messages
    }
    
    //MARK: Fetch Messages
    func fetchMessages(completionHandler: (chatInfoData: NSMutableArray) -> Void){
        
        let chatMessages: NSMutableArray = NSMutableArray()
        
        ChatInfoDataManager.sharedInstance.fetchChatMessages(ticketId) { (chatInfoData, error) -> Void in
            
            for chat in chatInfoData {
                
                let info = chat as! ChatInfo
                
                if info.eventType == EventType.VisitorMessage.rawValue {
                    
                    if info.msgType == MessageType.Image.rawValue {
                        chatMessages.addObject(ChatMediaData.sharedInstance.addPhotoMediaMessage(info.msgBody!, senderId: kJSQDemoAvatarIdSquires,messageId: info.msgId!, displayName: kJSQDemoAvatarDisplayNameSquires, date: info.timeStamp!, isfileUploaded: info.isUploaded))
                    }
                    else if info.msgType == MessageType.Video.rawValue {
                        chatMessages.addObject(ChatMediaData.sharedInstance.addVideoMediaMessage(NSURL(string: info.msgBody!)!, videoThumbnailURL:NSURL(string: info.thumbnailURL!)!, senderId:kJSQDemoAvatarIdSquires, messageId: info.msgId!, displayName:kJSQDemoAvatarDisplayNameSquires, date: NSDate(), isFileUploaded: info.isUploaded))
                    }
                    else {
                         chatMessages.addObject(JSQMessage(senderId: kJSQDemoAvatarIdSquires, messageId: info.msgId, senderDisplayName: kJSQDemoAvatarDisplayNameSquires, date: info.timeStamp, text: info.msgBody))
                    }
                    
                }
                else if info.eventType == EventType.AgentMessage.rawValue{
                    chatMessages.addObject(JSQMessage(senderId: info.senderId, messageId: info.msgId, senderDisplayName: info.displayName, date: info.timeStamp, text: info.msgBody))
                }
                
            }
            
        }
        
        completionHandler(chatInfoData: chatMessages)
        
    }
    
    func parseData(newMessages: NSArray) -> NSMutableArray {
        
        let chatMessages: NSMutableArray = NSMutableArray()
        
        for chat in newMessages {
            
            let info = chat as! ChatInfo
            
            if info.eventType == EventType.VisitorMessage.rawValue {
                
            chatMessages.addObject(JSQMessage(senderId: kJSQDemoAvatarIdSquires, messageId: info.msgId, senderDisplayName: kJSQDemoAvatarDisplayNameSquires, date: info.timeStamp, text: info.msgBody))
                
            }
            else if info.eventType == EventType.AgentMessage.rawValue{
                chatMessages.addObject(JSQMessage(senderId: info.senderId, messageId: info.msgId, senderDisplayName: info.displayName, date: info.timeStamp, text: info.msgBody))
            }
            
        }

        
        return chatMessages
    }
    
   
    
    
   
    
}
