

import UIKit
import Firebase

class DialogAddCategory: UIViewController , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var bg_view: UIView!
    @IBOutlet weak var btn_ok: UIButton!
    @IBOutlet weak var btn_cancel: UIButton!
    @IBOutlet weak var table_view: UITableView!
    
    var arrayOfIntervals = Array<String>()
    var myDelegate : IntervalListener?
    var selectedInterval : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()

    }
    
    func initVariables() {
        populateTimeIntervals()
        
        table_view.delegate = self
        table_view.dataSource = self
        
        let nibTimeInterval = UINib(nibName : "TimeIntervalCell" , bundle : nil)
        table_view.register(nibTimeInterval, forCellReuseIdentifier: "TimeIntervalCell")
    }
    
    func initUI() {
        overlayBlurredBackgroundView()
        
        let index = arrayOfIntervals.index(of: LocalPrefs.getCurrentInterval())
        self.table_view.selectRow(at: IndexPath(item : index! , section : 0), animated: false, scrollPosition: UITableView.ScrollPosition.none)
        tableView(table_view, didSelectRowAt: IndexPath(item : index! , section : 0))
    }
    
    func populateTimeIntervals() {
        arrayOfIntervals.append("Monthly")
        arrayOfIntervals.append("Quarterly")
        arrayOfIntervals.append("Half yearly")
        arrayOfIntervals.append("Yearly")
        arrayOfIntervals.append("All Time")
    }
    
    func overlayBlurredBackgroundView() {
        
        let blurredBackgroundView = UIVisualEffectView()
        blurredBackgroundView.frame = self.view.bounds
        blurredBackgroundView.effect = UIBlurEffect(style: .extraLight)
        blurredBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurredBackgroundView, at: 0)
    }

    // Action Listeners
    @IBAction func onCancelTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onOkTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        Analytics.logEvent("budget_interval", parameters: ["budget_interval" : selectedInterval])
        myDelegate?.onIntervalChanged(selectedInterval: selectedInterval)
    }
    
    
    // Table view Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfIntervals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table_view.dequeueReusableCell(withIdentifier: "TimeIntervalCell", for: indexPath) as! TimeIntervalCell
        
        cell.label_interval.text = arrayOfIntervals[indexPath.row]
        cell.selectionStyle = .none
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = table_view.cellForRow(at: indexPath) as! TimeIntervalCell
        cell.iv_checked.isHidden = false
        selectedInterval = arrayOfIntervals[indexPath.row]

    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = table_view.cellForRow(at: indexPath) as! TimeIntervalCell
        cell.iv_checked.isHidden = true
    }
    
}
