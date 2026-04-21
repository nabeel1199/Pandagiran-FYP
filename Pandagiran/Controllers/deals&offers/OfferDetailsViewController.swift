

import UIKit

class OfferDetailsViewController: BaseViewController {

    @IBOutlet weak var iv_filter: TintedImageView!
    @IBOutlet weak var table_view_offers: UITableView!
    @IBOutlet weak var label_filter_count: UILabel!
    @IBOutlet weak var view_filter: CardView!
    @IBOutlet weak var view_sort: GradientView!
    @IBOutlet weak var label_sort_type: UILabel!
    
    public var offersUrl = "/deals/popular/"
    
    private let nibDealName = "LikedDealViewCell"
    private let dealsNetworkHelper = DealsAndOffers()
    private var paginationOffset = 2
    private var arrayOfDeals : Array<Deal> = []
    private var sortType = 0
    private var amountRange = ""
    private var discountPercentage = 0
    private var brandName = ""
    private let refreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()
        fetchAllDealsNetworkCall()
        
    }
    
    private func initVariables () {
        initNibs()
        
        table_view_offers.delegate = self
        table_view_offers.dataSource = self
    }
    
    private func initNibs () {
        let nibDeal = UINib(nibName: nibDealName, bundle: nil)
        self.table_view_offers.register(nibDeal, forCellReuseIdentifier: nibDealName)
    }
    
    private func initUI () {
        table_view_offers.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(onDealsRefreshed), for: .valueChanged)
        
        let navSearch = UIBarButtonItem(image: UIImage(named: "ic_search"), style: .plain, target: self, action: #selector(onSearchTapped))
        let navWishlist = UIBarButtonItem(image: UIImage(named: "ic_wishlist"), style: .plain, target: self, action: #selector(onWishlistTapped))
        self.navigationItem.rightBarButtonItems = [navWishlist, navSearch]
        
        view_filter.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        let tapFilterGest = UITapGestureRecognizer(target: self, action: #selector(onFilterTapped))
        view_filter.addGestureRecognizer(tapFilterGest)
        
        let sortTapGest = UITapGestureRecognizer(target: self, action: #selector(onSortTapped))
        view_sort.addGestureRecognizer(sortTapGest)
    }
    
    private func fetchAllDealsNetworkCall () {
        UIUtils.showLoader(view: self.view)
        dealsNetworkHelper.fetchAllOffers(interests: "shahajsnka",
                                          url: offersUrl,
                                          offset: paginationOffset,
                                          price_range: amountRange,
                                          discount: discountPercentage,
                                          sort: sortType,
                                          successHandler:
            { (arrayOfDeals, status, message) in
                
                UIUtils.dismissLoader(uiView: self.view)
                
                if self.refreshControl.isRefreshing {
                    self.arrayOfDeals.removeAll()
                }
                
                if status == 1 {
                    self.paginationOffset += 1
                    
                    for deal in arrayOfDeals {
                        self.arrayOfDeals.append(deal)
                    }
                }
                
                
                self.refreshControl.endRefreshing()
                self.table_view_offers.reloadData()
                
        }) { (error) in
            UIUtils.dismissLoader(uiView: self.view)
        }
    }
    
    
    @objc private func onSearchTapped () {
        let searchVC = getStoryboard(name: ViewIdentifiers.SB_DEAL).instantiateViewController(withIdentifier: ViewIdentifiers.VC_DEAL_SEARCH) as! DealSearchViewController
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @objc private func onWishlistTapped () {
        let wishlistVC = getStoryboard(name: ViewIdentifiers.SB_WISHLIST).instantiateViewController(withIdentifier: ViewIdentifiers.VC_WISHLIST) as! WishlistViewController
        self.navigationController?.pushViewController(wishlistVC, animated: true)
    }
    
    @objc private func onSortTapped () {
        let sortPopup = SortPopup()
        sortPopup.delegate = self
        sortPopup.isDealSort = true
        self.presentPopupView(popupView: sortPopup)
    }
    
    @objc private func onFilterTapped () {
        let dealsFilterVC = getStoryboard(name: ViewIdentifiers.SB_DEAL).instantiateViewController(withIdentifier: ViewIdentifiers.VC_FILTER_DEALS) as! DealsFilterViewController
        dealsFilterVC.delegate = self
        dealsFilterVC.brandName = brandName
        dealsFilterVC.discountValue = discountPercentage
        self.navigationController?.pushViewController(dealsFilterVC, animated: true)
    }
    
    @objc private func onDealsRefreshed () {
        paginationOffset = 1
        fetchAllDealsNetworkCall()
    }
}

extension OfferDetailsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfDeals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nibDealName, for: indexPath) as! LikedDealViewCell
        
        let deal = arrayOfDeals[indexPath.row]
        cell.configureDealWithItem(deal: deal)
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dealDetailsVC = getStoryboard(name: ViewIdentifiers.SB_DEAL).instantiateViewController(withIdentifier: ViewIdentifiers.VC_DEAL_DETAILS) as! DealDetailsViewController
        dealDetailsVC.deal = arrayOfDeals[indexPath.row]
        self.navigationController?.pushViewController(dealDetailsVC, animated: true)
    }
}

extension OfferDetailsViewController {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if ((table_view_offers.contentOffset.y + (table_view_offers.frame.size.height)) >= table_view_offers.contentSize.height) {
            
            fetchAllDealsNetworkCall()
        }
    }
}

extension OfferDetailsViewController : SortSelectionListener, DealFilterSelectionListener {

    
    func onSortApplied(sortTitle: String, sortType: String, isAscending: Bool, sortIntType: Int) {
        arrayOfDeals.removeAll()
        paginationOffset = 1
        label_sort_type.text = sortTitle
        self.sortType = sortIntType
        fetchAllDealsNetworkCall()
    }
    
    func onDealFilterApplied(percentage: Int, amountRange: String, brandName: String, count: Int) {
        if count > 0 {
            self.arrayOfDeals.removeAll()
            view_filter.backgroundColor = UIColor.white
            iv_filter.tintColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
            label_filter_count.text = "\(count)"
            label_filter_count.isHidden = false
            self.amountRange = amountRange
            self.discountPercentage = percentage
            self.brandName = brandName
            self.paginationOffset = 1
            
            fetchAllDealsNetworkCall()
        } else {
            self.arrayOfDeals.removeAll()
            view_filter.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            iv_filter.tintColor = UIColor.white
            label_filter_count.isHidden = true
            self.amountRange = ""
            self.discountPercentage = 0
            self.brandName = ""
            
            fetchAllDealsNetworkCall()
        }
    }
    
}
