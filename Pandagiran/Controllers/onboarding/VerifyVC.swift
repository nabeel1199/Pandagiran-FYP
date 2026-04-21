

import UIKit
import Alamofire
import SwiftyJSON
import GoogleSignIn
import AuthenticationServices
import FBSDKLoginKit
import Firebase
import CoreData

class VerifyVC: UIViewController {

    @IBOutlet weak var verifyAppleButton: UIView!

    @IBOutlet weak var messageLBL: UILabel!
    @IBOutlet weak var verifyGoogleButton: UIButton!
    @IBOutlet weak var verifyFBButton: UIButton!
    @IBOutlet weak var verifyApple: UIButton!
    @IBOutlet weak var skipButton: GradientButton!
    
    var verify_Device = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance()?.presentingViewController = self
//        verifyAppleButton.isHidden = true
        self.verifyGoogleButton.addTarget(self, action: #selector(handleGoogleIdRequest), for: .touchUpInside)
        self.verifyFBButton.addTarget(self, action: #selector(handleFbIdRequest), for: .touchUpInside)
        self.verifyApple.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
        if verify_Device{
            skipButton.setTitle("LOGOUT", for: .normal)
            self.messageLBL.text = "We found that you are logged into other device with same email address. If you wish to continue here again, Verify with the same email address as your were logged in before."
            self.copyDatabase()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func skipNowPressed(_ sender: Any) {
        if skipButton.titleLabel?.text == "LOGOUT" {
            self.logOutUser()
//            self.dismiss(animated: true, completion: nil)
        } else {
            Analytics.logEvent("Verify_Skip", parameters: nil)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    private func logOutUser(){
        if let destination = UIUtils.getStoryboard(name: ViewIdentifiers.SB_BACKUP).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SKIP_MESSAGE) as? SkipRestoreMessage{
            destination.logout = true
            destination.modalPresentationStyle = .overCurrentContext
            present(destination, animated: true, completion: nil)
        }
    }
    
    
    // MARK:- Notification
    private func updateScreen() {
        Analytics.logEvent("Verify_Google", parameters: nil)
        if let user = GIDSignIn.sharedInstance()?.currentUser {
            // User signed in
            
            // Show greeting message
            print("\("Hello \(user.profile.givenName!)! ✌️")")
            if self.verify_Device{
                if LocalPrefs.getUserEmail() ==  user.profile.email{
                    self.registerSocialLogin(email: user.profile.email ?? "", name: user.profile.name ?? "No Name", appleTokenId: "")
                }else {
                    UIUtils.showSnackbarNegative(message: "Incorrect email")
                }
            } else {
                self.registerSocialLogin(email: user.profile.email ?? "", name: user.profile.name ?? "No Name", appleTokenId: "")
            }
            
            
        } else {
            // User signed out
            
            // Show sign in message
            UIUtils.showSnackbarNegative(message: "Failed to login")
            print("Please sign in... 🙂")
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
        Analytics.logEvent("Verify_Facebook", parameters: nil)
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
                    if self.verify_Device{
                        if LocalPrefs.getUserEmail() ==  email{
                            self.registerSocialLogin(email: email ?? "", name: name ?? "", appleTokenId: "")
                        } else {
                            UIUtils.showSnackbarNegative(message: "Incorrect email")
                        }
                    } else {
                        self.registerSocialLogin(email: email ?? "", name: name ?? "", appleTokenId: "")
                    }
                    
                }
                else {
                    print("error \(error)")
                    UIUtils.dismissLoader(uiView: self.view)
                    UIUtils.showSnackbarNegative(message: "Something went wrong\n\(String(describing: error?.localizedDescription))")
                }
            })
        }
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
        }
        
    }
}
extension VerifyVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding, GIDSignInDelegate{
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
//        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
//
//            let userIdentifier = appleIDCredential.user
//            self.userID = userIdentifier
//            let fullName = appleIDCredential.fullName
//            let emailAddress = appleIDCredential.email
//
//            self.socialLogin(email: "\(emailAddress)", name: "\(fullName)")
//            print("User id is \(userIdentifier) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: emailAddress))")
//
//        }
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
                if email.contains("@privaterelay.appleid") {
                    self.registerSocialLogin(email: "", name: "\(givenName ?? "") \(familyName ?? "")", appleTokenId: userID)
                } else {
                    self.registerSocialLogin(email: email, name: "\(givenName ?? "") \(familyName ?? "")", appleTokenId: userID)
                }
                
            } else {
                self.registerSocialLogin(email: "", name: "\(givenName ?? "") \(familyName ?? "")", appleTokenId: userID)
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

extension VerifyVC{
    
    func registerSocialLogin(email: String, name: String, appleTokenId: String?){
       UIUtils.showLoader(view: self.view)
       let URL = "\(Constants.BASE_URL)/consumers/email/update"
       let randString = Utils.getRandomString(size: 20)
       let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
       let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                          "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
       
       
       var dictToEncrypt =  ["device_type" : "Ios",
                             "consumer_id" : "\(LocalPrefs.getConsumerId())",
                             "consumer_name" : "\(name)",
                             "apple_id_token" : "\(appleTokenId ?? "")",
                             "email_address" : "\(email)"]
        if self.verify_Device{
            dictToEncrypt =  ["device_type" : "Ios",
                              "consumer_id" : "\(LocalPrefs.getConsumerId())",
                              "consumer_name" : "\(name)",
                              "apple_id_token" : "\(appleTokenId ?? "")",
                              "email_address" : "\(email)",
                              "use_case": "DEVICE_VERIFICATION"]
        }

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
                   let responseObj = JSON.init(parseJSON: decryptedObj ?? "")
                   let status = responseObj["status"].int
                   let message = responseObj["message"].string
                   
                   if status == 1 {
                    print("Message \(message) \nResponse: \(responseObj)")
                    LocalPrefs.setUserPhone(userPhone: "")
                    let data = responseObj["data"].dictionaryValue
                    let name = data["consumer_name"]?.stringValue
                    let email = data["email_address"]?.stringValue
                    let currency = data["currency"]?.stringValue
                    let userType = data["profession_type"]?.stringValue
                    let gender = data["gender"]?.stringValue
                    let consumerId = data["consumer_id"]?.int64
                    let dob = data["dob"]?.stringValue
                    let device_id = responseObj["data"]["device_id"].stringValue
                    
                    let userDetails : [String:String] = [Constants.USER_NAME : name!,
                                                         Constants.EMAIL : email!,
                                                         Constants.CONSUMER_ID : String(consumerId!),
                                                         Constants.CURRENCY : currency!,
                                                         Constants.USER_TYPE : userType!,
                                                         Constants.GENDER : gender!,
                                                         Constants.USER_DOB : dob!]
                    
                    
                    LocalPrefs.setDeviceId(deviceId: device_id)
                    LocalPrefs.setConsumerId(userId: consumerId!)
                    LocalPrefs.setUserEmail(userEmail: email ?? "")
                    LocalPrefs.setUserName(userName: name ?? "")
                    LocalPrefs.setUserData(userDetails: userDetails)
                    
                    if self.verify_Device{
                        self.restoreDataFromLocal()
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }

                    
                       
                   } else {
                    UIUtils.showAlert(vc: self, message: message ?? "")
                   }
                   
                   
               case .failure(let error):
                   UIUtils.dismissLoader(uiView: self.view)
                   UIUtils.showAlert(vc: self, message: error.localizedDescription)
               }
           }
       
   }
    
    private func copyDatabase() {
        let backUpFolderUrl = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask).first!
        let backupUrl = backUpFolderUrl.appendingPathComponent("backup")
        let backupUrl2 = backUpFolderUrl.appendingPathComponent("backup-shm")
        let backupUrl3 = backUpFolderUrl.appendingPathComponent("backup-wal")
        
        if FileManager.default.fileExists(atPath: backupUrl.path) {
            do {
                try FileManager.default.removeItem(at: backupUrl)
                try FileManager.default.removeItem(at: backupUrl2)
                try FileManager.default.removeItem(at: backupUrl3)
            } catch {
                print("Could not delete the existing backup")
                return
            }
        }
        
        let container = NSPersistentContainer(name: "Hysab Kytab")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in })
        
        let store:NSPersistentStore
        store = container.persistentStoreCoordinator.persistentStores.last!
        do {
            try container.persistentStoreCoordinator.migratePersistentStore(store,
                                                                            to: backupUrl,
                                                                            options: nil,
                                                                            withType: NSSQLiteStoreType)
            
            print(setLocalBackupTime())
//            UIUtils.showSnackbar(message: "Backup created successfully")
        } catch {
            print("Failed to migrate" , error)
//            UIUtils.showSnackbarNegative(message: "Could not create the backup")
        }
    }
    
    private func setLocalBackupTime () -> String {
        let backUpFolderUrl = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask).first!
        let backupUrl = backUpFolderUrl.appendingPathComponent("backup")
        
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: backupUrl.path)
            let creationDate = attrs[FileAttributeKey.creationDate] as! Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            let time = dateFormatter.string(from: creationDate)
            let localBackup = "\(Utils.currentDateUserFormat(date: creationDate)) at \(time)"
            return localBackup
