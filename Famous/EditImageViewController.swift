//
//  EditImageViewController.swift
//  Famous
//
//  Created by Petr Shypila on 09/02/2017.
//  Copyright © 2017 Petr Shypila. All rights reserved.
//

import UIKit

class EditImageViewController: UIViewController, UIScrollViewDelegate {
    var photoData: Data?
    var photoView: UIView!
    var stickers = [UIImageView]()
    
    @IBOutlet weak var photoScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let photoData = self.photoData {
            let photo = UIImage(data: photoData)
            photoView = UIImageView(image: photo)
            
            self.photoScrollView.contentSize = photoView.bounds.size
            self.photoScrollView.addSubview(photoView)
            self.photoScrollView.delegate = self
            
            setZoomScale(view.bounds.size)
        } else {
            print("Photo not set")
        }
    }
    
    
    
    @IBAction func goBack(_ sender: Any) {
        performSegueToReturnBack()
    }
    
    func add(sticker: UIImage) {
        
        let newSticker = UIImageView(image: sticker)
        photoScrollView.addSubview(newSticker)
        addGestures(view: newSticker)
        stickers.append(newSticker)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let stickerViewController = segue.destination as? StickerPickerViewController {
            stickerViewController.delegate = self
        }
 
    }
    
    func scaleImage(_ sender: UIPinchGestureRecognizer) {
        
        if let targetView = sender.view as? UIImageView {
        
            targetView.transform = targetView.transform.scaledBy(x: sender.scale, y: sender.scale)
            sender.scale = 1
        }
    }
    
    func panImage(_ sender: UIPanGestureRecognizer) {
        
        if let targetView = sender.view as? UIImageView {
            
            let translation = sender.translation(in: targetView)
            if let view = sender.view {
                view.center = CGPoint(x:view.center.x + translation.x,
                                      y:view.center.y + translation.y)
            }
            
            sender.setTranslation(CGPoint.zero, in: targetView)
        }
    }
    
    func rotateImage(_ sender : UIRotationGestureRecognizer) {
        
        if let targetView = sender.view as? UIImageView {
        
            targetView.transform = targetView.transform.rotated(by: sender.rotation)
            sender.rotation = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.photoView
    }
    
    override func viewWillLayoutSubviews() {
        setZoomScale(view.bounds.size)
    }
    
    func addGestures(view: UIView) {
        let scaleGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.scaleImage(_:)))
        view.addGestureRecognizer(scaleGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panImage(_:)))
        view.addGestureRecognizer(panGesture)
        
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(self.rotateImage(_:)))
        view.addGestureRecognizer(rotateGesture)
        
        view.isUserInteractionEnabled = true
    }
    
    func setZoomScale(_ size: CGSize) {
        let widthScale = size.width / self.photoView.bounds.width
        let heightScale = size.height / self.photoView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        self.photoScrollView.minimumZoomScale = minScale
        self.photoScrollView.zoomScale = minScale
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let imageViewSize = self.photoView.frame.size
        let scrollViewSize = self.photoScrollView.bounds.size
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        self.photoScrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding,
                                                         bottom: verticalPadding, right: horizontalPadding)
    }
}

extension UIViewController {
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
