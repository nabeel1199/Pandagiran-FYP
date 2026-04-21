

import UIKit


struct SortFields {
    var sortTitle : String
    var sortType : String
    var isAscending : Bool
}

protocol SortSelectionListener {
    
    func onSortApplied (sortTitle : String,
                        sortType : String,
                        isAscending : Bool,
                        sortIntType: Int)
}

class SortPopup: BasePopup {

    @IBOutlet weak var tableSortHeight: NSLayoutConstraint!
    @IBOutlet weak var table_view_sort: UITableView!
    
    public var isDealSort = false
    public var delegate : SortSelectionListener?
    
    private var sortArray : Array<SortFields> = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        populateSortArray()
    }
    
    private func initVariables () {
        table_view_sort.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        table_view_sort.delegate = self
        table_view_sort.dataSource = self
    }
    
    private func populateSortArray () {
        if isDealSort {
            var sortFields = SortFields(sortTitle: "Price (Ascending)", sortType: "date", isAscending: true)
            sortArray.append(sortFields)
            sortFields = SortFields(sortTitle: "Price (Descending)", sortType: "date", isAscending: false)
            sortArray.append(sortFields)
        } else {
            var sortFields = SortFields(sortTitle: "Date (Ascending)", sortType: "date", isAscending: true)
            sortArray.append(sortFields)
            sortFields = SortFields(sortTitle: "Date (Descending)", sortType: "date", isAscending: false)
            sortArray.append(sortFields)
            sortFields = SortFields(sortTitle: "Amount (Ascending)", sortType: "amount", isAscending: true)
            sortArray.append(sortFields)
            sortFields = SortFields(sortTitle: "Amount (Descending)", sortType: "amount", isAscending: false)
            sortArray.append(sortFields)
        }

    }
    
    @IBAction func onCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}

extension SortPopup : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = sortArray[indexPath.row].sortTitle
        cell.textLabel?.font = UIFont(name: Style.font.REGULAR_FONT, size: 14.0)
        
        tableSortHeight.constant = tableView.contentSize.height
        cell.selectionStyle = .none
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sortTitle = sortArray[indexPath.row].sortTitle
        let sortType = sortArray[indexPath.row].sortType
        let isAscending = sortArray[indexPath.row].isAscending
        
        delegate?.onSortApplied(sortTitle: sortTitle,
                                sortType: sortType,
                                isAscending: isAscending,
                                sortIntType: indexPath.row)
        self.dismiss(animated: true, completion: nil)
    }
    
}
