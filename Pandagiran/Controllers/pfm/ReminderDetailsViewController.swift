

import UIKit
import FSCalendar
import UserNotifications

class ReminderDetailsViewController: BaseViewController , UITableViewDelegate , UITableViewDataSource , FSCalendarDelegate , FSCalendarDataSource , ReminderAddedListener {

    @IBOutlet weak var view_placeholder: UIView!
    @IBOutlet weak var view_create: CardView!
    @IBOutlet weak var reminderTableHeight: NSLayoutConstraint!
    @IBOutlet weak var calendar_view: FSCalendar!
    @IBOutlet weak var table_view: UITableView!
    @IBOutlet weak var label_placeholder: UILabel!
    
    var arrayOfReminders : Array<Hkb_reminder> = []

    
    override func viewWillAppear(_ animated: Bool) {
           fetchAllReminders()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

     
        initVariables()
        initUI()
        setMarkersOnCalendar()
    }
    
    func initVariables () {
        calendar_view.allowsMultipleSelection = true
        calendar_view.allowsSelection = false
        calendar_view.delegate = self
        calendar_view.dataSource = self
        
        let reminderNib = UINib(nibName: "ActivityViewCell", bundle: nil)
        let transferNib = UINib(nibName: "TransferViewCell", bundle: nil)
        table_view.register(reminderNib, forCellReuseIdentifier: "ActivityViewCell")
        table_view.register(transferNib, forCellReuseIdentifier: "TransferViewCell")
        
        table_view.delegate = self
        table_view.dataSource = self
    }
    
    private func initUI () {
        self.navigationItem.title = "Reminders"
        table_view.estimatedRowHeight = 80
        
        calendar_view.layer.cornerRadius = 2.0
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_help"), style: .plain, target: self, action: #selector(showHelpDialog))
        
        let createTapGest = UITapGestureRecognizer(target: self, action: #selector(onCreateTapped))
        view_create.addGestureRecognizer(createTapGest)
    }
    
    private func fetchAllReminders () {
        arrayOfReminders.removeAll()
        arrayOfReminders = ReminderUtils.fetchAllReminders()
        self.table_view.reloadData()
        
        showPlaceHolder()
    }
    
    private func setMarkersOnCalendar () {
        for i in 0 ..< arrayOfReminders.count {
            let date : Date = Utils.convertStringToDate(dateString: arrayOfReminders[i].rmdate!)
            let newDate = Calendar.current.date(byAdding: .month, value: 1, to: date)
            calendar_view.select(newDate)
        }
    }
    
    func navigateToAddReminderVC (categoryType : String) {
        let storyboard = UIUtils.getStoryboard(name: Constants.SB_MAIN)
        let dest = storyboard.instantiateViewController(withIdentifier: "AddReminderVC") as! AddReminderViewController
        dest.reminderType = categoryType
        dest.myDelegate = self
        self.navigationController?.pushViewController(dest, animated: true)
    }
    
    private func navigateToTransferReminderVC () {

    }
    
    private func showPlaceHolder () {
        if arrayOfReminders.count == 0 {
            view_placeholder.isHidden = false
        } else {
            view_placeholder.isHidden = true
        }
    }
    
    @objc private func showHelpDialog () {
        let alert = UIAlertController(title: "Reminders", message: Constants.REMINDER_HELP, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // CUSTOM DELEGATES
    func onReminderAdded() {
        arrayOfReminders = ReminderUtils.fetchAllReminders()
        DispatchQueue.main.async {
            self.table_view.reloadData()
        }
//        showPlaceHolder() // if array count is zero
    }
    
    @objc private func onCreateTapped () {
        let createReminderVC = getStoryboard(name: ViewIdentifiers.SB_REMINDER).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_REMINDER) as! AddReminderViewController
        let navController = UINavigationController()
        navController.viewControllers = [createReminderVC]
        self.present(navController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfReminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reminder = arrayOfReminders[indexPath.row]
        let date = Utils.convertStringToDate(dateString: reminder.rmdate!)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityViewCell") as! ActivityViewCell
        
        //            let category = QueryUtils.fetchSingleCategory(categoryId: Int(arrayOfReminders[indexPath.row].categoryId))
        //            cell.tv_description.text = category.title
        cell.tv_category.text = reminder.title
        cell.tv_day.text = String(arrayOfReminders[indexPath.row].rmday)
        cell.tv_date.text = Utils.getMonthFromInt(num: Int(reminder.rmmonth) - 1)
        cell.tv_year.text = String(reminder.rmyear)
        UIUtils.activitiesBgColor(view: cell.date_bg, currentInterval: Constants.ALL_TIME, monthOrDay: Int(reminder.rmmonth))
        cell.tv_description.text = reminder.recurring!
        cell.label_time.text = Utils.getTimeString(date: date)
        
        cell.btn_menu.tag = indexPath.row
        cell.btn_menu.addTarget(self, action: #selector(onReminderItemMenuTapped), for: .touchUpInside)
        
        
        reminderTableHeight.constant = tableView.contentSize.height
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dest = getStoryboard(name: ViewIdentifiers.SB_REMINDER).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_REMINDER) as! AddReminderViewController
        dest.hkb_reminder = arrayOfReminders[indexPath.row]
        dest.myDelegate = self
        
        self.navigationController?.pushViewController(dest, animated: true)
    }
 
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let calendarDate = Utils.currentDateReminderFormat(date: date)
        return ReminderUtils.fetchReminderCountByDate(date: calendarDate)
    }
    
    @objc private func onReminderItemMenuTapped (sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Edit", style: UIAlertAction.Style.default, handler: {action in
            let index = sender.tag
            let addReminderVC = self.getStoryboard(name: ViewIdentifiers.SB_REMINDER).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_REMINDER) as! AddReminderViewController
            addReminderVC.hkb_reminder = self.arrayOfReminders[index]
            self.navigationController?.pushViewController(addReminderVC, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.default, handler: {action in
            let reminder = self.arrayOfReminders[sender.tag]
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [String(describing: (reminder.reminderId))])
            DbController.getContext().delete(reminder)
            DbController.saveContext()
            UIUtils.showSnackbar(message: "Reminder deleted successfully")
            self.arrayOfReminders.remove(at: sender.tag)
            self.table_view.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
