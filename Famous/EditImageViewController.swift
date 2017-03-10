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
    private var initialLayout = true
    
    var photo: UIImage!
    
    var viewIntersectionStorage = [Int: Bool]()
    var viewTransformStorage = [Int: CGAffineTransform]()
    
    @IBOutlet weak var stickersButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var photoScrollView: UIScrollView!
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var saveImageButton: UIButton!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var trashBinBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    

    @IBOutlet weak var trashBin: UIButton!
    
    @IBAction func saveImage(_ sender: Any) {
        
        //Create the UIImage
        let zoomVal = self.photoScrollView.zoomScale
        self.photoScrollView.zoomScale = 1.0
        
        showAlertMsg(title: "Saved!")
        
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
            
            addShadow(self.photoScrollView)
            addShadow(self.cancelButton)
            addShadow(self.saveImageButton)
            addShadow(self.stickersButton)
            
            addBlur(to: self.photoScrollView)
            
            let backgroundPhoto = imageForScreen(self.photo)
            self.photoScrollView.backgroundColor = UIColor(patternImage: backgroundPhoto)
            
        } else {
            print("Photo not set")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.initialLayout = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.initialLayout == true {
            updateMinZoomScaleForSize(view.bounds.size)
        }
        
        self.trashBinBottomConstraint.constant = self.scrollViewBottomConstraint.constant + self.bottomConstraint.constant + 10
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let stickerViewController = segue.destination as? StickerPickerViewController {
            stickerViewController.delegate = self
            stickerViewController.backgroundImage = self.photo
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateBlurConstraints(for: scrollView)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateBlurConstraints(for: scrollView)
        updateConstraintsFor(size: scrollView.frame.size)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.view.setNeedsUpdateConstraints()
    }

    private func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / self.photoView.bounds.width
        let heightScale = size.height / self.photoView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        self.photoScrollView.maximumZoomScale = 1.0
        self.photoScrollView.minimumZoomScale = minScale
        self.photoScrollView.zoomScale = minScale
    }
    
    private func updateConstraintsFor(size: CGSize) {
        
        let yOffset = max(0, (size.height - self.placeholderView.frame.height) / 2)
        self.topConstraint.constant = yOffset
        self.bottomConstraint.constant = yOffset
        
        self.view.layoutIfNeeded()
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension EditImageViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return placeholderView
    }
}
