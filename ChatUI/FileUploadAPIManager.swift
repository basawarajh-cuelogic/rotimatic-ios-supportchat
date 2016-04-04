//
//  FileUploadAPIManager.swift
//  ChatUI
//
//  Created by Basawaraj on 21/03/16.
//  Copyright © 2016 Basawaraj. All rights reserved.
//

import UIKit

let CognitoRegionType = AWSRegionType.USEast1  // e.g. AWSRegionType.USEast1
let DefaultServiceRegionType = AWSRegionType.USEast1 // e.g. AWSRegionType.USEast1
let CognitoIdentityPoolId = "us-east-1:4d8d59d9-0bb9-4953-9db4-4932df160e5d"
let S3BucketName = "mobile-chat-resources-dev/ios"
let AmazonS3URL = "https://s3.amazonaws.com/"

@objc protocol FileUploadAPIManagerDelegate {
    
    func progressUpload(totalBytesSent: Int64, totalBytesExpectedToSend: Int64);
    func uploadSuccess(fileURL: String)
    func uploadFailed()
    
}

@objc class FileUploadAPIManager: NSObject {

    var uploadRequest = AWSS3TransferManagerUploadRequest()
    var uploadFileURLs = Array<NSURL?>()
    var delegate: FileUploadAPIManagerDelegate?

    
    func uploadRequest(fileURL: NSURL?, fileName: String?) -> AWSS3TransferManagerUploadRequest {
        
        uploadRequest.body = fileURL
        uploadRequest.key = fileName
        uploadRequest.bucket = S3BucketName
    
       return uploadRequest
    }
    
    func uploadFile(uploadRequest: AWSS3TransferManagerUploadRequest) {
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        uploadRequest.uploadProgress = { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if totalBytesExpectedToSend > 0 {
                    self.delegate!.progressUpload(totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
                }
            })
        }

        
        transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject! in
            if let error = task.error {
                if error.domain == AWSS3TransferManagerErrorDomain as String {
                    if let errorCode = AWSS3TransferManagerErrorType(rawValue: error.code) {
                        switch (errorCode) {
                        case .Cancelled, .Paused:
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            })
                            break;
                            
                        default:
                            print("upload() failed: [\(error)]")
                            self.delegate?.uploadFailed()
                            break;
                        }
                    } else {
                        print("upload() failed: [\(error)]")
                        self.delegate?.uploadFailed()
                    }
                } else {
                    print("upload() failed: [\(error)]")
                    self.delegate?.uploadFailed()
                }
            }
            
            if let exception = task.exception {
                print("upload() failed: [\(exception)]")
                self.delegate?.uploadFailed()
            }
            
            if task.result != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    let url = AmazonS3URL + S3BucketName + "/" + uploadRequest.key!
                    
                    self.delegate!.uploadSuccess(url)
                })
            }
            return nil
        }
        
    }
    
    func cancelUpload(uploadRequet: AWSS3TransferManagerUploadRequest) {
        
        uploadRequest.cancel().continueWithBlock({ (task) -> AnyObject! in
            if let error = task.error {
                print("cancel() failed: [\(error)]")
            }
            else if let exception = task.exception {
                print("cancel() failed: [\(exception)]")
            }
            else {
                self.delegate?.uploadFailed()
            }
            return nil
        })
        
    }

    
    
    
    
}
