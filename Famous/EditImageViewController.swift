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
    
    @IBOutlet weak var watermark: UIImageView!
    @IBOutlet weak var watermarkWrapper: UIView!
    @IBOutlet weak var stickersButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var photoScrollView: UIScrollView!
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var saveImageButton: UIButton!
    
    @IBOutlet weak var watermarkWidth: NSLayoutConstraint!
    @IBOutlet weak var watermarkHeight: NSLayoutConstraint!
    @IBOutlet weak var watermarkBottomPadding: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var trashBinBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], target: nil)    

    @IBOutlet weak var trashBin: UIButton!
    
    @IBAction func saveImage(_ sender: Any) {
        sendEventAnalytics(event: joinArrStrings(stickers: placeholderView.subviews),
                           type: GAIActions.PRESS_BUTTON,
                           sessionQueue: self.sessionQueue)
        
        showAlertMsg(title: "Saved")
        
        //Create the UIImage
        let zoomVal = self.photoScrollView.zoomScale
        self.photoScrollView.zoomScale = 1.0
        
        UIGraphicsBeginImageContext(self.placeholderView.frame.size)
        self.watermarkWrapper.isHidden = false
        self.placeholderView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        self.watermarkWrapper.isHidden = true
        UIGraphicsEndImageContext()
        self.photoScrollView.zoomScale = zoomVal
        //Save it to the camera roll
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        sendEventAnalytics(event: "back-to-camera", type: GAIActions.PRESS_BUTTON, sessionQueue: self.sessionQueue)
        
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
            addBlur(to: self.watermarkWrapper)
            
            let backgroundPhoto = imageForScreen(self.photo)
            self.photoScrollView.backgroundColor = UIColor(patternImage: backgroundPhoto)
            
        } else {
            print("Photo not set")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.initialLayout = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.initialLayout == true {
            updateMinZoomScaleForSize(view.bounds.size)
            updateWatermarkView()
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
    
    private func updateWatermarkView() {
        self.watermark.image = UIImage(named: "ui.bundle/watermark.png")
        self.watermark.contentMode = .scaleAspectFit
        self.watermarkWidth.constant = self.photo.size.width / 12
        self.watermarkHeight.constant = self.watermarkWidth.constant * 5
        
        if isPortrait(image: self.photo) {
            let bottomPadding = self.watermarkHeight.constant / 8
            self.watermarkHeight.constant += bottomPadding
            self.watermarkBottomPadding.constant += bottomPadding
        }
        
    }
    
    private func isPortrait(image: UIImage) -> Bool {
        return image.size.width < image.size.height
    }
    
    private func joinArrStrings(stickers: [UIView]!) -> String! {
        var sticker_names = [String]()
        
        for s in stickers {
            if let stickerView = s as? UIImageView {
                
                if let imageName = stickerView.image?.accessibilityIdentifier {
                    sticker_names.append(imageName)
                }
            }
        }
        
        return sticker_names.joined(separator: ":")
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
