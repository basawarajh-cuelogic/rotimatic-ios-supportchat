//
//  RMTickets.swift
//  ZendeskiOS
//
//  Created by Basawaraj on 23/02/16.
//  Copyright © 2016 Cuelogic. All rights reserved.
//

import UIKit

class TicketRequest: NSObject {
    
    var ticketSubject: String =  String()
    var ticketDescription: String =  String()
    var ticketAttachments: [AnyObject] =  []
    
}

class Tickets: NSObject {
    
    var ticketId: String =  String()
    var ticketSubject: String =  String()
    var ticketStatus: String =  String()
    var ticketDescription: String = String()
    
}


class AttachmentUploadResponse: NSObject {
    
    var uploadToken: String =  String()
    
}


class RMTickets: NSObject {

    static var sharedInstance = RMTickets()
    
    let ticketRequest: ZDKRequestProvider = ZDKRequestProvider()

    func createTicketRequest(ticketRequestObj: TicketRequest, completionBlock: (tickets: AnyObject?, error: NSError?) -> Void) {
        
        let request =  requestObj(ticketRequestObj)
        
        ticketRequest.createRequest(request) { (response, error) -> Void in
            
            if error == nil {
                completionBlock(tickets: response, error: nil)
            }
            else {
                completionBlock(tickets: response, error: error)
            }
            
        }
        
    }
    
    func requestObj(ticketRequest: TicketRequest) -> ZDKCreateRequest {
        
        let requestObj: ZDKCreateRequest = ZDKCreateRequest()
        
        requestObj.subject = ticketRequest.ticketSubject
        requestObj.requestDescription = ticketRequest.ticketDescription
        requestObj.attachments = ticketRequest.ticketAttachments
        
        return requestObj
        
    }
    
    func getHelpCenterTickets(completionBlock: (tickets: NSArray?, error: NSError?) -> Void) {
        
        ticketRequest.getAllRequestsWithCallback { (response, error) -> Void in
            
            let tickets = response as! Array<ZDKRequest>
            
            if error == nil {
                completionBlock(tickets: self.parseTickets(tickets), error: nil)
            }
            else {
                completionBlock(tickets: tickets, error: error)
            }
            
        }
        
    }
    
    func getHelpCenterTicketsByStatus(status: String, completionBlock: (tickets: NSArray?, error: NSError?) -> Void) {
        
        ticketRequest.getRequestsByStatus(status) { (response, error) -> Void in
            
            if error == nil {
                let tickets = response as! Array<ZDKRequest>
                completionBlock(tickets: self.parseTickets(tickets), error: nil)
            }
            else {
                completionBlock(tickets: nil, error: error)
            }
            
        }
        
    }
    
    //Upload request/ticket attachments
    func uploadAttachments(imageData: NSData, completionBlock: (attachmentResponse: ZDKUploadResponse?, error: NSError?) -> Void) {
        
        ZDKUploadProvider().uploadAttachment(imageData, withFilename: "attachment", andContentType: "image/png") { (uploadResponse, error) -> Void in
            
            if error == nil {
                completionBlock(attachmentResponse: uploadResponse, error: nil)
            }
            else {
                completionBlock(attachmentResponse: nil, error: error)
            }
            
        }
        
    }
    
    func addCommentForTicket(ticketId: String, comment: String, completionBlock: (error: NSError?) -> Void) {
        
        ticketRequest.addComment(comment, forRequestId: ticketId) { (comment, error) -> Void in
            
            completionBlock(error: error)
            
        }
        
    }
    
    //MARK: Parse Tickets
    
    func parseTickets(tickets: Array<ZDKRequest>) -> NSArray {
        
        let ticketsArr: NSMutableArray = NSMutableArray()
        
        for ticket in tickets {
            
            let ticketObj: Tickets = Tickets()
            
            ticketObj.ticketId = ticket.requestId
            ticketObj.ticketSubject = ticket.subject
            ticketObj.ticketStatus = ticket.status
            ticketObj.ticketDescription = ticket.requestDescription
            
            ticketsArr.addObject(ticketObj)
            
        }
        
        return ticketsArr as NSArray
    }

    
   
    
}
