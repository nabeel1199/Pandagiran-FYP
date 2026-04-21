

import UIKit
import FirebaseDynamicLinks
import Instructions
import FirebaseAnalytics

class OffersViewController: BaseViewController {

    @IBOutlet weak var view_region: UIView!
    @IBOutlet weak var iv_swipe: UIImageView!
    @IBOutlet weak var scroll_view: UIScrollView!
    @IBOutlet weak var view_ending_week_height: NSLayoutConstraint!
    @IBOutlet weak var view_popular_offers_height: NSLayoutConstraint!
    @IBOutlet weak var collection_view_ending_week: UICollectionView!
    @IBOutlet weak var collection_view_popular_offers: UICollectionView!
    @IBOutlet weak var view_ending_week: UIView!
    @IBOutlet weak var view_popular_offers: UIView!
    @IBOutlet weak var view_categories: UIView!
    
    private let nibOfferName = "DealsViewCell"
    private var arrayOfDeals : Array<Deal> = []
    private var recommendedDeals : Array<Deal> = []
    private let dealsNetworkHelper = DealsAndOffers()
    private let refreshControl = UIRefreshControl()
    private let coachMarksController = CoachMarksController()
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if LocalPrefs.getCountryName() == "MY" || LocalPrefs.getCountryName() == "MAY" || LocalPrefs.getCountryName() == "MYR" {
            view_region.isHidden = true
            view_ending_week.isHidden = false
            view_popular_offers.isHidden = false
            
            if arrayOfDeals.count == 0 {
                fetchPopularDeals()
            }
            
            if recommendedDeals.count == 0 {
                fetchRecommendedDeals()
            }
        }
        else
        {
            view_region.isHidden = false
            view_ending_week.isHidden = true
            view_popular_offers.isHidden = true
        }
       
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Analytics.logEvent("deal_click", parameters: nil)
        initVariables()
        initUI()
    
    }
    
    private func initVariables () {
        self.coachMarksController.overlay.isUserInteractionEnabled = true
        self.coachMarksController.dataSource = self

        scroll_view.delegate = self
        initNibs()
        
        collection_view_ending_week.delegate = self
        collection_view_ending_week.dataSource = self
        
        collection_view_popular_offers.delegate = self
        collection_view_popular_offers.dataSource = self
    }
    
    private func initNibs () {
        let nibDeal = UINib(nibName: nibOfferName, bundle: nil)
        collection_view_popular_offers.register(nibDeal, forCellWithReuseIdentifier: nibOfferName)
        collection_view_ending_week.register(nibDeal, forCellWithReuseIdentifier: nibOfferName)
    }
    
    private func initUI () {
        view_categories.isHidden = true
        scroll_view.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(onDealsRefreshed), for: .valueChanged)
        
        if LocalPrefs.getCountryName() == "MY" || LocalPrefs.getCountryName() == "MAY" || LocalPrefs.getCountryName() == "MYR" {
            let navSearch = UIBarButtonItem(image: UIImage(named: "ic_search"), style: .plain, target: self, action: #selector(onSearchTapped))
            let navWishlist = UIBarButtonItem(image: UIImage(named: "ic_wishlist"), style: .plain, target: self, action: #selector(onWishlistTapped))
            self.navigationItem.rightBarButtonItems = [navWishlist, navSearch]
        }
        
        let popularOffersLayout = collection_view_popular_offers.collectionViewLayout as! UICollectionViewFlowLayout
        popularOffersLayout.estimatedItemSize = CGSize(width: 260, height: 340)
        
        let endingWeekLayout = collection_view_ending_week.collectionViewLayout as! UICollectionViewFlowLayout
        endingWeekLayout.estimatedItemSize = CGSize(width: 260, height: 340)
    }
    
    private func fetchPopularDeals () {
        UIUtils.showLoader(view: self.view)
        let dealNetworkCaller = DealsAndOffers()
        dealNetworkCaller.fetchPopularOffers(interests: LocalPrefs.getUserInterests(),
                                             offset: 1,
                                             successHandler:
            { (arrayOfDeals, status, message) in
                UIUtils.dismissLoader(uiView: self.view)
                
                if self.refreshControl.isRefreshing {
                    self.arrayOfDeals.removeAll()
                }
                
                self.arrayOfDeals = arrayOfDeals
                
                self.collection_view_popular_offers.reloadData()
                self.view_popular_offers_height.constant = self.collection_view_popular_offers.contentSize.height
                self.refreshControl.endRefreshing()
                
            
                
        }) { (error) in
            UIUtils.dismissLoader(uiView: self.view)
            UIUtils.showAlert(vc: self, message: error.localizedDescription)
        }
    }
    
    private func fetchRecommendedDeals () {
        UIUtils.showLoader(view: self.view)
        let dealNetworkCaller = DealsAndOffers()
        dealNetworkCaller.fetchRecommendedDeals(interests: LocalPrefs.getUserInterests(),
                                             offset: 1,
                                             successHandler:
            { (arrayOfDeals, status, message) in
                
                UIUtils.dismissLoader(uiView: self.view)
                
                if self.refreshControl.isRefreshing {
                    self.recommendedDeals.removeAll()
                }
                
                self.recommendedDeals = arrayOfDeals
                
                self.collection_view_ending_week.reloadData()
                self.view_ending_week_height.constant = self.collection_view_ending_week.contentSize.height
                self.refreshControl.endRefreshing()
                
        }) { (error) in
            UIUtils.dismissLoader(uiView: self.view)
            UIUtils.showAlert(vc: self, message: error.localizedDescription)
        }
    }
    
    private func navigateToAllDealsVC (url : String) {
        let offerDetailsVC = getStoryboard(name: ViewIdentifiers.SB_DEAL).instantiateViewController(withIdentifier: ViewIdentifiers.VC_OFFER_DETAILS) as! OfferDetailsViewController
        offerDetailsVC.offersUrl = url
        self.navigationController?.pushViewController(offerDetailsVC, animated: true)
    }
    
    @objc private func onDealsRefreshed () {
        fetchPopularDeals()
        fetchRecommendedDeals()
    }
    
    @objc private func onSearchTapped () {
        let searchVC = getStoryboard(name: ViewIdentifiers.SB_DEAL).instantiateViewController(withIdentifier: ViewIdentifiers.VC_DEAL_SEARCH)
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @objc private func onWishlistTapped () {
        let wishlistVC = getStoryboard(name: ViewIdentifiers.SB_WISHLIST).instantiateViewController(withIdentifier: ViewIdentifiers.VC_WISHLIST) as! WishlistViewController
        self.navigationController?.pushViewController(wishlistVC, animated: true)
    }
    
    @IBAction func onPopularViewAllTapped(_ sender: Any) {
        navigateToAllDealsVC(url: "/deals/popular/")
    }
    
    @IBAction func onRecommendedViewAllTapped(_ sender: Any) {
        navigateToAllDealsVC(url: "/deals/recommended/deals")
    }
    
    
}

extension OffersViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collection_view_popular_offers {
            return arrayOfDeals.count
        } else {
            return recommendedDeals.count
        }
    
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibOfferName, for: indexPath) as! DealsViewCell
        
        if collectionView == collection_view_popular_offers
        {
            let deal = arrayOfDeals[indexPath.row]
            cell.configureItemWithDeal(deal: deal)
            
            
            // show onboarding here
            if indexPath.row == 0 {
                if !LocalPrefs.getIsDealsOnboardingShown() {
                    self.coachMarksController.start(in: .window(over: self))
                    
                }
            }
        }
        else
        {
            let deal = recommendedDeals[indexPath.row]
            cell.configureItemWithDeal(deal: deal)
        }
        
        cell.btn_share.addTarget(self, action: #selector(onShareTapped), for: .touchUpInside)
        cell.btn_share.tag = indexPath.row
        
        let viewFavGest = UITapGestureRecognizer(target: self, action: #selector(onFavouriteTapped))
        cell.view_favourite.addGestureRecognizer(viewFavGest)
        cell.view_favourite.tag = indexPath.row
        
        cell.btn_wishlist.addTarget(self, action: #selector(onAddToWishlistTapped), for: .touchUpInside)
        cell.btn_wishlist.tag = indexPath.row
        
        cell.btn_reminder.addTarget(self, action: #selector(onReminderTapped), for: .touchUpInside)
        cell.btn_reminder.tag = indexPath.row
        

        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dealDetailsVC = getStoryboard(name: ViewIdentifiers.SB_DEAL).instantiateViewController(withIdentifier: ViewIdentifiers.VC_DEAL_DETAILS) as! DealDetailsViewController
        
        
        if collectionView == collection_view_popular_offers {
            dealDetailsVC.deal = arrayOfDeals[indexPath.row]
        } else {
            dealDetailsVC.deal = recommendedDeals[indexPath.row]
        }
        
        self.navigationController?.pushViewController(dealDetailsVC, animated: true)

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
    
    @objc private func onReminderTapped (sender: UIButton) {
        let createReminderVC = getStoryboard(name: ViewIdentifiers.SB_REMINDER).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_REMINDER) as! AddReminderViewController
        createReminderVC.reminderTitle = arrayOfDeals[sender.tag].deal_title!
        createReminderVC.segmentIndex = 3
        createReminderVC.reminderType = "Other"
        let navController = UINavigationController(rootViewController: createReminderVC)
        self.present(navController, animated: true, completion: nil)
        
    }
    
    @objc private func onFavouriteTapped (sender: UITapGestureRecognizer) {
        let index = (sender.view?.tag)!
        
        if !arrayOfDeals[index].is_liked! {
            UIUtils.showLoader(view: self.view)
            let deal = arrayOfDeals[index]
            dealsNetworkHelper.likeDealNetworkCall(dealId: deal.deal_id!,
                                                   partnerId: deal.partner_id!,
                                                   successHandler:
                { (status, message) in
                    UIUtils.dismissLoader(uiView: self.view)
                    
                    if status == 1 {
                        self.arrayOfDeals[(sender.view?.tag)!].is_liked = true
                        self.collection_view_popular_offers.reloadItems(at: [IndexPath(item: index, section: 0)])
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
    
    @objc private func onAddToWishlistTapped (sender: UIButton) {
        var wishlistUsecase = "add"
        UIUtils.showLoader(view: self.view)
        let index = sender.tag
        let deal = arrayOfDeals[index]
        
        if deal.is_in_wishlist! {
            wishlistUsecase = "delete"
        }
        
        dealsNetworkHelper.addDealToWishlistNetworkCall(dealId: deal.deal_id!,
                                                        partnerId: deal.partner_id!,
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
                    
                    self.collection_view_popular_offers.reloadItems(at: [IndexPath(item: index, section: 0)])
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

extension OffersViewController : CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 3
    }
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        
        if index == 0 {
            let pof = navigationItem.rightBarButtonItem?.value(forKey: "view") as? UIView
            return coachMarksController.helper.makeCoachMark(for: pof)
        } else if index == 1 {
            let cell = collection_view_popular_offers.cellForItem(at: IndexPath(item: 0, section: 0)) as! DealsViewCell
            let pof = cell.view_favourite
            return coachMarksController.helper.makeCoachMark(for: pof)
        } else {
            LocalPrefs.setIsDealsOnboardingShown(isShown: true)
            let cell = collection_view_popular_offers.cellForItem(at: IndexPath(item: 0, section: 0)) as! DealsViewCell
            let pof = cell.btn_reminder
            return coachMarksController.helper.makeCoachMark(for: pof)
        }
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        
        coachViews.bodyView.tintColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
        coachViews.arrowView?.tintColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
        coachViews.bodyView.hintLabel.textColor = UIColor.black
        coachViews.bodyView.nextLabel.textColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
        coachViews.bodyView.hintLabel.font = UIFont(name: Style.font.REGULAR_FONT, size: 12.0)
        coachViews.bodyView.nextLabel.font = UIFont(name: "\(Style.font.REGULAR_FONT)-Bold", size: 14.0)
        
        switch index {
            
        case 0:
            coachViews.bodyView.hintLabel.text = "View your wishlist. All offers you add to your wishlist are stored here"
            coachViews.bodyView.nextLabel.text = "NEXT"
            break
        case 1:
            coachViews.bodyView.hintLabel.text = "Tap the heart icon and like your favorite offer. This helps us create better content for you!"
            coachViews.bodyView.nextLabel.text = "NEXT"
            break
        case 2:
            coachViews.bodyView.hintLabel.text = "At any time, you can add an offer to wishlist, create a reminder for it or share it with your friends and family!"
            coachViews.bodyView.nextLabel.text = "GOT IT"
        default:
            print("Nothing")
        }
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
//    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
//        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
//
//        coachViews.bodyView.tintColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
//        coachViews.arrowView?.tintColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
//        coachViews.bodyView.hintLabel.textColor = UIColor.black
//        coachViews.bodyView.nextLabel.textColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
//        coachViews.bodyView.hintLabel.font = UIFont(name: Style.font.REGULAR_FONT, size: 12.0)
//        coachViews.bodyView.nextLabel.font = UIFont(name: "\(Style.font.REGULAR_FONT)-Bold", size: 14.0)
//
//        switch index {
//
//        case 0:
//            coachViews.bodyView.hintLabel.text = "View your wishlist. All offers you add to your wishlist are stored here"
//            coachViews.bodyView.nextLabel.text = "NEXT"
//            break
//        case 1:
//            coachViews.bodyView.hintLabel.text = "Tap the heart icon and like your favorite offer. This helps us create better content for you!"
//            coachViews.bodyView.nextLabel.text = "NEXT"
//            break
//        case 2:
//            coachViews.bodyView.hintLabel.text = "At any time, you can add an offer to wishlist, create a reminder for it or share it with your friends and family!"
//            coachViews.bodyView.nextLabel.text = "GOT IT"
//        default:
//            print("Nothing")
//        }
//
//        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
//    }
}

