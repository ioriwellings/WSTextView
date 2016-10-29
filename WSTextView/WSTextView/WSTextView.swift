//
//  WSTextView.swift
//  Weibo
//
//  Created by OneZens on 16/1/27.
//  Copyright © 2016年 OneZens. All rights reserved.
//

import UIKit

/// 计算字体的size
func sizeOfText(_ text: String, font: UIFont, maxSize: CGSize) -> CGSize {
    
    return ((text as NSString)).boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil).size
}

@IBDesignable
class WSTextView: UITextView {
    
    @IBInspectable
    // 预读文本
    var placeHolderText: String? {
        
        didSet {
            
            placeHolderLbl.text = placeHolderText
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        
        didSet {
            
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }
    //光标在水平位置的偏移距离
    var cursorOffsetX : CGFloat = 0 {
        didSet{
            let leadingMargin: CGFloat = 5 + cursorOffsetX
            let topMargin: CGFloat = 8
            placeHolderLbl.frame.origin = CGPoint(x: leadingMargin, y: topMargin)
            placeHolderLbl.frame.size = sizeOfText(placeHolderText!, font: placeHolderLbl.font, maxSize: CGSize(width: self.frame.width - leadingMargin * 2, height: CGFloat(MAXFLOAT)))
            textContainerInset = UIEdgeInsetsMake(textContainerInset.top, textContainerInset.left + cursorOffsetX, textContainerInset.bottom, textContainerInset.right + cursorOffsetX)
        }
    }
    
    // 显示的文字
    override var text: String? {
        
        didSet {
            
            placeHolderLbl.isHidden = self.hasText
        }
    }
    
    // 字体
    override var font: UIFont? {
        
        didSet {
            
            placeHolderLbl.font = font
        }
    }
    
    //最大能够添加的图片个数
    var maxInsertImageCount = 0
    var textFrame: CGRect = CGRect.zero
    
    // MARK: - init
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override func insertText(_ text: String) {
        
        super.insertText(text)
        delegate?.textViewDidChange?(self)
    }
    override func deleteBackward() {
        
        super.deleteBackward()
        delegate?.textViewDidChange?(self)
    }
    
    // MARK: - private method
    fileprivate func setupUI() {
        
        // 添加通知，监听当前的文字编辑情况
        NotificationCenter.default.addObserver(self, selector: #selector(WSTextView.valueChange), name: NSNotification.Name.UITextViewTextDidChange, object: self)
        
        placeHolderText = "placeHolderText"
        addSubview(placeHolderLbl)
        let topMargin: CGFloat = 8
        let leadingMargin: CGFloat = 5 + cursorOffsetX
        placeHolderLbl.frame.origin = CGPoint(x: leadingMargin, y: topMargin)
        placeHolderLbl.frame.size = sizeOfText(placeHolderText!, font: placeHolderLbl.font, maxSize: CGSize(width: self.frame.width - leadingMargin * 2, height: CGFloat(MAXFLOAT)))
        self.font = UIFont.systemFont(ofSize: 15)
        
    }
    
    @objc fileprivate func valueChange() {
        
        placeHolderLbl.isHidden = self.hasText
        let fixWidth = frame.width
        let newSize = sizeThatFits(CGSize(width: fixWidth, height: CGFloat(MAXFLOAT)))
        let newFrame = CGRect(origin: frame.origin, size: CGSize(width: fixWidth, height: newSize.height))
        self.textFrame = newFrame
        
    }
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - lazy loading
    
    fileprivate lazy var placeHolderLbl: UILabel = {
        
        let lbl = UILabel()
        lbl.textColor = UIColor.gray
        lbl.numberOfLines = 0
        return lbl
    }()
    
    var imageAttachement: [UIImage] {
        
        var images = [UIImage]()
        
        self.attributedText.enumerateAttributes(in: NSMakeRange(0, self.attributedText.length), options: .reverse) { (attri, range, _) -> Void in
            
            if attri["NSAttachment"] != nil {
                
                let attachment = attri["NSAttachment"] as! WSTextAttachment
                if attachment.attachmentType == .image {
                    
                    images.append(attachment.image!)
                }
            }
        }
        
        return images
    }
}


// MARK: - 文本操作 insertImage
extension WSTextView {
    
    ///  插入一个表情，图片可以是一个自定义表情，按当前的文字大小为尺寸来显示
    ///
    ///  - parameter image:表情图片
    func insertEmotionImage(_ image: UIImage) {
        
        let lineWidth = (self.font?.lineHeight)!
        insertImage(image, imageSize: CGSize(width: lineWidth, height: lineWidth), isEmotion: true)
    }
    
    ///  添加一张图片，图片大小按宽度的96%来等比缩放（96%，图片在中间😂）
    ///
    ///  - parameter image: 要添加的图片
    func insertImage(_ image: UIImage) {
        
        if self.imageAttachement.count >= maxInsertImageCount {
            
            return
        }
        let width = self.bounds.width * 0.96
        self.insertImage(image, imageSize: CGSize(width: width, height: (image.size.height / image.size.width) * width))
    }
    
    fileprivate func insertImage(_ image: UIImage, imageSize: CGSize, isEmotion: Bool = false) {
        
        let attachement = WSTextAttachment()
        attachement.attachmentType = isEmotion ? .emotion : .image
        attachement.image = image
        // let lineWidth = (self.font?.lineHeight)!
        attachement.bounds = CGRect(origin: CGPoint.zero, size: imageSize)
        
        //获取原始的富文本
        let originalAttr = NSMutableAttributedString(attributedString: self.attributedText)
        
        //后去当前光标的位置，并且替换文本
        var range = self.selectedRange
        originalAttr.replaceCharacters(in: range, with: NSAttributedString(attachment: attachement))
        
        //保持原先的文字的大小，没有这句话图片文字会在下次输入的时候变小
        originalAttr.addAttribute(NSFontAttributeName, value: self.font!, range: NSMakeRange(0, originalAttr.length))
        
        self.attributedText = originalAttr
        
        //让光标回到下一个位置
        range.location += 1
        range.length = 0
        selectedRange = range
        
        //发送通知和代理
        NotificationCenter.default.post(name: NSNotification.Name.UITextViewTextDidChange, object: self)
        delegate?.textViewDidChange?(self)
        
        if !isEmotion {
            //添加一个换行
            self.insertText("\n")
        }
    }
    
}


/************************** NSTextAttachment *******************************/

enum WSTextAttachmentType: Int {
    case `default`    =   0
    case image      =   1
    case emotion    =   2
}


class WSTextAttachment: NSTextAttachment {
    
    var attachmentType: WSTextAttachmentType = .default
    
}

