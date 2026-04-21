

import UIKit

class DialogGroupBy: UIViewController {

    @IBOutlet weak var table_view: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    private var groupBy: String = ""
    private var groupingArray = ["Categories", "Accounts", "Type (Expense, Income, Transfer)"]
    public var myDelegate: GroupByListener?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        overlayBlurredBackgroundView()
        initVariables()
        
    }
    
    private func initVariables () {
        table_view.delegate = self
        table_view.dataSource = self
        
        let nibGroupBy = UINib(nibName : "TimeIntervalCell" , bundle : nil)
        table_view.register(nibGroupBy, forCellReuseIdentifier: "TimeIntervalCell")
    }
    
    func overlayBlurredBackgroundView() {
        let blurredBackgroundView = UIVisualEffectView()
        blurredBackgroundView.frame = self.view.bounds
        blurredBackgroundView.effect = UIBlurEffect(style: .regular)
        blurredBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurredBackgroundView, at: 0)
    }

    @IBAction func onApplyTapped(_ sender: Any) {
        myDelegate?.onGroupByApplied(type: groupBy)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension DialogGroupBy : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table_view.dequeueReusableCell(withIdentifier: "TimeIntervalCell", for: indexPath) as! TimeIntervalCell
        cell.iv_checked.isHidden = false
        cell.label_interval.text = groupingArray[indexPath.row]
        cell.iv_checked.image = UIImage(named: "ic_radio_unchecked")?.withRenderingMode(.alwaysTemplate)
        cell.iv_checked.tintColor = UIColor.lightGray
        
        tableViewHeight.constant = table_view.contentSize.height
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = table_view.cellForRow(at: indexPath) as! TimeIntervalCell
        cell.iv_checked.image = UIImage(named: "ic_radio_checked")?.withRenderingMode(.alwaysTemplate)
//        cell.iv_checked.tintColor = Utils.hexStringToUIColor(hex: AppColors.hk_green)
        
        if indexPath.row == 2 {
            groupBy = "Type"
        } else {
            groupBy = groupingArray[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = table_view.cellForRow(at: indexPath) as! TimeIntervalCell
        cell.iv_checked.image = UIImage(named: "ic_radio_unchecked")?.withRenderingMode(.alwaysTemplate)
        cell.iv_checked.tintColor = UIColor.lightGray
    }
    
}
