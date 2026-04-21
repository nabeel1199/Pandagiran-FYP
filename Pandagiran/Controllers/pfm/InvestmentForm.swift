

import UIKit
import CoreAudio
import SwiftyBeaver
import Alamofire

class InvestmentForm: BaseViewController{
    
    @IBOutlet weak var proceedBtn: TintedButton!
    @IBOutlet weak var fieldTable: UITableView!
    
    var investmentPlanId : Int?
    var id : Int?
    var formId : Int?
    var textFieldList = [TextField]()
    var selectCityField = [Select]()
    var investmentFromData: InvestmentFormModel?
    var textField : NSArray?
    var selectedcity : NSArray?
    var filledForm = [String: String]()
    var ivestmentTitle : String?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = ivestmentTitle
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        initVariable()
        initUI()

    }
    
    private func initUI(){
        let button = UIBarButtonItem(image: UIImage(named: "ic_back"), style: .plain, target: self, action: #selector(onCloseTapped))
        navigationItem.leftBarButtonItem = button
        self.view.backgroundColor = UIColor().hexCode(hex: "#F5F7FC")

    }
    
    
    
    @objc func onCloseTapped(){
        navigationController?.popViewController(animated: true)
    }

    
    
    
    private func initVariable(){
        fieldTable.delegate = self
        fieldTable.dataSource = self
        initNib()
        getInvestmentForm()

    }
    
   private func initNib(){
        let nib = UINib(nibName: "TextFieldCell", bundle: nil)
       nib.instantiate(withOwner: self, options: nil)
        fieldTable.register(nib, forCellReuseIdentifier: "TextFieldCell")
    }
    
    private func getInvestmentForm(){
        UIUtils.showLoader(view: self.view)
        NITNetworkCalls.sharedInstance.getInformationForm(successHandler: {
            response in
            self.investmentFromData = response
            if self.investmentFromData?.data?.count ?? 0 > 0 {
            if let textFieldArray = self.investmentFromData?.data?[0].attributes?.textField{
                self.textFieldList = textFieldArray
                self.fieldTable.reloadData()
            }else {
                UIUtils.showSnackbar(message: "Something went wrong!")
                UIUtils.dismissLoader(uiView: self.view)
            }
            if let SelectCityArray = self.investmentFromData?.data?[0].attributes?.select{
                self.selectCityField = SelectCityArray
                print("City Select \(self.selectCityField)")
                self.fieldTable.reloadData()
            }else {
                UIUtils.showSnackbar(message: "Something went wrong!")
                UIUtils.dismissLoader(uiView: self.view)
            }

            self.fieldTable.reloadData()
            UIUtils.dismissLoader(uiView: self.view)
            }else {
                UIUtils.showSnackbar(message: "Some error occured!")
                self.proceedBtn.isEnabled = false
                UIUtils.dismissLoader(uiView: self.view)
            }
            }) { error in
            UIUtils.showSnackbarNegative(message: "\(error.localizedDescription)")
                UIUtils.dismissLoader(uiView: self.view)
        }
                                                          
        }
    @IBAction func proceedBtn(_ sender: UIButton) {
        if checkTextList(){
           if cityTextList(){
               let id = self.investmentPlanId!
               self.filledForm.updateValue("\(id)", forKey: "investment_plan")
               print(self.filledForm)
               let popUp = NITConfrimationPopup()
                popUp.modalPresentationStyle = .overCurrentContext
                popUp.agreeTap = self
                self.present(popUp, animated: true, completion: nil)
            }
        }
    }
    
        
        func checkTextList() -> Bool {
            for index in 0..<self.textFieldList.count {
                let indexPath = IndexPath.init(row: index, section: 0)
                if let cell = self.fieldTable.cellForRow(at: indexPath) as? TextFieldCell{
//                    let xyz = ["\(cell.textLbl.text ?? "")":"\(cell.infoField.text ?? "")"]
                    if cell.infoField.text ?? "" != "" {
                        switch cell.textLbl.text ?? "" {
                        case "Name":
                            if Utils.validateString(vc: self, string: cell.infoField.text!, errorMsg: "Enter Valid Name") {
                                self.filledForm.updateValue(cell.infoField.text ?? "", forKey: cell.textLbl.text ?? "")
                                print(filledForm)
                                break
                            }
                            print("Invalid Name")
                            break
                        case "Email":
                            if Utils.isValidEmail(vc: self, string: cell.infoField.text ?? "", errorMsg: "Enter Valid Email"){
                                self.filledForm.updateValue(cell.infoField.text ?? "", forKey: cell.textLbl.text ?? "")
                                break
                            }
                            print("Invalid Email")
                            break
                        case "Phone":
                            if cell.infoField.text?.count ?? 0 != 11 {
                                UIUtils.showAlert(vc: self, message: "Enter Valid Phone Number")
                                print("Invalid phone")
                                break
                            }else {
                            self.filledForm.updateValue(cell.infoField.text ?? "", forKey: cell.textLbl.text ?? "")
                            print(filledForm)
                                break
                            }
                        case "CNIC":
                            if cell.infoField.text?.count ?? 0 != 13 {
                                UIUtils.showAlert(vc: self, message: "Enter Valid CNIC Number")
                                print("Invalid CNIC")
                            }else{
                            self.filledForm.updateValue(cell.infoField.text ?? "", forKey: cell.textLbl.text ?? "")
                            print(filledForm)
                                break
                            }
                        default:
                            break
                        }
                    }else {
//                        UIUtils.showAlert(vc: self, message: "Please fill all the fields!")
                        UIUtils.showSnackbar(message: "Please fill all the fields!")
                        return false
                    }
                }
            }
return true
        }
  
        
        func cityTextList() -> Bool {
            for index in stride(from: 0,  to: self.selectCityField.count, by: 1) {
                let indexPath = IndexPath.init(row: index, section: 1)
                if let cell = fieldTable.cellForRow(at: indexPath) as? TextFieldCell{
                    
                    let xyz = ["\(cell.textLbl.text ?? "")":"\(cell.infoField.text ?? "")"]
                    print(xyz)
                    if cell.infoField.text! != ""{
                        self.filledForm.updateValue(cell.infoField.text ?? "", forKey: cell.textLbl.text ?? "")
                        }
                    }else{
                        UIUtils.showSnackbar(message: "Please fill all the fields!")
                        return false
                    }

                    }
            return true
            
        }
    
    


  

}

