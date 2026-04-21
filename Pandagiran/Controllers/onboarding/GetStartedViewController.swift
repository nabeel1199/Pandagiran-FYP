

import UIKit
import Alamofire
import FirebaseAnalytics
import SwiftyJSON


struct Onboarding {
    var featureImage : String
    var featureTitle : String
    var featureMessage : String
}

class GetStartedViewController: BaseViewController {

    @IBOutlet weak var page_control: UIPageControl!
    @IBOutlet weak var collection_view_onboarding: UICollectionView!
    
    private var onboardingArray : Array<Onboarding> = []
    private var indexToSelect = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()
        onboardingFeatures()
    }
    
   
    
    private func navigateToTermsAndConditions () {
        let dest = getStoryboard(name: ViewIdentifiers.SB_ONBOARDING).instantiateViewController(withIdentifier: ViewIdentifiers.VC_TERMS_AND_CONDITIONS)
        self.navigationController?.pushViewController(dest, animated: true)
    }

    private func initVariables() {
        collection_view_onboarding.delegate = self
        collection_view_onboarding.dataSource = self
    }
    
    private func initUI () {
        self.viewBackgroundColor = .white
        self.navigationItemColor = .light
        
//        let logo = UIImage(named: "bt_4")
//        let imageView = UIImageView(image:logo)
//        self.navigationItem.titleView = imageView
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SKIP", style: .plain, target: self, action: #selector(onSkipTapped))
    }
    
    private func onboardingFeatures () {
        var onboarding = Onboarding(featureImage: "get_started_1", featureTitle: "Purpose Fuels passion", featureMessage: "Always stay financially fit by tracking expenses, planning budgets and setting saving goals with Hysab Kytab.")
        onboardingArray.append(onboarding)
        
        onboarding = Onboarding(featureImage: "get_started_2", featureTitle: "Offers Just For You", featureMessage: "Looking for the best deals and actually save while staying within a budget? Hysab Kytab is the place for you!")
        onboardingArray.append(onboarding)
        
        onboarding = Onboarding(featureImage: "get_started_3", featureTitle: "Flyers Near You", featureMessage: "Start saving more by browsing local flyers and make shopping fun!")
        onboardingArray.append(onboarding)
    }
    
    private func registerUserNetworkCall () {
        UIUtils.showLoader(view: self.view)
        let URL = "\(Constants.BASE_URL)/consumers/register"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]

        let dictToEncrypt = ["device_type" : "Ios",
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
                    
                    if status == 1 {
                        let data = responseObj["data"].dictionaryValue
                        let consumerRecord = data["consumer_record"]?.dictionaryValue

                        let consumerId = consumerRecord!["consumer_id"]?.int
                        
                        LocalPrefs.setConsumerId(userId: Int64(consumerId!))
                        self.navigateToTermsAndConditions()
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

    @objc private func onSkipTapped () {
//        registerUserNetworkCall()
        self.navigateToTermsAndConditions()
    }
    
    @IBAction func onNextTapped(_ sender: Any) {
        if indexToSelect == 3 {
//           registerUserNetworkCall()
            self.navigateToTermsAndConditions()
        } else {
            DispatchQueue.main.async {
                self.collection_view_onboarding.selectItem(at: IndexPath(item: self.indexToSelect, section: 0), animated: true, scrollPosition: [.centeredHorizontally])
                self.page_control.currentPage = self.indexToSelect
            }
        }
    }
}

extension GetStartedViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onboardingArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection_view_onboarding.dequeueReusableCell(withReuseIdentifier: "OnboardingViewCell", for: indexPath) as! OnboardingViewCell
        
        let onboarding = onboardingArray[indexPath.row]
        cell.iv_onboarding.image = UIImage( named : onboarding.featureImage)
        cell.iv_onboarding.contentMode = .scaleAspectFill
        cell.label_title.text = onboarding.featureTitle
        cell.label_message.text = onboarding.featureMessage
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = self.view.frame.width
        let cellHeight = collectionView.frame.height
        return CGSize(width : cellWidth , height : cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        self.indexToSelect = indexPath.row + 1
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = self.collection_view_onboarding.frame.size.width
        page_control.currentPage = Int(self.collection_view_onboarding.contentOffset.x / pageWidth)
    }
}
