

import UIKit

class RecurringReminderIntervalPopup: BasePopup {

    @IBOutlet weak var table_view_recurring: UITableView!
    
    @IBOutlet weak var popup_view: CardView!
    @IBOutlet weak var recurringTableHeight: NSLayoutConstraint!
    
    private let nibIntervalName = "TimeIntervalCell"
    public var delegate: IntervalListener?
    private var intervalArray = ["Daily", "Weekly", "Monthly", "Once"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVariables()
        initUI()
        
    }
    
    private func initVariables () {
        initNibs()
        
        table_view_recurring.delegate = self
        table_view_recurring.dataSource = self
    }
    
    private func initNibs () {
        let nibInterval = UINib(nibName: nibIntervalName, bundle: nil)
        table_view_recurring.register(nibInterval, forCellReuseIdentifier: nibIntervalName)
    }
    
    private func initUI () {
        self.animateView(popup_view: popup_view)
    }
    
    
    @IBAction func onCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension RecurringReminderIntervalPopup: UITableViewDataSource, UITableViewDelegate {
    
    override func viewWillLayoutSubviews() {
        self.updateViewConstraints()
        self.recurringTableHeight.constant = table_view_recurring.contentSize.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return intervalArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nibIntervalName, for: indexPath) as! TimeIntervalCell
        
        cell.label_interval.text = intervalArray[indexPath.row]
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView.cellForRow(at: indexPath) != nil else {
            return
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! TimeIntervalCell
        
        delegate?.onIntervalChanged(selectedInterval: intervalArray[indexPath.row])
        cell.iv_checked.image = UIImage(named: "ic_radio_checked")
        cell.iv_checked.tintColor = Utils.hexStringToUIColor(hex: AppColors.PRIMARY_COLOR)
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard tableView.cellForRow(at: indexPath) != nil else {
            return
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! TimeIntervalCell
        
        cell.iv_checked.image = UIImage(named: "ic_radio_checked")
        cell.iv_checked.tintColor = UIColor.lightGray
    }
    
}
