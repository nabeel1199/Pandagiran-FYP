
import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class AddEventViewController: BaseViewController {

    
    @IBOutlet weak var btn_create_event: GradientButton!
    @IBOutlet weak var label_notify: UILabel!
    @IBOutlet weak var label_limit_heading: UILabel!
    @IBOutlet weak var label_description: UITextField!
    @IBOutlet weak var label_desc_heading: UILabel!
    @IBOutlet weak var label_end_date: UILabel!
    @IBOutlet weak var label_end_date_heading: UILabel!
    @IBOutlet weak var label_start_date: UILabel!
    @IBOutlet weak var label_start_date_heading: UILabel!
    @IBOutlet weak var text_field_event_name: UITextField!
    @IBOutlet weak var label_event_heading: UILabel!
    @IBOutlet weak var view_start_date: CardView!
    @IBOutlet weak var text_field_event_title: UITextField!
    @IBOutlet weak var view_end_date: CardView!
    @IBOutlet weak var text_field_description: UITextField!
    @IBOutlet weak var label_currency: UILabel!
    @IBOutlet weak var text_field_amount: AmountEnterTextField!
    
    private var isStartDate = true
    private var startDate : Date?
    private var endDate : Date?
    
    
    public var editEvent : Hkb_event?
    public var eventTitle = ""
    
    
    override func viewDidLoad() {

        initVariables()
        initUI()
        editEventDetails()
    }
    
    private func initVariables () {
        let startDateString = Utils.currentDateDbFormat(date: Date())
        startDate = Utils.formatDateExcludingTime(dateString: startDateString)
        let endDatetring = Utils.currentDateDbFormat(date: Calendar.current.date(byAdding: .day, value: 7, to: startDate!)!)
        endDate = Utils.formatDateExcludingTime(dateString: endDatetring)

        
        text_field_amount.delegate = self
        text_field_event_title.delegate = self
        text_field_description.delegate = self
        text_field_amount.delegate = self
    }
    
    private func initUI () {
        label_currency.text = LocalPrefs.getUserCurrency()
        self.navigationItemColor = .light
        self.navigationItem.title = "Add Event"
        
        text_field_event_name.text = eventTitle
        label_start_date.text = Utils.currentDateUserFormat(date: startDate!)
        label_end_date.text = Utils.currentDateUserFormat(date: endDate!)
        
        let rightNavIcon = UIBarButtonItem(image: UIImage(named: "ic_clear"), style: .plain, target: self, action: #selector(onRightIconTapped))
        self.navigationItem.rightBarButtonItem = rightNavIcon
        
        let dateTapGest = UITapGestureRecognizer(target: self, action: #selector(onStartDateTapped))
        view_start_date.addGestureRecognizer(dateTapGest)
        
        let endDateTap = UITapGestureRecognizer(target: self, action: #selector(onEndDateTapped))
        view_end_date.addGestureRecognizer(endDateTap)
        
        label_event_heading.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        text_field_event_name.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_start_date_heading.headingFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        label_start_date.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_end_date_heading.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        label_end_date.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_desc_heading.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        label_description.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_limit_heading.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        text_field_amount.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_currency.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        btn_create_event.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
    }
    
    private func editEventDetails () {
        if let event = editEvent {
            startDate = Utils.convertStringToDate(dateString: event.startdate!)
            endDate = Utils.convertStringToDate(dateString: event.enddate!)
            text_field_event_name.text = event.name!
            text_field_description.text = event.desc!
            label_start_date.text = Utils.currentDateUserFormat(date: startDate!)
            label_end_date.text = Utils.currentDateUserFormat(date: endDate!)

            btn_create_event.setTitle("UPDATE EVENT", for: .normal)
            self.navigationItem.title = "Edit Event"
        }
    }
    
    private func eventDetails (event: Hkb_event) {
        let eventStartDate = Calendar.current.date(bySettingHour: 0 , minute: 0 , second:  0, of: startDate!)
        let eventEndDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: endDate!)
        event.name = text_field_event_name.text
        event.desc = text_field_description.text
        event.startdate = Utils.currentDateDbFormat(date: eventStartDate!)
        event.enddate = Utils.currentDateDbFormat(date: eventEndDate!)
//        event.eventid = Int64(QueryUtils.getMaxEventId())
//        event.eventid = Utils.getUniqueId()
        event.active = 1
        
        if editEvent == nil {
//            event.eventid = Int64(QueryUtils.getMaxEventId() + 1)
            event.eventid = Utils.getUniqueId()
        } else {
            event.eventid = editEvent?.eventid ?? Utils.getUniqueId()
        }
    }
    
    @objc private func saveEvent () {
        if Utils.validateString(vc: self, string: text_field_event_name.text!, errorMsg: "Please enter the event name") {
            if let existingEvent = editEvent {
                eventDetails(event: existingEvent)
                if QueryUtils.getEventSync(eventId: existingEvent.eventid) == 1{
                    postEventToServer(event: existingEvent, isUpdate: true)
                } else {
                    existingEvent.is_synced = 0
                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                }
                
            } else {
                let newEvent : Hkb_event = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_EVENT, into: DbController.getContext()) as! Hkb_event
                eventDetails(event: newEvent)
                postEventToServer(event: newEvent, isUpdate: false)
                
               
            }
            
//            self.myDelegate?.onEventAdded()
            DbController.saveContext()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func postEventToServer (event : Hkb_event, isUpdate : Bool) {
        let eventDetails = Utils.convertVchIntoDict(object: event)
        let eventsJson = Utils.convertDictIntoJson(object: eventDetails)
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        var URL = "\(Constants.BASE_URL)/event/save"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        
        var httpMethod = Alamofire.HTTPMethod.post
        let dictToEncrypt =  ["events" : eventsJson,
                              "device_type" : "Ios",
                              "consumer_id" : consumerId]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        if isUpdate {
            URL = "\(Constants.BASE_URL)/event/update"
            httpMethod = Alamofire.HTTPMethod.post
        }
        
        Alamofire.request(URL, method: httpMethod, parameters: params, encoding: URLEncoding.httpBody , headers : headers)
            .responseJSON { response in
                print("Response : " , response)
                switch response.result {
                case .success:
                    let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    print("ResponseStatus : " , status,  message)
                    if status == 1 {
                            event.is_synced = 1
                    } else {
                        event.is_synced = 0
                        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    }
                    
                    DbController.saveContext()
                    
                case .failure(let error):
                    event.is_synced = 0
                    DbController.saveContext()
                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
//                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
    }
    
    private func showDateDialog() {
        let datePopup = DialogSelectDate()
        datePopup.myDelegate = self
        datePopup.dialogTitle = "Event Date"
        datePopup.disableBackdate = true
        self.presentPopupView(popupView: datePopup)
    }
    
    @IBAction func onCreateEventTapped(_ sender: Any) {
        saveEvent()
    }
    
    @objc private func onRightIconTapped () {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func onStartDateTapped () {
        isStartDate = true
        showDateDialog()
    }
    
    @objc private func onEndDateTapped () {
        isStartDate = false
        showDateDialog()
    }
}

extension AddEventViewController: UITextFieldDelegate, DateSelectionListener {
    
    
    func onDateSelected(date: Date) {
        let userFormatDate = Utils.currentDateUserFormat(date: date)
        if isStartDate {
            startDate = Utils.formatDateExcludingTime(dateString: Utils.currentDateDbFormat(date: date))
            label_start_date.text = userFormatDate
        } else {
            endDate = Utils.formatDateExcludingTime(dateString: Utils.currentDateDbFormat(date: date))
            label_end_date.text = userFormatDate
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        switch textField {
        case text_field_event_title:
            text_field_description.becomeFirstResponder()
            break
        case text_field_description:
            text_field_amount.becomeFirstResponder()
        default:
            print("Nothing")
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == text_field_amount {
            self.animateTextField(up: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField == text_field_amount {
            self.animateTextField(up: false)
        }
    }
}
