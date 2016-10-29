//
//  ViewController.swift
//  WSTextView
//
//  Created by OneZens on 3/8/16.
//  Copyright © 2016 www.onezen.cc. All rights reserved.
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
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.kbFrameWillChange(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        self.contentView.delegate = self
        self.contentView.maxInsertImageCount = 2
        self.contentView.isScrollEnabled = false
        self.contentView.cursorOffsetX = 10
        
    }
    deinit{
        
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func photoBtnClick(_ sender: AnyObject) {
        
        let imageVC = UIImagePickerController()
        imageVC.delegate = self
        self.present(imageVC, animated: true, completion: nil)
    }

    @IBAction func sendBtnClick(_ sender: AnyObject) {
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.contentView.insertImage(image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - private method
    @objc fileprivate func kbFrameWillChange(_ noti: Notification) {
        
        
        let kbY = ((noti as NSNotification).userInfo!["UIKeyboardFrameEndUserInfoKey"] as! NSValue).cgRectValue.origin.y
        self.toolViewBottom.constant = self.view.frame.height - kbY
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) 
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        //让输出框的大小根据内容的大小变化
        self.contentViewHeight.constant = contentView.textFrame.height
        self.toolViewHeight.constant = 44 + (contentView.textFrame.height - 34)
    }
    
}

