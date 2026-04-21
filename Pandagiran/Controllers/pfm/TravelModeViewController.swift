

import UIKit
import Firebase
import SwiftyJSON


class TravelModeViewController: BaseViewController , DateSelectionListener , CurrencySelectionListener , UITextFieldDelegate {

    @IBOutlet weak var view_travelling_from: CardView!
    @IBOutlet weak var btn_enable: GradientButton!
    @IBOutlet weak var view_end_date: CardView!
    @IBOutlet weak var view_start_date: CardView!
    @IBOutlet weak var view_travelling_to: CardView!
    @IBOutlet weak var view_travel_mode: UIView!
    @IBOutlet weak var view_placeholder: UIView!
    @IBOutlet weak var label_travelling_to: UILabel!
    @IBOutlet weak var label_travelling_to_country: UILabel!
    @IBOutlet weak var label_travelling_from: UILabel!
    @IBOutlet weak var label_travelling_from_country: UILabel!
    @IBOutlet weak var btn_start_date: UIButton!
    @IBOutlet weak var btn_end_date: UIButton!
    @IBOutlet weak var label_conversion_rate: UILabel!
    private let switch_travel_mode = UISwitch()
    private let label_switch_text = UILabel()
    
    var isStartDate = true
    var startDate : Date?
    var endDate : Date?
    var actualConversionRate : Double = 0
    var currencyTo : String = ""
    var currencyArray : Array<UserCurrency> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()
        addTapGestureToView()
        addSwitchViewOnNavigation()
    }
    

    private func initVariables () {
        fetchCurrencies()
        
        
        switch_travel_mode.addTarget(self, action: #selector(travelSwitchToggle), for: UIControl.Event.valueChanged)
        
        startDate = Date()
        endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate!)!
        btn_start_date.setTitle(Utils.currentDateUserFormat(date: startDate!), for: .normal)
        btn_end_date.setTitle(Utils.currentDateUserFormat(date: endDate!), for: .normal)
        
    }
    
    func initUI () {
//        self.navigationController?.navigationBar.isHidden = true
        view_travelling_from.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        view_travelling_to.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        switch_travel_mode.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
        self.navigationItem.title = "Travel Mode"
    
        label_travelling_from.text = LocalPrefs.getUserCurrency()
        for i in 0 ..< currencyArray.count {
            if currencyArray[i].currency3dg! == LocalPrefs.getUserCurrency() {
                label_travelling_from_country.text = currencyArray[i].currencyName
            }
        }
        
        if LocalPrefs.getIsTravelMode() {
            btn_enable.isHidden = true
            switch_travel_mode.isOn = true
            view_travel_mode.isHidden = false
            view_placeholder.isHidden = true
            label_switch_text.text = "On"
        
            
            let startDate = Utils.convertStringToDate(dateString: LocalPrefs.getTravelModeDetails()[Constants.TRAVEL_START_DATE]!)
            let endDate = Utils.convertStringToDate(dateString: LocalPrefs.getTravelModeDetails()[Constants.TRAVEL_END_DATE]!)
            label_travelling_to.text = LocalPrefs.getTravelModeDetails()[Constants.TRAVEL_CURRENCY_TO]
            label_travelling_to_country.text = LocalPrefs.getTravelModeDetails()[Constants.TRAVEL_TRAVEL_TO]
//            et_travelling_to.text = LocalPrefs.getTravelModeDetails()[Constants.TRAVEL_TRAVEL_TO]
            actualConversionRate = Double(LocalPrefs.getTravelModeDetails()[Constants.TRAVEL_CONVERSION_RATE]!)!
            currencyTo = LocalPrefs.getTravelModeDetails()[Constants.TRAVEL_CURRENCY_TO]!
            self.label_conversion_rate.text = "1 \(self.currencyTo) = \(Utils.formatDecimalNumber(number: self.actualConversionRate, decimal: 2)) \(LocalPrefs.getUserCurrency())"
            btn_start_date.setTitle(Utils.currentDateUserFormat(date: startDate), for: .normal)
            btn_end_date.setTitle(Utils.currentDateUserFormat(date: endDate), for: .normal)
        } else {
            btn_enable.isHidden = true
            label_switch_text.text = "Off"
            view_placeholder.isHidden = false
            view_travel_mode.isHidden = true
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func addSwitchViewOnNavigation () {
        let height = self.navigationController?.navigationBar.frame.height
        let viewSwitch = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: height!))
        viewSwitch.backgroundColor = .clear
        
        label_switch_text.frame = CGRect(x: 0, y: 0, width: 40, height: viewSwitch.frame.height)
        label_switch_text.font.withSize(12.0)
        label_switch_text.textColor = .white
        label_switch_text.text = "Off"
        
        switch_travel_mode.frame = CGRect(x: 35, y: 10, width: 50, height: 50)
        switch_travel_mode.thumbTintColor = .white
        switch_travel_mode.tintColor = .white
        switch_travel_mode.onTintColor = UIColor().hexCode(hex: Style.color.PRIMARY_COLOR)
//        switch_travel_mode.center.y = viewSwitch.frame.height / 2
        
        viewSwitch.addSubview(switch_travel_mode)
        viewSwitch.addSubview(label_switch_text)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: viewSwitch)
    }
    
    
    @objc func travelSwitchToggle () {
        if switch_travel_mode.isOn {
            self.view_travel_mode.isHidden = false
            label_switch_text.text = "On"
            btn_enable.isHidden = false
            view_placeholder.isHidden = true
        } else {
            if LocalPrefs.getIsTravelMode() {
                let alert = UIAlertController(title: "", message: "Do you really want to disable travel mode?", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {action in
                    LocalPrefs.setIsTravelMode(isTravelModeOn: false)
                    LocalPrefs.setTravelModeDetails(travelModeDetails: [:])
                    self.view_travel_mode.isHidden = true
                    self.label_switch_text.text = "Off"
                    self.emptyView()
                    self.btn_enable.isHidden = true
                    self.view_placeholder.isHidden = false
                }))
      
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
                    self.switch_travel_mode.isOn = true
                    self.view_placeholder.isHidden = true
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.view_travel_mode.isHidden = true
                label_switch_text.text = "Off"
                btn_enable.isHidden = true
                emptyView()
                view_placeholder.isHidden = false
            }
        }
    }
    
    func emptyView () {
//        label_travelling_to.text = ""
        label_conversion_rate.text = ""
        label_travelling_to.text = "---"
        label_travelling_to_country.text = "TAP TO SELECT CURRENCY"
    }
    
    private func enableTravelMode () {
        let validation = Validation.shared.validate(values: (ValidationType.travelCurrency, label_travelling_to.text!), (ValidationType.conversionRate, label_conversion_rate.text!))
        
        switch validation {
        case .success:
            let travelModeDetails : [String : String] =
                                                        [Constants.TRAVEL_START_DATE :   Utils.currentDateDbFormat(date:                                                          startDate!) ,
                                                         Constants.TRAVEL_END_DATE : Utils.currentDateDbFormat(date: endDate!) ,
                                                         Constants.TRAVEL_CONVERSION_RATE : String(actualConversionRate),
                                                         Constants.TRAVEL_TRAVEL_TO : label_travelling_to.text!,
                                                         Constants.TRAVEL_CURRENCY_TO : currencyTo,
                                                         Constants.TRAVEL_CURRENCY_FROM : LocalPrefs.getUserCurrency()]
            LocalPrefs.setIsTravelMode(isTravelModeOn: true)
            LocalPrefs.setTravelModeDetails(travelModeDetails: travelModeDetails)
            UIUtils.showSnackbar(message: "Travel mode turned on")
            self.navigationController?.popViewController(animated: true)
        case .failure(_ , let message):
            UIUtils.showAlert(vc: self, message: message.localized())
        }
    }
    
    func fetchCurrencyConversionRate (currencyToConvertIn : String) {
        UIUtils.showLoader(view: self.view)
        var currencyToConvert : Double = 0
        var baseCurrency : Double = 0
        
        Database.database().reference().child("currency").observeSingleEvent(of: .value) { (snapshot) in
            currencyToConvert = snapshot.childSnapshot(forPath: "USD\(currencyToConvertIn)").value as! Double
            
            Database.database().reference().child("currency").observeSingleEvent(of: .value, with: { (snapshot) in
                UIUtils.dismissLoader(uiView: self.view)
                baseCurrency = snapshot.childSnapshot(forPath: "USD\(LocalPrefs.getUserCurrency())").value as! Double
                
                
                self.actualConversionRate = (baseCurrency / currencyToConvert)
                self.label_conversion_rate.text = "1 \(self.currencyTo) = \(Utils.formatDecimalNumber(number: self.actualConversionRate, decimal: 4)) \(LocalPrefs.getUserCurrency())"
            })
        }
    }
    
    func addTapGestureToView () {
        let tap = UITapGestureRecognizer(target: self, action: #selector(showCurrencyDialog(sender:)))
        view_travelling_to.addGestureRecognizer(tap)
        
        let startDateTap = UITapGestureRecognizer(target: self, action: #selector(onStartDateTapped))
        view_start_date.addGestureRecognizer(startDateTap)
        
        let endDateTap = UITapGestureRecognizer(target: self, action: #selector(onEndDateTapped))
        view_end_date.addGestureRecognizer(endDateTap)
    }
    
    func fetchCurrencies() {
        let jsonObj = Utils.readJson(resourceName: "core_country")
        
        for currency in jsonObj{
            let objc = JSON(currency)
            let urlCode = objc["iso_code_2dg"].stringValue
            let currencyObj = UserCurrency()
            currencyObj.currency3dg = objc["iso_code_3dg"].stringValue
            currencyObj.currencyFlag = "http://bo.hysabkytab.com/HK_data_pics/country_flags/\(urlCode.lowercased()).png"
            currencyObj.currencyName = objc["country_name"].stringValue
            currencyArray.append(currencyObj)
        }
    }
    
    @objc func showCurrencyDialog (sender : UITapGestureRecognizer) {
        let currencyVC = getStoryboard(name: ViewIdentifiers.SB_ACCOUNT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SELECT_CURRENCY) as! AccountCurrencyViewController
        currencyVC.myDelegate = self
        self.navigationController?.pushViewController(currencyVC, animated: true)
    }
    
    func showDateDialog (date : Date?) {
        let dateDialog = DialogSelectDate()
        dateDialog.modalPresentationStyle = .overCurrentContext
        dateDialog.myDelegate = self
        dateDialog.isTravelMode = true
        dateDialog.date = date
        dateDialog.customDate = date
        self.presentPopupView(popupView: dateDialog)
    }
    
    @IBAction func onStartDateTapped(_ sender: Any) {
        isStartDate = true
        showDateDialog(date: Date())
    }
    
    @objc private func onEndDateTapped() {
        isStartDate = false
        showDateDialog(date: startDate)
    }
    
    @objc private func onBackTapped() {
        self.dismiss(animated: false, completion: nil)
    }
    
    func onDateSelected(date: Date) {
        let userFormatDate = Utils.currentDateUserFormat(date: date)
        if isStartDate {
            startDate = date
            btn_start_date.setTitle(userFormatDate, for: .normal)
            print("Start date : " , Utils.currentDateUserFormat(date: startDate!))
        } else {
            btn_end_date.setTitle(userFormatDate, for: .normal)
        }
    }
    
    func onCurrencySelected(currency: String, country2dg: String, currencyFlag: String, countryName: String , decimal: Int) {
        if currency != LocalPrefs.getUserCurrency() {
            currencyTo = currency
            label_travelling_to.text = currency
            label_travelling_to_country.text = countryName
            fetchCurrencyConversionRate(currencyToConvertIn: currency)
        } else {
            UIUtils.showAlert(vc: self, message: "Currency travelling from can not be same as currency travelling to.")
        }
    
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func onTravelModeSetTapped(_ sender: Any) {
        if Utils.validateString(vc: self, string: currencyTo, errorMsg: "Please select the country you're travelling to") {
            enableTravelMode()
        }
    }
    
}

