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
        trashBinCheck(sender)
        
        if let stickerView = sender.view as? UIImageView {
            
            let translation = sender.translation(in: self.view)
            stickerView.center = CGPoint(x:stickerView.center.x + translation.x / self.photoScrollView.zoomScale,
                                         y:stickerView.center.y + translation.y / self.photoScrollView.zoomScale)
            
            sender.setTranslation(CGPoint.zero, in: self.view)
            
            processView(from: sender)
        }
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
    
    func trashBinCheck(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            self.trashBin.isHidden = false
        } else if sender.state == .ended {
            self.trashBin.isHidden = true
        }
    }
    
    func intersect(_ gesture: UIGestureRecognizer, with view: UIView) -> Bool {
        // Transform from scaled space to screen space
        //let stickerOrigin = view.superview!.convert(view.frame, to: nil)
        let touchPoint = gesture.location(in: view.superview!)
        
        print("intersects ", view.frame.contains(touchPoint))
        
        return view.frame.contains(touchPoint)
    }
    
    func processView(from gesture: UIGestureRecognizer) {
        if let stickerView = gesture.view {
            
            // If sticker intersects with trash bin
            if intersect(gesture, with: self.trashBin) {
                
                // Animate downscale image
                UIView.animate(withDuration: 0.5,
                               delay: 1.0,
                               options: .beginFromCurrentState,
                               animations: {
                                
                                if self.intersect(gesture, with: self.trashBin) {
                                    // Flag intersection
                                    self.viewIntersectionStorage[stickerView.hash] = true
                                    
                                    //Store its scale and rotation state
                                    if self.viewTransformStorage[stickerView.hash] == nil {
                                        self.viewTransformStorage[stickerView.hash] = stickerView.transform
                                    }
                                    
                                    stickerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                                    
                                    if gesture.state == .ended {
                                        stickerView.removeFromSuperview()
                                    }
                                }
                               },
                               completion: nil)
                
                // If not intersected anymore - restore scale to previous one.
            } else if let stickerIntersected = self.viewIntersectionStorage[stickerView.hash], stickerIntersected == true {
                
                //Check if previous state saved
                if let previousTransform = self.viewTransformStorage[stickerView.hash] {
                    
                    // Restore to original state
                    UIView.animate(withDuration: 0.5,
                                   delay: 1.0,
                                   options: .beginFromCurrentState,
                                   animations: {
                                    
                                    if !self.intersect(gesture, with: self.trashBin) {
                                        stickerView.transform = previousTransform
                                        self.viewTransformStorage[stickerView.hash] = nil
                                    }
                                    
                                   },
                                   completion: nil)
                }
                
                // Set back to false
                self.viewIntersectionStorage[stickerView.hash] = false
            }
        }
    }
}
