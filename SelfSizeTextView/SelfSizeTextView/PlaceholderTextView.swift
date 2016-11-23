//
//  PlaceholderTextView.swift
//  SelfSizeTextView
//
//  Created by luojie on 16/5/12.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@IBDesignable class PlaceholderTextView: UITextView {
    
    @IBInspectable var placeholder: NSString? { didSet { setNeedsDisplay() } }
    
    @IBInspectable var placeholderColor: UIColor = .lightGray { didSet { setNeedsDisplay() } }
    
    override var text: String! { didSet { setNeedsDisplay() } }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    fileprivate func setup() {
        observeForName(.UITextViewTextDidChange, object: self) { [unowned self] _ in
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let placeholder = placeholder, text.isEmpty else { return }
        
        var placeholderAttributes = [String: AnyObject]()
        placeholderAttributes[NSFontAttributeName] = font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
        placeholderAttributes[NSForegroundColorAttributeName] = placeholderColor
        
        let placeholderRect = rect.insetBy(dx: contentInset.left + textContainerInset.left + textContainer.lineFragmentPadding, dy: contentInset.top + textContainerInset.top)
        placeholder.draw(in: placeholderRect, withAttributes: placeholderAttributes)
    }
}
