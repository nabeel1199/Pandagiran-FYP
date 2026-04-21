

import Foundation


class LimitedCharacterTextField: UITextField , UITextFieldDelegate {
    
    @IBInspectable var limit : Int = 50
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        super.delegate = self
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField.text?.count)! > limit && string != "" {
            return false
        } else if (textField.text?.count)! == 0 && string == " " {
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resignFirstResponder()
        return true
    }
}
