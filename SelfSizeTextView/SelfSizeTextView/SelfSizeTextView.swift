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
import RxBlocking

@IBDesignable class SelfSizeTextView: PlaceholderTextView {
    
    @IBInspectable var maxLines: Int = 6 { didSet { updateSizeIfNeededAnimated(false) } }
    
    private let estimationLayoutManager = NSLayoutManager()
    private let estimationTextContainer = NSTextContainer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private var heightConstraint: NSLayoutConstraint {
        guard let constraint = constraints.find({ $0.firstAttribute == .Height && $0.relation == .Equal }) else {
            fatalError("Height Constraint is required to enable self size textView!")
        }
        return constraint
    }
    
    private var estimatedHeight: CGFloat {
        let estimatedTextStorage = NSTextStorage(attributedString: attributedText)
        estimatedTextStorage.addLayoutManager(estimationLayoutManager)
        
        estimationTextContainer.lineFragmentPadding = textContainer.lineFragmentPadding
        estimationTextContainer.size = textContainer.size
        
        estimationLayoutManager.ensureLayoutForTextContainer(estimationTextContainer)
        
        let height = estimationLayoutManager.usedRectForTextContainer(estimationTextContainer).height + contentInset.top + contentInset.bottom + textContainerInset.top + textContainerInset.bottom
        return min(max(miniHeight, height), maxHeight)
    }
    
    private var maxHeight: CGFloat { return heightForLines(maxLines) }
    private var miniHeight: CGFloat { return heightForLines(2) }
    
    override var contentSize: CGSize {
        didSet {
            guard isOnScreen && oldValue != contentSize else { return }
            updateSizeIfNeededAnimated(isFirstResponder())
        }
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric)
    }
    
    private func setup() {
        contentInset = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
        estimationLayoutManager.addTextContainer(estimationTextContainer)
    }
    
    
    private func heightForLines(lines: Int) -> CGFloat {
        var height = contentInset.top + contentInset.bottom
        if let font = font {
            height += font.lineHeight * CGFloat(lines)
        }
        return ceil(height)
    }
    
    private func updateSizeIfNeededAnimated(animated: Bool) {
        let oldHeight = bounds.height
        let estimatedHeight = self.estimatedHeight
        
        guard oldHeight != estimatedHeight else { return }
        
        if animated {
            UIView.animateWithDuration(
                0.3,
                delay: 0,
                options: [.AllowUserInteraction, .BeginFromCurrentState],
                animations: { [unowned self] in
                    self.setHeight(estimatedHeight)
                    self.superview?.layoutIfNeeded()
                },
                completion: { [unowned self] _ in
                    self.layoutManager.ensureLayoutForTextContainer(self.textContainer)
                    self.scrollToVisibleCaretIdNeeded()
            })
            
        } else {
            setHeight(estimatedHeight)
            superview?.layoutIfNeeded()
            layoutManager.ensureLayoutForTextContainer(textContainer)
            scrollToVisibleCaretIdNeeded()
        }
    }
    
    private func scrollToVisibleCaretIdNeeded() {
        guard let endPosition = selectedTextRange?.end else { return }
        
        if textStorage.editedRange.location == NSNotFound && !dragging && !decelerating {
            let caretRect = caretRectForPosition(endPosition)
            let caretCenterRect = CGRect(x: caretRect.midX, y: caretRect.midY, width: 0, height: 0)
            scrollRectToVisibleConsideringInsets(caretCenterRect)
        }
    }
    
    private func scrollRectToVisibleConsideringInsets(rect: CGRect) {
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
    
    private func setHeight(height: CGFloat) {
        heightConstraint.constant = height
    }
    
}

extension UIView {
    var isOnScreen: Bool {
        return window != nil
    }
}

extension CGRect {
    func contains(rect: CGRect) -> Bool {
        return CGRectContainsRect(self, rect)
    }
}


