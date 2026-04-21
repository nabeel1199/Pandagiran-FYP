
import UIKit


protocol CategorySelectionListener {
    func onCategorySelected (category: String, categoryId: Int64)
}

class CategorySelectionPopup: BasePopup {

    @IBOutlet weak var popup_view: CardView!
    @IBOutlet weak var label_choose_category: CustomFontLabel!
    @IBOutlet weak var categoriesTableHeight: NSLayoutConstraint!
    @IBOutlet weak var table_view_categories: UITableView!
    
    private let nibCategoryName = "CategorySelectionViewCell"
    private var arrayOfCategories : Array<Hkb_category> = []
    
    public var delegate: CategorySelectionListener?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        fetchCategories()

    }
    
    private func initVariables () {
        initNibs()
        
        table_view_categories.dataSource = self
        table_view_categories.delegate = self
    }
    
    private func initNibs () {
        let nibCategory = UINib(nibName: nibCategoryName, bundle: nil)
        table_view_categories.register(nibCategory, forCellReuseIdentifier: nibCategoryName)
    }
    
    private func fetchCategories () {
        arrayOfCategories = QueryUtils.fetchCategories(type: "ALL")
    }

    @IBAction func onCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CategorySelectionPopup: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfCategories.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nibCategoryName, for: indexPath) as! CategorySelectionViewCell
        
        cell.iv_selection.image = UIImage(named: "ic_radio_unchecked")
        
        if indexPath.row == 0 {
            cell.label_category.text = "All Categories"
        } else {
            let category = arrayOfCategories[indexPath.row - 1]
            cell.label_category.text = category.title!
        }
   
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView.cellForRow(at: indexPath) != nil else {
            return
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! CategorySelectionViewCell
        cell.iv_selection.image = UIImage(named: "ic_radio_checked")
        
        if indexPath.row == 0 {
            delegate?.onCategorySelected(category: "All Categories", categoryId: 0)
        } else {
            delegate?.onCategorySelected(category: arrayOfCategories[indexPath.row - 1].title!, categoryId: arrayOfCategories[indexPath.row - 1].categoryId)
        }
        

        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard tableView.cellForRow(at: indexPath) != nil else {
            return
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! CategorySelectionViewCell
        
        cell.iv_selection.image = UIImage(named: "ic_radio_unchecked")
    }
    
    
}
