

import UIKit

class SearchActivityViewController: BaseViewController {

    
    @IBOutlet weak var view_placeholder: UIView!
    @IBOutlet weak var table_view_search: UITableView!
    
    var currentInterval : String = Constants.MONTHLY
    private let nibTransactionName = "TransactionViewCell"
    private var searchArray : Array<Hkb_voucher> = []
    public var month : String = ""
    public var year = 0
    public var intervalIndex = 0
    private let searchBar = UISearchBar()
    
    override func viewWillAppear(_ animated: Bool) {
        initUI()
    }
    
    override func viewDidLoad() {

        initVariables()
        
    }
    
    private func initVariables () {
        searchBar.delegate = self
        initNibs()
        
        table_view_search.delegate = self
        table_view_search.dataSource = self
    }
    
    private func initUI () {
        let closeBtn = UIBarButtonItem(image: UIImage(named: "ic_clear"), style: .plain, target: self, action: #selector(onCloseTapped))
        self.navigationItem.leftBarButtonItem = closeBtn
        
        self.navigationItemColor = .light
        
        searchBar.sizeToFit()
        searchBar.layer.borderWidth = 1.0
        searchBar.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        searchBar.layer.cornerRadius = 8.0
        searchBar.clipsToBounds = true
        searchBar.placeholder = "Search Transactions"
        searchBar.becomeFirstResponder()
        self.navigationItem.titleView = searchBar
        
        if #available(iOS 11.0, *) {
            searchBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
        
    }
    
    private func initNibs () {
        let nibTransaction = UINib(nibName: nibTransactionName, bundle: nil)
        table_view_search.register(nibTransaction, forCellReuseIdentifier: nibTransactionName)
    }
    
    
    private func fetchSearchResults (searchString : String) {
        self.searchArray = []
        let month = Utils.getCurrentMonth()
        let year = Utils.getCurrentYear()
        searchArray = ActivitiesDbUtils.fetchSearchResults(currentInterval: currentInterval, month: String(month), year: year, searchString: searchString)
        
        self.table_view_search.reloadData()
        
        showPlaceholder()
    }
    
    private func showPlaceholder () {
        if searchArray.count == 0 {
            view_placeholder.isHidden = false
        } else {
            view_placeholder.isHidden = true
        }
    }
    
    @objc private func onCloseTapped () {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        
    }
    

}

extension SearchActivityViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table_view_search.dequeueReusableCell(withIdentifier: nibTransactionName, for: indexPath) as! TransactionViewCell
        
        let searchedTrx = searchArray[indexPath.row]
        cell.configureWithItem(accountId: 0, voucher: searchedTrx)
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchedTrx = searchArray[indexPath.row]
        let transactionVC = getStoryboard(name: ViewIdentifiers.SB_TRANSACTION).instantiateViewController(withIdentifier: ViewIdentifiers.VC_TRANSACTION_DETAILS) as! TransactionDetailsViewController
        transactionVC.viewVoucher = searchedTrx
        transactionVC.showViewMode = true
        self.navigationController?.pushViewController(transactionVC, animated: true)
    }
    
    
}


extension SearchActivityViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text!.count > 0 {
            fetchSearchResults(searchString: searchBar.text!)
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

