//
//  CameraViewControllerExtension.swift
//  Famous
//
//  Created by Petr Shypila on 18/02/2017.
//  Copyright © 2017 Petr Shypila. All rights reserved.
//
import UIKit
import Photos
import Foundation

extension UIViewController {
    
    func sendScreenAnalytics(screen name: String, sessionQueue: DispatchQueue) {
        sessionQueue.async {
            
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.set(kGAIDescription, value: name)
                
                let eventTracker: NSObject = GAIDictionaryBuilder.createScreenView().build()
                tracker.send(eventTracker as! [NSObject : AnyObject])
            }
        }
    }
    
    func addBlur(to view: UIView) {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
    }
    
    func updateBlurConstraints(for view: UIView) {
        let blurEffectView = view.subviews[0]
        blurEffectView.frame = view.bounds
    }
    
    func imageForScreen(_ image: UIImage) -> UIImage {
        UIGraphicsBeginImageContext(self.view.frame.size);
        image.draw(in: self.view.bounds)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return scaledImage!
    }
    
    func addShadow(_ button: UIView) {
        button.layer.shadowRadius = 5
        button.layer.shadowOpacity = 0.5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
    }
    
    func updateImageToLastPhoto(_ rollButton: UIButton) {
        
        let imgManager = PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        // If the fetch result isn't empty,
        // proceed with the image request
        if fetchResult.count > 0 {
            // Perform the image request
            imgManager.requestImage(for: fetchResult.object(at: fetchResult.count - 1) as PHAsset, targetSize: view.frame.size, contentMode: .aspectFill, options: requestOptions, resultHandler: { (img, _) in
                
                if img != nil {
                    rollButton.setBackgroundImage(img, for: .normal)
                } else {
                    rollButton.backgroundColor = UIColor.white
                }
            })
        }

    }    
    
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func showAlertMsg(title: String){
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        alertController.view.subviews.first!.alpha = 1.0
        
        self.present(alertController, animated: true, completion: nil)
        
        let delay = DispatchTime.now() + .seconds(1)
        
        DispatchQueue.main.asyncAfter(deadline: delay, execute: {
            alertController.dismiss(animated: true, completion: nil)
        })
    }
}
