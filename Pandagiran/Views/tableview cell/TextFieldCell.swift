

import UIKit
import DropDown

class TextFieldCell: UITableViewCell{
    
    @IBOutlet weak var textFieldBtn: UIButton!
    @IBOutlet weak var anchorView: UIView!
    @IBOutlet weak var textLbl: UILabel!
    @IBOutlet weak var infoField: customTextField!
    @IBOutlet weak var dropDownBtn: UIButton!
    var dropDownDataSource = [String]()
    var investmentFromData: InvestmentFormModel?
    
    let dropDown = DropDown()
    

    override func awakeFromNib() {
        super.awakeFromNib()
        dropDown.anchorView = anchorView
        self.infoField.delegate = self
        print("DropdownData:\(self.dropDown.dataSource)")
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.topOffset = CGPoint(x: 0, y: (dropDown.anchorView?.plainView.bounds.height)!)
        dropDownBtn.addTarget(self, action: #selector(btnTapped), for: .touchUpInside)
        textFieldBtn.addTarget(self, action: #selector(btnTapped), for: .touchUpInside)
        dropDownAction()

    }

    
    private func dropDownAction(){
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
          print("Selected item: \(item) at index: \(index)")
            self.infoField.text = dropDownDataSource[index]
        }
    }
    
    @objc func btnTapped(){
        getCityNames()
        print("Assigned Data 2:\(self.dropDown.dataSource)")
        print("tapped!!!!!")
        dropDown.show()
    }

    
    private func getCityNames(){
        NITNetworkCalls.sharedInstance.getInformationForm( successHandler: {
            response in
//            if response != nil
            self.investmentFromData = response
            if self.investmentFromData?.data != nil {
                if let cities = self.investmentFromData?.data?[0].attributes?.select?[0].values{
                    self.dropDownDataSource = cities.map {$0.value ?? ""}
                }else {
                    print(self.dropDownDataSource)
                }
                print(self.dropDownDataSource)
                self.dropDown.dataSource = self.dropDownDataSource
                print("Assigned Data:\(self.dropDown.dataSource)")
            }else {
                UIUtils.showSnackbar(message: "Some error occured!")
            }
        }) { error in
            UIUtils.showSnackbarNegative(message: "\(error.localizedDescription)")
        }
                                                          
        }
    
}

extension TextFieldCell: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        infoField.resignFirstResponder()
        return true
    }

}

class customTextField: UITextField{
    
    var maxLength: Int = 10
        override func willMove(toSuperview newSuperview: UIView?) {
            addTarget(self, action: #selector(editingChanged), for: .editingChanged)
            editingChanged()
        }
        @objc func editingChanged() {
            text = String(text!.prefix(maxLength))
        }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
           if action == #selector(UIResponderStandardEditActions.paste(_:)) {
               return false
           }
           return super.canPerformAction(action, withSender: sender)
      }
  
}