extension InvestmentForm: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.textFieldList.count
        } else{
            return self.selectCityField.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userDetails : [String:String] = LocalPrefs.getUserData()
        
        
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as? TextFieldCell else{
                return UITableViewCell()
            }
            cell.textLbl.text = self.textFieldList[indexPath.row].label?.capitalizingFirstLetter() ?? "\(LocalPrefs.getUserName())"
//            print(self.textFieldList[indexPath.row].label?.capitalizingFirstLetter())
            cell.infoField.placeholder =  self.textFieldList[indexPath.row].label?.capitalizingFirstLetter() ?? ""
            let label = cell.textLbl.text
            if label == "Name" {
                if let name = userDetails[Constants.USER_NAME] {
                    cell.infoField.text = name
                } else {
                    cell.infoField.text = LocalPrefs.getUserName()
                }
                cell.infoField.isEnabled = false
            }else if label == "Email"{
                cell.infoField.text = LocalPrefs.getUserEmail()
                cell.infoField.isEnabled = false
            }else if label == "Phone"{
                cell.infoField.placeholder = "Eg: 0312XXXXXXX"
                cell.infoField.maxLength = 11
                cell.infoField.keyboardType = .phonePad
            }else if label == "CNIC"{
                cell.infoField.placeholder = "Eg: 42XXX-XXXXXXXX-X"
                cell.infoField.maxLength = 13
                cell.infoField.keyboardType = .numberPad
            }else {
                cell.infoField.keyboardType = .default
            }
            cell.textFieldBtn.isHidden = true
            cell.infoField.tag = indexPath.row
            cell.selectionStyle = .none
            return cell
        }else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as? TextFieldCell else{
                return UITableViewCell()
            }
            cell.textLbl.text = self.selectCityField[indexPath.row].label?.capitalizingFirstLetter() ?? ""
            cell.infoField.placeholder =  self.selectCityField[indexPath.row].label?.capitalizingFirstLetter() ?? ""
            cell.infoField.isUserInteractionEnabled = true
            cell.textFieldBtn.isHidden = false
            cell.dropDownBtn.isHidden = false
            cell.infoField.tag = indexPath.row
            cell.selectionStyle = .none
            return cell
        }
    
    
}
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 85
//    }
    
    

}

extension InvestmentForm: onAgreeTap{
    func agreeTapped() {
        NITNetworkCalls.sharedInstance.postFormInformation(formData: self.filledForm, successHandler: {
            response in
            let dest = self.getStoryboard(name: ViewIdentifiers.SB_HKNIT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_HK_SUCCESSSCREEN) as! NITSuccessScreen
            dest.navigationItem.title = self.ivestmentTitle
            dest.userName = self.filledForm["Name"]
            self.navigationItem.title = ""
            self.navigationController?.pushViewController(dest, animated: true)
            }) { error in
            UIUtils.showSnackbarNegative(message: "\(error.localizedDescription)")
        }

    }
}
