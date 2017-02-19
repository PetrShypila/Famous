//
//  EditImageViewController.swift
//  Famous
//
//  Created by Petr Shypila on 09/02/2017.
//  Copyright © 2017 Petr Shypila. All rights reserved.
//

import UIKit

class EditImageViewController: UIViewController, UIScrollViewDelegate {
    var photo: UIImage?
    var stickers = [UIImageView]()
    
    @IBOutlet weak var photoScrollView: UIScrollView!
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var photoView: UIImageView!

    @IBAction func saveImage(_ sender: Any) {
        
        //Create the UIImage
        let zoomVal = photoScrollView.zoomScale
        photoScrollView.zoomScale = 1.0
        
        UIGraphicsBeginImageContext(placeholderView.frame.size)
        placeholderView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        photoScrollView.zoomScale = zoomVal
        //Save it to the camera roll
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

    }
    
    @IBAction func goBack(_ sender: Any) {
        stickers = [UIImageView]()
        performSegueToReturnBack()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let activePhoto = self.photo {
            photoView.image = activePhoto
            
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
        
        let newSticker = UIImageView(image: sticker)
        let parentCenterPoint = CGPoint(x: parent.bounds.width/2, y: parent.bounds.height/2) //parent.convert(parent.center, from: parent.superview)
        
        newSticker.backgroundColor = UIColor.blue
        newSticker.center = parentCenterPoint
        newSticker.contentMode = UIViewContentMode.scaleAspectFit
        newSticker.frame.size = CGSize(width: stickerSize.width / photoScrollView.zoomScale, height: stickerSize.height / photoScrollView.zoomScale)
        
        addGestures(view: newSticker)
        parent.addSubview(newSticker)
    }
}

extension EditImageViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return placeholderView
    }
}
