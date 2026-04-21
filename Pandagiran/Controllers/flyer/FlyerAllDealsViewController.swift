

import UIKit

class FlyerAllDealsViewController: BaseViewController {

    @IBOutlet weak var iv_filter: TintedImageView!
    @IBOutlet weak var view_sort: GradientView!
    @IBOutlet weak var view_filter: CardView!
    @IBOutlet weak var label_filter_count: UILabel!
    @IBOutlet weak var label_sort_title: UILabel!
    @IBOutlet weak var table_view_deals: UITableView!
    
    
    private let nibDealName = "FlyerOfferViewCell"
    private var arrayOfDeals : Array<FlyerDeal> = []
    private var amountRange = ""
    private var categoryName = ""
    private var retailerName = ""
    private var expiry: Int64 = 0
    private var paginationOffset = 1
    private var sortIntType = 0
    private var url = "/flyers/trending/offers"
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()
        fetchAllFlyerDealsNetworkCall()

    }
    
    private func initVariables () {
        initNibs()
        
        table_view_deals.delegate = self
        table_view_deals.dataSource = self
    }
    
    private func initUI () {
        table_view_deals.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(onDealsRefreshed), for: .valueChanged)

        view_filter.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        let tapFilterGest = UITapGestureRecognizer(target: self, action: #selector(onFilterTapped))
        view_filter.addGestureRecognizer(tapFilterGest)
        
        let sortTapGest = UITapGestureRecognizer(target: self, action: #selector(onSortTapped))
        view_sort.addGestureRecognizer(sortTapGest)
    }
    
    private func initNibs () {
        let nibDeal = UINib(nibName: nibDealName, bundle: nil)
        table_view_deals.register(nibDeal, forCellReuseIdentifier: nibDealName)
    }
    
    private func fetchAllFlyerDealsNetworkCall () {
        UIUtils.showLoader(view: self.view)
        let dealsNetworkHelper = DealsAndOffers()
        dealsNetworkHelper.fetchAllFlyerOffersNetworkCall(url: url,
                                                          offset: 1,
                                                          price_range: amountRange,
                                                          retailer_name: retailerName,
                                                          category: categoryName,
                                                          expiry: expiry,
                                                          sort: sortIntType,
                                                          successHandler:
            { (arrayOfDeal, status, message) in
                UIUtils.dismissLoader(uiView: self.view)
                
                if status == 1 {
                    self.paginationOffset += 1
                   
                    if self.refreshControl.isRefreshing {
                        self.arrayOfDeals.removeAll()
                    }
                    
                    for flyerDeal in arrayOfDeal {
                        self.arrayOfDeals.append(flyerDeal)
                    }
                    
                } else {
                    UIUtils.showAlert(vc: self, message: message)
                }
                
                self.table_view_deals.reloadData()
                self.refreshControl.endRefreshing()
                
        })
        { (error) in
            UIUtils.showAlert(vc: self, message: error.localizedDescription)
            UIUtils.dismissLoader(uiView: self.view)
        }
    }

    @objc private func onSortTapped () {
        let sortPopup = SortPopup()
        sortPopup.delegate = self
        sortPopup.isDealSort = true
        self.presentPopupView(popupView: sortPopup)
    }
    
    @objc private func onFilterTapped () {
        let dealsFilterVC = getStoryboard(name: ViewIdentifiers.SB_FLYER).instantiateViewController(withIdentifier: ViewIdentifiers.VC_FLYER_FILTER) as! FlyerFilterViewController
        dealsFilterVC.delegate = self
        self.navigationController?.pushViewController(dealsFilterVC, animated: true)
    }
    
    @objc private func onDealsRefreshed () {
        paginationOffset = 1
        fetchAllFlyerDealsNetworkCall()
    }

}

extension FlyerAllDealsViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrayOfDeals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table_view_deals.dequeueReusableCell(withIdentifier: nibDealName, for: indexPath) as! FlyerOfferViewCell

        print("COUNT : " , arrayOfDeals.count)
        let deal = arrayOfDeals[indexPath.row]
        cell.configureDealWithItem(deal: deal)
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let offerDetailsVC = getStoryboard(name: ViewIdentifiers.SB_FLYER).instantiateViewController(withIdentifier: ViewIdentifiers.VC_FLYER_DETAILS) as! FlyerDealDetailsViewController
        offerDetailsVC.flyerDeal = arrayOfDeals[indexPath.row]
        self.navigationController?.pushViewController(offerDetailsVC, animated: true)
    }
}

extension FlyerAllDealsViewController : SortSelectionListener, FlyerDealSelectionListener {
    
    func onDealFilterApplied(amountRange: String,
                             retailerName: String,
                             category: String,
                             expiryDate: Int64,
                             count: Int) {
        self.arrayOfDeals.removeAll()
        
        if count > 0 {
            view_filter.backgroundColor = UIColor.white
            iv_filter.tintColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
            label_filter_count.text = "\(count)"
            label_filter_count.isHidden = false
            self.retailerName = retailerName
            self.amountRange = amountRange
            self.categoryName = category
            self.expiry = expiryDate
            self.paginationOffset = 1
        } else {
            view_filter.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            iv_filter.tintColor = UIColor.white
            label_filter_count.isHidden = true
            self.amountRange = ""
            self.retailerName = ""
            self.categoryName = ""
            self.expiry = 0
        }
        
        fetchAllFlyerDealsNetworkCall()
    }
    
    func onSortApplied(sortTitle: String, sortType: String, isAscending: Bool, sortIntType: Int) {
        label_sort_title.text = sortTitle
        self.sortIntType = sortIntType
    }
}

extension FlyerAllDealsViewController: UIScrollViewDelegate {

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if ((table_view_deals.contentOffset.y + (table_view_deals.frame.size.height)) >= self.table_view_deals.contentSize.height) {
            
            fetchAllFlyerDealsNetworkCall()
        }
    }
}
