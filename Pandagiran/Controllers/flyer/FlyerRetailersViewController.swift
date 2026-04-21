

import UIKit
import FSPagerView
import Alamofire
import SwiftyJSON
import FirebaseDynamicLinks
import FirebaseAnalytics

class FlyerRetailersViewController: BaseViewController, UITabBarDelegate {

    @IBOutlet weak var view_trending_deals: UIView!
    @IBOutlet weak var view_flyers: UIView!
    @IBOutlet weak var view_region: UIView!
    @IBOutlet weak var scroll_view: UIScrollView!
    @IBOutlet weak var collection_view_trending: UICollectionView!
    @IBOutlet weak var collection_view_flyers_height: NSLayoutConstraint!
    @IBOutlet weak var collection_view_trending_height: NSLayoutConstraint!
    @IBOutlet weak var collection_view: UICollectionView!
    @IBOutlet weak var pager_view: FSPagerView!
    
    private let nibFlyerName = "FlyerViewCell"
    private let nibDealName = "FlyerSimilarDealViewCell"
    private var retailerArray : Array<Retailer> = []
    private var bannerArray : Array<Banner> = []
    private var arrayOfDeals : Array<FlyerDeal> = []
    private let dealsNetworkHelper = DealsAndOffers()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidAppear(_ animated: Bool) {
        if LocalPrefs.getCountryName() == "MY" || LocalPrefs.getCountryName() == "MAY" || LocalPrefs.getCountryName() == "MYR" {
            view_region.isHidden = true
            view_flyers.isHidden = false
            pager_view.isHidden = false
            view_trending_deals.isHidden = false
            
            if retailerArray.count == 0 || bannerArray.count == 0 || arrayOfDeals.count == 0 {
                fetchFlyerRetailersServiceHit()
            }
        }
        else
        {
            view_region.isHidden = false
            view_flyers.isHidden = true
            pager_view.isHidden = true
            view_trending_deals.isHidden = true
        }
 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        Analytics.logEvent("flyer_click", parameters: nil)
        initVariables()
        initUI()
        
    }
    
    private func initVariables () {
        scroll_view.delegate = self
        retailerArray = []
        bannerArray = []
        arrayOfDeals = []
        
        initNibs()
        
        collection_view.delegate = self
        collection_view.dataSource = self
        
        collection_view_trending.delegate = self
        collection_view_trending.dataSource = self
        
        pager_view.delegate = self
        pager_view.dataSource = self
        
    
    }
    
