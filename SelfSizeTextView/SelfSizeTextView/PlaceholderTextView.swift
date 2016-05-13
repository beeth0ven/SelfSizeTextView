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
import RxBlocking

@IBDesignable class PlaceholderTextView: UITextView {
    
    @IBInspectable var placeholder: NSString? { didSet { setNeedsDisplay() } }
    
    @IBInspectable var placeholderColor: UIColor = .lightGrayColor() { didSet { setNeedsDisplay() } }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        observeForName(UITextViewTextDidChangeNotification, object: self) { [unowned self] _ in
            self.setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        guard let placeholder = placeholder
            where text.isEmpty else { return }
        
        var placeholderAttributes = [String: AnyObject]()
        placeholderAttributes[NSFontAttributeName] = font ?? UIFont.systemFontOfSize(UIFont.systemFontSize())
        placeholderAttributes[NSForegroundColorAttributeName] = placeholderColor
        
        let placeholderRect = CGRectInset(rect, contentInset.left + textContainerInset.left + textContainer.lineFragmentPadding, contentInset.top + textContainerInset.top)
        placeholder.drawInRect(placeholderRect, withAttributes: placeholderAttributes)
    }
}
