

import UIKit
import Alamofire
import SwiftyJSON

class WishlistViewController: BaseViewController {

    @IBOutlet weak var table_view_offer_height: NSLayoutConstraint!
    @IBOutlet weak var table_view_flyer_height: NSLayoutConstraint!
    @IBOutlet weak var view_offer: UIView!
    @IBOutlet weak var view_flyer: UIView!
    @IBOutlet weak var table_view_offer: UITableView!
    @IBOutlet weak var table_view_flyer: UITableView!
    @IBOutlet weak var segment_view: SignatureSegmentedControl!
    
    private let nibWishlistName = "WishlistViewCell"
    private let nibFlyerOfferName = "FlyerOfferViewCell"
    
    private var arrayOfFlyers : Array<FlyerWishlist> = []
    private var arrayOfOffers : Array<OfferWishlist> = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        fetchFlyersWishlist()
    }
    
    private func initVariables () {
        initNibs()
        
        table_view_flyer.delegate = self
        table_view_flyer.dataSource = self
        
        table_view_offer.delegate = self
        table_view_offer.dataSource = self
    }
    
    private func initNibs () {
        let nibWishlist = UINib(nibName: nibWishlistName, bundle: nil)
        let nibFlyerOffer = UINib(nibName: nibFlyerOfferName, bundle: nil)
        table_view_flyer.register(nibFlyerOffer, forCellReuseIdentifier: nibFlyerOfferName)
        table_view_offer.register(nibWishlist, forCellReuseIdentifier: nibWishlistName)
    }

    private func fetchFlyersWishlist () {
        UIUtils.showLoader(view: self.view)
        
        let consumerId = LocalPrefs.getUserData()[Constants.CONSUMER_ID]!
        let URL = "\(Constants.BASE_URL)/flyer/wishlist/fetch?consumer_id=\(consumerId)&device_type=Ios"
        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        
        
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
                        
                        let data = responseObj["data"].dictionaryValue
                        let flyerArray = data["flyers"]?.arrayValue
                        let offerArray = data["offers"]?.arrayValue

                        for arrayObj in flyerArray! {
                            let flyerWishlistJsonObj = arrayObj.dictionaryObject!

                            do {
                                let data = try JSONSerialization.data(withJSONObject: flyerWishlistJsonObj, options: .prettyPrinted)
                                let flyerWishlistObj = try JSONDecoder().decode(FlyerWishlist.self, from: data)
                                self.arrayOfFlyers.append(flyerWishlistObj)
                            } catch {
                                print("ERROR : " , error)
                            }
                        }
                        
                        for arrayObj in offerArray! {
                            let offerWishlistJsonObj = arrayObj.dictionaryObject!
                            
                            do {
                                let data = try JSONSerialization.data(withJSONObject: offerWishlistJsonObj, options: .prettyPrinted)
                                let offerWishlistObj = try JSONDecoder().decode(OfferWishlist.self, from: data)
                                self.arrayOfOffers.append(offerWishlistObj)
                            } catch {
                                print("ERROR : " , error)
                            }
                        }
                      
                    } else {
                        UIUtils.showAlert(vc: self, message: message)
                    }
                    
                    if self.arrayOfOffers.count == 0 {
                        self.view_offer.isHidden = true
                    } else {
                        self.view_offer.isHidden = false
                    }
                    
                    if self.arrayOfFlyers.count == 0 {
                        self.view_flyer.isHidden = true
                    } else {
                        self.view_flyer.isHidden = false
                    }
                    
                    self.table_view_offer.reloadData()
                    self.table_view_flyer.reloadData()
                    
                case .failure(let error):
                    UIUtils.dismissLoader(uiView: self.view)
                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
    }

}

extension WishlistViewController: UITableViewDelegate, UITableViewDataSource {
    
    override func viewWillLayoutSubviews() {
        
        self.table_view_flyer_height.constant = self.table_view_flyer.contentSize.height
        self.table_view_offer_height.constant = self.table_view_offer.contentSize.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == table_view_offer {
            return arrayOfOffers.count
        } else {
            return arrayOfFlyers.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
//        let wishlist = arrayOfWishlist[indexPath.row]
//        cell.configureWishlistWithItem(wishlist: wishlist)
        
        switch tableView {
            
        case table_view_offer:
            let cell = tableView.dequeueReusableCell(withIdentifier: nibWishlistName, for: indexPath) as! WishlistViewCell
            
            let offer = arrayOfOffers[indexPath.row]
            cell.configureOfferWishlistWithItem(offer: offer)
            
            cell.selectionStyle = .none
            return cell
    
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: nibFlyerOfferName, for: indexPath) as! FlyerOfferViewCell
            
            let flyerDeal = arrayOfFlyers[indexPath.row]
            cell.configureFlyerDealWishlist(wishlist: flyerDeal)
            
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == table_view_flyer {
            let offerDetailsVC = getStoryboard(name: ViewIdentifiers.SB_FLYER).instantiateViewController(withIdentifier: ViewIdentifiers.VC_FLYER_DETAILS) as! FlyerDealDetailsViewController
            offerDetailsVC.flyerDeal = arrayOfFlyers[indexPath.row].offer_meta!
            self.navigationController?.pushViewController(offerDetailsVC, animated: true)
        }
        else
        {
            let dealDetailsVC = getStoryboard(name: ViewIdentifiers.SB_DEAL).instantiateViewController(withIdentifier: ViewIdentifiers.VC_DEAL_DETAILS) as! DealDetailsViewController
            dealDetailsVC.deal = arrayOfOffers[indexPath.row].offer_meta!
            self.navigationController?.pushViewController(dealDetailsVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewWillLayoutSubviews()
    }
}