    private func initUI () {
        scroll_view.refreshControl = self.refreshControl
        refreshControl.addTarget(self, action: #selector(onSwipedToRefresh), for: .valueChanged)

        
        if LocalPrefs.getCountryName() == "MY" || LocalPrefs.getCountryName() == "MY" || LocalPrefs.getCountryName() == "MYR" {
            let wishlistItem = UIBarButtonItem(image: UIImage(named: "ic_wishlist"), style: .plain, target: self, action: #selector(onWishlistTapped))
            let searchItem = UIBarButtonItem(image: UIImage(named: "ic_search"), style: .plain, target: self, action: #selector(onSearchTapped))
            self.navigationItem.rightBarButtonItems = [wishlistItem, searchItem]
        }
       
        
        let flyersLayout = collection_view.collectionViewLayout as! UICollectionViewFlowLayout
        flyersLayout.itemSize = CGSize(width: (UIScreen.main.bounds.width) / 1.8  , height: 215)
        
        pager_view.transformer = FSPagerViewTransformer(type: .overlap)
        pager_view.automaticSlidingInterval = 3.0
        pager_view.layer.cornerRadius = 5.0
        
        let trendingLayout = collection_view_trending.collectionViewLayout as! UICollectionViewFlowLayout
        trendingLayout.estimatedItemSize = CGSize(width: 260, height: 300)
    }
    
    private func initNibs () {
        let nibFlyer = UINib(nibName: nibFlyerName, bundle: nil)
        collection_view.register(nibFlyer, forCellWithReuseIdentifier: nibFlyerName)
        
        let nibDeal = UINib(nibName: nibDealName, bundle: nil)
        collection_view_trending.register(nibDeal, forCellWithReuseIdentifier: nibDealName)
        
        pager_view.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    public func fetchFlyerRetailersServiceHit () {
        UIUtils.showLoader(view: self.view)
        
        let consumerId = LocalPrefs.getConsumerId()
        let URL = "\(Constants.BASE_URL)/flyer/retailers/list?consumer_id=\(consumerId)&device_type=Ios"
        
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
                    
                    if self.refreshControl.isRefreshing {
                        self.arrayOfDeals.removeAll()
                        self.bannerArray.removeAll()
                        self.retailerArray.removeAll()
                    }
                    
                    if status == 1 {
                        let data = responseObj["data"].dictionaryValue
                        
                        let retailersJsonArray = data["retailers"]?.arrayValue
                        let bannerJsonArray = data["banners"]?.arrayValue
                        let trendingJsonArray = data["trending"]?.arrayValue
                        
           
                        
                        for retailerJsonObj in retailersJsonArray! {
                            let retailer = Retailer(phone: retailerJsonObj["phone"].stringValue,
                                                    title: retailerJsonObj["title"].stringValue,
                                                    id: retailerJsonObj["id"].stringValue,
                                                    flyers_count: retailerJsonObj["flyers_count"].intValue,
                                                    img: retailerJsonObj["img"].stringValue,
                                                    address: retailerJsonObj["address"].stringValue,
                                                    email: retailerJsonObj["email"].stringValue)
                            
                            self.retailerArray.append(retailer)
                        }
                        
                        for dealJsonObj in trendingJsonArray! {
                            let dealObj = dealJsonObj.dictionaryObject
                            
                            do {
                                let data = try JSONSerialization.data(withJSONObject: dealObj!, options: .prettyPrinted)
                                let deal = try JSONDecoder().decode(FlyerDeal.self, from: data)
                                self.arrayOfDeals.append(deal)
                            } catch {
                                print("ERROR : " , error)
                            }
                        }
                        
                        for bannerJsonObj in bannerJsonArray! {
                            let banner = Banner(id: bannerJsonObj["id"].stringValue,
                                                img: bannerJsonObj["img"].stringValue,
                                                click_url: bannerJsonObj["click_url"].stringValue,
                                                click_type: bannerJsonObj["click_type"].stringValue,
                                                type: bannerJsonObj["type"].stringValue,
                                                banner_search: bannerJsonObj["banner_search"].stringValue)
                            
                            self.bannerArray.append(banner)
                        }
                        
                        self.collection_view.reloadData()
                        self.collection_view_trending.reloadData()
                        self.pager_view.reloadData()
                       
                    } else {
                        UIUtils.showAlert(vc: self, message: message)
                    }
                    
                    self.refreshControl.endRefreshing()
                    
                case .failure(let error):
                    UIUtils.dismissLoader(uiView: self.view)
                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
    }
    
    @objc private func onSwipedToRefresh () {
        fetchFlyerRetailersServiceHit()
    }
    
    @objc private func onWishlistTapped () {
        let wishlistVC = getStoryboard(name: ViewIdentifiers.SB_WISHLIST).instantiateViewController(withIdentifier: ViewIdentifiers.VC_WISHLIST) as! WishlistViewController
        self.navigationController?.pushViewController(wishlistVC, animated: true)
    }
    
    @objc private func onSearchTapped () {
        let flyerSearchVC = getStoryboard(name: ViewIdentifiers.SB_FLYER).instantiateViewController(withIdentifier: ViewIdentifiers.VC_FLYER_SEARCH) as! FlyerSearchViewController
        self.navigationController?.pushViewController(flyerSearchVC, animated: true)
    }
    
    @IBAction func onViewAllTapped(_ sender: Any) {
        let allDealsVC = getStoryboard(name: ViewIdentifiers.SB_FLYER).instantiateViewController(withIdentifier: ViewIdentifiers.VC_FLYER_ALL_DEALS) as! FlyerAllDealsViewController
        self.navigationController?.pushViewController(allDealsVC, animated: true)
    }
    
}

extension FlyerRetailersViewController : UICollectionViewDelegate , UICollectionViewDataSource {
    
    override func viewWillLayoutSubviews() {
        if retailerArray.count > 0 {
            collection_view_flyers_height.constant = 210
        }
        
            collection_view_trending_height.constant = 310
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collection_view {
            return retailerArray.count
        } else {
            return arrayOfDeals.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == collection_view {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibFlyerName, for: indexPath) as! FlyerViewCell
            
            let retailer = retailerArray[indexPath.row]
            cell.configureRetailerWithItem(retailer: retailer)
            
            return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibDealName, for: indexPath) as! FlyerSimilarDealViewCell
            
            cell.btn_reminder.addTarget(self, action: #selector(onReminderTapped), for: .touchUpInside)
            cell.btn_reminder.tag = indexPath.row
            
            cell.btn_share.addTarget(self, action: #selector(onShareTapped), for: .touchUpInside)
            cell.btn_share.tag = indexPath.row
            
            cell.btn_add_wishlist.addTarget(self, action: #selector(onAddToWishlistTapped), for: .touchUpInside)
            cell.btn_add_wishlist.tag = indexPath.row
                        
            let deal = arrayOfDeals[indexPath.row]
            cell.configureDealWithItem(deal: deal)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == collection_view_trending {
            let offerDetailsVC = getStoryboard(name: ViewIdentifiers.SB_FLYER).instantiateViewController(withIdentifier: ViewIdentifiers.VC_FLYER_DETAILS) as! FlyerDealDetailsViewController
            offerDetailsVC.flyerDeal = arrayOfDeals[indexPath.row]
            self.navigationController?.pushViewController(offerDetailsVC, animated: true)
        }
        else
        {
            let flyersVC = getStoryboard(name: ViewIdentifiers.SB_FLYER).instantiateViewController(withIdentifier: ViewIdentifiers.VC_FLYER) as! FlyersListingViewController
            flyersVC.retailerId = retailerArray[indexPath.row].id
            flyersVC.retailerName = retailerArray[indexPath.row].title
            self.navigationController?.pushViewController(flyersVC, animated: true)
        }

    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        viewWillLayoutSubviews()
        
    }
    
    @objc private func onReminderTapped (sender: UIButton) {
        let createReminderVC = getStoryboard(name: ViewIdentifiers.SB_REMINDER).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_REMINDER) as! AddReminderViewController
        createReminderVC.reminderTitle = arrayOfDeals[sender.tag].title
        createReminderVC.segmentIndex = 3
        createReminderVC.reminderType = "Other"
        let navController = UINavigationController(rootViewController: createReminderVC)
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc private func onShareTapped () {
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
    
    @objc private func onAddToWishlistTapped (sender: UIButton) {
        var wishlistUsecase = "add"
        UIUtils.showLoader(view: self.view)
        let index = sender.tag
        let deal = arrayOfDeals[index]
        
        if deal.is_in_wishlist! {
            wishlistUsecase = "delete"
        }
        
        dealsNetworkHelper.addToWishlistNetworkCall(dealId: deal.id,
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
                    
                    self.collection_view_trending.reloadItems(at: [IndexPath(item: index, section: 0)])
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

extension FlyerRetailersViewController : FSPagerViewDelegate, FSPagerViewDataSource {
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return bannerArray.count
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        let imageUrl = bannerArray[index].img
        
        if imageUrl != nil {
            cell.imageView?.kf.setImage(with: URL(string: imageUrl))
        }
    
        cell.imageView?.contentMode = .scaleToFill
        cell.imageView?.clipsToBounds = true
        cell.imageView?.layer.cornerRadius = 5.0
        
        
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        let banner = bannerArray[index]
        
        if banner.type == "search" {
            let searchFlyerDealVC = getStoryboard(name: ViewIdentifiers.SB_FLYER).instantiateViewController(withIdentifier: ViewIdentifiers.VC_FLYER_SEARCH) as! FlyerSearchViewController
            searchFlyerDealVC.searchQuery = banner.banner_search
            self.navigationController?.pushViewController(searchFlyerDealVC, animated: true)
            
        } else if banner.type == "url" {
            let buyNowVC = getStoryboard(name: ViewIdentifiers.SB_DEAL).instantiateViewController(withIdentifier: ViewIdentifiers.VC_BUY_NOW) as! BuyNowViewController
            buyNowVC.dealUrl = banner.click_url
            self.navigationController?.pushViewController(buyNowVC, animated: true)
        }
    }
}
