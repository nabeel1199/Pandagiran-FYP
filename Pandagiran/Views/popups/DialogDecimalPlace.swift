

import UIKit
import Firebase

class DialogDecimalPlace: BasePopup , UIPickerViewDelegate , UIPickerViewDataSource  {

    @IBOutlet weak var picker_view: UIPickerView!
    
    let pickerData = ["0" , "1" , "2" , "3"]
    var selectedItem : Int?
    var myDelegate : FormatUpdateListener?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVariables()
    }
    
    func initVariables () {
        selectedItem = LocalPrefs.getDecimalFormat()
        
        picker_view.delegate = self
        picker_view.dataSource = self
        
        picker_view.selectRow(LocalPrefs.getDecimalFormat(), inComponent: 0, animated: true)
    }
    
    @IBAction func onSelectTapped(_ sender: Any) {
        LocalPrefs.setDecimalFormat(decimalFormat: self.selectedItem!)
        self.myDelegate?.onFormatUpdated(format: self.selectedItem!)
        self.dismiss(animated: true, completion: nil)
    
        
    }
    
    @IBAction func onCloseTapped(_ sender: Any) {
              self.dismiss(animated: true, completion: nil)
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedItem = Int(pickerData[row])
        Analytics.logEvent("decimal_format", parameters: ["format" : Int(pickerData[row])])
        

    }
}
