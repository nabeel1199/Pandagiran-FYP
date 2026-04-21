

import UIKit
import FirebaseAnalytics
import Alamofire
import SwiftyJSON


struct UserData {
    var userName : String?
    var userEmail : String?
    var userDob : String?
    var userGender : String?
    var userInterests : String?
    var userType : String?
    var userCurrency : String?
    var countryFlag : String?
    var userCountry : String?
    var currencyFlag : String?
    var userContact : String?
}

class SignupDetailsViewController: BaseViewController {

    @IBOutlet weak var btn_female: GradientButton!
    @IBOutlet weak var btn_male: GradientButton!
    @IBOutlet weak var view_date: CardView!
    @IBOutlet weak var text_field_date: UITextField!
    @IBOutlet weak var text_field_email: UITextField!
    @IBOutlet weak var text_field_name: CustomTextField!
    
    private var dob = ""
    private var gender = ""
    var email = ""
    var name = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()
    }
    
    private func initVariables () {
        text_field_name.delegate = self
        text_field_name.valueType = .fullName
        text_field_name.maxLength = 35
        text_field_email.delegate = self
        LocalPrefs.setUpdateMessage(isShown: true)
    }
    
    private func initUI () {
        self.viewBackgroundColor = .white
        self.navigationItemColor = .light
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Signup Details"
        self.text_field_email.isEnabled = false
        let dateTapGest = UITapGestureRecognizer(target: self, action: #selector(onDateTapped))
        view_date.addGestureRecognizer(dateTapGest)
        
        // Exisitng user details
        if let name = LocalPrefs.getUserData()[Constants.USER_NAME] {
            text_field_name.text = name
        }
        
        if let email = LocalPrefs.getUserData()[Constants.EMAIL] {
            text_field_email.text = email
        }
        
        if LocalPrefs.getUserData()[Constants.USER_DOB] != nil  &&
            LocalPrefs.getUserData()[Constants.USER_DOB] != "" {
            
            self.dob = LocalPrefs.getUserData()[Constants.USER_DOB]!
            let dobDate = Utils.convertStringToDate(dateString: dob)
            text_field_date.text = Utils.currentDateUserFormat(date: dobDate)
        }
        
        if let userGender = LocalPrefs.getUserData()[Constants.GENDER] {
            configureGenderButtons(userGender: userGender)
        }
    }
    
    private func configureGenderButtons (userGender : String) {
        if userGender == (btn_male.titleLabel?.text)! {
            gender = (btn_male.titleLabel?.text)!
            btn_male.backgroundColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
            btn_female.backgroundColor = UIColor.groupTableViewBackground
            btn_male.setTitleColor(UIColor.white, for: .normal)
            btn_female.setTitleColor(UIColor.black, for: .normal)
        } else if userGender == (btn_female.titleLabel?.text)! {
            gender = (btn_female.titleLabel?.text)!
            btn_male.backgroundColor =  UIColor.groupTableViewBackground
            btn_female.backgroundColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
            btn_male.setTitleColor(UIColor.black, for: .normal)
            btn_female.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    @objc private func onDateTapped () {
        let datePopup = DialogSelectDate()
        datePopup.myDelegate = self
        datePopup.disableFutureDate = true
        datePopup.customDate = Utils.convertStringToDate(dateString: dob)
        self.presentPopupView(popupView: datePopup)
    }
    
    @IBAction func onBtnMaleTapped(_ sender: Any) {
        configureGenderButtons(userGender: (btn_male.titleLabel?.text)!)
    }
    
    @IBAction func onBtnFemaleTapped(_ sender: Any) {
        configureGenderButtons(userGender: (btn_female.titleLabel?.text)!)
    }
    
    
    @IBAction func onNextTapped(_ sender: Any) {
        let trimmedEmail = text_field_email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//        if Utils.validateString(vc: self, string: text_field_name.text!, errorMsg: "Please enter your name") && Utils.isValidEmail(vc: self, string: trimmedEmail, errorMsg: "Please enter valid email") && Utils.validateString(vc: self, string: dob, errorMsg: "Please select your date of birth") {
        if Utils.validateString(vc: self, string: text_field_name.text!, errorMsg: "Please enter your name") &&  Utils.validateString(vc: self, string: dob, errorMsg: "Please select your date of birth") {


            var user = UserData()
            user.userName = text_field_name.text!
            user.userEmail = text_field_email.text!
            user.userDob = self.dob
            user.userGender = self.gender

            self.registerUserNetworkCall(user: user)
            
        }
    }
    
    func navigateToUserTypeSelection(user: UserData){
        Analytics.logEvent("USOB_5_Singup_detail_entered", parameters: nil)
        let userTypeVC = getStoryboard(name: ViewIdentifiers.SB_ONBOARDING).instantiateViewController(withIdentifier: ViewIdentifiers.VC_USER_TYPE) as! UserTypeSelectionViewController
        userTypeVC.user = user
        self.navigationController?.pushViewController(userTypeVC, animated: true)
    }
    
    private func registerUserNetworkCall(user: UserData) {
        UIUtils.showLoader(view: self.view)
        let URL = "\(Constants.BASE_URL)/consumers/token/update"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]

        let dictToEncrypt = ["device_type" : "Ios",
                             "consumer_id" : "\(LocalPrefs.getConsumerId())",
                             "token" : LocalPrefs.getDeviceToken()]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        Alamofire.request(URL, method: .post, parameters: params, encoding: URLEncoding.httpBody , headers : headers)
            .responseJSON { response in
                print("Response : " , response.result.value!)
                UIUtils.dismissLoader(uiView: self.view)
                switch response.result {
                case .success:
            
                    let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    print(responseObj)
                    if status == 1 {
                        let data = responseObj["data"].dictionaryValue
                        let consumerRecord = data["consumer_record"]?.dictionaryValue
                        self.navigateToUserTypeSelection(user: user)
                        Analytics.logEvent("USOB_1_Get_Started_Clicked", parameters: nil)
                    } else {
                       UIUtils.showAlert(vc: self, message: message)
                    }
                    
                    
                case .failure(let error):
                    UIUtils.dismissLoader(uiView: self.view)
                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
    }
}

extension SignupDetailsViewController : DateSelectionListener, UITextFieldDelegate {
    
    
    func onDateSelected(date: Date) {
        dob = Utils.currentDateDbFormat(date: date)
        text_field_date.text = Utils.currentDateUserFormat(date: date)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case text_field_name:
            text_field_email.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let textFieldName = textField as? CustomTextField {
                 return textFieldName.verifyFields(shouldChangeCharactersIn: range, replacementString: string)
             }
        return false
    
    }
}

         
//        if textField.text?.count == 35 {
//            return false
//        }
//
//        if textField == self.text_field_name {
//            let allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
//            let allowedCharacterSet = CharacterSet(charactersIn: allowedCharacters)
//            let typedCharacterSet = CharacterSet(charactersIn: string)
//            let alphabet = allowedCharacterSet.isSuperset(of: typedCharacterSet)
//            return alphabet
//
//
//        } else {
//            return false
//        }
//        do {
//            let regex = try NSRegularExpression(pattern: ".*[^A-Za-z ].*", options: [])
//            if regex.firstMatch(in: string, options: [], range: NSMakeRange(0, string.count)) != nil {
//                return false
//            }
//        }
//        catch {
//            UIUtils.showSnackbarNegative(message: "No Characters Allow")
//        }
//
//        return true
//
//    }



