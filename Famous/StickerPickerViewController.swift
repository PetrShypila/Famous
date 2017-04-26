//
//  StickerPickerViewController.swift
//  Famous
//
//  Created by Petr Shypila on 13/02/2017.
//  Copyright © 2017 Petr Shypila. All rights reserved.
//
import UIKit
import Darwin

class StickerPickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let ROW_HEIGHT = CGFloat(100.0)
    private let STICKERS_BUNDLE = "stickers.bundle"
    private let STICKERS_PER_ROW = 2
    private let cellSpacingHeight = CGFloat(20)
    private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], target: nil)
    
    private var stickerViews: [UIImage]!
    
    weak var delegate: EditImageViewController!
    weak var backgroundImage: UIImage!
    
    @IBOutlet weak var stickersTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    @IBAction func performBack(_ sender: Any) {
        self.sendEventAnalytics(event: "back-from-stickers", type: GAIActions.PRESS_BUTTON, sessionQueue: self.sessionQueue)
        
        performSegueToReturnBack()
    }
    
    private func loadStickersImages(from boundle: String) -> [UIImage] {
        var stickers = [UIImage]()
        
        let fileManager = FileManager.default
        let bundleURL = Bundle.main.bundleURL
        let assetURL = bundleURL.appendingPathComponent(boundle)
        let contents = try! fileManager.contentsOfDirectory(at: assetURL,
                                                            includingPropertiesForKeys: [URLResourceKey.nameKey,
                                                                                         URLResourceKey.isDirectoryKey],
                                                            options: .skipsHiddenFiles)
        
        for img in contents {
            if let sticker = UIImage(named: "\(boundle)/\(img.lastPathComponent)") {
                sticker.accessibilityIdentifier = img.lastPathComponent
                stickers.append(sticker)
            }
        }
        
        return stickers
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stickerViews = loadStickersImages(from: STICKERS_BUNDLE)
        self.stickersTableView.backgroundColor = UIColor.clear
        
        let background = imageForScreen(self.backgroundImage)
        self.view.backgroundColor = UIColor(patternImage: background)
        
        addBlur(to: [self.view])
        addShadow(to: [self.backButton])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return stickerViews.count/2 + stickerViews.count % 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.clear
        cell.frame.size.height = cell.frame.size.height * 3
        let startIdx = indexPath.section * STICKERS_PER_ROW
        let endIdx = min(startIdx+STICKERS_PER_ROW, stickerViews.count)
        
        if startIdx < endIdx {
            
            let stickersStack = UIStackView(frame: cell.bounds)
            stickersStack.alignment = .fill
            stickersStack.axis = .horizontal
            stickersStack.distribution = .fillEqually
            stickersStack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            for idx in startIdx..<endIdx  {
                let stickerView = UIImageView(image: stickerViews[idx])
                stickerView.frame.size.height = cell.frame.size.height
                stickerView.frame.size.width = cell.frame.size.width / 4
                stickerView.contentMode = UIViewContentMode.scaleAspectFit
                
                createPinchGestureFor(sticker: stickerView)
                stickersStack.addArrangedSubview(stickerView)
            }
            cell.addSubview(stickersStack)
        }
        return cell
    }
    
    func createPinchGestureFor(sticker: UIImageView) {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.sendImageBackTo(_:)))
        sticker.addGestureRecognizer(gesture)
        sticker.isUserInteractionEnabled = true
    }
    
    func sendImageBackTo(_ sender: UITapGestureRecognizer) {
        
        if let targetView = sender.view as? UIImageView {
            if let sticker = targetView.image {
                
                self.sendEventAnalytics(event: sticker.accessibilityIdentifier!, type: GAIActions.ADD_STICKER, sessionQueue: self.sessionQueue)
                
                delegate.addStciker(sticker, size: targetView.frame.size, to: delegate.placeholderView)
                performSegueToReturnBack()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        stickersTableView.rowHeight = ROW_HEIGHT
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
