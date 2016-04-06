//
//  ChatInfo+CoreDataProperties.swift
//  
//
//  Created by Basawaraj on 01/04/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ChatInfo {

    @NSManaged var agentId: String?
    @NSManaged var avatarUrl: String?
    @NSManaged var displayName: String?
    @NSManaged var eventType: NSNumber?
    @NSManaged var mediaFileUrl: String?
    @NSManaged var msgBody: String?
    @NSManaged var msgId: String?
    @NSManaged var msgType: String?
    @NSManaged var senderId: String?
    @NSManaged var ticketId: String?
    @NSManaged var timeStamp: NSDate?
    @NSManaged var vendorId: NSNumber?
    @NSManaged var isUploaded: Bool
    @NSManaged var thumbnailURL: String?
    @NSManaged var commentSync: Bool

}
