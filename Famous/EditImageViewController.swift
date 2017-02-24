//
//  EditImageViewController.swift
//  Famous
//
//  Created by Petr Shypila on 09/02/2017.
//  Copyright © 2017 Petr Shypila. All rights reserved.
//

import UIKit

class EditImageViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    private let SCALE_FACTOR = CGFloat(1.2)
    var photo: UIImage?
    
    var viewIntersectionStorage = [Int: Bool]()
    var viewTransformStorage = [Int: CGAffineTransform]()
    
    @IBOutlet weak var photoScrollView: UIScrollView!
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var photoView: UIImageView!

    @IBOutlet weak var trashBin: UIButton!
    
    @IBAction func saveImage(_ sender: Any) {
        
        //Create the UIImage
        let zoomVal = self.photoScrollView.zoomScale
        self.photoScrollView.zoomScale = 1.0
        
        UIGraphicsBeginImageContext(self.placeholderView.frame.size)
        self.placeholderView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.photoScrollView.zoomScale = zoomVal
        //Save it to the camera roll
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

    }
    
    @IBAction func goBack(_ sender: Any) {
        performSegueToReturnBack()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let activePhoto = self.photo {
            photoView.image = activePhoto
            self.placeholderView.clipsToBounds = true
            self.photoScrollView.delegate = self
            
        } else {
            print("Photo not set")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let stickerViewController = segue.destination as? StickerPickerViewController {
            stickerViewController.delegate = self
        }
    }

    private func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / self.photoView.bounds.width
        let heightScale = size.height / self.photoView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        self.photoScrollView.maximumZoomScale = 1.0
        self.photoScrollView.minimumZoomScale = minScale
        self.photoScrollView.zoomScale = minScale
    }
    
    func addStciker(_ sticker: UIImage, size stickerSize: CGSize, to parent: UIView) {
        let newSticker = createView(for: sticker, of: stickerSize, to: parent)
        
        addGestures(view: newSticker)
        parent.addSubview(newSticker)
    }
    
    private func createView(for stickerImage: UIImage, of size: CGSize, to parent: UIView) -> UIImageView {
        let newSticker = UIImageView(image: stickerImage)
        let parentCenterPoint = self.view.convert(self.view.center, to: self.placeholderView)
        
        let imageRatio = newSticker.image!.size.width / newSticker.image!.size.height
        let imageViewHeight = size.height / photoScrollView.zoomScale * SCALE_FACTOR
        let imageViewWidth = size.height / photoScrollView.zoomScale * imageRatio * SCALE_FACTOR
        
        newSticker.center = parentCenterPoint
        newSticker.contentMode = UIViewContentMode.scaleAspectFit
        newSticker.frame.size = CGSize(width: imageViewWidth, height: imageViewHeight)
        
        return newSticker
    }
}

extension EditImageViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return placeholderView
    }
}
