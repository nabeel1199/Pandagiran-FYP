

import UIKit

class GlobalSearchViewController: BaseViewController {

    @IBOutlet weak var view_segment: SignatureSegmentedControl!
    
    @IBOutlet weak var dealsTableHeight: NSLayoutConstraint!
    @IBOutlet weak var table_view_deals: UITableView!
    @IBOutlet weak var label_deals_found: UILabel!
    @IBOutlet weak var table_view_transactions: UITableView!
    @IBOutlet weak var transactionsTableHeight: NSLayoutConstraint!
    @IBOutlet weak var label_transactions_found: UILabel!
    
    
    private let nibTransactionName = "TransactionViewCell"
    private let nibDealSearchName = "DealSearchViewCell"
    
    override func viewDidLoad() {

        initVariables ()
        initUI()

    }
    
    private func initVariables () {
        initNibs()
        
        table_view_transactions.delegate = self
        table_view_transactions.dataSource = self
        
        table_view_deals.delegate = self
        table_view_deals.dataSource = self
    }
    
    private func initUI () {
        self.navigationItemColor = .light
        
        label_deals_found.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        label_transactions_found.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        
        let closeBtn = UIBarButtonItem(image: UIImage(named: "ic_clear"), style: .plain, target: self, action: #selector(onCloseTapped))
        self.navigationItem.rightBarButtonItem = closeBtn
        
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.layer.borderWidth = 1.0
        searchBar.layer.borderColor = UIColor.lightGray.cgColor
        searchBar.layer.cornerRadius = 5.0
        searchBar.clipsToBounds = true
        searchBar.placeholder = "Search"
        self.navigationItem.titleView = searchBar
    }
    
    private func initNibs () {
        let nibTransaction = UINib(nibName: nibTransactionName, bundle: nil)
        let nibDealSearch = UINib(nibName: nibDealSearchName, bundle: nil)
        table_view_transactions.register(nibTransaction, forCellReuseIdentifier: nibTransactionName)
        table_view_deals.register(nibDealSearch, forCellReuseIdentifier: nibDealSearchName)
    }
    
    @objc private func onCloseTapped () {
        self.dismiss(animated: true, completion: nil)
    }
}

extension GlobalSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        transactionsTableHeight.constant = table_view_transactions.contentSize.height
        dealsTableHeight.constant = table_view_deals.contentSize.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case table_view_transactions:
            return 5
        default:
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        viewWillLayoutSubviews()
        
        switch tableView {
        case table_view_transactions:
            let cell = tableView.dequeueReusableCell(withIdentifier: nibTransactionName, for: indexPath) as! TransactionViewCell
            
            
            cell.selectionStyle = .none
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: nibDealSearchName, for: indexPath) as! DealSearchViewCell
            
            
            cell.selectionStyle = .none
            return cell
        }
    }
    
    
}
