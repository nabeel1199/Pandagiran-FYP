

import UIKit
import FirebaseAnalytics
import Alamofire
import SwiftyJSON
import GoogleSignIn
import AuthenticationServices
import FBSDKLoginKit



class TermsAndConditionsViewController: BaseViewController{
    
    @IBOutlet weak var appleViiew: UIView!
    @IBOutlet weak var fbView: UIView!
    @IBOutlet weak var googleView: UIView!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var buttonsStack: UIStackView!
//    @IBOutlet weak var btn_signup: GradientButton!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var label_already_user: UILabel!
    @IBOutlet weak var iv_checkbox: TintedImageView!
    var userID = ""
    
    private var isSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initVariables()
        buttonsStack.isUserInteractionEnabled = false
        GIDSignIn.sharedInstance()?.presentingViewController = self
        initUI()
        
    }
    
    private func initVariables () {

        fbView.alpha = 0.5
        googleView.alpha = 0.5
        appleViiew.alpha = 0.5
        
        googleView.layer.cornerRadius = 5
        fbView.layer.cornerRadius = 5
        appleViiew.layer.cornerRadius = 5
        
        self.googleButton.addTarget(self, action: #selector(handleGoogleIdRequest), for: .touchUpInside)
        self.facebookButton.addTarget(self, action: #selector(handleFbIdRequest), for: .touchUpInside)
        self.appleButton.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.isHidden = false
    }

    
    private func initUI () {
        self.viewBackgroundColor = .white
        self.navigationItemColor = .light
        self.navigationItem.hidesBackButton = true

        
        //        let logo = UIImage(named: "bt_4")
        //        let imageView = UIImageView(image:logo)
        //        self.navigationItem.titleView = imageView
        
        let checkBoxTapGest = UITapGestureRecognizer(target: self, action: #selector(onCheckboxTapped))
        iv_checkbox.isUserInteractionEnabled = true
        iv_checkbox.addGestureRecognizer(checkBoxTapGest)
        
        
//        if #available(iOS 13.0, *) {
//
//            let authorizationButton = ASAuthorizationAppleIDButton()
//            authorizationButton.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
//            //            authorizationButton.cornerRadius = 10
//            //Add button on some view or stack
//            self.appleViiew.addSubview(authorizationButton)
////            self.buttonsStack.addArrangedSubview(authorizationButton)
//            authorizationButton.translatesAutoresizingMaskIntoConstraints = false
////            authorizationButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
//            NSLayoutConstraint.activate([
//                authorizationButton.leadingAnchor.constraint(equalTo: self.appleViiew.leadingAnchor, constant: 0),
//                authorizationButton.trailingAnchor.constraint(equalTo: self.appleViiew.trailingAnchor, constant: 0),
//                authorizationButton.heightAnchor.constraint(equalToConstant: self.appleViiew.frame.height),
////                authorizationButton.widthAnchor.constraint(equalToConstant: self.appleViiew.frame.width)
//            ])
//        } else {
//            // Fallback on earlier versions
//            self.appleViiew.isHidden = true
//        }
        
        NotificationCenter.default.addObserver(forName: .AccessTokenDidChange, object: nil, queue: OperationQueue.main) { (notification) in
            
            // Print out access token
            print("FB Access Token: \(String(describing: AccessToken.current?.tokenString))")
        }
        
    }
    
    
    @objc private func onCheckboxTapped () {
        if isSelected {
//            btn_signup.isEnabled = false
            buttonsStack.isUserInteractionEnabled = false
            fbView.alpha = 0.5
            googleView.alpha = 0.5
            appleViiew.alpha = 0.5
            isSelected = false
            iv_checkbox.image = UIImage(named: "ic_cb_unchecked")
            iv_checkbox.tintColor = UIColor.lightGray
        } else {
//            btn_signup.isEnabled = true
            buttonsStack.isUserInteractionEnabled = true
//            btn_signup.alpha = 1
            fbView.alpha = 1
            googleView.alpha = 1
            appleViiew.alpha = 1
            isSelected = true
            iv_checkbox.image = UIImage(named: "ic_cb_checked")
            iv_checkbox.tintColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
        }
    }
    
    private func skipOtpNetworkCall () {
        UIUtils.showLoader(view: self.view)
        let URL = "\(Constants.BASE_URL)/consumers/skip/otp"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
        
        let dictToEncrypt =  ["device_type" : "Ios",
                              "mobile" : "",
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
                        
                        let userDetails : [String:String] = [Constants.USER_NAME : name!,
                                                             Constants.EMAIL : email!,
                                                             Constants.USER_PHONE : phone!,
                                                             Constants.CONSUMER_ID : String(consumerId!),
                                                             Constants.CURRENCY : currency!,
                                                             Constants.USER_TYPE : userType!,
                                                             Constants.GENDER : gender!,
                                                             Constants.USER_DOB : dob!]
                        
                        LocalPrefs.setUserPhone(userPhone: "")
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
    
     func socialLogin(email: String, name: String){
        UIUtils.showLoader(view: self.view)
        let URL = "\(Constants.BASE_URL)/consumers/social/login"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
        
        let dictToEncrypt =  ["device_type" : "Ios",
                              "token" : "\(LocalPrefs.getDeviceToken())",
                              "email_address" : "\(email)"]
        
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
                        let data = responseObj["data"]["data"].dictionaryValue
                        let isUserAlreadyRegistered = responseObj["data"]["already_registered"].boolValue
                        let usersname = data["consumer_name"]?.stringValue
                        let device_id = data["device_id"]?.stringValue
                        let emailAdress = data["email_address"]?.stringValue
                        let phone = data["phone_number"]?.stringValue
                        let currency = data["currency"]?.stringValue
                        let userType = data["profession_type"]?.stringValue
                        let gender = data["gender"]?.stringValue
                        let consumerId = data["consumer_id"]?.int64
                        let dob = data["dob"]?.stringValue
                        
                        
                        let userDetails : [String:String] = [Constants.USER_NAME : usersname ?? name,
                                                             Constants.EMAIL : emailAdress ?? email,
                                                             Constants.USER_PHONE : phone ?? "",
                                                             Constants.CONSUMER_ID : String(consumerId!),
                                                             Constants.CURRENCY : currency ?? "",
                                                             Constants.USER_TYPE : userType ?? "",
                                                             Constants.GENDER : gender ?? "",
                                                             Constants.USER_DOB : dob ?? ""]
                        
                        LocalPrefs.setUserPhone(userPhone: "")
                        LocalPrefs.setUserName(userName: usersname ?? name)
                        LocalPrefs.setUserData(userDetails: userDetails)
                        LocalPrefs.setDeviceId(deviceId: device_id ?? "")
                        LocalPrefs.setConsumerId(userId: consumerId!)
                        LocalPrefs.setIsVerified(isVerified: true)
                        LocalPrefs.setAlreadyRegistered(registered: isUserAlreadyRegistered)
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
    
    func appleIdLogin(email: String, name: String, userId: String){
       UIUtils.showLoader(view: self.view)
       let URL = "\(Constants.BASE_URL)/consumers/ios/login"
       let randString = Utils.getRandomString(size: 20)
       let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
       let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                          "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
       
       
       let dictToEncrypt =  ["device_type" : "Ios",
                             "apple_id_token" : "\(userId)",
                             "consumer_name" : "\(name)",
                             "email_address" : "\(email)"]
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
                   print(responseObj)
                   
                   if status == 1 {
                       let data = responseObj["data"].dictionaryValue
                       let isUserAlreadyRegistered = responseObj["data"]["already_registered"].boolValue
                       let usersname = data["consumer_name"]?.stringValue
                       let device_id = data["device_id"]?.stringValue
                       let emailAdress = data["email_address"]?.stringValue
                       let phone = data["phone_number"]?.stringValue
                       let currency = data["currency"]?.stringValue
                       let userType = data["profession_type"]?.stringValue
                       let gender = data["gender"]?.stringValue
                       let consumerId = data["consumer_id"]?.int64Value
                       let dob = data["dob"]?.stringValue
                       
                       let userDetails : [String:String] = [Constants.USER_NAME : usersname ?? name,
                                                            Constants.EMAIL : emailAdress ?? email,
                                                            Constants.USER_PHONE : phone ?? "",
                                                            Constants.CONSUMER_ID : String(consumerId!),
                                                            Constants.CURRENCY : currency ?? "",
                                                            Constants.USER_TYPE : userType ?? "",
                                                            Constants.GENDER : gender ?? "",
                                                            Constants.USER_DOB : dob ?? ""]
                       
                       LocalPrefs.setUserName(userName: usersname ?? name)
                       LocalPrefs.setUserPhone(userPhone: phone ?? "")
                       LocalPrefs.setDeviceId(deviceId: device_id ?? "")
                       LocalPrefs.setUserData(userDetails: userDetails)
                       LocalPrefs.setConsumerId(userId: consumerId!)
                       LocalPrefs.setIsVerified(isVerified: true)
                       LocalPrefs.setAlreadyRegistered(registered: isUserAlreadyRegistered)
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
    
    @IBAction func onSignupTapped(_ sender: Any) {
        //        GIDSignIn.sharedInstance()?.signIn()
        Analytics.logEvent("USOB_2_Signup_mobile_clicked", parameters: nil)
        let phoneVerificationVC = getStoryboard(name: ViewIdentifiers.SB_ONBOARDING).instantiateViewController(withIdentifier: ViewIdentifiers.VC_PHONE_VERIFICATION)
        self.navigationController?.pushViewController(phoneVerificationVC, animated: true)
    }
    
    
    @IBAction func onSkipTapped(_ sender: Any) {
        skipOtpNetworkCall()
    }
    
    @IBAction func onPrivacyPolicyTapped(_ sender: Any) {
        guard let url = URL(string: "http://hysabkytab.com/policy.html") else { return }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    
    private func updateScreen() {
        Analytics.logEvent("Sign_In_Google", parameters: nil)
        if let user = GIDSignIn.sharedInstance()?.currentUser {
            // User signed in
            
            // Show greeting message
            print("\("Hello \(user.profile.givenName!)! ✌️")")
            self.socialLogin(email: user.profile.email ?? "", name: user.profile.name ?? "No Name")
            
        } else {
            // User signed out
            
            // Show sign in message
            UIUtils.showSnackbarNegative(message: "Failed to login")
            print("Please sign in... 🙂")
        }
    }
    
    //     // MARK:- Button action
    //     @objc func signInButtonTapped(_ sender: UIButton) {
    //         GIDSignIn.sharedInstance()?.signIn()
    //     }
    //
    //     @objc func signOutButtonTapped(_ sender: UIButton) {
    //         GIDSignIn.sharedInstance()?.signOut()
    //
    //         // Update screen after user successfully signed out
    //         updateScreen()
    //     }
    
    // MARK:- Notification
    @objc private func userDidSignInGoogle(_ notification: Notification) {
        // Update screen after user successfully signed in
        updateScreen()
    }
    
    @objc func handleAppleIdRequest() {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        } else {
            // Fallback on earlier versions
            appleViiew.isHidden = true
        }
        
    }
    
    //when google login button clicked
    @objc func handleGoogleIdRequest() {
        print("Button Tapped")
        GIDSignIn.sharedInstance()?.signIn()
        GIDSignIn.sharedInstance().delegate = self
    }
    
    //when fb login button clicked
    @objc func handleFbIdRequest() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["email"], from: self) { loginResult, error in
            print(loginResult)
                print("User cancelled login.")
                self.getFBUserData()
        }
    }

    //function is fetching the user data
    func getFBUserData(){
        Analytics.logEvent("Sign_In_Facebook", parameters: nil)
        if((AccessToken.current) != nil){
            GraphRequest(graphPath: "me", parameters: ["fields": "email, name"]).start(completionHandler: { (connection, result, error) -> Void in
                if error == nil {
                    print("result \(result)")
                    let response = result as? NSDictionary
                    let email = response?["email"] as? String
                    let id =  response?["id"] as? String
                    let name =  response?["name"] as? String
                    print("ID: \(id ?? "No id"), Email: \(email ?? "no email"), Name: \(name ?? "no name")")
                    UIUtils.dismissLoader(uiView: self.view)
                    self.socialLogin(email: email ?? "", name: name ?? "")
                }
                else {
                    print("error \(error)")
                    UIUtils.dismissLoader(uiView: self.view)
                    UIUtils.showSnackbarNegative(message: "Something went wrong\n\(String(describing: error?.localizedDescription))")
                }
//                if (error == nil){
//                    let dict = result as! [String : AnyObject]
//                    print("Result: \(result)")
//                    print("Dictionary Data: \(dict)")
//                }
            })
        }
    }
}

extension TermsAndConditionsViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding, GIDSignInDelegate{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        } else {
            updateScreen()
        }
    }
    
    
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                // unique ID for each user, this uniqueID will always be returned
                let userID = appleIDCredential.user

                // optional, might be nil
                let email = appleIDCredential.email

                // optional, might be nil
                let givenName = appleIDCredential.fullName?.givenName

                // optional, might be nil
                let familyName = appleIDCredential.fullName?.familyName

                // optional, might be nil
                let nickName = appleIDCredential.fullName?.nickname
            
    
                let fullName = appleIDCredential.fullName

                print(userID)
                print(fullName)
                print(familyName)
                print(nickName)
            
                /*
                    useful for server side, the app can send identityToken and authorizationCode
                    to the server for verification purpose
                */
                var identityToken : String?
                if let token = appleIDCredential.identityToken {
                    identityToken = String(bytes: token, encoding: .utf8)
                }

                var authorizationCode : String?
                if let code = appleIDCredential.authorizationCode {
                    authorizationCode = String(bytes: code, encoding: .utf8)
                }
            
            
            print("User id is \(userID)\n Identity Token is \(identityToken) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: email))\n Authorization Code: \(authorizationCode)")
            if let email = appleIDCredential.email{
                self.appleIdLogin(email: email, name: "\(givenName ?? "") \(familyName ?? "")", userId: userID)
            } else {
                self.appleIdLogin(email: "", name: "", userId: userID)
            }
        }
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("authorization error")
        guard let error = error as? ASAuthorizationError else {
            return
        }

        switch error.code {
        case .canceled:
            // user press "cancel" during the login prompt
            print("Canceled")
        case .unknown:
            // user didn't login their Apple ID on the device
            print("Unknown")
        case .invalidResponse:
            // invalid response received from the login
            print("Invalid Respone")
        case .notHandled:
            // authorization request not handled, maybe internet failure during login
            print("Not handled")
        case .failed:
            // authorization failed
            print("Failed")
        @unknown default:
            print("Default")
        }
    }
}
