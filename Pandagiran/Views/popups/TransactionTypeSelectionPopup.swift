

import UIKit

protocol TransactionTypeSelectionListener {
    func onTypeSelected (vchType: String)
}

class TransactionTypeSelectionPopup: BasePopup {

    
    @IBOutlet weak var label_choose_transaction: CustomFontLabel!
    @IBOutlet weak var table_view_types: UITableView!
    private let nibTypeName = "CategorySelectionViewCell"
    private var arrayOfType : Array<String> = ["All", "Income", "Expense", "Transfer"]
    
    public var delegate : TransactionTypeSelectionListener?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVariables()
        
    }
    
    private func initVariables () {
        initNibs()
        
        table_view_types.dataSource = self
        table_view_types.delegate = self
    }
    
    private func initNibs () {
        let nibType = UINib(nibName: nibTypeName, bundle: nil)
        table_view_types.register(nibType, forCellReuseIdentifier: nibTypeName)
    }
    
    @IBAction func onCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension TransactionTypeSelectionPopup: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfType.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nibTypeName, for: indexPath) as! CategorySelectionViewCell
        
    
        cell.label_category.text = arrayOfType[indexPath.row]
        cell.iv_selection.image = UIImage(named: "ic_radio_unchecked")
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView.cellForRow(at: indexPath) != nil else {
            return
        }
        

        let cell = tableView.cellForRow(at: indexPath) as! CategorySelectionViewCell
        
        cell.iv_selection.image = UIImage(named: "ic_radio_checked")

        delegate?.onTypeSelected(vchType: arrayOfType[indexPath.row])
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
