//
//  StickerPickerViewController.swift
//  Famous
//
//  Created by Petr Shypila on 13/02/2017.
//  Copyright © 2017 Petr Shypila. All rights reserved.
//

import UIKit

class StickerPickerViewController: UIViewController {
    
    weak var delegate: EditImageViewController!
    @IBOutlet weak var stickerView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        createPinchGestureFor(sticker: stickerView)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createPinchGestureFor(sticker: UIImageView) {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.sendImageBackTo(_:)))
        sticker.addGestureRecognizer(gesture)
        sticker.isUserInteractionEnabled = true
    }
    
    //_ sender: UIPinchGestureRecognizer
    func sendImageBackTo(_ sender: UITapGestureRecognizer) {
        
        if let targetView = sender.view as? UIImageView {
            if let sticker = targetView.image {
                delegate.add(sticker: sticker)
                performSegueToReturnBack()
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
