//
//  UserInfoDataManager.swift
//  RotimaticMobile
//
//  Created by Basawaraj on 27/10/15.
//  Copyright © 2015 Cuelogic. All rights reserved.
//

import UIKit
import CoreData


//MARK: Keys
let kFirstName = "firstName"


class ChatInfoDataManager: NSObject {
    
    //SharedInstance
    static let sharedInstance = ChatInfoDataManager()
    
    //Entities
    let CHAT_INFO_ENTITY = "ChatInfo"
    
    //MARK: Insert ChatInfo
    func insertChatInfo(chatData: ChatMessage, failureHandler: (chatInfo: ChatInfo, error: NSError?) -> Void) {
        
        let request: NSFetchRequest = NSFetchRequest(entityName: CHAT_INFO_ENTITY)
        request.predicate = NSPredicate(format: "msgId = %@", chatData.msgId!)
        
        CoreDataManager.shared.executeFetchRequest(request) { (results, error) -> Void in
            print(results)
            
            if results?.count == 0 {
                
                let chatInfo: ChatInfo = NSEntityDescription.insertNewObjectForEntityForName(self.CHAT_INFO_ENTITY, inManagedObjectContext: CoreDataManager.shared.managedObjectContext) as! ChatInfo
                
                chatInfo.ticketId = chatData.ticketId
                chatInfo.displayName = chatData.displayName
                chatInfo.senderId  = chatData.senderId
                chatInfo.msgId = chatData.msgId
                chatInfo.msgBody = chatData.msgBody
                chatInfo.eventType = chatData.eventType!
                chatInfo.timeStamp = chatData.timeStamp
                chatInfo.msgType = chatData.msgType
                chatInfo.thumbnailURL = chatData.thumbnailURL
                
                if chatData.msgType == MessageType.Video.rawValue || chatData.msgType == MessageType.Image.rawValue {
                    chatInfo.isUploaded = chatData.isUploaded!
                }
                
                CoreDataManager.shared.save { (error) -> Void in
                    if error != nil {
                        failureHandler(chatInfo:chatInfo, error: error)
                    }
                    else {
                        failureHandler(chatInfo:chatInfo, error: nil)
                    }
                }
                                
            }
            
        }
        
    }
    
    //MARK: Fetch Chat With TicketId Method
    func fetchChatMessages(ticketId: String, completionHandler: (chatInfoData: NSMutableArray, error: NSError?) -> Void) {
        
        let request: NSFetchRequest = NSFetchRequest(entityName: CHAT_INFO_ENTITY)
        request.predicate = NSPredicate(format: "ticketId = %@", ticketId)
        let chatMessages: NSMutableArray = NSMutableArray()
        
        CoreDataManager.shared.executeFetchRequest(request) { (results, error) -> Void in
            print(results)
            
            for chatInfo in results! {
                chatMessages.addObject(chatInfo)
            }
            
            completionHandler(chatInfoData: chatMessages, error: error)
        }
        
    }
    
