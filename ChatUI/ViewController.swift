//
//  ViewController.swift
//  ChatUI
//
//  Created by Basawaraj on 13/03/16.
//  Copyright © 2016 Basawaraj. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import AVKit



let kJSQDemoAvatarIdSquires = "053496-4509-289"
let kJSQDemoAvatarIdNameSupportTeam = "707-8956784-57"
let kJSQDemoAvatarDisplayNameSquires = UserName
let kJSQDemoAvatarDisplayNameSupportTeam = "Support Team"


class ViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChatAPIManagerDelegate, FileUploadAPIManagerDelegate {

    var messageModel: MessageModel = MessageModel()
    var subject: String = String()
    var ticketId: String = String()
    
    let picker = UIImagePickerController()
    var uploadImage: UIImage = UIImage()
    var temMessages: NSMutableArray = NSMutableArray()
    
    var sessionTimeOut: Bool = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeUI()
        
        initiateChatAPI()
        
        checkSessionTimeOut()
        
        //self.showLoadEarlierMessagesHeader = !ZDCChat.instance().session.dataSource().accountOnline()
        
        showEarlierMessages()
        
        createUploadFolder()
        
        
    }
    
    
    func customizeUI() {
        
        automaticallyScrollsToMostRecentMessage = true
        
        self.navigationItem.title = subject
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "End Chat", style: UIBarButtonItemStyle.Plain, target: self, action: "endChat")
        
        self.senderId = kJSQDemoAvatarIdSquires
        self.senderDisplayName = kJSQDemoAvatarDisplayNameSquires
        
        self.collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(100, 100)
        self.collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(100, 100)

        preChatInfo()
    }
    
    func initiateChatAPI() {
        
        ChatAPIManager.sharedManager.configureZopimChatSDK()
        ChatAPIManager.sharedManager.delegate = self
        ChatAPIManager.sharedManager.ticketId = ticketId
       
    }
    
    func preChatInfo() {
        
        let message: JSQMessage = JSQMessage(senderId: kJSQDemoAvatarIdNameSupportTeam, displayName: kJSQDemoAvatarDisplayNameSupportTeam, text: "Hi \(kJSQDemoAvatarDisplayNameSquires), how may i help you today")
        messageModel.messages.insertObject(message, atIndex: 0)
        
    }
    
    func createUploadFolder() {
        
        let error = NSErrorPointer()
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(
                NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload"),
                withIntermediateDirectories: true,
                attributes: nil)
        } catch let error1 as NSError {
            error.memory = error1
            print("Creating 'upload' directory failed. Error: \(error)")
        }

    }
    
    func showEarlierMessages() {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            
            ChatAPIManager.sharedManager.fetchMessages { (chatInfoData) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.messageModel.messages = chatInfoData
                    self.preChatInfo()
                    //self.showLoadEarlierMessagesHeader = !ZDCChat.instance().session.dataSource().accountOnline()
                    self.finishSendingMessageAnimated(false)
                    
                })
                
            }
            
        }
        
    }
 
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        collectionView!.collectionViewLayout.springinessEnabled = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    //MARK: ACTIONS
    
    override func didPressSendButton(button: UIButton!,
        withMessageText text: String!,
        senderId: String!,
        senderDisplayName: String!,
        date: NSDate!) {
            
            checkSessionTimeOut()
            
            //self.showLoadEarlierMessagesHeader = !ZDCChat.instance().session.dataSource().accountOnline()
            
            if NetworkAvailability.sharedInstance.hasConnectivity() {
                ChatAPIManager.sharedManager.sendChatMessage(text)
            }
            else {
                ChatAPIManager.sharedManager.sendOfflineChatMessage(text)
            }
            
            finishSendingMessageAnimated(true)
            
    }
    
    
    override func didPressAccessoryButton(sender: UIButton!) {
        print("Camera pressed!")
        
        showAttachmentMenu()
        
    }
        
    
    func endChat() {
        ChatAPIManager.sharedManager.endChat()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func checkSessionTimeOut() {
        if sessionTimeOut {
            sessionTimeOut = false
        }
    }
    
    //MARK: JSQMessageController Datasource
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messageModel.messages.objectAtIndex(indexPath.item) as! JSQMessageData
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message: JSQMessage = messageModel.messages.objectAtIndex(indexPath.item) as! JSQMessage
        if message.senderId == senderId {
            return messageModel.outgoingBubbleImageData
        } else {
            return messageModel.incomingBubbleImageData
        }
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message: JSQMessage = messageModel.messages.objectAtIndex(indexPath.item) as! JSQMessage
        if message.senderId == senderId {
            return JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "demo_avatar_cook.png"), diameter: 100)
        } else {
            return JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "demo_avatar_jobs.png"), diameter: 100)
        }

    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messageModel.messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        if cell.textView != nil {
            
            let message = messageModel.messages.objectAtIndex(indexPath.item) as! JSQMessage
            if message.senderId == senderId {
                cell.textView!.textColor = UIColor.whiteColor()
            } else {
                cell.textView!.textColor = UIColor.blackColor()
            }
                        
            let attributes : [String: AnyObject] =  [NSForegroundColorAttributeName: UIColor.blueColor(),
                NSFontAttributeName: UIFont(name: "Helvetica Neue", size: 15)!, NSUnderlineStyleAttributeName: 1]
            cell.textView!.linkTextAttributes = attributes

        }
        
        return cell
    }
    
    
    // View  usernames above bubbles
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        let message = messageModel.messages.objectAtIndex(indexPath.item) as! JSQMessage
        
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        let timeString = formatter.stringFromDate(message.date)

        let myAttributes1 = [ NSForegroundColorAttributeName: UIColor.darkGrayColor(), NSFontAttributeName: UIFont.boldSystemFontOfSize(8) ]
        
        // Sent by me, skip
        if message.senderId == senderId {
            let senderName = NSAttributedString(string: self.senderDisplayName + " " + timeString, attributes: myAttributes1)
            return senderName
        }
        else {
            let senderName = NSAttributedString(string: message.senderDisplayName + " " + timeString, attributes: myAttributes1)
            return senderName
        }
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        let message = messageModel.messages.objectAtIndex(indexPath.item) as! JSQMessage
        
        // Sent by me, skip
        if message.senderId == senderId {
            return CGFloat(0.0);
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messageModel.messages.objectAtIndex(indexPath.item - 1) as! JSQMessage
            if previousMessage.senderId == message.senderId {
                return CGFloat(0.0);
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 20.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        let message = messageModel.messages.objectAtIndex(indexPath.item) as! JSQMessage
                
        if (message.media != nil) {
            
            let mediaData = message.media
            
            if mediaData.isKindOfClass(JSQPhotoMediaItem){
              print("Tapped on image bubble")
                
            }
            else if mediaData.isKindOfClass(JSQVideoMediaItem) {
                print("Tapped on video bubble")
                
                let videoData = mediaData as! JSQVideoMediaItem
                
                if videoData.isFileUploaded {
                    
                    playVideoFromURL(videoData.fileURL)
                    
                }
                
            }
            
        }
        
    }
    
    //MARK: Attachment Menu
    func showAttachmentMenu() {
        
        let attachmentActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertControllerStyle.ActionSheet)
        
        attachmentActionSheet.addAction(UIAlertAction(title:"Camera", style:UIAlertActionStyle.Default, handler:{ action in
            self.presentPickerController(.Camera , mediaTypes:[kUTTypeImage as String])
        }))        
        attachmentActionSheet.addAction(UIAlertAction(title:"Photo", style:UIAlertActionStyle.Default, handler:{ action in
            self.presentPickerController(.PhotoLibrary, mediaTypes:[kUTTypeImage as String])
        }))
        attachmentActionSheet.addAction(UIAlertAction(title:"Video", style:UIAlertActionStyle.Default, handler:{ action in
            self.presentPickerController(.PhotoLibrary , mediaTypes:[kUTTypeMovie as String])
        }))
        attachmentActionSheet.addAction(UIAlertAction(title:"Cancel", style:UIAlertActionStyle.Cancel, handler:nil))
        presentViewController(attachmentActionSheet, animated:true, completion:nil)
        
    }
    
    func presentPickerController(sourceType: UIImagePickerControllerSourceType, mediaTypes: [String]) {
        
        self.picker.delegate = self
        self.picker.allowsEditing = false //2
        self.picker.sourceType = sourceType//3
        self.picker.mediaTypes = mediaTypes
        self.presentViewController(self.picker, animated: true, completion: nil)//4
        
    }
    
    //MARK: UIImagePickerDelegates
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        if mediaType == kUTTypeImage as String{
            let imageSelected = info[UIImagePickerControllerOriginalImage] as! UIImage //2
            
            self.uploadPhoto(imageSelected)

            
        }
        else if mediaType == kUTTypeMovie as String {
            
            let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
            
            self.uploadVideo(videoURL)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil) //5
        
        finishSendingMessageAnimated(true)

    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        self.dismissViewControllerAnimated(true, completion: nil) //5
        
    }
    
    //MARK: Upload Media Methods
    func uploadPhoto(chosenImage: UIImage) {
        
        let fileName: String = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".png")
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload").URLByAppendingPathComponent(fileName)
        let filePath = fileURL.path!
        let imageData = UIImagePNGRepresentation(chosenImage.resize(0.8))
        let messageDate = NSDate()
        
        imageData!.writeToFile(filePath, atomically: true)
        
        messageModel.messages.addObject(ChatMediaData.sharedInstance.addPhotoMediaMessage(filePath, senderId: kJSQDemoAvatarIdSquires, displayName: kJSQDemoAvatarDisplayNameSquires, date: messageDate, isfileUploaded: false))
        
        let messageInfo: ChatMessage = ChatMessage()
        messageInfo.ticketId = self.ticketId
        messageInfo.msgId = NSProcessInfo.processInfo().globallyUniqueString
        messageInfo.msgBody = AmazonS3URL + S3BucketName + "/" + fileName
        messageInfo.senderId = kJSQDemoAvatarIdSquires
        messageInfo.displayName = kJSQDemoAvatarDisplayNameSquires
        messageInfo.mediaFileURL = filePath
        messageInfo.msgType = MessageType.Image.rawValue
        messageInfo.eventType = EventType.VisitorMessage.rawValue
        messageInfo.timeStamp = messageDate
        messageInfo.isUploaded = false
        
        ChatInfoDataManager.sharedInstance.insertChatInfo(messageInfo, failureHandler: { (error) -> Void in
            
        })

    }
    
    func uploadVideo(mediaURL: NSURL) {
       
        let fileName: String = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".mov")
        let fileThumbnailName: String = fileName.stringByReplacingOccurrencesOfString(".mov", withString: ".png")
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload").URLByAppendingPathComponent(fileName)
        let fileThumnailURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload").URLByAppendingPathComponent(fileThumbnailName)
        let filePath = fileURL.path!
        let fileThumbnailPath = fileThumnailURL.path!
        let videoData = NSData(contentsOfURL: mediaURL)
        videoData?.writeToFile(filePath, atomically: true)
        let messageDate = NSDate()
        
        
        ChatMediaData.sharedInstance.loadThumbnail(mediaURL, completionBlock: { (image) -> Void in
            
            let videoData = NSData(data: UIImagePNGRepresentation(image)!)
            videoData.writeToFile(fileThumbnailPath, atomically: true)
            
            self.messageModel.messages.addObject(ChatMediaData.sharedInstance.addVideoMediaMessage(fileURL, videoThumbnailURL: fileThumnailURL, senderId: kJSQDemoAvatarIdSquires, displayName: kJSQDemoAvatarDisplayNameSquires, date: messageDate, isFileUploaded: false))
            
            let messageInfo: ChatMessage = ChatMessage()
            messageInfo.ticketId = self.ticketId
            messageInfo.msgId = NSProcessInfo.processInfo().globallyUniqueString
            messageInfo.msgBody = AmazonS3URL + S3BucketName + "/" + fileName
            messageInfo.senderId = kJSQDemoAvatarIdSquires
            messageInfo.displayName = kJSQDemoAvatarDisplayNameSquires
            messageInfo.mediaFileURL = filePath
            messageInfo.msgType = MessageType.Video.rawValue
            messageInfo.eventType = EventType.VisitorMessage.rawValue
            messageInfo.timeStamp = messageDate
            messageInfo.isUploaded = false
            messageInfo.thumbnailURL = fileThumnailURL.path
            
            ChatInfoDataManager.sharedInstance.insertChatInfo(messageInfo, failureHandler: { (error) -> Void in
                
            })
            
            self.finishSendingMessageAnimated(true)
            
        })

        
    }
    
    //MARK: Validate Camera Permission
    func validateCameraPermission() -> Bool {
        
        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        
        if status == AVAuthorizationStatus.Authorized {
            return true
        }
        else if status == AVAuthorizationStatus.Denied {
            
            UIAlertView(title: "Camera Permission Denied", message: "To re-enable, please go to Settings and turn on camera permission for this app.", delegate: self, cancelButtonTitle: "OK").show()
            return false
            
        }
        
        return true
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        if buttonIndex == 0 {
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }
        
    }
    
    //MARK: ChatAPIManager Delegate
    func connectionStatus(status: ZDCConnectionStatus) {
        
        switch (status)
        {
        case .Uninitialized:
            break
        case .Connecting:
            break
        case .Connected:
            break
        case .Disconnected:
            break
        case .Closed:
            break
        case .NoConnection:
            break
        }
        
    }
    
    func receivedMessagesEvent(messages: NSArray) {
        
        for chatMessage in messages {
            messageModel.messages.addObject(chatMessage)
        }
        
        //messageModel.messages = messages as! NSMutableArray
        //self.preChatInfo()
        //self.showLoadEarlierMessagesHeader = !ZDCChat.instance().session.dataSource().accountOnline()
        finishSendingMessageAnimated(true)
    }
    
    func agentEventData(agentInfo: NSDictionary) {
        
        if agentInfo.count > 0 {
            
            if (agentInfo.objectForKey(agentInfo.allKeys[0]) != nil) {
                self.showTypingIndicator = (agentInfo.objectForKey(agentInfo.allKeys[0])?.typing)!
                scrollToBottomAnimated(true)
            }

        }
        
    }
    
    func sessionTimeout() {
        initiateChatAPI()
        ZDCChat.instance().session.notifyVisitorActive()
        sessionTimeOut = true
    }
    
    //MARK: FileUploadManager Delegate
    func progressUpload(totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        SVProgressHUD.showProgress(Float(Double(totalBytesSent) / Double(totalBytesExpectedToSend)), status: "Uploading...")
    }
    
    func uploadSuccess(fileURL: String) {
        ChatAPIManager.sharedManager.sendChatMessage(fileURL)
        SVProgressHUD.dismiss()
    }
    
    func uploadFailed() {
        SVProgressHUD.showErrorWithStatus("Upload Failed")
    }
    
    
    func playVideoFromURL(videoPath: NSURL) {
        //filePath may be from the Bundle or from the Saved file Directory, it is just the path for the video
        let player: AVPlayer = AVPlayer(URL: videoPath)
        let playerViewController: AVPlayerViewController = AVPlayerViewController()
        playerViewController.player = player;
        self.navigationController!.presentViewController(playerViewController, animated: true) { () -> Void in
            playerViewController.player?.play()
        }
    }
    
    

}

