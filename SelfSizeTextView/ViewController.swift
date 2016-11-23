//
//  ViewController.swift
//  SelfSizeTextView
//
//  Created by luojie on 16/5/12.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

}

extension ViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            guard let text = textView.text, text.characters.count > 0 else { return false }
            textView.text = nil
            return false
        }
        return true
    }
}