    //MARK: Fetch All Chat Method
    func fetchAllChatMessages(ticketId: String, completionHandler: (chatInfoData: NSMutableArray, error: NSError?) -> Void) {
        
        let request: NSFetchRequest = NSFetchRequest(entityName: CHAT_INFO_ENTITY)
        let chatMessages: NSMutableArray = NSMutableArray()
        
        CoreDataManager.shared.executeFetchRequest(request) { (results, error) -> Void in
            print(results)
            
            for chatInfo in results! {
                chatMessages.addObject(chatInfo)
            }
            
            completionHandler(chatInfoData: chatMessages, error: error)
        }
        
    }

    
    //MARK: Update Chat Info Method
    func updateChatInfo(chatData: ChatMessage, mediaMsg: String, failureHandler: (messageId: String?, error: NSError?) -> Void) {
        
        let request: NSFetchRequest = NSFetchRequest(entityName: CHAT_INFO_ENTITY)
        request.predicate = NSPredicate(format: "msgBody = %@", mediaMsg)
        
        CoreDataManager.shared.executeFetchRequest(request) { (results, error) -> Void  in
            print(results)
            
            if error == nil {
                
                if results?.count > 0 {
                    
                    let chatInfo : ChatInfo = results?[0] as! ChatInfo
                    
                    chatInfo.msgId = chatData.msgId
                    chatInfo.msgBody = chatData.msgBody
                    chatInfo.isUploaded = chatData.isUploaded!
                    
                    CoreDataManager.shared.save({ (error) -> Void in
                        if error != nil {
                            failureHandler(messageId: nil, error: error)
                        }else {
                            failureHandler(messageId: chatInfo.msgId, error: nil)
                        }
                    })

                }
                
            }
            
        }
        
    }
    
    
    //MARK: Update Comment Status For Chat Message Method
    func updateChatCommentStatusInfo(chatData: ChatMessage, messageId: String, failureHandler: (messageId: String?, error: NSError?) -> Void) {
        
        let request: NSFetchRequest = NSFetchRequest(entityName: CHAT_INFO_ENTITY)
        request.predicate = NSPredicate(format: "msgId = %@", messageId)
        
        CoreDataManager.shared.executeFetchRequest(request) { (results, error) -> Void  in
            print(results)
            
            if error == nil {
                
                if results?.count > 0 {
                    
                    let chatInfo : ChatInfo = results?[0] as! ChatInfo
                    
                    chatInfo.msgId = chatData.msgId
                    chatInfo.msgBody = chatData.msgBody
                    chatInfo.isUploaded = chatData.isUploaded!
                    
                    CoreDataManager.shared.save({ (error) -> Void in
                        if error != nil {
                            failureHandler(messageId: nil, error: error)
                        }else {
                            failureHandler(messageId: chatInfo.msgId, error: nil)
                        }
                    })
                    
                }
                
            }
            
        }
        
    }

    


    //MARK: Delete Chat Info Method
    func deleteChatInfo(chatData: ChatInfo, failureHandler: (error: NSError?) -> Void) {
        
        // delete all user info
        CoreDataManager.shared.managedObjectContext.deleteObject(chatData)
        // save your changes
        CoreDataManager.shared.save { (error) -> Void in
            if error != nil {
                failureHandler(error: error)
            }
        }
        
    }
    
    
    func deleteChatMessage(messageId: String) {
        
        let request: NSFetchRequest = NSFetchRequest(entityName: CHAT_INFO_ENTITY)
        request.predicate = NSPredicate(format: "msgId = %@", messageId)
        
        CoreDataManager.shared.executeFetchRequest(request) { (results, error) -> Void in
            
            print(results)
            
            if results?.count > 0 {
                
                let chatInfo : ChatInfo = results?[0] as! ChatInfo
                
                self.deleteChatInfo(chatInfo, failureHandler: { (error) -> Void in
                    
                })
                
            }

        }
        
    }
    
    //MARK: Delete All UserInfo Method
    func deleteAllUserInfo(failureHandler: (error: NSError?) -> Void) {
        
        let request: NSFetchRequest = NSFetchRequest(entityName: CHAT_INFO_ENTITY)
        request.sortDescriptors = [NSSortDescriptor(key: kFirstName , ascending: true)]
        
        CoreDataManager.shared.executeFetchRequest(request) { (results, error) -> Void in
            print(results)
            
            if error == nil {
                for userInfo in (results)! {
                    CoreDataManager.shared.managedObjectContext.deleteObject(userInfo as! ChatInfo)
                }
                CoreDataManager.shared.save({ (error) -> Void in
                    if error != nil {
                        failureHandler(error: error)
                    }
                })
            }
        }
    }
    
    //MARK: Check User Present Method
    func isUserPresent() -> Bool {
        
        let context = CoreDataManager.shared.managedObjectContext
        let request = NSFetchRequest(entityName: CHAT_INFO_ENTITY)
        var results : NSArray?
        
        do {
            results = try context.executeFetchRequest(request)
            
            if let res = results
            {
                if res.count == 0
                {
                    return false
                }
                else
                {
                    return true
                }
            }
            else
            {
                print("Error: fetch request returned nil")
                return true
            }
        } catch let error as NSError {
            // failure
            print("Error: \(error.debugDescription)")
            return true
        }
    }
    
}
