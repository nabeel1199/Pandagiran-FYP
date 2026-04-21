

import UIKit

class DialogSelectDate: BasePopup {

    @IBOutlet weak var date_picker: UIDatePicker!
    @IBOutlet weak var label_select_date: UILabel!
    
    var isTravelMode = false
    public var dialogTitle = "Select Date"
    
    var date : Date?
    var customDate : Date?
    var isDateSelection = true
    var myDelegate : DateSelectionListener?
    var disableBackdate : Bool = false
    var disableFutureDate : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVariables()
        initUI()
        disablePreviousDate()
        if #available(iOS 13.4, *) {
            self.date_picker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
            print("Do Nothing")
        }
        
    }
    
    func initVariables () {
        if !isDateSelection {
            date_picker.datePickerMode = .time
//            date_picker.minimumDate = Date()
        } else {
            let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
            let currentDate: NSDate = NSDate()
            let components: NSDateComponents = NSDateComponents()
            
            components.year = -100
            let minDate: NSDate = gregorian.date(byAdding: components as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))! as NSDate
            
            
            date_picker.datePickerMode = UIDatePicker.Mode.date
            
            if !disableBackdate {
                date_picker.minimumDate = minDate as Date
            } else {
                date_picker.minimumDate = Date()
            }
            
            if disableFutureDate{
                date_picker.maximumDate = Date()
            }
            
            if let date = customDate {
                date_picker.setDate(customDate!, animated: true)
            }
            
            date = date_picker.date
        }
    }
    
    private func initUI () {
        label_select_date.text = dialogTitle
    }
    
    func disablePreviousDate () {
        if isTravelMode {
            if let newDate = date {
                date_picker.minimumDate = newDate
                print("Start Date : " , Utils.currentDateUserFormat(date: newDate))
            }
        }
    }
    
    @IBAction func okOkTapped(_ sender: Any) {
//        if !isDateSelection {
//            let date = date_picker.date
//            let calendar = Calendar.current
//            let comp = calendar.dateComponents([.hour, .minute], from: date)
//            let hour = comp.hour
//            let minute = comp.minute
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "hh:mm a" // for specifying the change to format hour:minute am/pm.
//            let dateInString = dateFormatter.string(from: date)
//            print("HOUR : " , dateInString)
//        } else {
            myDelegate?.onDateSelected(date: date_picker.date)
            self.dismiss(animated: true, completion: nil)
//        }
    }

    
    @IBAction func onCloseTapped(_ sender: Any) {
          self.dismiss(animated: true, completion: nil)
    }
}
