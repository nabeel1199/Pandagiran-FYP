

import UIKit

class FilterRetailersViewController: BaseViewController {

    @IBOutlet weak var table_view: UITableView!
    @IBOutlet weak var search_bar: UISearchBar!
    
    public var delegate : CategoryAndRetilerSelectionListener?
    
    private let nibRetailerName = "CategorySelectionViewCell"
    private var arrayOfRetailer : Array<String> = []
    private var searchArray : Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVariables()
        initUI()
        fetchRetailersNetworkCall()
    }
    
    private func initVariables () {
        initNibs()
        
        table_view.delegate = self
        table_view.dataSource = self
        search_bar.delegate = self
    }
    
    private func initUI () {
        self.navigationItemColor = .light
    }
    
    private func initNibs () {
        let nibCategory = UINib(nibName: nibRetailerName, bundle: nil)
        table_view.register(nibCategory, forCellReuseIdentifier: nibRetailerName)
    }
    
    private func searchRetailers (searchString: String) {
        searchArray = []
        
        for retailer in arrayOfRetailer {
            if retailer.lowercased().contains(searchString.lowercased()) {
                searchArray.append(retailer)
            }
        }
        
        table_view.reloadData()
    }
    
    private func fetchRetailersNetworkCall () {
        let dealsNetworkHelper = DealsAndOffers()
        dealsNetworkHelper.fetchCategoryAndRetailersNewtorkCall(type: "Retailer",
                                                                successHandler:
            { (arrayOfCategories, status, message) in
                
                if status == 1 {
                    self.arrayOfRetailer = arrayOfCategories
                    self.searchArray = arrayOfCategories
                } else {
                    UIUtils.showAlert(vc: self, message: message)
                }
                
                self.table_view.reloadData()
        })
        { (error) in
            UIUtils.showAlert(vc: self, message: error.localizedDescription)
        }
    }
}

extension FilterRetailersViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table_view.dequeueReusableCell(withIdentifier: nibRetailerName, for: indexPath) as! CategorySelectionViewCell
        
        cell.label_category.text = searchArray[indexPath.row]
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        delegate?.onCategoryOrRetailerSelected(selectedString: arrayOfRetailer[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
}

extension FilterRetailersViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchRetailers(searchString: search_bar.text!)
        
        if search_bar.text?.count == 0 {
            searchArray = arrayOfRetailer
        }
        
        self.table_view.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search_bar.resignFirstResponder()
    }
}

