

import UIKit

class IntervalSelectionPopup: BasePopup {

    @IBOutlet weak var table_view_interval: UITableView!
    @IBOutlet weak var intervalTableHeight: NSLayoutConstraint!
    @IBOutlet weak var popup_view: CardView!
    
    private let nibIntervalName = "CategorySelectionViewCell"
    public var delegate: IntervalListener?
    private var selectedInterval = ""
    private var intervalArray = ["Monthly", "Quarterly", "Half yearly", "Yearly", "All Time"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()
        
    }
    
    private func initVariables () {
        selectedInterval = LocalPrefs.getCurrentInterval()
        initNibs()
        
        table_view_interval.delegate = self
        table_view_interval.dataSource = self
    }
    
    private func initNibs () {
        let nibInterval = UINib(nibName: nibIntervalName, bundle: nil)
        table_view_interval.register(nibInterval, forCellReuseIdentifier: nibIntervalName)
    }
    
    private func initUI () {
        self.animateView(popup_view: popup_view)
        
        DispatchQueue.main.async {
            if let index = self.intervalArray.index(of: LocalPrefs.getCurrentInterval()) {
                self.table_view_interval.selectRow(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: UITableView.ScrollPosition.middle)
                self.tableView(self.table_view_interval, didSelectRowAt: IndexPath(item: index, section: 0))
            }
        }
    }

    
    @IBAction func onCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onApplyTapped(_ sender: Any) {
        delegate?.onIntervalChanged(selectedInterval: selectedInterval)
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension IntervalSelectionPopup: UITableViewDataSource, UITableViewDelegate {
    
    override func viewWillLayoutSubviews() {
        self.updateViewConstraints()
        self.intervalTableHeight.constant = table_view_interval.contentSize.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return intervalArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nibIntervalName, for: indexPath) as! CategorySelectionViewCell
        
        cell.label_category.text = intervalArray[indexPath.row]
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView.cellForRow(at: indexPath) != nil else {
            return
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! CategorySelectionViewCell
        
        
        self.selectedInterval = intervalArray[indexPath.row]
        cell.iv_selection.image = UIImage(named: "ic_radio_checked")
        cell.iv_selection.tintColor = Utils.hexStringToUIColor(hex: AppColors.PRIMARY_COLOR)
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard tableView.cellForRow(at: indexPath) != nil else {
            return
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! CategorySelectionViewCell
        
        cell.iv_selection.image = UIImage(named: "ic_radio_unchecked")
    }
    
}
