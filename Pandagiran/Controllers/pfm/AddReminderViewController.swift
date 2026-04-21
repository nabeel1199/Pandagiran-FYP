

import UIKit
import UserNotifications
import CoreData

class AddReminderViewController: BaseViewController  {
    
    
    @IBOutlet weak var btn_create: GradientButton!
    @IBOutlet weak var view_segment: SignatureSegmentedControl!
    @IBOutlet weak var btn_date: UIButton!
    @IBOutlet weak var view_date: CardView!
    @IBOutlet weak var view_interval: CardView!
    @IBOutlet weak var btn_interval: UIButton!
    @IBOutlet weak var view_time: CardView!
    @IBOutlet weak var btn_time: UIButton!
    @IBOutlet weak var text_field_reminder_title: UITextField!
    
    
    public var hkb_reminder : Hkb_reminder?
    public var myDelegate : ReminderAddedListener?
    public var reminderTitle = ""
    public var segmentIndex = 0
    
    var reminderType : String = Constants.EXPENSE
    var reminderDate : String = ""
    var reminderTime : String = ""
    var isDateSelection = false
    var hour : Int = 0 , min : Int = 0
    
    private var date = Date()
    private var repeatInterval : String = ""
    private var hkb_voucher : Hkb_voucher?
    private var time = Date()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setInitialDate()
        initVariables()
        initUI ()
        editReminder()
    }
    
    func initVariables () {
        text_field_reminder_title.delegate = self
        view_segment.delegate = self
//        let nibRepeat = UINib(nibName : "CellWithImageAndText" , bundle : nil)
//        repeat_reminder_collection_view.register(nibRepeat, forCellWithReuseIdentifier: "CellWithImageAndText")
//        self.collection_view.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
//        collection_view.delegate = self
//        collection_view.dataSource = self
//        repeat_reminder_collection_view.delegate = self
//        repeat_reminder_collection_view.dataSource = self
//
        (reminderTime , hour , min) = getTimeFromDate(date: Date())
//
//        showOrHideRecurringView(show: false)
    }
    
    private func setInitialDate(){
        let date : Date = Date()
        reminderDate = Utils.currentDateDbFormat(date: date)
        btn_date.setTitle(Utils.currentDateUserFormat(date: date), for: .normal)
    }
    

    private func initUI () {
        self.viewBackgroundColor = .white
        self.navigationItemColor = .light
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_clear"), style: .plain, target: self, action: #selector(dismissVC))

        setTime(date: self.time)
        
        let timeTapGest = UITapGestureRecognizer(target: self, action: #selector(onReminderTimeTapped))
        view_time.addGestureRecognizer(timeTapGest)
        
        let intervalTapGest = UITapGestureRecognizer(target: self, action: #selector(onIntervalTapped))
        view_interval.addGestureRecognizer(intervalTapGest)
        
        let dateTapGest = UITapGestureRecognizer(target: self, action: #selector(onDateTapped))
        view_date.addGestureRecognizer(dateTapGest)
        
        text_field_reminder_title.text = reminderTitle
        view_segment.selectedSegmentIndex = segmentIndex
    }
    
    private func editReminder () {
        if let reminder = hkb_reminder {
            repeatInterval = reminder.recurring!
            btn_interval.setTitle(repeatInterval, for: .normal)
            reminderDate = reminder.rmdate!
            let date = Utils.convertStringToDate(dateString: reminderDate)
            text_field_reminder_title.text = reminder.title!
            btn_date.setTitle(Utils.currentDateUserFormat(date: date), for: .normal)
            setTime(date: date)
            view_segment.selectedSegmentIndex = Int(reminder.isexpense)
            
            btn_create.setTitle("SAVE CHANGES", for: .normal)
        }
    }

    
    // set Cuurent time on time edit text
    private func setTime (date : Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" // for specifying the change to format hour:minute am/pm.
        reminderTime = dateFormatter.string(from: date)
        btn_time.setTitle(reminderTime, for: .normal)
    }
    
    @objc private func dismissVC () {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func deleteReminder () {
//        if hkb_reminder != nil {
//            let alert = UIAlertController(title: "", message: "Are you sure you want to delete this reminder?", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {action in
//                self.hkb_reminder?.active = 0
//                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [String(describing: (self.hkb_reminder?.reminderId)!)])
//
//                self.myDelegate?.onReminderAdded()
//                DbController.saveContext()
//                self.navigationController?.popViewController(animated: true)
//            }))
//
//            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
    }
    
    @objc func saveReminder () {
        
        if Utils.validateString(vc: self, string: text_field_reminder_title.text!, errorMsg: "Please enter the reminder title") {
            let current = UNUserNotificationCenter.current()
            
            current.getNotificationSettings(completionHandler: { (settings) in
                if settings.authorizationStatus == .denied {
                    // Notification permission was previously denied, go to settings & privacy to re-enable
                    let alert = UIAlertController(title: "Application needs notification access", message: "In order to send you reminders, the application needs notification access", preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: {action in
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.openURL(url)
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                    
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }
                
                if settings.authorizationStatus == .authorized {
                    // Notification permission was already granted
                    if let reminder = self.hkb_reminder {
                        self.reminderDetails(reminder: reminder)
                    } else {
                        let reminder : Hkb_reminder = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_REMINDER, into: DbController.getContext()) as! Hkb_reminder
                        self.reminderDetails(reminder: reminder)
                    }
                    
                    self.myDelegate?.onReminderAdded()
                    DbController.saveContext()
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                }
            })
        }
    }
    
    private func reminderDetails (reminder : Hkb_reminder) {
        let date = Utils.convertStringToDate(dateString: reminderDate)
        let reminDate = Calendar.current.date(bySettingHour: hour, minute: min, second: 0, of: date)!
        let reminderDbDate = Utils.currentDateDbFormat(date: reminDate)
 

        reminder.title = text_field_reminder_title.text
        reminder.rmdate = reminderDbDate
        reminder.rmday = Utils.getDayMonthAndYear(givenDate: reminderDbDate, dayMonthOrYear: "day")
        reminder.rmmonth = Utils.getDayMonthAndYear(givenDate: reminderDbDate, dayMonthOrYear: "month")
        reminder.rmyear = Utils.getDayMonthAndYear(givenDate: reminderDbDate, dayMonthOrYear: "year")
        reminder.rmtime = reminderTime
        reminder.active = 1
        reminder.recurring = repeatInterval
//        reminder.reminderId = Int64(QueryUtils.getMaxReminderId() + 1)
        reminder.reminderId = Utils.getUniqueId()
        reminder.createdon = Utils.currentDateDbFormat(date: Date())
        reminder.rmweek = Utils.getDayMonthAndYear(givenDate: reminderDbDate, dayMonthOrYear: "day")

        if reminderType == Constants.EXPENSE {
            reminder.isexpense = 1
        } else if reminderType == Constants.INCOME {
            reminder.isexpense = 0
        } else if reminderType == Constants.TRANSFER {
            reminder.isexpense = 2
        } else {
            reminder.isexpense = 3
        }

        if hkb_reminder != nil {
            reminder.reminderId = (hkb_reminder?.reminderId)!
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [String(describing: (self.hkb_reminder?.reminderId)!)]) // remove existing reminder from notifying
        } else {
//            reminder.reminderId = Int64(QueryUtils.getMaxReminderId() + 1)
            reminder.reminderId = Utils.getUniqueId()
            
        }
        
        // if time is less than time = now()
        // increase by 1 second
        var timeInterval = reminDate.timeIntervalSinceNow
        if timeInterval < 0 {
            timeInterval = 1
        }

        let content = UNMutableNotificationContent()
        content.title = "Hysab Kytab"
        content.body = "You have a reminder for \(reminderType)"
        content.sound = UNNotificationSound.default
        
        if reminder.isexpense == 3 {
            content.body = "You have a reminder for: \(text_field_reminder_title.text!)"
        }

        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest.init(identifier: String(reminder.reminderId), content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print("Error : " , error)
        }
    }
    
    private func getTimeFromDate (date : Date) -> (String , Int , Int) {
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.hour, .minute], from: date)
        hour = comp.hour!
        min = comp.minute!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" // for specifying the change to format hour:minute am/pm.
        let dateInString = dateFormatter.string(from: date)
        return (dateInString , hour , min)
    }
    
    @objc private func onDateTapped () {
        isDateSelection = true
        let datePopup = DialogSelectDate()
        datePopup.myDelegate = self
        datePopup.dialogTitle = "Reminder Date"
        self.presentPopupView(popupView: datePopup)
    }
    
    @objc private func onReminderTimeTapped() {
        isDateSelection = false
        let dateDialog = DialogSelectDate()
        dateDialog.myDelegate = self
        dateDialog.dialogTitle = "Select Time"
        dateDialog.isDateSelection = false
        self.presentPopupView(popupView: dateDialog)
    }
    
    @objc private func onIntervalTapped () {
        let recurringIntervalPopup = RecurringReminderIntervalPopup()
        recurringIntervalPopup.delegate = self
        self.presentPopupView(popupView: recurringIntervalPopup)
    }
    

    @IBAction func onCreateTapped(_ sender: Any) {
        saveReminder()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        self.navigationItemColor = .dark
    }
   
    
}

extension AddReminderViewController : DateSelectionListener, IntervalListener, SegmentButtonTappedListener, UITextFieldDelegate {
    
    func onSegmentTapped(btnTitle: String) {
        reminderType = btnTitle
    }
    
    func onDateSelected(date: Date) {
        if isDateSelection {
            btn_date.setTitle(Utils.currentDateUserFormat(date: date), for: .normal)
            reminderDate = Utils.currentDateDbFormat(date: date)
        } else {
            self.time = date
            let calendar = Calendar.current
            let comp = calendar.dateComponents([.hour, .minute], from: self.time)
            hour = comp.hour!
            min = comp.minute!
            setTime(date: date)
        }
    }
    
    func onIntervalChanged(selectedInterval: String) {
        btn_interval.setTitle(selectedInterval, for: .normal)
        repeatInterval = selectedInterval
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
