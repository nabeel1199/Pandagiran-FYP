

import UIKit
import Cosmos
import Alamofire
import SwiftyJSON
import FirebaseDynamicLinks

class FlyerDealDetailsViewController: BaseViewController {

    @IBOutlet weak var view_flyer: CardView!
    @IBOutlet weak var label_flyer_top: UILabel!
    @IBOutlet weak var iv_flyer_top: UIImageView!
    @IBOutlet weak var iv_favourite: UIImageView!
    @IBOutlet weak var view_favourite: UIView!
    @IBOutlet weak var iv_wishlist: UIImageView!
    @IBOutlet weak var label_wishlist: UILabel!
    @IBOutlet weak var label_retailer_address: UILabel!
    @IBOutlet weak var label_retailer_title: UILabel!
    @IBOutlet weak var iv_retailer: UIImageView!
    @IBOutlet weak var iv_flyer: UIImageView!
    @IBOutlet weak var iv_flyer_retailer: UIImageView!
    @IBOutlet weak var label_flyer_expiry: UILabel!
    @IBOutlet weak var label_flyer_title: UILabel!
    @IBOutlet weak var label_flyer_heading: UILabel!
    @IBOutlet weak var view_directions: CardView!
    @IBOutlet weak var view_contact: CardView!
    @IBOutlet weak var deal_collection_height: NSLayoutConstraint!
    @IBOutlet weak var collection_view_similar_deals: UICollectionView!
    @IBOutlet weak var view_wishlisht: CardView!
    @IBOutlet weak var label_amount_before: UILabel!
    @IBOutlet weak var label_amount_now: UILabel!
    @IBOutlet weak var label_expiry: UILabel!
    @IBOutlet weak var label_deal_views: UILabel!
    @IBOutlet weak var label_deal_title: UILabel!
    @IBOutlet weak var iv_deal: UIImageView!
    @IBOutlet weak var scroll_view: UIScrollView!
    
    public var flyerDeal : FlyerDeal!
    
    private let nibDealName = "FlyerSimilarDealViewCell"
    private var arrayOfDeals : Array<FlyerDeal> = []
    private let dealsCalls = DealsAndOffers()
    private var wishlistUsecase = "add"
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            print("Height : " , self.collection_view_similar_deals.contentSize.height )
            self.deal_collection_height.constant = self.collection_view_similar_deals.contentSize.height
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


