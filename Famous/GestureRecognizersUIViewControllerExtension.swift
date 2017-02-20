//
//  GestureRecognizersUIViewControllerExtension.swift
//  Famous
//
//  Created by Petr Shypila on 19/02/2017.
//  Copyright © 2017 Petr Shypila. All rights reserved.
//
import UIKit
import Foundation

extension EditImageViewController {
    
    func addGestures(view: UIView) {
        let scaleGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.scaleImage(_:)))
        view.addGestureRecognizer(scaleGesture)
        scaleGesture.delegate = self
        
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(self.rotateImage(_:)))
        view.addGestureRecognizer(rotateGesture)
        rotateGesture.delegate = self
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panImage(_:)))
        view.addGestureRecognizer(panGesture)
        
        view.isUserInteractionEnabled = true
    }

    func scaleImage(_ sender: UIPinchGestureRecognizer) {
        if let targetView = sender.view as? UIImageView {
            
            targetView.transform = targetView.transform.scaledBy(x: sender.scale, y: sender.scale)
            sender.scale = 1
        }
    }
    
    func panImage(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: self.view)
        if let view = sender.view {
            view.center = CGPoint(x:view.center.x + translation.x / self.photoScrollView.zoomScale,
                                  y:view.center.y + translation.y / self.photoScrollView.zoomScale)
        }
        
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    func rotateImage(_ sender : UIRotationGestureRecognizer) {
        
        if let targetView = sender.view as? UIImageView {
            
            targetView.transform = targetView.transform.rotated(by: sender.rotation)
            sender.rotation = 0
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