//            label_last_backup.text = "Last synced on : \(localBackup)"
            
        } catch {
            
//            label_last_backup.text = "Last synced on : No backup"
        }
        
        return ""
    }

    
    private func restoreDataFromLocal(){
        Constants.IS_RESTORE = true
        Constants.IS_LOCAL_RESTORE = true
        LocalPrefs.setIsDataWiped(isDataWiped: true)
        QueryUtils.deleteAllSavings()
        QueryUtils.deleteAllAccounts()
        QueryUtils.deleteAllCategories()
        QueryUtils.deleteSavingTransactions()
        QueryUtils.deleteAllTransaction()
        self.clearDataFromServer()
        let storyboard = UIUtils.getStoryboard(name: Constants.SB_MAIN)
        let dest = storyboard.instantiateViewController(withIdentifier: "LandingViewController") as! LandingViewController
        dest.verify_device = true
        self.present(dest, animated: true, completion: nil)
    }
    
    func clearDataFromServer(){
        Analytics.logEvent("Wipe_Server", parameters: nil)
        RestoreNetworkCalls.sharedInstance.getWipAllData(isRestore: true) { status, message, response in
            if status == 1{
                print(response)
                print(message)
            } else{
                print(response)
                print(message)
                UIUtils.showSnackbarNegative(message: "Failed to clear Data")
            }
        }
    }
}
