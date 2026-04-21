

import UIKit

class DialogCalculator: BasePopup  {

    @IBOutlet weak var view_input: CardView!
    @IBOutlet weak var label_info: UILabel!
    @IBOutlet weak var et_amount: UITextField!
    @IBOutlet weak var label_currency: UILabel!
    
    private var LAST_ACTION: String = ""
    private var operationHistory: Array<String> = []
    private var numericTrail: Array<Double> = []
    private var charReplace: String = ""
    private var CURRENT_ACTION: String = ""
    private var ADDITION = "+" , SUBTRACTION = "-" , MULTIPLICATION = "*" , DIVISION = "/"
    private var finalResult: Double = 0
    private var limit = 11
    public var initialText: String = ""
    public var myDelegate: CalculatorListener?
    private var countDots = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        view_input.roundCorners([.topLeft, .topRight], radius: 10.0)
        et_amount.text = initialText
        et_amount.addTarget(self, action: #selector(didChangeText), for: UIControl.Event.editingChanged)
    }
    
    @IBAction func btn0Tapped(_ sender: Any) {
        if LAST_ACTION != "" {
            et_amount.text = ""
            LAST_ACTION = ""
            et_amount.text = "\(String(describing: et_amount.text!))0"
        } else {
            et_amount.text = "\(String(describing: et_amount.text!))0"
        }
        
        operationHistory.append("0")
        et_amount.sendActions(for: UIControl.Event.editingChanged)
    }
    
    @IBAction func btn1Tapped(_ sender: Any) {
        if LAST_ACTION != "" {
            et_amount.text = ""
            LAST_ACTION = ""
            et_amount.text = "\(String(describing: et_amount.text!))1"
        } else {
            et_amount.text = "\(String(describing: et_amount.text!))1"
        }
        
        operationHistory.append("1")
        et_amount.sendActions(for: UIControl.Event.editingChanged)
    }
    
    @IBAction func btn2Tapped(_ sender: Any) {
        if LAST_ACTION != "" {
            et_amount.text = ""
            LAST_ACTION = ""
            et_amount.text = "\(String(describing: et_amount.text!))2"
        } else {
            et_amount.text = "\(String(describing: et_amount.text!))2"
        }
        
        operationHistory.append("2")
        et_amount.sendActions(for: UIControl.Event.editingChanged)
    }
    
    @IBAction func btn3Tapped(_ sender: Any) {
        if LAST_ACTION != "" {
            et_amount.text = ""
            LAST_ACTION = ""
            et_amount.text = "\(String(describing: et_amount.text!))3"
        } else {
            et_amount.text = "\(String(describing: et_amount.text!))3"
        }
        
        operationHistory.append("3")
        et_amount.sendActions(for: UIControl.Event.editingChanged)
    }
    
    @IBAction func btn4Tapped(_ sender: Any) {
        if LAST_ACTION != "" {
            et_amount.text = ""
            LAST_ACTION = ""
            et_amount.text = "\(String(describing: et_amount.text!))4"
        } else {
            et_amount.text = "\(String(describing: et_amount.text!))4"
        }
        
        operationHistory.append("4")
        et_amount.sendActions(for: UIControl.Event.editingChanged)
    }
    
    @IBAction func btn5Tapped(_ sender: Any) {
        if LAST_ACTION != "" {
            et_amount.text = ""
            LAST_ACTION = ""
            et_amount.text = "\(String(describing: et_amount.text!))5"
        } else {
            et_amount.text = "\(String(describing: et_amount.text!))5"
        }
        
        operationHistory.append("5")
        et_amount.sendActions(for: UIControl.Event.editingChanged)
    }
    
    @IBAction func btn6Tapped(_ sender: Any) {
        if LAST_ACTION != "" {
            et_amount.text = ""
            LAST_ACTION = ""
            et_amount.text = "\(String(describing: et_amount.text!))6"
        } else {
            et_amount.text = "\(String(describing: et_amount.text!))6"
        }
        
        operationHistory.append("6")
        et_amount.sendActions(for: UIControl.Event.editingChanged)
    }
    
