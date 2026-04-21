

import UIKit
import PinCodeTextField
import Alamofire
import SwiftyJSON
import Kingfisher
import FirebaseAnalytics

class PhoneVerificationViewController: BaseViewController {
    
    
    @IBOutlet weak var btn_request_call: GradientButton!
    @IBOutlet weak var view_call: UIView!
    @IBOutlet weak var view_country_code: CardView!
    @IBOutlet weak var btn_send: GradientButton!
    @IBOutlet weak var view_enter_otp: UIView!
    @IBOutlet weak var text_field_otp: PinCodeTextField!
    @IBOutlet weak var text_field_phone: UITextField!
    @IBOutlet weak var iv_country: UIImageView!
    @IBOutlet weak var label_2dg: UILabel!
    
    private var timerSeconds = 60
    private var timer = Timer()
    private var callTimer = Timer()
    private var countryFlag = "http://bo.hysabkytab.com/HK_data_pics/country_flags/pk.png"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initVariables()
        initUI()
        
    }
    
    private func initVariables () {
        text_field_otp.keyboardType = .numberPad
        text_field_otp.delegate = self
        text_field_phone.delegate = self
        
        LocalPrefs.setUserCurrency(userCurrency: "MYR")
        LocalPrefs.setCountryFlag(countryFlag: self.countryFlag)
        LocalPrefs.setCountryName(countryName: "MY")
    }
    
    private func initUI () {
        iv_country.kf.setImage(with: URL(string: countryFlag))
        self.viewBackgroundColor = .white
        self.navigationItemColor = .light
        self.navigationItem.title = "Phone Verification"
        
        let countryCodeGest = UITapGestureRecognizer(target: self, action: #selector(onCountryTapped))
        view_country_code.addGestureRecognizer(countryCodeGest)
        
        print("TF : " , text_field_otp.subviews)
        
        
    }
    
    private func requestOtpNetworkCall () {
        UIUtils.showLoader(view: self.view)
        let URL = "\(Constants.BASE_URL)/consumers/mobile/otp"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
        var deviceToken = "asdfhgjkadjlsajdlkas"
        
        if LocalPrefs.getDeviceToken() != nil && LocalPrefs.getDeviceToken() != "" {
            deviceToken = LocalPrefs.getDeviceToken()
        }
        
        var countryCode = label_2dg.text!
        countryCode.removeFirst()
        
        let dictToEncrypt =  ["device_type" : "Ios",
                              "token" : deviceToken,
                              "consumer_id" : "\(LocalPrefs.getConsumerId())",
            "country_code" : countryCode,
            "mobile" : "\(countryCode)\(text_field_phone.text!)"]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        Alamofire.request(URL, method: .post, parameters: params, encoding: URLEncoding.httpBody , headers : headers)
            .responseJSON { response in
                UIUtils.dismissLoader(uiView: self.view)
                print("Response : " , response)
                switch response.result {
                case .success:
                    let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    
                    
                    if status == 1 {
                        let data = responseObj["data"].dictionaryValue
                        let consumerId = data["consumer_id"]?.int64Value
                        
                        LocalPrefs.setConsumerId(userId: consumerId!)
                        
                        self.view_call.isHidden = false
                        self.view_enter_otp.isHidden = false
                        self.runTimer()
                        Analytics.logEvent("USOB_3_GET_OTP_SMS_clicked", parameters: nil)
                        
                    } else {
                        UIUtils.showAlert(vc: self, message: message)
                    }
                    
                    
                case .failure(let error):
                    UIUtils.dismissLoader(uiView: self.view)
                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
    }
    
    private func requestCallNetworkCall () {
        UIUtils.showLoader(view: self.view)
        let URL = "\(Constants.BASE_URL)/consumers/otp/call"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
        
        var countryCode = label_2dg.text!
        countryCode.removeFirst()
        
        let dictToEncrypt =  [  "device_type" : "Ios",
                                "consumer_id" : "\(LocalPrefs.getConsumerId())",
            "country_code" : countryCode,
            "mobile" : "\(countryCode)\(text_field_phone.text!)"]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        print("Params : " , params.description)
        
        Alamofire.request(URL, method: .post, parameters: params, encoding: URLEncoding.httpBody , headers : headers)
            .responseJSON { response in
                UIUtils.dismissLoader(uiView: self.view)
                print("Response : " , response)
                switch response.result {
                case .success:
                    let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    
                    
                    if status == 1 {
                        //                        let data = responseObj["data"].dictionaryValue
                        
                        
                        self.view_call.isHidden = false
                        self.view_enter_otp.isHidden = false
                        self.runTimer()
                        Analytics.logEvent("USOB_4_Get_OTP_CALL_clicked", parameters: nil)
                        
                    } else {
                        UIUtils.showAlert(vc: self, message: message)
                    }
                    
                    
                case .failure(let error):
                    UIUtils.dismissLoader(uiView: self.view)
                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
    }
    
    fileprivate func skipOtpNetworkCall () {
        UIUtils.showLoader(view: self.view)
        let URL = "\(Constants.BASE_URL)/consumers/skip/otp"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
        var countryCode = label_2dg.text!
        countryCode.removeFirst()
        
        let dictToEncrypt =  ["device_type" : "Ios",
                              "mobile" : "\(countryCode)\(text_field_phone.text!)",
                              "consumer_id" : "\(LocalPrefs.getConsumerId())"]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        Alamofire.request(URL, method: .post, parameters: params, encoding: URLEncoding.httpBody , headers : headers)
            .responseJSON { response in
                UIUtils.dismissLoader(uiView: self.view)
                print("Response : " , response)
                switch response.result {
                case .success:
                    let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    
                    
                    if status == 1 {
                        let data = responseObj["data"].dictionaryValue
                        let name = data["name"]?.stringValue
                        let email = data["email_address"]?.stringValue
                        let phone = data["phone_number"]?.stringValue
                        let currency = data["currency"]?.stringValue
                        let userType = data["profession_type"]?.stringValue
                        let gender = data["gender"]?.stringValue
                        let consumerId = data["consumer_id"]?.int64
                        let dob = data["dob"]?.stringValue
                        
                        print(responseObj)
                        let userDetails : [String:String] = [Constants.USER_NAME : name!,
                                                             Constants.EMAIL : email!,
                                                             Constants.USER_PHONE : phone!,
                                                             Constants.CONSUMER_ID : String(consumerId!),
                                                             Constants.CURRENCY : currency!,
                                                             Constants.USER_TYPE : userType!,
                                                             Constants.GENDER : gender!,
                                                             Constants.USER_DOB : dob!]
                        LocalPrefs.setUserData(userDetails: userDetails)
                        LocalPrefs.setUserName(userName: name ?? "")
                        LocalPrefs.setUserEmail(userEmail: email ?? "")
                        LocalPrefs.setUserPhone(userPhone: phone!)
                        LocalPrefs.setConsumerId(userId: consumerId!)
                        LocalPrefs.setIsVerified(isVerified: true)
//                        QueryUtils.saveAccounts()
//                        QueryUtils.saveCategories()
                        
                        
                        self.navigateToSignupDetails()
                        
                    } else {
                        UIUtils.showAlert(vc: self, message: message)
                    }
                    
                    
                case .failure(let error):
                    UIUtils.dismissLoader(uiView: self.view)
                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
    }
    
    private func runTimer () {
        btn_send.isEnabled = false
        btn_send.alpha = 0.5
        btn_request_call.isEnabled = false
        btn_request_call.alpha = 0.5
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    private func runCallTimer () {
        btn_request_call.isEnabled = false
        callTimer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc private func updateTimer () {
        timerSeconds -= 1
        
        if timerSeconds == 0 {
            timerSeconds =  60
            timer.invalidate()
            btn_send.isEnabled = true
            btn_send.setTitle("Resend SMS", for: .normal)
            btn_request_call.isEnabled = true
            btn_request_call.setTitle("Request Call", for: .normal)
            btn_send.alpha = 1.0
            btn_request_call.alpha = 1.0
        } else {
            UIView.performWithoutAnimation {
                self.btn_send.setTitle("Resend SMS in \(timerSeconds) seconds", for: .normal)
                self.btn_request_call.setTitle("Get verification code on call (in \(timerSeconds) sec)", for: .normal)
                self.btn_send.layoutIfNeeded()
                self.btn_request_call.layoutIfNeeded()
            }
        }
    }
    
    private func verifyOtpNetworkCall () {
        UIUtils.showLoader(view: self.view)
        let URL = "\(Constants.BASE_URL)/consumers/verify/otp"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
        var countryCode = label_2dg.text!
        countryCode.removeFirst()
        
        
        let dictToEncrypt =  ["device_type" : "Ios",
                              "otp_code" : text_field_otp.text!,
                              "consumer_id" : "\(LocalPrefs.getConsumerId())",
            "mobile" : "\(countryCode)\(text_field_phone.text!.trimmingCharacters(in: .whitespacesAndNewlines))"]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        
        Alamofire.request(URL, method: .post, parameters: params, encoding: URLEncoding.httpBody , headers : headers)
            .responseJSON { response in
                print("Response : " , response)
                UIUtils.dismissLoader(uiView: self.view)
                switch response.result {
                case .success:
                    let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    
                    if status == 1 {
                        UIUtils.showSnackbar(message: "Verified!")
                        LocalPrefs.setIsVerified(isVerified: true)
                        QueryUtils.saveAccounts()
                        QueryUtils.saveCategories()
                        
                        let data = responseObj["data"].dictionaryValue
                        let name = data["name"]?.stringValue
                        let email = data["email_address"]?.stringValue
                        let phone = data["phone_number"]?.stringValue
                        let currency = data["currency"]?.stringValue
                        let userType = data["profession_type"]?.stringValue
                        let gender = data["gender"]?.stringValue
                        let consumerId = data["consumer_id"]?.int64
                        let dob = data["dob"]?.stringValue
                        
                        let userDetails : [String:String] = [Constants.USER_NAME : name!,
                                                             Constants.EMAIL : email!,
                                                             Constants.USER_PHONE : phone!,
                                                             Constants.CONSUMER_ID : String(consumerId!),
                                                             Constants.CURRENCY : currency!,
                                                             Constants.USER_TYPE : userType!,
                                                             Constants.GENDER : gender!,
                                                             Constants.USER_DOB : dob!]
                        
                        LocalPrefs.setUserPhone(userPhone: phone!)
                        LocalPrefs.setUserData(userDetails: userDetails)
                        LocalPrefs.setConsumerId(userId: consumerId!)
                        self.navigateToSignupDetails()
                    } else {
                        UIUtils.showAlert(vc: self, message: message)
                    }
                    
                    
                case .failure(let error):
                    UIUtils.dismissLoader(uiView: self.view)
                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
    }
    
    private func navigateToSignupDetails () {
        let signupDetailsVC = getStoryboard(name: ViewIdentifiers.SB_ONBOARDING).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SIGNUP_DETAILS) as! SignupDetailsViewController
        self.navigationController?.pushViewController(signupDetailsVC, animated: true)
    }
    
    @IBAction func onBtnSendTapped(_ sender: Any) {
        if Utils.validatePhone(vc: self, string: text_field_phone.text!, errorMsg: "Please enter valid phone number") {
            requestOtpNetworkCall()
        }
    }
    
    @IBAction func onBtnCallTapped(_ sender: Any) {
        if Utils.validatePhone(vc: self, string: text_field_phone.text!, errorMsg: "Please enter valid phone number") {
            requestCallNetworkCall()
        }
    }
    
    
    @IBAction func onNextTapped(_ sender: Any) {
        if LocalPrefs.getIsVerified() {
            verifyOtpNetworkCall()
        } else {
            UIUtils.showAlert(vc: self, message: "Sorry, we could not verify your phone number")
        }
    }
    
    @objc private func onCountryTapped () {
        let currencyVC = getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SELECT_CURRENCY) as! AccountCurrencyViewController
        currencyVC.countryCodeDelegate = self
        currencyVC.isCountryOpted = true
        currencyVC.isDialCodeOpted = true
        self.navigationController?.pushViewController(currencyVC, animated: true)
    }
    
    @IBAction func onSkipTapped(_ sender: Any) {
        skipOtpNetworkCall()
    }
}

extension PhoneVerificationViewController : PinCodeTextFieldDelegate, UITextFieldDelegate, CountryCodeSelection {
    
    
    
    func textFieldValueChanged(_ textField: PinCodeTextField) {
        if textField.text?.count == 6 {
            verifyOtpNetworkCall()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == text_field_phone {
            
            if textField.text?.count == 15 {
                if string != "" {
                    return false
                }
            }
        }
        
        return true
    }
    
    func onCountryCodeSelected(countryName: String, countryCurrency: String, dialCode: Int64, countryFlag: String, country2dg: String) {
        
        label_2dg.text = "+\(dialCode)"
        iv_country.kf.setImage(with: URL(string: countryFlag))
        LocalPrefs.setCountryName(countryName: country2dg)
        LocalPrefs.setCountryFlag(countryFlag: countryFlag)
        LocalPrefs.setUserCurrency(userCurrency: countryCurrency)
    }
    
    func textFieldDidBeginEditing(_ textField: PinCodeTextField) {
        self.animateTextField(up: true)
    }
    
    func textFieldDidEndEditing(_ textField: PinCodeTextField) {
        self.animateTextField(up: false)
    }
    

    
}
