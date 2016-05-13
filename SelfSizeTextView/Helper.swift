//
//  Helper.swift
//  SelfSizeTextView
//
//  Created by luojie on 16/5/12.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxBlocking


extension UIView {
    
    @IBInspectable
    public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable
    public var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    public var borderColor: UIColor? {
        get {
            return layer.borderColor?.uiColor
        }
        set {
            layer.borderColor = newValue?.CGColor
        }
    }
}


extension CGColor {
    
    public var uiColor: UIColor {
        
        return UIColor(CGColor: self)
    }
}

public protocol DisposeBagHasable {
    
    var disposeBag: DisposeBag { get }
}

extension NSObject: DisposeBagHasable {
    
    public var disposeBag: DisposeBag {
        if let result = objc_getAssociatedObject(self, &AssociatedKeys.DisposeBag) as? DisposeBag {
            return result
        }
        let result = DisposeBag()
        objc_setAssociatedObject(self, &AssociatedKeys.DisposeBag, result, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return result
    }
}

private struct AssociatedKeys {
    
    static var DisposeBag = "DisposeBag"
}

extension Array {
    func find(@noescape predicate: (Element) -> Bool) -> Element? {
        return filter(predicate).first
    }
}

extension NSObject {
    
    func postNotificationForName(name: String) {
        NSNotificationCenter.defaultCenter()
            .postNotificationName(name, object: self)
    }
    
    func observeForName(name: String, object: AnyObject? = nil, didReceiveNotification: (NSNotification) -> Void) {
        NSNotificationCenter.defaultCenter()
            .rx_notification(name, object: object)
            .subscribeNext(didReceiveNotification)
            .addDisposableTo(disposeBag)
    }
}


