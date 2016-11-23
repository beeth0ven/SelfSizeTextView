//
//  SelfSizeTextView.swift
//  SelfSizeTextView
//
//  Created by luojie on 16/5/12.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@IBDesignable class SelfSizeTextView: PlaceholderTextView {
    
    var didIncreaseHeight: ((CGFloat) -> Void)?
    
    @IBInspectable var maxLines: Int = 6 { didSet { updateSizeIfNeededAnimated(false) } }
    
    fileprivate let estimationLayoutManager = NSLayoutManager()
    fileprivate let estimationTextContainer = NSTextContainer()

    fileprivate var heightConstraint: NSLayoutConstraint {
        guard let constraint = constraints.find({ $0.firstAttribute == .height && $0.relation == .equal }) else {
            fatalError("Height Constraint is required to enable self size textView!")
        }
        return constraint
    }
    
    fileprivate var estimatedHeight: CGFloat {
        let estimatedTextStorage = NSTextStorage(attributedString: attributedText)
        estimatedTextStorage.addLayoutManager(estimationLayoutManager)
        
        estimationTextContainer.lineFragmentPadding = textContainer.lineFragmentPadding
        estimationTextContainer.size = textContainer.size
        
        estimationLayoutManager.ensureLayout(for: estimationTextContainer)
        
        let height = estimationLayoutManager.usedRect(for: estimationTextContainer).height + contentInset.top + contentInset.bottom + textContainerInset.top + textContainerInset.bottom
        return min(max(miniHeight, height), maxHeight)
    }
    
    fileprivate var maxHeight: CGFloat { return heightForLines(maxLines) }
    fileprivate var miniHeight: CGFloat { return heightForLines(2) }
    
    override var contentSize: CGSize {
        didSet {
            guard isOnScreen && oldValue != contentSize else { return }
            updateSizeIfNeededAnimated(isFirstResponder)
        }
    }
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    fileprivate func setup() {
        contentInset = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
        estimationLayoutManager.addTextContainer(estimationTextContainer)
    }
    
    fileprivate func heightForLines(_ lines: Int) -> CGFloat {
        var height = contentInset.top + contentInset.bottom
        if let font = font {
            height += font.lineHeight * CGFloat(lines)
        }
        return ceil(height)
    }
    
    fileprivate func updateSizeIfNeededAnimated(_ animated: Bool) {
        let oldHeight = bounds.height
        let estimatedHeight = self.estimatedHeight
        
        guard oldHeight != estimatedHeight else { return }
        
        if animated {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.allowUserInteraction, .beginFromCurrentState],
                animations: { [unowned self] in
                    self.setHeight(estimatedHeight)
                    self.superview?.layoutIfNeeded()
                },
                completion: { [unowned self] _ in
                    self.layoutManager.ensureLayout(for: self.textContainer)
                    self.scrollToVisibleCaretIfNeeded()
                    if estimatedHeight > oldHeight { self.didIncreaseHeight?(estimatedHeight - oldHeight) }
            })
            
        } else {
            setHeight(estimatedHeight)
            superview?.layoutIfNeeded()
            layoutManager.ensureLayout(for: textContainer)
            scrollToVisibleCaretIfNeeded()
            if estimatedHeight > oldHeight { didIncreaseHeight?(estimatedHeight - oldHeight) }
        }
    }
    
    fileprivate func scrollToVisibleCaretIfNeeded() {
        guard let endPosition = selectedTextRange?.end else { return }
        
        if textStorage.editedRange.location == NSNotFound && !isDragging && !isDecelerating {
            let caretRect = self.caretRect(for: endPosition)
            let caretCenterRect = CGRect(x: caretRect.midX, y: caretRect.midY, width: 0, height: 0)
            scrollRectToVisibleConsideringInsets(caretCenterRect)
        }
    }
    
    fileprivate func scrollRectToVisibleConsideringInsets(_ rect: CGRect) {
        var contentInset = self.contentInset
        contentInset.left += textContainer.lineFragmentPadding
        
        let visibleRect = UIEdgeInsetsInsetRect(bounds, contentInset)
        
        guard !visibleRect.contains(rect) else { return }
        
        var contentOffset = self.contentOffset
        if rect.minY < visibleRect.minY {
            contentOffset.y = rect.minY - contentInset.top * 2
        } else {
            contentOffset.y = rect.maxY + contentInset.bottom * 2 - bounds.height
        }
        setContentOffset(contentOffset, animated: false)
    }
    
    fileprivate func setHeight(_ height: CGFloat) {
        heightConstraint.constant = height
    }
    
}

extension UIView {
    var isOnScreen: Bool {
        return window != nil
    }
}


