
import UIKit
import FSCalendar

protocol DateSelectionListener {
    func onDateSelected (date: Date)
}

class DateSelectionPopup: BasePopup {

    @IBOutlet weak var label_popup_title: CustomFontLabel!
    @IBOutlet weak var calendar_view: FSCalendar!
    @IBOutlet weak var popup_view: CardView!
    
    public var selectedDate : Date?
    public var disableBackdate = false
    public var delegate : DateSelectionListener?
    public var popupTitle = "Transaction Date"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        configureIfDateSelected()
    }
    
    private func initVariables () {
        calendar_view.dataSource = self
    }
    
    private func initUI () {
        self.label_popup_title.text = popupTitle
    }
    
    private func configureIfDateSelected () {
        if let date = selectedDate {
            calendar_view.select(date)
        } else {
            calendar_view.select(Date())
        }
    }
    
    @IBAction func onCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onApplyTapped(_ sender: Any) {
        delegate?.onDateSelected(date: calendar_view.selectedDate!)
        self.dismiss(animated: true, completion: nil)
    }
    

}

extension DateSelectionPopup : FSCalendarDataSource {
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let currentDate: NSDate = NSDate()
        let components: NSDateComponents = NSDateComponents()
        
        components.year = -200
        let minDate: NSDate = gregorian.date(byAdding: components as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))! as NSDate
        
        if !disableBackdate {
            return minDate as Date
        } else {
            return Date()
        }
    }
}
