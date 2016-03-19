//
//  ViewController.swift
//  WSTextView
//
//  Created by WackoSix on 3/8/16.
//  Copyright © 2016 www.wackosix.cn. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var toolViewHeight: NSLayoutConstraint!
    @IBOutlet weak var toolViewBottom: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var contentView: WSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "kbFrameWillChange:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        self.contentView.delegate = self
        self.contentView.maxInsertImageCount = 2
        self.contentView.scrollEnabled = false
        
    }
    deinit{
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @IBAction func photoBtnClick(sender: AnyObject) {
        
        let imageVC = UIImagePickerController()
        imageVC.delegate = self
        self.presentViewController(imageVC, animated: true, completion: nil)
    }

    @IBAction func sendBtnClick(sender: AnyObject) {
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.contentView.insertImage(image)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - private method
    @objc private func kbFrameWillChange(noti: NSNotification) {
        
        
        let kbY = (noti.userInfo!["UIKeyboardFrameEndUserInfoKey"] as! NSValue).CGRectValue().origin.y
        self.toolViewBottom.constant = self.view.frame.height - kbY
        UIView.animateWithDuration(0.25) { () -> Void in
            self.view.layoutIfNeeded()
        }
        
    }
    
    func textViewDidChange(textView: UITextView) {
        self.contentViewHeight.constant = contentView.textFrame.height
        self.toolViewHeight.constant = 44 + (contentView.textFrame.height - 34)
    }
    
}

