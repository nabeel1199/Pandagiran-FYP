

import UIKit

class DealSearchViewController: BaseViewController {

    @IBOutlet weak var stack_view: UIStackView!
    @IBOutlet weak var table_view_deals_height: NSLayoutConstraint!
    @IBOutlet weak var table_view_search_height: NSLayoutConstraint!
    @IBOutlet weak var view_recently_liked: UIView!
    @IBOutlet weak var view_recent_search: UIView!
    @IBOutlet weak var label_search_count: UILabel!
    @IBOutlet weak var table_view_recently_liked: UITableView!
    @IBOutlet weak var table_view_searches: UITableView!
    private let searchBar = UISearchBar(frame: CGRect.zero)
    
    private let nibSearchName = "NavigationViewCell"
    private let nibDealName = "LikedDealViewCell"
    private var searchArray : Array<String> = []
    private var arrayOfDeals : Array<Deal> = []
    private var isSearchApplied = false
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        initVariables()
        initUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

 
        fetchSearchResultsAndLikedDeals()
    }
    
    private func initVariables () {
        initNibs()
        
        searchBar.delegate = self
        
        table_view_recently_liked.delegate = self
        table_view_recently_liked.dataSource = self
        
        table_view_searches.delegate = self
        table_view_searches.dataSource = self
        
    }
    
    private func initNibs () {
        let nibDeal = UINib(nibName: nibDealName, bundle: nil)
        let nibSearch = UINib(nibName: nibSearchName, bundle: nil)
        
        table_view_searches.register(nibSearch, forCellReuseIdentifier: nibSearchName)
        table_view_recently_liked.register(nibDeal, forCellReuseIdentifier: nibDealName)
    }
    
    private func initUI () {
        self.navigationItemColor = .light
        self.viewBackgroundColor = .white
        
        
        searchBar.layer.borderWidth = 1.0
        searchBar.isTranslucent = true
        searchBar.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        searchBar.layer.cornerRadius = 8.0
        searchBar.placeholder = "Search deals"
        self.navigationItem.titleView = searchBar
        
        if #available(iOS 11.0, *) {
            searchBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
        
    }
    
    private func fetchSearchResultsAndLikedDeals () {
        UIUtils.showLoader(view: self.view)
        let dealsNetworkHelper = DealsAndOffers()
        dealsNetworkHelper.fetchSearchResultsAndLikedDeals(search_query: searchBar.text!,
                                                           offset: 1,
                                                           successHandler:
            { (arrayOfDeals, searchArray, status, message) in
                
                UIUtils.dismissLoader(uiView: self.view)
                
                if status == 1 {
                    self.arrayOfDeals.removeAll()
                    self.arrayOfDeals = arrayOfDeals
                    self.searchArray = searchArray
                    
                    if self.searchBar.text!.count > 0 {
                        self.label_search_count.text = "\(arrayOfDeals.count) Deal(s) found"
                    } else {
                        self.label_search_count.text = "Recently Liked Deals"
                    }
                    
                    
                    self.table_view_searches?.reloadData()
                    self.table_view_recently_liked.reloadData()
                }
    
                if self.arrayOfDeals.count == 0 {
                    self.view_recently_liked.isHidden = true
                } else {
                    self.view_recently_liked.isHidden = false
                }
                
                if self.searchArray.count == 0 {
                    self.view_recent_search.isHidden = true
                } else {
                    self.view_recent_search.isHidden = false
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

extension DealSearchViewController : UITableViewDelegate, UITableViewDataSource {
    
    override func viewWillLayoutSubviews() {
        
        if arrayOfDeals.count > 0 {
            table_view_deals_height.constant = self.table_view_recently_liked.contentSize.height
        }
        
        if searchArray.count > 0 {
            table_view_search_height.constant = self.table_view_searches.contentSize.height
        }
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == table_view_recently_liked {
           
            return arrayOfDeals.count
        }
        else
        {
            return searchArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == table_view_recently_liked {
            let cell = tableView.dequeueReusableCell(withIdentifier: nibDealName, for: indexPath) as! LikedDealViewCell
            
            let deal = arrayOfDeals[indexPath.row]
            cell.configureDealWithItem(deal: deal)
            
            cell.selectionStyle = .none
            return cell
        }
        
        else
        
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: nibSearchName, for: indexPath) as! NavigationViewCell
            
            cell.navImage.image = UIImage(named: "ic_clock")
            cell.label_nav_text.text = searchArray[indexPath.row]
            
            cell.selectionStyle = .none
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == table_view_searches {
            searchBar.text = searchArray[indexPath.row]
            fetchSearchResultsAndLikedDeals()
        } else {
            let dealDetailsVC = getStoryboard(name: ViewIdentifiers.SB_DEAL).instantiateViewController(withIdentifier: ViewIdentifiers.VC_DEAL_DETAILS) as! DealDetailsViewController
            dealDetailsVC.deal = arrayOfDeals[indexPath.row]
            self.navigationController?.pushViewController(dealDetailsVC, animated: true)
        }
     
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewWillLayoutSubviews()
    }
    
}

extension DealSearchViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchBar.text?.count == 0 {
            fetchSearchResultsAndLikedDeals()
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchSearchResultsAndLikedDeals()
        searchBar.resignFirstResponder()
    }
}
