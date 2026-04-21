
import UIKit


protocol CategoryAndRetilerSelectionListener {
    func onCategoryOrRetailerSelected (selectedString : String)
}

class FilterCategoryViewController: BaseViewController {

    @IBOutlet weak var table_view: UITableView!
    @IBOutlet weak var search_bar: UISearchBar!
    
    public var delegate : CategoryAndRetilerSelectionListener?
    
    private let nibCategoryName = "CategorySelectionViewCell"
    private var arrayOfCategories : Array<String> = []
    private var searchArray : Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()
        fetchCategoriesNetworkCall()
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
        let nibCategory = UINib(nibName: nibCategoryName, bundle: nil)
        table_view.register(nibCategory, forCellReuseIdentifier: nibCategoryName)
    }
    
    private func searchCategories (searchString: String) {
        searchArray = []
        
        for category in arrayOfCategories {
            if category.lowercased().contains(searchString.lowercased()) {
                searchArray.append(category)
            }
        }
        
        table_view.reloadData()
    }
    
    private func fetchCategoriesNetworkCall () {
        UIUtils.showLoader(view: self.view)
        let dealsNetworkHelper = DealsAndOffers()
        dealsNetworkHelper.fetchCategoryAndRetailersNewtorkCall(type: "Category",
                                                                successHandler:
            { (arrayOfCategories, status, message) in
            
                UIUtils.dismissLoader(uiView: self.view)
                
                if status == 1 {
                    self.arrayOfCategories = arrayOfCategories
                    self.searchArray = arrayOfCategories
                } else {
                    UIUtils.showAlert(vc: self, message: message)
                }
                
                self.table_view.reloadData()
        })
        { (error) in
            UIUtils.dismissLoader(uiView: self.view)
            UIUtils.showAlert(vc: self, message: error.localizedDescription)
        }
    }
}

extension FilterCategoryViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table_view.dequeueReusableCell(withIdentifier: nibCategoryName, for: indexPath) as! CategorySelectionViewCell
        
        cell.label_category.text = searchArray[indexPath.row]
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.onCategoryOrRetailerSelected(selectedString: arrayOfCategories[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }

}

extension FilterCategoryViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCategories(searchString: search_bar.text!)
        
        if search_bar.text?.count == 0 {
            searchArray = arrayOfCategories
        }
        
        self.table_view.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search_bar.resignFirstResponder()
    }

}
