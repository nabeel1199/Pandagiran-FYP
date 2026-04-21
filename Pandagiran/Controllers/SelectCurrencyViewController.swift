

import UIKit
import Kingfisher
import Alamofire
import SwiftyJSON
import Firebase

class SelectCurrencyViewController: UIViewController , CurrencySelectionListener , UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var btn_currency: UIButton!
    @IBOutlet weak var iv_flag: UIImageView!
    @IBOutlet weak var collection_view: UICollectionView!
    
    var currency : String = "MYR"
    var countryName : String = "MYR"
    var countryFlag = "http://bo.hysabkytab.com/HK_data_pics/country_flags/my.png"
    var lat : String = ""
    var long : String = ""
    var userDescriptionArray : Array<UserDescription> = []
    var professionType : String = ""
    var currencyArray : Array<UserCurrency> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()
        populateUserDescriptionArray()
    }
    
    func initVariables () {
        fetchCurrencies()
        
        if LocalPrefs.getUserData()["currency"] != nil {
            self.currency = LocalPrefs.getUserData()["currency"]!
        } else {
            self.currency = "MYR"
        }
       
        collection_view.delegate = self
        collection_view.dataSource = self
        collection_view.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
    }
    
    func initUI () {
        setCustomBackground()
        var urlString = "http://hysabkytab.com/bo/HK_data_pics/country_flags/my.png"
        let flagURL = URL(string : "http://hysabkytab.com/bo/HK_data_pics/country_flags/my.png")
     
        for i in 0 ..< currencyArray.count {
            if currencyArray[i].currency3dg == self.currency {
                btn_currency.setTitle("\(currencyArray[i].currencyName!) (\(self.currency))", for: .normal)
                urlString = "http://hysabkytab.com/bo/HK_data_pics/country_flags/\(currencyArray[i].currency2dg!.lowercased()).png"
                LocalPrefs.setCurrencyFlag(currencyFlag: urlString)
                LocalPrefs.setDecimalFormat(decimalFormat: currencyArray[i].currencyPrecision!)
                
                iv_flag.kf.setImage(with: URL(string: urlString))
                return
            }
        }
    }
    
    func fetchCurrencies() {
        let jsonObj = Utils.readJson(resourceName: "core_country")

        for currency in jsonObj{
            let objc = JSON(currency)
            let urlCode = objc["country_iso_code_2dg"].stringValue
            let currencyObj = UserCurrency()
            currencyObj.currency3dg = objc["iso_code_3dg"].stringValue
            currencyObj.currencyFlag = "http://bo.hysabkytab.com/HK_data_pics/country_flags/\(urlCode.lowercased()).png"
            currencyObj.currencyName = objc["currency_name"].stringValue
            currencyObj.currency2dg = objc["country_iso_code_2dg"].stringValue
            currencyObj.currencyPrecision = objc["currency_precision"].intValue
            currencyArray.append(currencyObj)
        }
    }
    
    func populateUserDescriptionArray () {
        userDescriptionArray.append(UserDescription(boxColor : "#2196f3", boxIcon : "bt_1", userOccupation : "Student"))
        userDescriptionArray.append(UserDescription(boxColor : "#795548", boxIcon : "bt_90", userOccupation : "Professional"))
        userDescriptionArray.append(UserDescription(boxColor : "#33691e", boxIcon : "bt_2", userOccupation : "Housewife"))
        userDescriptionArray.append(UserDescription(boxColor : "#e91e63", boxIcon : "bt_65", userOccupation : "Retired"))
    }
    
    func completeRegistrationNetworkCall () {
        UIUtils.showLoader(view: self.view)
        self.view.isUserInteractionEnabled = false
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["MAC" : sha256,
                                           "random" : randString]
        
        
        let url = "\(Constants.BASE_URL)/updateprofile"
        let params : [String : String] = [ "user_id" : LocalPrefs.getUserData()["user_id"]!,
                                           "branch_id" : LocalPrefs.getUserData()["branch_id"]!,
                                           "company_id" : LocalPrefs.getUserData()["company_id"]!,
                                           "lat" : lat,
                                           "long" : long,
                                           "token" : LocalPrefs.getDeviceToken(),
                                           "email" : LocalPrefs.getUserData()["email"]!,
                                           "name" : LocalPrefs.getUserData()["user_name"]!,
                                           "gender" : LocalPrefs.getUserData()["gender"]!,
                                           "currency" : currency,
                                           "device_type" : "Ios",
                                           "describe" : professionType]
        
        
        Alamofire.request(url, method: .put, parameters: params, encoding: URLEncoding.httpBody , headers : headers)
            .responseString { response in
                switch response.result {
                case .success:
                    UIUtils.dismissLoader(uiView: self.view)
                    self.view.isUserInteractionEnabled = true
                    guard let objc = response.result.value else { return }
                    let responseObj = JSON(response.result.value)
                
                    Analytics.logEvent("get_started", parameters: ["0" : LocalPrefs.getUserData()["user_mobile"]! ,
                                                                                "1" : responseObj["email"].stringValue,
                                                                                "2" : "guest"])
                    
        
                    LocalPrefs.setUserCurrency(userCurrency: self.currency)
                    LocalPrefs.setCurrencyFlag(currencyFlag: self.countryFlag)
                    LocalPrefs.setCountryName(countryName: self.currency)
                    LocalPrefs.setCountryFlag(countryFlag: self.countryFlag)
                    self.appInitialConfiguration()
                    
                case .failure(let error):
                    UIUtils.dismissLoader(uiView: self.view)
                    self.view.isUserInteractionEnabled = true
                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
    }
    
    func navigateToMainVC () {
        let storyboard = UIUtils.getStoryboard(name: Constants.SB_MAIN)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "MainVC")
        self.present(mainVC, animated: true, completion: nil)
    }
    
    func appInitialConfiguration() {
        LocalPrefs.setCurrentInterval(currentInterval: Constants.MONTHLY)
        LocalPrefs.setIsRegistered(isRegistered: true)
        LocalPrefs.setIsVerified(isVerified: true)
        LocalPrefs.setProfessionType(professionType: professionType)
//        QueryUtils.saveAccounts()
//        QueryUtils.saveCategories()
        
        navigateToMainVC()
    }
    
    func setCustomBackground () {
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "background_icon.png")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
    }
    
    @IBAction func onCurrencyTapped(_ sender: Any) {
        let dialog = DialogSelectCurrency()
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.myDelegate = self
        present(dialog, animated: true, completion: nil)
    }
    
    @IBAction func onContinueTapped(_ sender: Any) {
        if professionType != "" {
            completeRegistrationNetworkCall()
        } else {
            UIUtils.showAlert(vc: self, message: "Please select user type")
        }
    }
    
    func onCurrencySelected(currency: String, country2dg: String, currencyFlag: String, countryName: String, decimal: Int) {
        self.currency = currency
        self.countryName = currency
        self.countryFlag = currencyFlag
        let flagURL = URL(string : currencyFlag)
        LocalPrefs.setCurrencyFlag(currencyFlag: currencyFlag)
        LocalPrefs.setDecimalFormat(decimalFormat: decimal)
        LocalPrefs.setCountryName(countryName: countryName)
        LocalPrefs.setCountryFlag(countryFlag: countryFlag)
        iv_flag.kf.setImage(with: flagURL)
        btn_currency.setTitle("\(countryName) (\(currency))", for: .normal)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userDescriptionArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection_view.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        
        cell.bg_view.layer.borderColor = Utils.hexStringToUIColor(hex: userDescriptionArray[indexPath.row].boxColor!).cgColor
        cell.category_title.text = userDescriptionArray[indexPath.row].userOccupation
        cell.category_title.textColor = UIColor.black
        cell.categoryImage.image = UIImage(named : userDescriptionArray[indexPath.row].boxIcon!)?.withRenderingMode(.alwaysTemplate)
        cell.categoryImage.tintColor = Utils.hexStringToUIColor(hex: userDescriptionArray[indexPath.row].boxColor!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
        cell.bg_view.backgroundColor = Utils.hexStringToUIColor(hex: userDescriptionArray[indexPath.row].boxColor!)
        cell.categoryImage.tintColor = UIColor.white
        professionType = userDescriptionArray[indexPath.row].userOccupation!
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
        
        cell.bg_view.backgroundColor = UIColor.white
        cell.categoryImage.tintColor = Utils.hexStringToUIColor(hex: userDescriptionArray[indexPath.row].boxColor!)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let widthPerItem = collectionView.frame.width / 2
        let heightPerItem = (collectionView.frame.height - 40) / 2
        return CGSize(width: widthPerItem , height: heightPerItem)
    }
}
