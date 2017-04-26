//
//  InstagramManager.swift
//  Famous
//
//  Created by Petr Shypila on 24/04/2017.
//  Copyright © 2017 Petr Shypila. All rights reserved.
//

import UIKit
import Foundation

class InstagramManager: NSObject, UIDocumentInteractionControllerDelegate {
    
    private let kInstagramURL = "instagram://app"
    private let kUTI = "com.instagram.photo"
    private let kfileNameExtension = "instagram.ig"
    private let kAlertViewTitle = "Error"
    private let kAlertViewMessage = "Please install the Instagram application"
    
    private let documentInteractionController = UIDocumentInteractionController()
    
    // singleton manager
    class var sharedManager: InstagramManager {
        struct Singleton {
            static let instance = InstagramManager()
        }
        return Singleton.instance
    }
    
    func postImageToInstagramWithCaption(imageInstagram: UIImage, instagramCaption: String, view: UIView, vc: UIViewController) {
        // called to post image with caption to the instagram application
        
        let instagramURL = URL(string: kInstagramURL)
        if UIApplication.shared.canOpenURL(instagramURL!) {
            
            let jpgPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(kfileNameExtension)
            do {
                let jpgImage = UIImageJPEGRepresentation(imageInstagram, 1.0)
                try jpgImage!.write(to: jpgPath)
                let rect = CGRect(x:0, y:0, width:612, height:612)
                
                documentInteractionController.uti = kUTI
                documentInteractionController.url = jpgPath
                documentInteractionController.delegate = self
                
                // adding caption for the image
                documentInteractionController.annotation = ["InstagramCaption": instagramCaption]
                documentInteractionController.presentOpenInMenu(from: rect, in: view, animated: true)
            } catch {
                print(" Cannot save image. \(error)")
            }
        } else {
            
            // alert displayed when the instagram application is not available in the device
            UIAlertController(title: kAlertViewTitle, message: kAlertViewMessage, preferredStyle: UIAlertControllerStyle.alert).show(vc, sender: nil)
            
        }
    }
    
    
}
