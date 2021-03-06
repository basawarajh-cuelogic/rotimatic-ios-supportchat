//
//  MessageModel.swift
//  ChatUI
//
//  Created by Basawaraj on 13/03/16.
//  Copyright © 2016 Basawaraj. All rights reserved.
//

import UIKit

let ThemeColor: UIColor = UIColor(red: 217/255, green: 99/255, blue: 51/255, alpha: 1)
let OutGoingBubbleColor: UIColor = UIColor(red: 243/255, green: 90/255, blue: 77/255, alpha: 1)

class MessageModel: NSObject {

    var messages: NSMutableArray = NSMutableArray()
    var avatars: NSDictionary = NSDictionary()
    var outgoingBubbleImageData: JSQMessagesBubbleImage = JSQMessagesBubbleImageFactory(bubbleImage: UIImage.jsq_bubbleRegularImage(), capInsets: UIEdgeInsetsMake(30, 15, 10, 15)).outgoingMessagesBubbleImageWithColor(OutGoingBubbleColor)
    var incomingBubbleImageData: JSQMessagesBubbleImage = JSQMessagesBubbleImageFactory(bubbleImage: UIImage.jsq_bubbleRegularImage(), capInsets: UIEdgeInsetsMake(30, 15, 10, 15)).incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var users: NSDictionary = NSDictionary()
    
    
}