        initVariables()
        initUI()
        populateDealDetails()
        fetchDeals()
    }
    
    private func initVariables () {
        initNibs()
        
        collection_view_similar_deals.delegate = self
        collection_view_similar_deals.dataSource = self

    }
    
    private func initUI () {
        self.navigationItem.title = flyerDeal.title
        
        if let layout = collection_view_similar_deals.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: 300, height: 300)
        }
        
        let wishListTapGest = UITapGestureRecognizer(target: self, action: #selector(onWishlistTapped))
        view_wishlisht.addGestureRecognizer(wishListTapGest)
        
        let viewContactGest = UITapGestureRecognizer(target: self, action: #selector(onContactTapped))
        view_contact.addGestureRecognizer(viewContactGest)
        
        let viewDirectionGest = UITapGestureRecognizer(target: self, action: #selector(onDirectionsTapped))
        view_directions.addGestureRecognizer(viewDirectionGest)
        
        let viewFavGest = UITapGestureRecognizer(target: self, action: #selector(onFavouriteTapped))
        view_favourite.addGestureRecognizer(viewFavGest)
        
        let flyerTapGest = UITapGestureRecognizer(target: self, action: #selector(onFlyerTapped))
        view_flyer.addGestureRecognizer(flyerTapGest)
        
    }
    
    private func initNibs () {
        let nibDeal = UINib(nibName: nibDealName, bundle: nil)
        collection_view_similar_deals.register(nibDeal, forCellWithReuseIdentifier: nibDealName)
    }
    
    private func populateDealDetails () {
        if let expiryDate = flyerDeal.flyer?.expiry {
            let expiry = Date(timeIntervalSince1970: TimeInterval(expiryDate / 1000))
            
            
            if expiry >= Date() {
                label_expiry.text = "Expiry: \(Utils.currentDateUserFormat(date: expiry))"
                label_flyer_expiry.text = "Expiry: \(Utils.currentDateUserFormat(date: expiry))"
            } else {
                label_expiry.textColor = .red
                label_flyer_expiry.textColor = .red
                label_expiry.text = "Expired"
                label_flyer_expiry.text = "Expired"
            }
        }
        
        
        iv_flyer_top.kf.setImage(with: URL(string: flyerDeal.retailer!.img))
        label_flyer_top.text = flyerDeal.retailer!.title
        iv_deal.kf.setImage(with: URL(string: flyerDeal.img))
        label_deal_title.text = flyerDeal.title
        label_deal_views.text = "\(flyerDeal.total_views) Views"
        label_amount_now.text = "Rs \(Utils.formatDecimalNumber(number: flyerDeal.sale_price, decimal: 0))"
        label_amount_before.attributedText = UIUtils.getStruckThroughText(text: "Rs \(Utils.formatDecimalNumber(number: flyerDeal.original_price, decimal: 0))")
        
        label_flyer_heading.text = "\(flyerDeal.retailer!.title) Flyer"
        label_flyer_title.text = flyerDeal.flyer!.title
        
        if let flyerImage = flyerDeal.flyer?.img {
            iv_flyer.kf.setImage(with: URL(string: flyerImage))
        }
        
        
        iv_retailer.kf.setImage(with: URL(string: flyerDeal.retailer!.img))
        iv_flyer_retailer.kf.setImage(with: URL(string: flyerDeal.retailer!.img))
        label_retailer_title.text = flyerDeal.retailer!.title
        label_retailer_address.text = flyerDeal.retailer!.address
        
        if let isInWishlist = flyerDeal.is_in_wishlist {
            configureWishlistButton(isSelected: isInWishlist)
            
            if isInWishlist {
                self.wishlistUsecase = "delete"
            }
        }
        
        if let isLiked = flyerDeal.is_liked {
            configureLikeButton(isSelected: isLiked)
        }
    }
    
    private func fetchDeals () {
        UIUtils.showLoader(view: self.view)
        dealsCalls.fetchSimilarDeals(dealId: flyerDeal!.id, successHandler: ({ (arrayOfDeals, status, message) in
            UIUtils.dismissLoader(uiView: self.view)
            self.arrayOfDeals = arrayOfDeals
            self.collection_view_similar_deals.reloadData()
            
        }))
        { (error) in
            UIUtils.dismissLoader(uiView: self.view)
            print("ERROR : " , error)
        }
    }
    
    private func fetchSimilarDeals () {
        UIUtils.showLoader(view: self.view)
        
        let consumerId = LocalPrefs.getConsumerId()
        let URL = "\(Constants.BASE_URL)/flyer/deal/similar/offers?consumer_id=\(consumerId)&device_type=Ios&deal_id=\(flyerDeal.id)"
        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
       

        Alamofire.request(URL, method: .get , encoding : URLEncoding.httpBody , headers: headers)
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
                        self.arrayOfDeals.removeAll()
                        let dataArray = responseObj["data"].arrayValue
                        
                        for dataObj in dataArray {
                            let dealJsonObj = dataObj.dictionaryObject
                            
                            
                            do {
                                let data = try JSONSerialization.data(withJSONObject: dealJsonObj!, options: .prettyPrinted)
                                let deal = try JSONDecoder().decode(FlyerDeal.self, from: data)
                                self.arrayOfDeals.append(deal)
                            } catch {
                                print("ERROR : " , error)
                            }
                        }
                        
                        self.collection_view_similar_deals.reloadData()
                        
                    } else {
                        UIUtils.showAlert(vc: self, message: message)
                    }
                    
                    
                case .failure(let error):
                    UIUtils.dismissLoader(uiView: self.view)
                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
    }
    
    private func addToWishlistNetworkCall () {
        UIUtils.showLoader(view: self.view)
        
        dealsCalls.addToWishlistNetworkCall(dealId: flyerDeal.id,
                                            use_case: wishlistUsecase,
                                            successHandler:
            { (status, messsage) in
            UIUtils.dismissLoader(uiView: self.view)
            
                if status == 1 {
                    if self.wishlistUsecase == "add" {
                        self.configureWishlistButton(isSelected: true)
                        self.wishlistUsecase = "delete"
                    } else {
                        self.configureWishlistButton(isSelected: false)
                        self.wishlistUsecase = "add"
                    }
                    
                } else {
                    UIUtils.showAlert(vc: self, message: messsage)
                    self.configureWishlistButton(isSelected: false)
                }
            
        }) { (error) in
            UIUtils.dismissLoader(uiView: self.view)
            UIUtils.showAlert(vc: self, message: error.localizedDescription)
        }
    }
    
    private func likeFlyerDealNetworkCall () {
        dealsCalls.likeFlyerOfferNetworkCall(flyer_id: flyerDeal.flyer_id,
                                             offer_id: flyerDeal.id,
                                             successHandler:
            { (status, message) in
                
                if status == 1 {
                    self.configureLikeButton(isSelected: true)
                } else {
                    UIUtils.showAlert(vc: self, message: message)
                    self.configureLikeButton(isSelected: false)
                }
                
                
        })
        { (error) in
            UIUtils.dismissLoader(uiView: self.view)
            UIUtils.showAlert(vc: self, message: error.localizedDescription)
        }
    }
    
    private func configureWishlistButton (isSelected : Bool) {
        if isSelected {
            view_wishlisht.backgroundColor = UIColor.groupTableViewBackground
            iv_wishlist.tintColor = UIColor.black
            label_wishlist.textColor = UIColor.black
            label_wishlist.text = "REMOVE FROM WISHLIST"
        } else {
            view_wishlisht.backgroundColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
            iv_wishlist.tintColor = UIColor.white
            label_wishlist.textColor = UIColor.white
            label_wishlist.text = "ADD TO WISHLIST"
        }
    }
    
    private func displaySharePopup () {
        guard let link = URL(string: Constants.APP_LINK) else { return }
        let dynamicLinksDomainURIPrefix = Constants.APP_DOMAIN_LINK
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)
        linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.jbs.hk.c.i")
        linkBuilder?.androidParameters = DynamicLinkAndroidParameters(packageName: "com.jbs.hk.c")
        
        guard let longDynamicLink = linkBuilder?.url else { return }
        
        //        linkBuilder.shorten() { url, warnings, error in
        //            print("URL : " , url)
        //            guard let url = url, error != nil else { return }
        //            print("The short URL is: \(url)")
        //        }
        
        let activityViewController = UIActivityViewController(activityItems: [longDynamicLink], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private func navigateToReminderVC (reminderTitle: String) {
        let createReminderVC = getStoryboard(name: ViewIdentifiers.SB_REMINDER).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_REMINDER) as! AddReminderViewController
        createReminderVC.reminderTitle = reminderTitle
        createReminderVC.segmentIndex = 3
        createReminderVC.reminderType = "Other"
        let navController = UINavigationController(rootViewController: createReminderVC)
        self.present(navController, animated: true, completion: nil)
    }
    
    private func configureLikeButton (isSelected : Bool) {
        if isSelected {
            iv_favourite.tintColor = UIColor.red
        } else {
            iv_favourite.tintColor = UIColor.groupTableViewBackground
        }
    }
    
    @objc private func onDirectionsTapped () {
        let baseUrl: String = "http://maps.apple.com/?q="
        if let address = flyerDeal.retailer?.address {
            let encodedName = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let finalUrl = baseUrl + encodedName
            if let url = URL(string: finalUrl)
            {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
       
    }
    
    @objc private func onContactTapped () {
        if let url = URL(string: "tel://\((flyerDeal.retailer?.phone)!)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc private func onWishlistTapped () {
        addToWishlistNetworkCall()
    }
    
    @objc private func onFavouriteTapped () {
        likeFlyerDealNetworkCall()
    }
    
    @objc private func onFlyerTapped () {
        let flyerWebVC = getStoryboard(name: ViewIdentifiers.SB_FLYER).instantiateViewController(withIdentifier: ViewIdentifiers.VC_FLYER_WEBVIEW) as! FlyerWebViewViewController
        flyerWebVC.flyerId = (flyerDeal.flyer?.id)!
        flyerWebVC.flyerName = (flyerDeal.flyer?.title)!
        self.navigationController?.pushViewController(flyerWebVC, animated: true)
    }
    
    @IBAction func onReminderTapped(_ sender: Any) {
        navigateToReminderVC(reminderTitle: flyerDeal.title)
    }
    
    @IBAction func onShareTapped(_ sender: Any) {
        var flyerDealJson = ""
        do {
            let jsonData = try JSONEncoder().encode(flyerDeal)
            flyerDealJson = String(data: jsonData, encoding: .utf8)!
            print("JSON : " , flyerDealJson)
        } catch {
            print(error)
        }
        
       displaySharePopup()
    }
    
    @IBAction func onGoFlyerTapped(_ sender: Any) {
        
    }
    
}

extension FlyerDealDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfDeals.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibDealName, for: indexPath) as! FlyerSimilarDealViewCell
        
        cell.btn_reminder.addTarget(self, action: #selector(onBtnReminderTapped), for: .touchUpInside)
        cell.btn_reminder.tag = indexPath.row
        
        cell.btn_share.addTarget(self, action: #selector(onBtnShareTapped), for: .touchUpInside)
        cell.btn_share.tag = indexPath.row
        
        cell.btn_add_wishlist.addTarget(self, action: #selector(onAddToWishlistTapped), for: .touchUpInside)
        cell.btn_add_wishlist.tag = indexPath.row
        
        let deal = arrayOfDeals[indexPath.row]
        cell.configureDealWithItem(deal: deal)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.flyerDeal = arrayOfDeals[indexPath.row]
        populateDealDetails()
        fetchSimilarDeals()
        scroll_view.setContentOffset(.zero, animated: true)
    }
    
    @objc private func onBtnReminderTapped (sender: UIButton) {
        navigateToReminderVC(reminderTitle: arrayOfDeals[sender.tag].title)
    }
    
    @objc private func onBtnShareTapped () {
        displaySharePopup()
    }
    
    @objc private func onAddToWishlistTapped (sender: UIButton) {
        var wishlistUsecase = "add"
        UIUtils.showLoader(view: self.view)
        let index = sender.tag
        let deal = arrayOfDeals[index]
        
        if deal.is_in_wishlist! {
            wishlistUsecase = "delete"
        }
        
        dealsCalls.addToWishlistNetworkCall(dealId: deal.id,
                                                    use_case: wishlistUsecase,
                                                    successHandler:
            { (status, message) in
                UIUtils.dismissLoader(uiView: self.view)
                
                if status == 1 {
                    if wishlistUsecase == "add" {
                        self.arrayOfDeals[index].is_in_wishlist = true
                    } else {
                        self.arrayOfDeals[index].is_in_wishlist = false
                    }
                    
                    self.collection_view_similar_deals.reloadItems(at: [IndexPath(item: index, section: 0)])
                } else {
                    UIUtils.showAlert(vc: self, message: message)
                }
                
        })
        { (error) in
            UIUtils.dismissLoader(uiView: self.view)
            UIUtils.showAlert(vc: self, message: error.localizedDescription)
        }
    }
}
