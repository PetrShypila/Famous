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
    
    func addBlur(to view: UIView) {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
    }
    
    func addShadow(_ button: UIView, width: Int, height: Int) {
        button.layer.shadowRadius = 2
        button.layer.shadowOpacity = 0.8
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: width, height: height)
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
}
