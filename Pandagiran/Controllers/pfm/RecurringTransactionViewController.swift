

import UIKit

class RecurringTransactionViewController: BaseViewController {

    @IBOutlet weak var view_interval: UIView!
    @IBOutlet weak var view_date: UIView!
    @IBOutlet weak var view_time: UIView!
    @IBOutlet weak var view_recurring_till: UIView!
    
    @IBOutlet weak var btn_recurring_till: UIButton!
    @IBOutlet weak var btn_time: UIButton!
    @IBOutlet weak var btn_date: UIButton!
    @IBOutlet weak var btn_interval: UIButton!
    
    private var isMonthly = false
    private var isDateSelection = false
    private var selectedInterval = "Daily"
    private var reminderDay = 0
    private var repeatTitle = "Daily"
    public var delegate : ReminderFrequencyListener?
    
    override func viewDidLoad() {

        initUI()

    }

    private func initUI () {
        setTime(date: Date())
        view_date.isHidden = true
        self.navigationItemColor = .light
        
        self.navigationItem.title = "Recurring Transaction"
    }
    
    @IBAction func onIntervalTapped(_ sender: Any) {
        let recurringIntervalPopup = RecurringReminderIntervalPopup()
        recurringIntervalPopup.delegate = self
        self.presentPopupView(popupView: recurringIntervalPopup)
    }
    
    @IBAction func onRepeatFrequencyTapped(_ sender: Any) {
        let repeatReminderPopup = ReminderRepeatPopup()
        
        if selectedInterval == "Monthly" {
            repeatReminderPopup.isMonthly = true
        } else {
            repeatReminderPopup.isMonthly = false
        }
        
        repeatReminderPopup.delegate = self
        self.presentPopupView(popupView: repeatReminderPopup)
    }
    
    private func setTime (date : Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" // for specifying the change to format hour:minute am/pm.
        let reminderTime = dateFormatter.string(from: date)
        btn_time.setTitle(reminderTime, for: .normal)
    }
    
    @IBAction func onTimeTapped(_ sender: Any) {
        isDateSelection = false
        let timeSelectionPopup = TimeSelectionPopup()
        timeSelectionPopup.delegate = self
        self.presentPopupView(popupView: timeSelectionPopup)
    }
    
    @IBAction func onRecurringTillTapped(_ sender: Any) {
        isDateSelection = true
        let dateSelectionPopup = DateSelectionPopup()
        dateSelectionPopup.delegate = self
        self.presentPopupView(popupView: dateSelectionPopup)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        self.navigationItemColor = .dark
    }
    
    
    @IBAction func onSetRecurringTapped(_ sender: Any) {
        if selectedInterval == "Monthly" || selectedInterval == "Weekly" {
            if reminderDay != 0 {
                delegate?.onFrequencySelected(repeatInterval: selectedInterval, repeatTitle: repeatTitle, day: reminderDay)
                self.navigationController?.popViewController(animated: true)
            } else {
                UIUtils.showAlert(vc: self, message: "Please select reminder day")
            }
        } else {
            delegate?.onFrequencySelected(repeatInterval: selectedInterval, repeatTitle: repeatTitle, day: reminderDay)
            self.navigationController?.popViewController(animated: true)
        }
    }
}


extension RecurringTransactionViewController: IntervalListener, ReminderFrequencyListener, DateSelectionListener {
    

    func onDateSelected(date: Date) {
        if isDateSelection {
            self.btn_recurring_till.setTitle("Recurring till \(Utils.currentDateUserFormat(date: date))", for: .normal)
        } else {
            setTime(date: date)
        }
    }
    
    func onIntervalChanged(selectedInterval: String) {
        reminderDay = 0
        btn_date.setTitle("Select day", for: .normal)
        self.btn_interval.setTitle(selectedInterval, for: .normal)
        self.selectedInterval = selectedInterval
        if selectedInterval == "Daily" || selectedInterval == "Never" {
            self.view_date.isHidden = true
        } else {
            self.view_date.isHidden = false
        }
    }
    
    func onFrequencySelected(repeatInterval: String, repeatTitle: String, day: Int) {
        self.repeatTitle = repeatTitle
        btn_date.setTitle(repeatTitle, for: .normal)
        reminderDay = day
    }
    
}
