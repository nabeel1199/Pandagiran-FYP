

import UIKit
import Alamofire
import SwiftyJSON
import FirebaseAnalytics

protocol AlreadySignUpUser {
    func continueSignUp()
}

class UserInterestsViewController: BaseViewController {
    
    @IBOutlet weak var table_view_interests: UITableView!
    
    private var userInterestsArray : Array<UserInterests> = []
    private let nibUserTypeName = "UserSelectionViewCell"
    private var selectedInterests : Array<String> = []
    
    public var user : UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateUserDescriptionArray()
        initVariables()
        initUI ()
        
    }
    
    private func populateUserDescriptionArray () {
        let userInterestsArray = Utils.readJson(resourceName: "user_interests")
        
        for userInterest in userInterestsArray {
            let userObj = JSON(userInterest).dictionaryValue
            let name = userObj["name"]?.stringValue
            let icon = userObj["icon"]?.stringValue
            let userInterest = UserInterests(name: name!, icon: icon!)
            self.userInterestsArray.append(userInterest)
        }
    }
    
    private func initVariables () {
        initNibs()
        
        table_view_interests.delegate = self
        table_view_interests.dataSource = self
    }
    
    private func initUI () {
        self.viewBackgroundColor = .white
        self.navigationItemColor = .light
        
          self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SKIP", style: .plain, target: self, action: #selector(onSkipTapped))
    }
    
    private func initNibs () {
        let nibuserType = UINib(nibName: nibUserTypeName, bundle: nil)
        table_view_interests.register(nibuserType, forCellReuseIdentifier: nibUserTypeName)
    }
    
    private func navigateToBackupVC() {
        let backupMainVC = getStoryboard(name: ViewIdentifiers.SB_BACKUP).instantiateViewController(withIdentifier: ViewIdentifiers.VC_BACKMAINVC) as! BackupMainVC
        self.navigationController?.pushViewController(backupMainVC, animated: true)
    }
    
    private func navigateToLocationVC () {
        let locationVC = getStoryboard(name: ViewIdentifiers.SB_ONBOARDING).instantiateViewController(withIdentifier: ViewIdentifiers.VC_USER_LOCATION) as! UserLocationViewController
        self.navigationController?.pushViewController(locationVC, animated: true)
    }
    
    private func showSignUpAlert(){
        let signupAlert = getStoryboard(name: ViewIdentifiers.SB_BACKUP).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SIGNUP_ALERT) as! SignupContinueAlertVC
        signupAlert.delegate = self
        print("Hey \(LocalPrefs.getUserName()) !")
        signupAlert.modalPresentationStyle = .overCurrentContext
        present(signupAlert, animated: true, completion: nil)
    }
    
    private func registerNetworkCall () {
        UIUtils.showLoader(view: self.view)
        let URL = "\(Constants.BASE_URL)/consumers/profile/update"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        
        
        let dictToEncrypt =  [  "device_type" : "Ios",
                                "profession_type" : user!.userType!,
                                "consumer_id" : "\(LocalPrefs.getConsumerId())",
                                "gender" : user!.userGender!,
                                "interests" : user!.userInterests!,
                                "dob" : user!.userDob!,
                                "currency" : user!.userCurrency!,
                                "email" : user!.userEmail!,
                                "name" : user!.userName!]
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
                    print(responseObj)
                    if status == 1 {
                        let userDetails : [String : String] = [
                            Constants.CONSUMER_ID : "\(LocalPrefs.getConsumerId())",
                            Constants.GENDER : (self.user?.userGender)!,
                            Constants.EMAIL : (self.user?.userEmail)!,
                            Constants.TOKEN : LocalPrefs.getDeviceToken(),
                            Constants.USER_NAME : (self.user?.userName)! ,
                            Constants.USER_PHONE : LocalPrefs.getUserPhone(),
                            Constants.CURRENCY : (self.user?.userCurrency)!,
                            Constants.USER_DOB : (self.user?.userDob)!,
                            Constants.USER_TYPE : (self.user?.userType)!]
                        let device_id = responseObj["data"]["device_id"].stringValue
                        
                        LocalPrefs.setDeviceId(deviceId: device_id)
                        LocalPrefs.setUserData(userDetails: userDetails)
                        LocalPrefs.setUserInterests(userInterets: (self.user?.userInterests)!)
                        LocalPrefs.setUserCurrency(userCurrency: (self.user?.userCurrency)!)
                        LocalPrefs.setCurrencyFlag(currencyFlag: (self.user?.currencyFlag)!)
                        LocalPrefs.setCurrentInterval(currentInterval: Constants.MONTHLY)
                        LocalPrefs.setProfessionType(professionType: (self.user?.userType)!)
                        LocalPrefs.setIsRegistered(isRegistered: true)
                                               
                        if let backupAvailable = responseObj["data"]["backup_available"].int{
                            if backupAvailable == 1{
                                self.navigateToBackupVC()
                            } else {
                                QueryUtils.saveAccounts()
                                QueryUtils.saveCategories()
                                self.navigateToLocationVC()
                            }
                        } else {
                            QueryUtils.saveAccounts()
                            QueryUtils.saveCategories()
                            self.navigateToLocationVC()
                        }
                    
                        
                    } else {
                        UIUtils.showAlert(vc: self, message: message)
                    }
                    
                    
                case .failure(let error):
                    UIUtils.dismissLoader(uiView: self.view)
                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
    }
    
 
    
    @objc private func onSkipTapped () {
        Analytics.logEvent("USOB_7_Interest_skiped", parameters: nil)
        let userInterests = selectedInterests.joined(separator: "~")
        user?.userInterests = userInterests
        if LocalPrefs.getAlreadyRegistered(){
            self.showSignUpAlert()
        } else {
            self.registerNetworkCall()
        }
    }

    @IBAction func onNextTapped(_ sender: Any) {
        Analytics.logEvent("USOB_8_interest_entered", parameters: nil)
        let userInterests = selectedInterests.joined(separator: "~")
        user?.userInterests = userInterests
        if LocalPrefs.getAlreadyRegistered(){
            self.showSignUpAlert()
        } else {
            self.registerNetworkCall()
        }
        
    }
    
}
extension UserInterestsViewController: AlreadySignUpUser{
    func continueSignUp() {
        self.registerNetworkCall()
    }
}

extension UserInterestsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userInterestsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nibUserTypeName, for: indexPath) as! UserSelectionViewCell
        
        let interest = userInterestsArray[indexPath.row]
        cell.iv_user.image = UIImage(named: interest.icon)
        cell.label_profession_type.text = interest.name
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView.cellForRow(at: indexPath) != nil else {
            return
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! UserSelectionViewCell
        
        let interest = userInterestsArray[indexPath.row].name
        
        if let index = selectedInterests.index(of: interest) {
            selectedInterests.remove(at: index)
            cell.setSelected(false, animated: true)
        } else {
            selectedInterests.append(interest)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard tableView.cellForRow(at: indexPath) != nil else {
            return
        }
       
    }
    
    
}
