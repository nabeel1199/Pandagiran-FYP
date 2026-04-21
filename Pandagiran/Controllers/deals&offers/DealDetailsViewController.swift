

import UIKit
import Cosmos
import FirebaseDynamicLinks

class DealDetailsViewController: BaseViewController {
    
    @IBOutlet weak var label_brand: UILabel!
    @IBOutlet weak var iv_brand: UIImageView!
    @IBOutlet weak var scroll_view: UIScrollView!
    @IBOutlet weak var label_review_count: UILabel!
    @IBOutlet weak var view_create_goal_height: NSLayoutConstraint!
    @IBOutlet weak var view_create_goal: CardView!
    @IBOutlet weak var iv_about: UIButton!
    @IBOutlet weak var view_about: UIView!
    @IBOutlet weak var view_add_review: CardView!
    @IBOutlet weak var view_about_expanded_height: NSLayoutConstraint!
    @IBOutlet weak var view_about_expanded: UIView!
    @IBOutlet weak var table_view_reviews_height: NSLayoutConstraint!
    @IBOutlet weak var table_view_liked_height: NSLayoutConstraint!
    @IBOutlet weak var iv_retailer: UIImageView!
    @IBOutlet weak var label_retailer_address: UILabel!
    @IBOutlet weak var label_retailer_title: UILabel!
    @IBOutlet weak var btn_wishlist_count: TintedButton!
    @IBOutlet weak var label_about_deal: UILabel!
    @IBOutlet weak var label_rating_count: UILabel!
    @IBOutlet weak var iv_favourite: UIImageView!
    @IBOutlet weak var view_favourite: UIView!
    @IBOutlet weak var iv_add_wishlist: TintedImageView!
    @IBOutlet weak var label_add_wishlist: UILabel!
    @IBOutlet weak var view_add_wishlist: CardView!
    @IBOutlet weak var rating_bar: CosmosView!
    @IBOutlet weak var label_original_price: UILabel!
    @IBOutlet weak var label_discount_price: UILabel!
    @IBOutlet weak var label_deal_title: UILabel!
    @IBOutlet weak var label_view_count: UILabel!
    @IBOutlet weak var label_percentage: UILabel!
    @IBOutlet weak var view_percentage: CardView!
    @IBOutlet weak var iv_deal: UIImageView!
    @IBOutlet weak var table_view_reviews: UITableView!
    @IBOutlet weak var table_view_liked_deals: UITableView!
    
    private let nibDealName = "LikedDealViewCell"
    private let nibReviewName = "ReviewViewCell"
    private var isViewAboutExpanded = true
    private var wishlistUsecase = "add"
    private let dealsNetworkHelper = DealsAndOffers()
    private var arrayOfDeals : Array<Deal> = []
    private var arrayOfReviews : Array<Reviews> = []
    
