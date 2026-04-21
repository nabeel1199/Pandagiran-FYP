

import UIKit

class FlyerSearchViewController: BaseViewController {

    @IBOutlet weak var view_flyer_offers: UIView!
    @IBOutlet weak var table_view_flyer_offer_height: NSLayoutConstraint!
    @IBOutlet weak var table_view_flyer_offers: UITableView!
    @IBOutlet weak var label_flyer_offer_count: UILabel!
    @IBOutlet weak var view_search_results: UIView!
    @IBOutlet weak var table_view_search_height: NSLayoutConstraint!
    @IBOutlet weak var table_view_search: UITableView!
    private let searchBar = UISearchBar(frame: CGRect.zero)
    
    public var searchQuery = ""
    
    private let nibSearchName = "NavigationViewCell"
    private let nibFlyerOfferName = "FlyerOfferViewCell"
    private var searchArray : Array<String> = []
    private var arrayOfDeals : Array<FlyerDeal> = []
    
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()
        searchFlyerDealsNetworkCall(query: searchQuery)
    }
    
    private func initVariables () {
        initNibs()
        
        searchBar.delegate = self
        
        table_view_search.delegate = self
        table_view_search.dataSource = self
        
        table_view_flyer_offers.delegate = self
        table_view_flyer_offers.dataSource = self
        
    }
    
    private func initUI () {
        self.navigationItemColor = .light
        self.viewBackgroundColor = .white
        
        
        searchBar.sizeToFit()
        searchBar.layer.borderWidth = 1.0
        searchBar.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        searchBar.layer.cornerRadius = 8.0
        searchBar.clipsToBounds = true
        searchBar.placeholder = "Search Flyer Offers"
        self.navigationItem.titleView = searchBar
        
        searchBar.text = searchQuery
        
        if #available(iOS 11.0, *) {
            searchBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
    }
    
    private func initNibs () {
        let nibFlyerOffer = UINib(nibName: nibFlyerOfferName, bundle: nil)
        let nibSearch = UINib(nibName: nibSearchName, bundle: nil)
        table_view_search.register(nibSearch, forCellReuseIdentifier: nibSearchName)
        table_view_flyer_offers.register(nibFlyerOffer, forCellReuseIdentifier: nibFlyerOfferName)
    }
    
    private func searchFlyerDealsNetworkCall (query: String) {
        UIUtils.showLoader(view: self.view)
        let dealsNetworkHelper = DealsAndOffers()
        print("TEXT : " , searchBar.text!)
        dealsNetworkHelper.searchFlyerDealsNetworkCall(search_query: query,
                                                       offset: 1,
                                                       successHandler:
            { (arrayOfDeals, searchArray, status, message) in
                
                UIUtils.dismissLoader(uiView: self.view)
                
                self.arrayOfDeals.removeAll()
                self.arrayOfDeals = arrayOfDeals
                self.searchArray = searchArray
                
                if self.searchBar.text!.count > 0 {
                    self.label_flyer_offer_count.text = "\(arrayOfDeals.count) Deal(s) found"
                } else {
                    self.label_flyer_offer_count.text = "Recently Liked Offers"
                }
                
                
                self.table_view_search?.reloadData()
                self.table_view_flyer_offers.reloadData()
                
                if arrayOfDeals.count == 0 {
                    self.view_flyer_offers.isHidden = true
                } else {
                    self.view_flyer_offers.isHidden = false
                }
                
                if searchArray.count == 0 {
                    self.view_search_results.isHidden = true
                } else {
                    self.view_search_results.isHidden = false
                }
                
                
        })
        { (error) in
            UIUtils.dismissLoader(uiView: self.view)
            UIUtils.showAlert(vc: self, message: error.localizedDescription)
        }
    }
    
    override func willMove(toParent parent: UIViewController?) {
        self.navigationItemColor = .dark
    }
}

extension FlyerSearchViewController : UITableViewDelegate , UITableViewDataSource {
    
    override func viewWillLayoutSubviews() {
        
        if arrayOfDeals.count > 0 {
            table_view_flyer_offer_height.constant = self.table_view_flyer_offers.contentSize.height
        }
        
        if searchArray.count > 0 {
            table_view_search_height.constant = self.table_view_search.contentSize.height
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == table_view_search {
            return searchArray.count
        }
        else
        {
            return arrayOfDeals.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == table_view_search {
            let cell = tableView.dequeueReusableCell(withIdentifier: nibSearchName, for: indexPath) as! NavigationViewCell
            
            cell.navImage.image = UIImage(named: "ic_clock")
            cell.label_nav_text.text = searchArray[indexPath.row]
            
            cell.selectionStyle = .none
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: nibFlyerOfferName, for: indexPath) as! FlyerOfferViewCell
            
            let deal = arrayOfDeals[indexPath.row]
            cell.configureDealWithItem(deal: deal)
            
            cell.selectionStyle = .none
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == table_view_search {
            searchBar.text = searchArray[indexPath.row]
            searchFlyerDealsNetworkCall(query: searchBar.text!)
        } else {
            let offerDetailsVC = getStoryboard(name: ViewIdentifiers.SB_FLYER).instantiateViewController(withIdentifier: ViewIdentifiers.VC_FLYER_DETAILS) as! FlyerDealDetailsViewController
            offerDetailsVC.flyerDeal = arrayOfDeals[indexPath.row]
            self.navigationController?.pushViewController(offerDetailsVC, animated: true)
        }
    
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewWillLayoutSubviews()
    }
}

extension FlyerSearchViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            searchFlyerDealsNetworkCall(query: searchBar.text!)
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchFlyerDealsNetworkCall(query: searchBar.text!)
        searchBar.resignFirstResponder()
    }
}

