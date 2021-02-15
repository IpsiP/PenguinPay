//
//  PenguinTextField.swift
//  PenguinPay
//
//

import UIKit

class PenguinTextField : UITextField {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        applyPenguinTextFieldStyle()
    }
}
