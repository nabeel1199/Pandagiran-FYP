

import UIKit
import Alamofire
import SwiftyJSON

class FlyersListingViewController: BaseViewController {

    @IBOutlet weak var label_flyer_count: UILabel!
    @IBOutlet weak var collection_view_flyers: UICollectionView!
    
    public var retailerId : String = ""
    public var retailerName = ""
    
    private let nibFlyerName = "FlyerViewCell"
    private var flyerArray : Array<Flyer> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVariables()
        initUI()
        fetchFlyerServiceHit()
    }
    
    private func initVariables () {
        initNibs()
        
        collection_view_flyers.delegate = self
        collection_view_flyers.dataSource = self
        
    }
    
    private func initUI () {
        self.navigationItem.title = retailerName
        
        let flyerLayout = collection_view_flyers.collectionViewLayout as! UICollectionViewFlowLayout
        flyerLayout.itemSize = CGSize(width: (UIScreen.main.bounds.width) / 2  , height: 215)
    }
    
    private func initNibs () {
        let nibFlyer = UINib(nibName: nibFlyerName, bundle: nil)
        collection_view_flyers.register(nibFlyer, forCellWithReuseIdentifier: nibFlyerName)
    }
    
    private func fetchFlyerServiceHit () {
        UIUtils.showLoader(view: self.view)
        
        let consumerId = LocalPrefs.getConsumerId()
        let URL = "\(Constants.BASE_URL)/flyer/list?consumer_id=\(consumerId)&device_type=Ios&retailer_id=\(retailerId)"
        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
        
        Alamofire.request(URL, method: .get, encoding: URLEncoding.httpBody , headers : headers)
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
                        let flyerJsonArray = responseObj["data"].arrayValue
                        
                        for flyerJsonObj in flyerJsonArray {
                            let flyer = Flyer(id: flyerJsonObj["id"].stringValue,
                                              title: flyerJsonObj["title"].stringValue,
                                              img: flyerJsonObj["img"].stringValue,
                                              start_date: flyerJsonObj["start_date"].stringValue,
                                              end_date: flyerJsonObj["end_date"].stringValue,
                                              total_pages: flyerJsonObj["total_pages"].intValue,
                                              expiry: flyerJsonObj["expiry"].int64Value)
                            
                            self.flyerArray.append(flyer)
                        }
                        
                        self.label_flyer_count.text = "\(self.flyerArray.count) Flyer(s)"
                        self.collection_view_flyers.reloadData()
                        
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

extension FlyersListingViewController : UICollectionViewDelegate , UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flyerArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collection_view_flyers.dequeueReusableCell(withReuseIdentifier: nibFlyerName, for: indexPath) as! FlyerViewCell
        
        let flyer = flyerArray[indexPath.row]
        cell.iv_flyer.kf.setImage(with: URL(string: flyer.img!))
        cell.label_flyer_title.text = flyer.title
        
        if let expiryDate = flyer.end_date {
            let expiryDateInt = Int64(expiryDate)
            let expiry = Date(timeIntervalSince1970: TimeInterval(expiryDateInt! / 1000))
            
            if expiry >= Date() {
                cell.label_flyer_expiry.text = "Expiry: \(Utils.currentDateUserFormat(date: expiry))"
            } else {
                cell.label_flyer_expiry.text = "Expired"
                cell.label_flyer_expiry.textColor = .red
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let flyerWebVC = getStoryboard(name: ViewIdentifiers.SB_FLYER).instantiateViewController(withIdentifier: ViewIdentifiers.VC_FLYER_WEBVIEW) as! FlyerWebViewViewController
        flyerWebVC.flyerId = flyerArray[indexPath.row].id!
        flyerWebVC.flyerName = flyerArray[indexPath.row].title!
        self.navigationController?.pushViewController(flyerWebVC, animated: true)
        

    }
}
