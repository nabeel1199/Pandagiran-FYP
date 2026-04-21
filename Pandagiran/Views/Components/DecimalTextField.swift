

import UIKit

class DecimalTextField: UITextField {
  
    static let toolbar: UIToolbar = UIToolbar()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
      
        addDoneCancelToolbar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addDoneCancelToolbar()
       
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
        self.resignFirstResponder()
        
    }
    
    @objc func cancelButtonTapped() {
        self.resignFirstResponder()
        
    }

}
