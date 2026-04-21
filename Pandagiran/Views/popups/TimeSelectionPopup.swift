
import UIKit

class TimeSelectionPopup: BasePopup {

    @IBOutlet weak var label_select_time: UILabel!
    @IBOutlet weak var time_picker: UIDatePicker!
    @IBOutlet weak var btn_ok: UIButton!
    @IBOutlet weak var btn_cancel: UIButton!
    @IBOutlet weak var popup_view: CardView!
    
    public var delegate : DateSelectionListener?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        if #available(iOS 13.4, *) {
            self.time_picker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
            print("Do Nothing")
        }
    }

    private func initUI () {
        animateView(popup_view: popup_view)
        label_select_time.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        btn_ok.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        btn_cancel.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
    }

    @IBAction func onOkTapped(_ sender: Any) {
        delegate?.onDateSelected(date: time_picker.date)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
