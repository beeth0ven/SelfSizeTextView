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
            layer.borderColor = newValue?.cgColor
        }
    }
}


extension CGColor {
    
    public var uiColor: UIColor {
        
        return UIColor(cgColor: self)
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
    func find(_ predicate: (Element) -> Bool) -> Element? {
        return filter(predicate).first
    }
}

extension NSObject {
    
    func postNotificationForName(_ name: String) {
        NotificationCenter.default
            .post(name: Notification.Name(rawValue: name), object: self)
    }
    
    func observeForName(_ name: Notification.Name, object: AnyObject? = nil, didReceiveNotification: @escaping (Notification) -> Void) {
        NotificationCenter.default
            .rx.notification(name, object: object)
            .subscribe(onNext: didReceiveNotification)
            .addDisposableTo(disposeBag)
    }
}


