//
//  ChatTranscriptManager.swift
//  ChatUI
//
//  Created by Basawaraj on 06/04/16.
//  Copyright © 2016 Basawaraj. All rights reserved.
//

import UIKit

class ChatTranscriptManager: NSObject {

    
    func sendChatTranscriptToComment(ticketId: String) {
        
        getAllUnsyncCommentMessages { (chatInfoData, error) -> Void in
            
            if chatInfoData.count > 0 {
               
                let transcriptString = self.createTranscriptForMessages(chatInfoData)
                
                RMTickets.sharedInstance.addCommentForTicket(ticketId, comment: transcriptString, completionBlock: { (error) -> Void in
                    
                    if error == nil {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            ChatInfoDataManager.sharedInstance.updateChatCommentStatus(chatInfoData, failureHandler: { (messageId, error) -> Void in
                                
                                if error == nil {
                                    NSLog("Updated all values")
                                }
                                
                            })
                            
                        })
                        
                    }
                    
                })
                
            }
            
        }
        
    }
    
    func getAllUnsyncCommentMessages(completionBlock:(chatInfoData: NSMutableArray, error: NSError?) -> Void) {
        
        ChatInfoDataManager.sharedInstance.fetchAllChatMessages(false) { (chatInfoData, error) -> Void in
            
            completionBlock(chatInfoData: chatInfoData, error: error)
        }
        
    }
    
    func createTranscriptForMessages(messages: NSMutableArray) -> String {
        
        var chatTranscript: String = String()
        
        chatTranscript = "Chat Transcript on " + getCurrentDateString(NSDate()) + "\n\n"
        
        for message in messages {
            
            let chatMessage  = message as! ChatInfo
            chatTranscript = chatTranscript + "[\(getCurrentDateString(chatMessage.timeStamp!))] " + chatMessage.displayName! + " : " + chatMessage.msgBody! + "\n"
            
        }
        
        return chatTranscript
    }
    
    
    func getCurrentDateString(date: NSDate) -> String {
        
        var dateString : String = String()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM-dd-yy h:mm:ss a"
        dateString = formatter.stringFromDate(date)
        
        return dateString
        
    }
    
}


 