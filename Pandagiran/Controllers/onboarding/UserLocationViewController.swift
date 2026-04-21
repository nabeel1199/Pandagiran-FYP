

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import FirebaseAnalytics

class UserLocationViewController: BaseViewController {

    @IBOutlet weak var switch_location: UISwitch!
    
    private var locationManager = CLLocationManager()
    private var latitude: Double = 0
    private var longitude: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables ()
        initUI()
    }
    
    private func initVariables () {
        locationManager.delegate = self
    }
    
    private func initUI () {
        self.navigationItemColor = .light
        self.viewBackgroundColor = .white
        self.navigationItem.hidesBackButton = true
    }
    
    private func updateLocationNetworkCall (latitude: String, longitude: String) {
        let URL = "\(Constants.BASE_URL)/consumers/update/geo/location"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        
        
        let dictToEncrypt =  [  "device_type" : "Ios",
                                "consumer_id" : "\(LocalPrefs.getConsumerId())",
                                "latitude" : latitude,
                                "longitude" : longitude]
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
                        UIUtils.dismissLoader(uiView: self.view)
                    } else {
                        UIUtils.dismissLoader(uiView: self.view)
                        UIUtils.showAlert(vc: self, message: message)
                    }
                    
                    
                case .failure(let error):
                    UIUtils.dismissLoader(uiView: self.view)
                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
    }
    
    private func navigateToMainVC () {
        
        let dest = self.getStoryboard(name: ViewIdentifiers.SB_MAIN).instantiateViewController(withIdentifier: "MainVC")
        self.present(dest, animated: true, completion: nil)
    }

    @IBAction func onLocationSwitchToggled(_ sender: Any) {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        } else {
            UIUtils.dismissLoader(uiView: self.view)
        }
    }
    
    @IBAction func onNextTapped(_ sender: Any) {
        Analytics.logEvent("USOB_9_Letsgo_clicked", parameters: nil)
        self.navigateToMainVC()
    }
    
}

extension UserLocationViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        UIUtils.dismissLoader(uiView: self.view)
        
        if status == .denied {
            switch_location.isUserInteractionEnabled = false
            switch_location.isOn = false
        } else if status == .restricted {
//            switch_location.isUserInteractionEnabled = false
//            switch_location.isUserInteractionEnabled = false
//            switch_location.isOn = false
//            UIUtils.dismissLoader(uiView: self.view)
        } else {
            UIUtils.dismissLoader(uiView: self.view)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        if latitude == 0 && longitude == 0 {
            UIUtils.showLoader(view: self.view)
            latitude = locValue.latitude
            longitude = locValue.longitude
            updateLocationNetworkCall(latitude: String(latitude), longitude: String(longitude))
        }

        
    }
    
    
}
