# WSTextView
UITextview 的子类，可以根据输入的文字动态变化大小，插入图片，获取图片，PlaceHolder

# 效果演示

![](http://7xq8l3.com1.z0.glb.clouddn.com/textView.gif)
# 用法

 * 首先通过storyboard拖控件，然后关联类，在storyboard中可以设置CornerRadius、placeHolderText等
 * 关联类之后设置属性和代理
 * 设置最大的可添加的图片数：self.textView.maxInsertImageCount = 2
 * 通过属性： `var imageAttachement: [UIImage] ` 来获取添加的图片
 * 实现代理方法，监听输入的内容变化后textframe(内容大小变化)的变化
 
 ```
    func textViewDidChange(textView: UITextView) {
        //让输出框的大小根据内容的大小变化
        self.contentViewHeight.constant = contentView.textFrame.height
        self.toolViewHeight.constant = 44 + (contentView.textFrame.height - 34)
    }
    
 	
 ```
 

