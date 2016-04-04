//
//  ChatMediaData.swift
//  ChatUI
//
//  Created by Basawaraj on 01/04/16.
//  Copyright © 2016 Basawaraj. All rights reserved.
//

import UIKit
import AVFoundation

class ChatMediaData: NSObject {

    static var sharedInstance = ChatMediaData()
    
    func addPhotoMediaMessage(photoURL: String, senderId: String, displayName: String, date: NSDate, isfileUploaded: Bool) -> JSQMessage {
        
        let photoItem: JSQPhotoMediaItem = JSQPhotoMediaItem(URL: NSURL(string: photoURL), fileUploaded: isfileUploaded)
        let photoMessage: JSQMessage = JSQMessage(senderId: senderId, senderDisplayName: displayName, date: date, media: photoItem)

        
        return photoMessage
    }
    
    func addVideoMediaMessage(videoURL: NSURL, videoThumbnailURL: NSURL, senderId: String, displayName: String,  date: NSDate, isFileUploaded: Bool) -> JSQMessage {
        
        let videoItem: JSQVideoMediaItem = JSQVideoMediaItem(fileURL: videoURL, thumbnailURL: videoThumbnailURL, isReadyToPlay: true, isFileUploaded: isFileUploaded )
        let videoMessage: JSQMessage = JSQMessage(senderId: senderId, senderDisplayName: displayName, date: date, media: videoItem)

        
        return videoMessage
    }

    
    func loadThumbnail(urlVideo: NSURL, completionBlock:(image: UIImage) -> Void) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            
            let asset: AVURLAsset = AVURLAsset(URL: urlVideo)
            let generate: AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            generate.appliesPreferredTrackTransform = true
            let time: CMTime = CMTimeMake(1, 60)
            var imgRef: CGImageRef?
            
            do {
                imgRef = try generate.copyCGImageAtTime(time, actualTime: nil)
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionBlock(image: UIImage(CGImage: imgRef!))
            })
            
        }
        
    }
    
    
    
}
