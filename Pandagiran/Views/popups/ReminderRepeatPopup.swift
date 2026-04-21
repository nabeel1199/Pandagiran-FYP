

import UIKit

class ReminderRepeatPopup: BasePopup {

    @IBOutlet weak var popup_view: CardView!
    @IBOutlet weak var label_select_day: CustomFontLabel!
    @IBOutlet weak var picker_view: UIPickerView!
    
    public var isMonthly = false
    private var arrayOfDays: Array<Int> = []
    public var delegate : ReminderFrequencyListener?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI ()
        fetchDays()
    }

    private func initVariables () {
        picker_view.delegate = self
        picker_view.dataSource = self
    }
    
    private func initUI () {
        self.animateView(popup_view: popup_view)
    }
    
    private func fetchDays () {
        if isMonthly {
            for i in 1 ... 31 {
                arrayOfDays.append(i)
            }
        } else {
            for i in 1 ... 7 {
                arrayOfDays.append(i)
            }
        }
        
        picker_view.selectRow(4, inComponent: 0, animated: true)
    }

    @IBAction func onOkTapped(_ sender: Any) {
        let index = picker_view.selectedRow(inComponent: 0)
        if isMonthly {
            let repeatTitle = "\(Utils.getDaySuffix(day: String(index + 1))) of every month"
            delegate?.onFrequencySelected(repeatInterval: "Monthly", repeatTitle: repeatTitle, day: arrayOfDays[index])
        } else {
            let repeatTitle = "Every \(Utils.reminderDays[arrayOfDays[index]]!)"
            delegate?.onFrequencySelected(repeatInterval: "Weekly", repeatTitle: repeatTitle, day: arrayOfDays[index])
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension ReminderRepeatPopup : UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrayOfDays.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if isMonthly {
            return Utils.getDaySuffix(day: String(arrayOfDays[row]))
        } else {
            return Utils.reminderDays[arrayOfDays[row]]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
}