    @IBAction func btn7Tapped(_ sender: Any) {
        if LAST_ACTION != "" {
            et_amount.text = ""
            LAST_ACTION = ""
            et_amount.text = "\(String(describing: et_amount.text!))7"
        } else {
            et_amount.text = "\(String(describing: et_amount.text!))7"
        }
        
        operationHistory.append("7")
        et_amount.sendActions(for: UIControl.Event.editingChanged)
    }
    
    @IBAction func btn8Tapped(_ sender: Any) {
        if LAST_ACTION != "" {
            et_amount.text = ""
            LAST_ACTION = ""
            et_amount.text = "\(String(describing: et_amount.text!))8"
        } else {
            et_amount.text = "\(String(describing: et_amount.text!))8"
        }
        
        operationHistory.append("8")
        et_amount.sendActions(for: UIControl.Event.editingChanged)
    }
    
    @IBAction func btn9Tapped(_ sender: Any) {
        if LAST_ACTION != "" {
            et_amount.text = ""
            LAST_ACTION = ""
            et_amount.text = "\(String(describing: et_amount.text!))9"
        } else {
            et_amount.text = "\(String(describing: et_amount.text!))9"
        }
        
        operationHistory.append("9")
        et_amount.sendActions(for: UIControl.Event.editingChanged)
    }
    
    @IBAction func btnDecimalTapped(_ sender: Any) {
        if LAST_ACTION != "" {
            et_amount.text = ""
            LAST_ACTION = ""
            et_amount.text = "\(String(describing: et_amount.text!))."
        } else {
            et_amount.text = "\(String(describing: et_amount.text!))."
        }
        
        operationHistory.append(".")
        et_amount.sendActions(for: UIControl.Event.editingChanged)
    }
    
    @IBAction func btnEqualsTapped(_ sender: Any) {
        if et_amount.text! != "" && CURRENT_ACTION != "" && isOperationAllowed() {
            numericTrail.append(Utils.removeComma(numberString: et_amount.text!))
        }
        
        if numericTrail.count > 1 && CURRENT_ACTION != "" {
            switch CURRENT_ACTION {
            case ADDITION :
                finalResult = numericTrail[0] + numericTrail[1]
                break
            case SUBTRACTION :
                finalResult = numericTrail[0] - numericTrail[1]
                break
            case MULTIPLICATION :
                finalResult = numericTrail[0] * numericTrail[1]
                break
            case DIVISION :
                if numericTrail[1] != 0 {
                    finalResult = numericTrail[0] / numericTrail[1]
                } else {
                    UIUtils.showSnackbarNegative(message: "Can not divide by 0")
                    label_info.text = ""
                    et_amount.text = ""
                    numericTrail.removeAll()
                    operationHistory.removeAll()
                    CURRENT_ACTION = ""
                    LAST_ACTION = ""
                    return
                }
                break
            default:
                UIUtils.showSnackbarNegative(message: "Unknown error occured")
            }
            
            et_amount.text = Utils.formatDecimalNumber(number: finalResult, decimal: LocalPrefs.getDecimalFormat())
            numericTrail.removeAll()
            numericTrail.append(finalResult)
        }
        
        label_info.text = ""
        CURRENT_ACTION = ""
        LAST_ACTION = ""
    }
    
    @IBAction func btnAdditionTapped(_ sender: Any) {
        performOperation(opeartionChar: "+", operationString: ADDITION)
    }
    
    @IBAction func btnSubtractionTapped(_ sender: Any) {
        performOperation(opeartionChar: "-", operationString: SUBTRACTION)
    }
    
    @IBAction func btnMuliplicationTapped(_ sender: Any) {
        performOperation(opeartionChar: "*", operationString: MULTIPLICATION)
    }
    
    @IBAction func btnDivisionTapped(_ sender: Any) {
        performOperation(opeartionChar: "/", operationString: DIVISION)
    }
    
