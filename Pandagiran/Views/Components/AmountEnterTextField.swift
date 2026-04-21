

import Foundation

class AmountEnterTextField : UITextField , UITextFieldDelegate {
    
    var limit : Int = 11
    var textToConvert = ""
    static let toolbar: UIToolbar = UIToolbar()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        super.delegate = self
        addDoneCancelToolbar()
        delegate = self
        addTarget(self, action: #selector(didChangeText), for: UIControl.Event.editingChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addDoneCancelToolbar()
        delegate = self
        addTarget(self, action: #selector(didChangeText), for: UIControl.Event.editingChanged)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField.text?.count)! > 0 {
            if (textField.text?.contains("."))! {
                limit = (textField.text?.count)! - 1
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
 
        let countDots = (textField.text?.components(separatedBy: ".").count)! - 1
        var charCount : Int = 0
        

        
        if (textField.text?.count)! >= limit && string != "." && string != "" && countDots == 0 {
//            limit += LocalPrefs.getDecimalFormat()
            return false
        } else if countDots == 0 && string == "." {
            if LocalPrefs.getDecimalFormat() == 0 {
                return false
            }
            charCount = (textField.text?.count)!
            limit = charCount + LocalPrefs.getDecimalFormat()
        } else if countDots > 0 && string == "." {
            return false
        } else if countDots > 0 && (textField.text?.count)! > limit && string != "" {
            return false
        }
        
        return true
    }
    
    @objc func didChangeText () {
        if (self.text?.count)! > 0 {
            let lastChar = self.text?.last!
            
            if !(self.text?.contains("."))! {
                limit = 11
                let amount = Utils.removeComma(numberString: self.text!)
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                numberFormatter.locale = Locale.current
                let commaSeperatedString = numberFormatter.string(from: NSNumber(value : amount))
                self.text = commaSeperatedString
            }
        }
    }
    
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
        
        
        AmountEnterTextField.toolbar.barStyle = .default
        AmountEnterTextField.toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        AmountEnterTextField.toolbar.sizeToFit()
        
        self.inputAccessoryView = AmountEnterTextField.toolbar
    }
    
    // Default actions:
    @objc func doneButtonTapped() {
        if !isFirstResponder {
            self.becomeFirstResponder()
        }
        
        self.resignFirstResponder()
    }
    
    @objc func cancelButtonTapped() {
        if !isFirstResponder {
            self.becomeFirstResponder()
        }
        
        self.resignFirstResponder()
    }
}