    public var deal : Deal!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVariables()
        initUI()
        fetchLikedDealsAndReviews()
        
    }
    
    private func initVariables () {
        initNibs()
        
        table_view_liked_deals.delegate = self
        table_view_liked_deals.dataSource = self
        
        table_view_reviews.delegate = self
        table_view_reviews.dataSource = self
    }
    
    private func initUI () {
        self.navigationItem.title = deal.deal_title!
        
//        view_about_expanded_height.constant = 0
//        view_about_expanded.isHidden = true
        
        if deal.deal_sale_price! < 10000 {
            view_create_goal_height.constant = 0
            view_create_goal.isHidden = true
        }
        
        let viewAboutGest = UITapGestureRecognizer(target: self, action: #selector(onViewAboutTapped))
        view_about.addGestureRecognizer(viewAboutGest)
        
        let addWishListGest = UITapGestureRecognizer(target: self, action: #selector(onAddWishlistTapped))
        view_add_wishlist.addGestureRecognizer(addWishListGest)
        
        let addReviewGest = UITapGestureRecognizer(target: self, action: #selector(onAddReviewTapped))
        view_add_review.addGestureRecognizer(addReviewGest)
        
        let viewFavGest = UITapGestureRecognizer(target: self, action: #selector(onFavouriteTapped))
        view_favourite.addGestureRecognizer(viewFavGest)
        
        let expiryDateInt = deal.deal_expiry!
        let expiry = Date(timeIntervalSince1970: TimeInterval(expiryDateInt / 1000))
        iv_deal.kf.setImage(with: URL(string: deal.deal_image_link!))
        label_deal_title.text = deal.deal_title!
        label_brand.text = (deal.brand?.brand_name)!
        iv_brand.kf.setImage(with: URL(string: (deal.brand?.brand_logo)!))
        label_view_count.text = "\((deal.impressions?.total_views)!) Views"
        label_discount_price.text = "Rs \(Utils.formatDecimalNumber(number: deal.deal_sale_price!, decimal: 0))"
        label_original_price.attributedText = UIUtils.getStruckThroughText(text: "Rs \(Utils.formatDecimalNumber(number: deal.deal_price!, decimal: 0))")
        label_retailer_title.text = deal.brand?.brand_name!
        iv_retailer.kf.setImage(with: URL(string: (deal.brand?.brand_logo)!))
        rating_bar.rating = (deal.impressions?.average_rating)!
        label_rating_count.text = "(\((deal.impressions?.average_rating_by_users_count)!))"
        label_about_deal.text = deal.deal_description!
        label_percentage.text = "\(Int(deal.deal_discount!))% Off"

        
        if let isInWishlist = deal.is_in_wishlist {
            configureWishlistButton(isSelected: isInWishlist)
            
            if isInWishlist {
                wishlistUsecase = "delete"
            }
        }
        
        if let isLiked = deal.is_liked {
            configureLikeButton(isSelected: isLiked)
        }
        
        if deal.deal_discount! == 0 {
            view_percentage.isHidden = true
            label_original_price.isHidden = true
        }
    }
    
    
    private func initNibs () {
        let nibLikedDeal = UINib(nibName: nibDealName, bundle: nil)
        let nibReview = UINib(nibName: nibReviewName, bundle: nil)
        
        table_view_liked_deals.register(nibLikedDeal, forCellReuseIdentifier: nibDealName)
        table_view_reviews.register(nibReview, forCellReuseIdentifier: nibReviewName)
    }
    
    private func addToWishlistNetworkCall () {
        UIUtils.showLoader(view: self.view)
        
        dealsNetworkHelper.addDealToWishlistNetworkCall(dealId: deal.deal_id!,
                                                        partnerId: deal.partner_id!,
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
                
        })
        { (error) in
            UIUtils.dismissLoader(uiView: self.view)
            UIUtils.showAlert(vc: self, message: error.localizedDescription)
        }
    }
    
    private func likeDealNetworkCall () {
        UIUtils.showLoader(view: self.view)
        dealsNetworkHelper.likeDealNetworkCall(dealId: deal.deal_id!,
                                               partnerId: deal.partner_id!,
                                               successHandler:
            { (status, message) in
                UIUtils.dismissLoader(uiView: self.view)
                
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
    
    private func fetchLikedDealsAndReviews () {
        dealsNetworkHelper.fetchLikedDealsAndReviews(dealId: deal.deal_id!,
                                                     partnerId: deal.partner_id!,
                                                     categoryName: (deal.category?.category_name)!,
                                                     subCategoryName: (deal.category?.sub_category_name)!,
                                                     brandName: (deal.brand?.brand_name)!,
                                                     successHandler:
            { (arrayOfDeals, arrayOfReviews, wishListCount, status, message) in
                
                if status == 1 {
                    self.arrayOfDeals = arrayOfDeals
                    self.arrayOfReviews = arrayOfReviews
                
                    self.table_view_liked_deals.reloadData()
                    self.table_view_reviews.reloadData()
                    self.btn_wishlist_count.isHidden = false
                    self.btn_wishlist_count.setTitle("\(wishListCount) added to their wishlist", for: .normal)
                    
                    if arrayOfReviews.count > 0 {
                        self.label_review_count.text = "\(arrayOfReviews.count) Review(s)"
                    }
                    
                } else {
                    UIUtils.showAlert(vc: self, message: message)
                }
        })
        { (error) in
            UIUtils.dismissLoader(uiView: self.view)
            UIUtils.showAlert(vc: self, message: error.localizedDescription)
        }
    }
    
    private func configureWishlistButton (isSelected : Bool) {
        if isSelected {
            view_add_wishlist.backgroundColor = UIColor.groupTableViewBackground
            iv_add_wishlist.tintColor = UIColor.black
            label_add_wishlist.textColor = UIColor.black
            label_add_wishlist.text = "REMOVE FROM WISHLIST"
        } else {
            view_add_wishlist.backgroundColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
            iv_add_wishlist.tintColor = UIColor.white
            label_add_wishlist.textColor = UIColor.white
            label_add_wishlist.text = "ADD TO WISHLIST"
        }
    }
    
    private func configureLikeButton (isSelected : Bool) {
        if isSelected {
            iv_favourite.tintColor = UIColor.red
        } else {
            iv_favourite.tintColor = UIColor.groupTableViewBackground
        }
    }
    
    private func navigateToReminderVC (reminderTitle: String) {
        let createReminderVC = getStoryboard(name: ViewIdentifiers.SB_REMINDER).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_REMINDER) as! AddReminderViewController
        createReminderVC.reminderTitle = reminderTitle
        createReminderVC.segmentIndex = 3
        createReminderVC.reminderType = "Other"
        let navController = UINavigationController(rootViewController: createReminderVC)
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc private func onViewAboutTapped () {
        if isViewAboutExpanded {
            UIView.transition(with: view_about_expanded, duration: 0.5, options: .transitionCrossDissolve, animations: {
                UIUtils.rotateImage(imageView: self.iv_about, angle: .upsideDown)
                self.view_about_expanded.isHidden = true
                self.view_about_expanded_height.constant = 0
                self.isViewAboutExpanded = false
            })
        } else {
            UIView.transition(with: view_about_expanded, duration: 0.5, options: .transitionCrossDissolve, animations: {
                UIUtils.rotateImage(imageView: self.iv_about, angle: .normal)
                self.view_about_expanded.isHidden = false
                self.view_about_expanded_height.constant = 160
                self.isViewAboutExpanded = true
            })
            
        }
    }
    
    @objc private func onFavouriteTapped () {
        likeDealNetworkCall()
    }
    
    @objc private func onAddWishlistTapped () {
        addToWishlistNetworkCall()
    }
    
    @objc private func onAddReviewTapped () {
        let addReviewVC = getStoryboard(name: ViewIdentifiers.SB_DEAL).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_REVIEW) as! AddReviewViewController
        addReviewVC.deal = self.deal
        addReviewVC.delegate = self
        self.navigationController?.pushViewController(addReviewVC, animated: true)
    }
    
    @IBAction func onShareTapped(_ sender: Any) {
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
    
    @IBAction func onReminderTapped(_ sender: Any) {
        navigateToReminderVC(reminderTitle: deal.deal_title!)
    }
    
    @IBAction func onCreateGoalTapped(_ sender: Any) {
        let createGoalVC = getStoryboard(name: ViewIdentifiers.SB_SAVING).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_SAVING) as! AddSavingViewController
        createGoalVC.savingTitle = deal.deal_title!
        createGoalVC.savingAmount = deal.deal_sale_price!
        let navController = UINavigationController(rootViewController: createGoalVC)
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func onBuyNowTapped(_ sender: Any) {
        let consumerId = LocalPrefs.getUserData()[Constants.CONSUMER_ID]!
        let buyNowVC = getStoryboard(name: ViewIdentifiers.SB_DEAL).instantiateViewController(withIdentifier: ViewIdentifiers.VC_BUY_NOW) as! BuyNowViewController
        buyNowVC.dealUrl = "https://services.hysabkytab.app/deals/redirect/link?consumer_id=\(consumerId)&device_type=Ios&deal_id=\(deal.deal_id!)&partner_id=\(deal.partner_id!)&link=\(deal.deal_link!)"
        self.navigationController?.pushViewController(buyNowVC, animated: true)
    }
    
    
}

extension DealDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        
        if arrayOfDeals.count > 0 {
            table_view_liked_height.constant = table_view_liked_deals.contentSize.height + 10
        }
        
        if arrayOfReviews.count > 0 {
            table_view_reviews_height.constant = table_view_reviews.contentSize.height
        } else {
            table_view_reviews_height.constant = 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == table_view_liked_deals {
            return arrayOfDeals.count
        } else {
            return arrayOfReviews.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == table_view_liked_deals {
            let cell = tableView.dequeueReusableCell(withIdentifier: nibDealName, for: indexPath) as! LikedDealViewCell
            
            let deal = arrayOfDeals[indexPath.row]
            cell.configureDealWithItem(deal: deal)
            
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: nibReviewName, for: indexPath) as! ReviewViewCell
        
            let review = arrayOfReviews[indexPath.row]
            cell.configureReviewWithItem(review: review)
            cell.label_time_string.isHidden = true
        
            cell.selectionStyle = .none
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewWillLayoutSubviews()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == table_view_liked_deals {
            self.deal = arrayOfDeals[indexPath.row]
            initUI()
            fetchLikedDealsAndReviews()
            scroll_view.setContentOffset(.zero, animated: true)
        }
      
    }
}

extension DealDetailsViewController : ReviewAddedListener {
    
    func onReviewAdded(review: Reviews) {
        self.arrayOfReviews.append(review)
        self.table_view_reviews.reloadData()
        label_review_count.text = "\(arrayOfReviews.count) Review(s)"
        viewWillLayoutSubviews()
    }
    
    
}