    @IBAction func btnClearTapped(_ sender: Any) {
        removeLastChar()
    }
    
    @IBAction func onApplyTapped(_ sender: Any) {
        myDelegate?.onCalculationCompleted(amount: et_amount.text!.replacingOccurrences(of: "-", with: "", options: [.regularExpression, .caseInsensitive]))
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func isOperationAllowed () -> Bool {
        if operationHistory.count > 0 {
            if operationHistory[operationHistory.count - 1] == "+" || operationHistory[operationHistory.count - 1] == "-" || operationHistory[operationHistory.count - 1] == "*" || operationHistory[operationHistory.count - 1] == "/" {
                return false
            }
        }
    
        return true
    }
    
    private func performOperation (opeartionChar: Character , operationString: String) {
        if et_amount.text! != "" {
            if isOperationAllowed() {
                numericTrail.append(Utils.removeComma(numberString: et_amount.text!))
                label_info.text = "\(label_info.text!)\(et_amount.text!)\(opeartionChar)"
            } else {
                charReplace.append(label_info.text!)
                charReplace.insert(opeartionChar, at: charReplace.index(charReplace.startIndex, offsetBy: charReplace.count - 2))
                label_info.text = charReplace
            }
        }
        
        if numericTrail.count > 1 {
            if isOperationAllowed() {
                switch CURRENT_ACTION {
                case ADDITION :
                    finalResult = numericTrail[0] + numericTrail[1]
                    break
                case SUBTRACTION :
                    finalResult = numericTrail[0] - numericTrail[1]
                    break
                case MULTIPLICATION :
                    finalResult = numericTrail[0] * numericTrail[1]
                    break
                case DIVISION :
                    if numericTrail[1] != 0 {
                        finalResult = numericTrail[0] / numericTrail[1]
                    } else {
                        UIUtils.showSnackbarNegative(message: "Can not divide by 0")
                        label_info.text = ""
                        et_amount.text = ""
                        numericTrail.removeAll()
                        operationHistory.removeAll()
                        CURRENT_ACTION = ""
                        LAST_ACTION = ""
                        return
                    }
                    break
                default:
                    print("")
                }
                
                et_amount.text = Utils.formatDecimalNumber(number: finalResult, decimal: LocalPrefs.getDecimalFormat())
                
                numericTrail.removeAll()
                numericTrail.append(finalResult)
            }
        }
        
        operationHistory.append(String(opeartionChar))
        CURRENT_ACTION = operationString
        LAST_ACTION = operationString
    }
    
    private func removeLastChar () {
        if (et_amount.text?.count)! > 0 {
                et_amount.text = Utils.customSubstring(givenString: et_amount.text!, location: 0, endIndex: (et_amount.text?.count)! - 1)
        }
    }
    
    @objc func didChangeText () {
    
        if (self.et_amount.text?.count)! > 0 {
            var charCount : Int = 0
            let lastChar = (self.et_amount.text?.last!)!
            
            if (self.et_amount.text?.count)! >= 11 && lastChar != "." && countDots == 0 {
                removeLastChar()
            } else if countDots == 0 && lastChar == "." {
                print("Decimal format : " , LocalPrefs.getDecimalFormat())
                if LocalPrefs.getDecimalFormat() == 0 {
                    removeLastChar()
                }
                countDots = 1
                charCount = (et_amount.text?.count)!
                limit = charCount + LocalPrefs.getDecimalFormat()
            } else if countDots > 0 && lastChar == "." {
                removeLastChar()
            } else if countDots > 0 && (et_amount.text?.count)! > limit && lastChar != " " {
                removeLastChar()
            }
            
            if !(self.et_amount.text?.contains("."))! {
                countDots = 0
                limit = 11
                let amount = Utils.removeComma(numberString: self.et_amount.text!)
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                let commaSeperatedString = numberFormatter.string(from: NSNumber(value : amount))
                self.et_amount.text = commaSeperatedString
            }
        }
    }
}
