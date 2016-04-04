//
//  Extensions.swift
//  ChatUI
//
//  Created by Basawaraj on 28/03/16.
//  Copyright © 2016 Basawaraj. All rights reserved.
//

import Foundation

//UIImage Extensions
extension UIImage {
    
    func resize(scale:CGFloat)-> UIImage {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width*scale, height: size.height*scale)))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    func resizeToWidth(width:CGFloat)-> UIImage {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
}

//String Extensions
extension String {
    
    func isUrl() -> Bool {
        
        // create NSURL instance
        if let url = NSURL(string: self) {
            // check if your application can open the NSURL instance
            let isValid = UIApplication.sharedApplication().canOpenURL(url)
            
            return isValid
        }
        
        return false
    }
    
    func fileExtension() -> String {
        
        let filePathURL = NSURL(string: self)
        let fileComponent: NSString = (filePathURL?.lastPathComponent)!
        
        return fileComponent.pathExtension
        
    }
    
    func MIMEType() -> String?
    {
        let fileExtension = self.fileExtension()
        
        if !fileExtension.isEmpty {
            let UTIRef = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, nil)
            let UTI = UTIRef!.takeUnretainedValue()
            UTIRef!.release()
            
            let MIMETypeRef = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType)
            if MIMETypeRef != nil
            {
                let MIMEType = MIMETypeRef!.takeUnretainedValue()
                MIMETypeRef!.release()
                return MIMEType as String
            }
        }
        return nil
    }


    
}