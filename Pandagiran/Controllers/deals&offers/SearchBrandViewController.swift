

import UIKit

protocol BrandSelectionListener {
    func onBrandSelected (brandName: String)
}

class SearchBrandViewController: BaseViewController {

    @IBOutlet weak var search_bar: UISearchBar!
    @IBOutlet weak var table_view: UITableView!
    
    public var delegate : BrandSelectionListener?
    
    private let nibBrandName = "CategorySelectionViewCell"
    private var arrayOfBrands : Array<String> = []

    
    override func viewDidLoad() {
        super.viewDidLoad()


        initVariables()
        initUI()
        fetchBrandsNetworkCall(searchQuery: "")
    }
    
    
    private func initVariables () {
        initNibs()
        
        search_bar.delegate = self
        table_view.delegate = self
        table_view.dataSource = self
    }
    
    
    private func initNibs () {
        let nibBrand = UINib(nibName: nibBrandName, bundle: nil)
        self.table_view.register(nibBrand, forCellReuseIdentifier: nibBrandName)
    }
    
    private func initUI () {
        self.navigationItemColor = .light
    }

    private func fetchBrandsNetworkCall (searchQuery: String) {
        UIUtils.showLoader(view: self.view)
        let dealsNetworkHelper = DealsAndOffers()
        dealsNetworkHelper.searchBrandsNetworkCall(search_query: searchQuery,
                                                   successHandler:
            { (arrayOfBrands, status, message) in
                
                UIUtils.dismissLoader(uiView: self.view)
                
                if status == 1 {
                    self.arrayOfBrands = arrayOfBrands
                } else {
                    UIUtils.showAlert(vc: self, message: message)
                }
                
                self.table_view.reloadData()
            
        }) { (error) in
            UIUtils.showAlert(vc: self, message: error.localizedDescription)
            UIUtils.dismissLoader(uiView: self.view)
        }
    }
}

extension SearchBrandViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfBrands.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table_view.dequeueReusableCell(withIdentifier: nibBrandName, for: indexPath) as! CategorySelectionViewCell
        
        cell.label_category.text = arrayOfBrands[indexPath.row]
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.onBrandSelected(brandName: arrayOfBrands[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
}

extension SearchBrandViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if search_bar.text!.count == 0 {
            fetchBrandsNetworkCall(searchQuery: "")
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchBrandsNetworkCall(searchQuery: searchBar.text!)
    }
}


