

import UIKit
import GoogleMaps
import GooglePlacePicker
import CoreLocation
import Alamofire
import SwiftyJSON
import CoreData
import FirebaseAnalytics
import Lightbox
import UserNotifications

class TransactionDetailsViewController: BaseViewController {
    
    @IBOutlet weak var iv_category: TintedImageView!
    @IBOutlet weak var btn_preview: UIButton!
    @IBOutlet weak var btn_remove: UIButton!
    @IBOutlet weak var view_finish: GradientView!
    @IBOutlet weak var view_add_another: GradientView!
    @IBOutlet weak var btn_finish: GradientButton!
    @IBOutlet weak var btn_add_another: GradientButton!
    @IBOutlet weak var label_additional: UILabel!
    @IBOutlet weak var label_category: UILabel!
    @IBOutlet weak var label_account: UILabel!
    @IBOutlet weak var label_amount: UILabel!
    @IBOutlet weak var text_field_description: UITextField!
    @IBOutlet weak var stack_view_details: UIStackView!
    @IBOutlet weak var view_date: UIView!
    @IBOutlet weak var view_description: UIView!
    @IBOutlet weak var view_add_tags: UIView!
    @IBOutlet weak var view_location: UIView!
    @IBOutlet weak var view_receipt: UIView!
    @IBOutlet weak var view_event: UIView!
    @IBOutlet weak var view_recurring: UIView!
    @IBOutlet weak var btn_date: UIButton!
    @IBOutlet weak var btn_description: UIButton!
    @IBOutlet weak var btn_location: UIButton!
    @IBOutlet weak var btn_receipt: UIButton!
    @IBOutlet weak var btn_event: UIButton!
    @IBOutlet weak var btn_recurring: UIButton!
    @IBOutlet weak var btn_tags: UIButton!
    @IBOutlet weak var view_transaction_details: CardView!

    private var vchDate = ""
    private let border = CALayer()
    private var locationManager = CLLocationManager()
    private let imagePicker = UIImagePickerController()
    private var selectedPlace = ""
    private var placeType = ""
    private var eventId: Int64 = 0
    private var eventName = ""
    private var vchImage = ""
    private var vchTags = ""
    private var isRecurring = false
    private var reminderDay = 0
    private var repeatInterval = ""
    private var reminderDate = Date()
    private var tagsArray : [String] = []
    private var imgData : Data? = nil
    private var imageFileName = ""
    
    public var vchType = "Expense"
    public var accountId: Int64 = 0
    public var accountToId: Int64 = 0
    public var categoryId: Int64 = 0
    public var vchAmount: Double = 0
    public var viewVoucher: Hkb_voucher?
    public var editVoucher: Hkb_voucher?
    public var editVoucher2: Hkb_voucher?
    public var accountName = ""
    public var categoryName = ""
    public var accountToName = ""
    public var useCaseType = ""
    public var showViewMode = false
    public var vchCurrency = LocalPrefs.getUserCurrency()
    public var addAnotherDelegate : TransactionAddAnotherListener?


    
    override func viewDidAppear(_ animated: Bool) {
        
        populateTransactionData()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()
    
    }
    
    
    private func initVariables () {
        imagePicker.delegate = self
//        print(Utils.formatStringDate(dateString: viewVoucher?.vch_date ?? Utils.currentDateUserFormat(date: Date())))
        vchDate =  Utils.formatStringDate(dateString: editVoucher?.vch_date ?? viewVoucher?.vch_date ?? Utils.currentDateUserFormat(date: Date()))
        text_field_description.delegate = self
    }
    
    private func initUI () {
        text_field_description.attributedPlaceholder =
            NSAttributedString(string: "Add description", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        btn_date.setTitle(Utils.formatStringDate(dateString: editVoucher?.vch_date ?? viewVoucher?.vch_date ?? Utils.currentDateUserFormat(date: Date())), for: .normal)
        
        btn_remove.isHidden = true
        
        
        self.navigationItem.title = "Transaction Details"
        
        label_additional.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        label_category.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        label_account.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_amount.regularFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        btn_date.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        text_field_description.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        btn_location.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        btn_receipt.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        btn_event.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        btn_recurring.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        btn_add_another.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        btn_finish.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        
    }
    
    private func populateTransactionData () {
        // If open in view mode
        if let voucher = viewVoucher {
            editVoucher = voucher
            fetchVoucherDetails(voucher: voucher)
            populateViewModeCardData(voucher: voucher)
            view_finish.isHidden = true
            view_add_another.isHidden = true
            self.stack_view_details.isUserInteractionEnabled = false
            let navIconDelete = UIBarButtonItem(image: UIImage(named: "ic_delete"), style: .plain, target: self, action: #selector(onDeleteTapped))
            let navIconEdit = UIBarButtonItem(image: UIImage(named: "ic_edit"), style: .plain, target: self, action: #selector(onEditTapped))
            self.navigationItem.rightBarButtonItems = [navIconDelete, navIconEdit]
        }
        
        else
        
        {
            if let voucher = editVoucher {
                btn_finish.setTitle("SAVE CHANGES", for: .normal)
                fetchVoucherDetails(voucher: voucher)
            }
            
            populateCardData()
        }
    }
    
    private func populateViewModeCardData (voucher: Hkb_voucher) {
        let vchType = voucher.vch_type!
        let account = QueryUtils.fetchSingleAccount(accountId: Int64(voucher.account_id))
        var currency = LocalPrefs.getUserCurrency()
        var amount = voucher.vch_amount
        
        if voucher.travelmode == 1 {
            currency = voucher.fccurrency!
            amount = voucher.fcamount
        }
        
        if vchType == Constants.EXPENSE {
            border.borderColor = UIColor.red.cgColor
            label_amount.text = "- \(currency) \(Utils.formatDecimalNumber(number: abs(amount), decimal: LocalPrefs.getDecimalFormat()))"
            label_amount.textColor = UIColor.red
            let category = QueryUtils.fetchSingleCategory(categoryId: Int64(voucher.category_id))
            iv_category.image = UIImage(named: category?.box_icon ?? "ic_clear")
            label_category.text = category?.title ?? Constants.NULL_TEXT
            label_account.text = account?.title ?? Constants.NULL_TEXT
        } else if vchType == Constants.INCOME {
            
            label_amount.text = "\(currency) \(Utils.formatDecimalNumber(number: abs(amount), decimal: LocalPrefs.getDecimalFormat()))"
            label_amount.textColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
            let category = QueryUtils.fetchSingleCategory(categoryId: Int64(voucher.category_id))
            iv_category.image = UIImage(named: category?.box_icon ?? "ic_clear")
            label_category.text = "\(category?.title ?? Constants.NULL_TEXT) Income"
            label_account.text = account?.title ?? Constants.NULL_TEXT
        } else {
            
            guard let voucher2 = QueryUtils.fetchSingleVoucher(voucherId: Int64(voucher.ref_no!) ?? 0) else {
                return
            }
            guard let accountTo = QueryUtils.fetchSingleAccount(accountId: Int64(voucher2.account_id)) else {
                return
            }
            label_category.text = Constants.TRANSFER
            label_amount.text = "\(currency) \(Utils.formatDecimalNumber(number: abs(amount), decimal: LocalPrefs.getDecimalFormat()))"
            label_amount.textColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
            label_account.text = "\(account?.title ?? Constants.NULL_TEXT) > \(accountTo.title ?? Constants.NULL_TEXT)"
            iv_category.image = UIImage(named: "transfer_icon")
            if voucher.eventid != 0 {
                
                if let event = QueryUtils.fetchSingleEvent(eventId: voucher.eventid) {
                    eventId = event.eventid
                    eventName = event.name!
                    btn_event.setTitle(eventName, for: .normal)
                }
            }
        }
    }
    
    private func populateCardData () {
        if vchType == Constants.EXPENSE {
            border.borderColor = UIColor.red.cgColor
            label_category.text = categoryName
            label_amount.text = "- \(vchCurrency) \(Utils.formatDecimalNumber(number: abs(vchAmount), decimal: LocalPrefs.getDecimalFormat()))"
            label_amount.textColor = UIColor.red
            let category = QueryUtils.fetchSingleCategory(categoryId: Int64(categoryId))
            iv_category.image = UIImage(named: category?.box_icon ?? "ic_clear")
            label_category.text = category?.title ?? Constants.NULL_TEXT
            label_account.text = accountName
        } else if vchType == Constants.INCOME {
            
            label_category.text = "\(categoryName) Income"
            label_amount.text = "+ \(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: abs(vchAmount), decimal: LocalPrefs.getDecimalFormat()))"
            label_amount.textColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
            let category = QueryUtils.fetchSingleCategory(categoryId: Int64(categoryId))
            iv_category.image = UIImage(named: category?.box_icon ?? "ic_clear")
            label_category.text = category?.title ?? Constants.NULL_TEXT
            label_account.text = accountName
        } else {
            label_category.text = Constants.TRANSFER
            label_amount.text = "\(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: abs(vchAmount), decimal: LocalPrefs.getDecimalFormat()))"
            label_amount.textColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
            label_account.text = "\(accountName) > \(accountToName)"
            iv_category.image = UIImage(named: "transfer_icon")
        }
    }
    
    private func fetchVoucherDetails (voucher: Hkb_voucher) {
        
        let account = QueryUtils.fetchSingleAccount(accountId: Int64(voucher.account_id))
        label_account.text = account?.title ?? Constants.NULL_TEXT
        
//        let voucherDate = Utils.convertStringToDate(dateString: vchDate)
//        btn_date.setTitle(Utils.currentDateUserFormat(date: voucherDate), for: .normal)
        btn_date.setTitle(vchDate, for: .normal)
        text_field_description.text = voucher.vch_description
        
        if let voucherType = voucher.vch_type {
            self.vchType = voucherType
        }
        
        if let useCase = voucher.use_case {
            useCaseType = useCase
        }
        
        if voucher.travelmode == 1 {
            label_amount.text = "\(voucher.fccurrency!) \(Utils.formatDecimalNumber(number: abs(voucher.fcamount), decimal: LocalPrefs.getDecimalFormat()))"
        } else {
            label_amount.text = "\(LocalPrefs.getUserCurrency()) \(Utils.formatDecimalNumber(number: abs(voucher.vch_amount), decimal: LocalPrefs.getDecimalFormat()))"
        }
        
        if voucher.vch_image != nil && voucher.vch_image != "" {
            vchImage = voucher.vch_image!
            btn_preview.isHidden = false
            btn_remove.isHidden = false
            btn_receipt.setTitle("Receipt Attached", for: .normal)
        }
        
        if voucher.tag != nil && voucher.tag != "" {
            vchTags = voucher.tag!
            btn_tags.setTitle(vchTags, for: .normal)
        }
        
        if voucher.flex1 != nil && voucher.flex1 != "" {
            selectedPlace = voucher.flex1!
            btn_location.setTitle(selectedPlace, for: .normal)
        }
        
        if voucher.eventid != 0 {
            
            if let event = QueryUtils.fetchSingleEvent(eventId: voucher.eventid) {
                eventId = event.eventid
                eventName = event.name!
                btn_event.setTitle(eventName, for: .normal)
            }
        }
        
        if voucher.vch_type == Constants.TRANSFER {
            editVoucher2 = QueryUtils.fetchSingleVoucher(voucherId: Int64(voucher.ref_no!)!)
            if let accountTo = QueryUtils.fetchSingleAccount(accountId: Int64((editVoucher2?.account_id ?? 0))){
                accountToName = accountTo.title ?? Constants.NULL_TEXT
            }
            
        }
        
      
    }
    
    fileprivate func getEditVoucher2 ()  {
        let fetchRequest : NSFetchRequest<Hkb_voucher> = Hkb_voucher.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format : "voucher_id = %@" , (editVoucher?.ref_no)!)
        
        do {
            let vouchers = try DbController.getContext().fetch(fetchRequest)
            
            for voucher in vouchers as [Hkb_voucher]{
                editVoucher = voucher
            }
        } catch {
            print("Error : " , error)
        }
    }
    
    private func postTransferVoucherDetails (voucher1 : Hkb_voucher , voucher2 : Hkb_voucher, isUpdate: Bool) {
//        let maxVoucherId : Int = Int(QueryUtils.getMaxVoucherId() + 1)
        let firstVoucherId : Int64 = Utils.getUniqueId()
        let secondVoucherId : Int64 = Utils.getUniqueId()
        voucher1.account_id = accountId
        voucher1.active = 1
        voucher1.vch_no = "1"
        voucher1.vch_date = vchDate
        voucher1.flex1 = selectedPlace
        voucher1.vch_amount = (vchAmount * -1)
        voucher1.vch_description = text_field_description.text!
        voucher1.vch_day = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "day")
        voucher1.vch_year = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "year")
        voucher1.month = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "month")
        voucher1.vch_type = Constants.TRANSFER
        voucher1.tag = vchTags
        voucher1.categoryname = ""
        voucher1.fcrate = ""
        voucher1.eventid = eventId
        voucher1.eventname = eventName
        voucher1.fccurrency = ""
        voucher1.accountname = accountName
        voucher1.vch_image = vchImage
        voucher1.vchcurrency = LocalPrefs.getUserCurrency()
        voucher1.use_case = self.useCaseType
        
        voucher2.account_id = accountToId
        voucher2.active = 1
        voucher2.vch_no = "0"
        voucher2.vch_date = vchDate
        voucher2.flex1 = selectedPlace
        voucher2.accountname = accountToName
        voucher2.vch_amount = vchAmount
        voucher2.vch_description = text_field_description.text
        voucher2.vch_day = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "day")
        voucher2.vch_year = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "year")
        voucher2.month = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "month")
        voucher2.vch_type = Constants.TRANSFER
        voucher2.tag = vchTags
        voucher2.categoryname = ""
        voucher2.eventname = eventName
        voucher2.fcrate = ""
        voucher2.fccurrency = ""
        voucher2.vch_image = vchImage
        voucher2.vchcurrency = LocalPrefs.getUserCurrency()
        voucher2.use_case = self.useCaseType
        
        if editVoucher != nil {
            voucher1.updated_on = Utils.currentDateDbFormat(date: Date())

            voucher2.updated_on = Utils.currentDateDbFormat(date: Date())
        } else {
            voucher1.voucher_id = firstVoucherId
            voucher1.ref_no = String(secondVoucherId)
            voucher1.created_on = Utils.currentDateDbFormat(date: Date())
            voucher2.created_on = Utils.currentDateDbFormat(date: Date())
//            voucher2.voucher_id = Int64(Int(QueryUtils.getMaxVoucherId() + 1))
            voucher2.voucher_id = secondVoucherId
            
            voucher2.ref_no = String(firstVoucherId)
        }
        
        if isRecurring {
            fetchReminderTime(repeatInterval: repeatInterval, day: reminderDay)
        }
        
        var mobileNo = ""
        let email = LocalPrefs.getUserData()[Constants.EMAIL]!
        if let mobile = LocalPrefs.getUserData()[Constants.USER_PHONE] {
            mobileNo = mobile
        }
        
        print("ACC NAME : " , accountName , accountToName)
        let vchDetails : [String : String] = ["account name" : accountName ,
                                              "account_to" : accountToName ,
                                              "amount" : String(voucher1.vch_amount) ,
                                              "consumer_mobile" : mobileNo,
                                              "consumer_name" : LocalPrefs.getUserData()["user_name"]!,
                                              "consumer_email" : email,
                                              "currency" : LocalPrefs.getUserCurrency(),
                                              "place" : selectedPlace,
                                              "place_type" : placeType,
                                              "trx_type" : "Transfer"]
        Analytics.logEvent("trx_added", parameters: vchDetails)
        if editVoucher != nil{
            if QueryUtils.getAccountSync(accountId: voucher1.account_id) == 1 && QueryUtils.getAccountSync(accountId: voucher2.account_id) == 1  && QueryUtils.getVoucherSync(voucherId: voucher1.voucher_id) == 1  && QueryUtils.getVoucherSync(voucherId: voucher2.voucher_id) == 1 {
                if voucher1.eventid != 0 {
                    if QueryUtils.getEventSync(eventId: voucher1.eventid) == 1 {
                        postTransactionToServer(voucher: voucher1, voucher2: voucher2, isUpdate: isUpdate)
                    } else {
                        voucher1.is_synced = 0
                        voucher2.is_synced = 0
                        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    }
                } else {
                    postTransactionToServer(voucher: voucher1, voucher2: voucher2, isUpdate: isUpdate)
                }
            } else {
                voucher1.is_synced = 0
                voucher2.is_synced = 0
                NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
            }
        } else {
            if QueryUtils.getAccountSync(accountId: voucher1.account_id) == 1 && QueryUtils.getAccountSync(accountId: voucher2.account_id) == 1 {
                if voucher1.eventid != 0 {
                    if QueryUtils.getEventSync(eventId: voucher1.eventid) == 1 {
                        postTransactionToServer(voucher: voucher1, voucher2: voucher2, isUpdate: isUpdate)
                    } else {
                        voucher1.is_synced = 0
                        voucher2.is_synced = 0
                        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    }
                } else {
                    postTransactionToServer(voucher: voucher1, voucher2: voucher2, isUpdate: isUpdate)
                }
            } else {
                voucher1.is_synced = 0
                voucher2.is_synced = 0
                NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
            }
        }
        
        
        DbController.saveContext()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func postVoucherDetails(vch: Hkb_voucher, isUpdate: Bool) -> Void {
        let currentDate = Date()
        let voucherDate = Utils.convertStringToDate(dateString: vchDate)
        vch.account_id = Int64(accountId)
        vch.active = 1
        vch.vch_amount = vchAmount
        vch.category_id = Int64(categoryId)
        vch.vch_no = "1"
        vch.month = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: Constants.MONTH)
        vch.vch_type = vchType
        vch.vch_date = vchDate
        vch.vch_year = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: Constants.YEAR)
        vch.vch_day = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: Constants.DAY)
        vch.vch_description = text_field_description.text!
        vch.vch_image = vchImage
        vch.flex3 = "0"
        vch.flex1 = selectedPlace
        vch.vchtrxplace = placeType
        vch.accountname = accountName
        vch.categoryname = categoryName
        vch.tag = vchTags
        vch.eventid = Int64(eventId)
        vch.eventname = eventName
        vch.ref_no = "1"
        vch.use_case = useCaseType
        vch.vchcurrency = LocalPrefs.getUserCurrency()
        
        if vchType == Constants.EXPENSE {
            vch.vch_amount = vch.vch_amount * -1
        }
        
        
        
        if editVoucher != nil && editVoucher?.travelmode == 1 {
            let conversionRate = editVoucher?.fcrate!
            vch.fcamount = vchAmount
            vch.vch_amount = vchAmount * (conversionRate! as NSString).doubleValue
            
            if vchType == Constants.EXPENSE {
                vch.vch_amount = (vchAmount * (conversionRate! as NSString).doubleValue) * -1
                vch.fcamount = vchAmount * -1
            } else {
                vch.fcamount = vchAmount
                vch.vch_amount = vchAmount * (conversionRate! as NSString).doubleValue
            }
        } else {
            if LocalPrefs.getIsTravelMode() {
                let startDateString = LocalPrefs.getTravelModeDetails()[Constants.TRAVEL_START_DATE]
                let endDateString = LocalPrefs.getTravelModeDetails() [Constants.TRAVEL_END_DATE]
                let startDate = Utils.convertStringToDate(dateString: startDateString!)
                let endDate = Utils.convertStringToDate(dateString: endDateString!)
                
                if Utils.isDateBetween(startDate, and: endDate, middleDate: voucherDate) {
                    let currencyTo = LocalPrefs.getTravelModeDetails()[Constants.TRAVEL_CURRENCY_TO]!
                    let conversionRate = LocalPrefs.getTravelModeDetails()[Constants.TRAVEL_CONVERSION_RATE]!
                    let travelPlace = LocalPrefs.getTravelModeDetails()[Constants.TRAVEL_TRAVEL_TO]!
                    vch.fcamount = vchAmount
                    vch.fccurrency = currencyTo
                    vch.fcrate = conversionRate
                    vch.vch_amount = vchAmount * (conversionRate as NSString).doubleValue
                    vch.travelmode = 1
                    vch.travelmodeplace = travelPlace
                    vch.travlemodelocation = "\(startDate)~\(endDate)"
                    
                    if vchType == Constants.EXPENSE {
                        vch.vch_amount = (vchAmount * (conversionRate as NSString).doubleValue) * -1
                        vch.fcamount = vchAmount * -1
                    } else {
                        vch.fcamount = vchAmount
                        vch.vch_amount = vchAmount * (conversionRate as NSString).doubleValue
                    }
                }
            }
        }
        
        if editVoucher != nil {
            vch.voucher_id = (editVoucher?.voucher_id)!
            vch.updated_on = Utils.currentDateDbFormat(date: currentDate)
        } else {
            
//            vch.voucher_id = Int64(Int((QueryUtils.getMaxVoucherId() + 1)))
            vch.voucher_id = Utils.getUniqueId()
            vch.created_on = Utils.currentDateDbFormat(date: currentDate)
        }
        
//        if isRecuring {
//            fetchReminderTime(repeatInterval: repearInterval, day: reminderDay!)
//        }
        
        if let attachedImg = imgData {
            print(String(vch.voucher_id))
            uploadReceiptNetworkCall(vchId: String(vch.voucher_id), imgData: attachedImg, name: imageFileName, fileName: imageFileName)
        }
        var mobileNo = ""
        
        let email = LocalPrefs.getUserData()["email"]!
        if let mobile = LocalPrefs.getUserData()[Constants.USER_PHONE] {
            mobileNo = mobile
        }
        
        
        let vchDetails : [String : String] = ["account_name" : accountName,
                                              "amount" : String(vch.vch_amount),
                                              "category_name" : categoryName,
                                              "consumer_mobile" : mobileNo,
                                              "consumer_email" : email,
                                              "consumer_name" : LocalPrefs.getUserData()["user_name"]!,
                                              "currency" : LocalPrefs.getUserCurrency(),
                                              "place" : selectedPlace,
                                              "place_type" : placeType,
                                              "trx_type" : vchType]
        Analytics.logEvent("trx_added", parameters: vchDetails)
        
        if isRecurring {
            fetchReminderTime(repeatInterval: repeatInterval, day: reminderDay)
        }
        
        if editVoucher != nil{
            if QueryUtils.getAccountSync(accountId: vch.account_id) == 1 && QueryUtils.getVoucherSync(voucherId: vch.voucher_id) == 1{
                if vch.eventid == 0 {
                    postTransactionToServer(voucher: vch, voucher2: nil, isUpdate: isUpdate)
                } else {
                    if QueryUtils.getEventSync(eventId: vch.eventid) == 1 {
                        postTransactionToServer(voucher: vch, voucher2: nil, isUpdate: isUpdate)
                    } else {
                        vch.is_synced = 0
                        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    }
                }
                
            } else {
                vch.is_synced = 0
                NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
            }
        } else {
            if QueryUtils.getAccountSync(accountId: vch.account_id) == 1{
                if vch.eventid == 0 {
                    postTransactionToServer(voucher: vch, voucher2: nil, isUpdate: isUpdate)
                } else {
                    if QueryUtils.getEventSync(eventId: vch.eventid) == 1 {
                        postTransactionToServer(voucher: vch, voucher2: nil, isUpdate: isUpdate)
                    } else {
                        vch.is_synced = 0
                        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    }
                }
                
            } else {
                vch.is_synced = 0
                NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
            }
        }
        
       
        
        DbController.saveContext()
        self.notifyForBudgetProceed()
        self.dismiss(animated: true, completion: nil)
    }
    
 
    
    @objc private func saveVoucher() {
        if let voucher = editVoucher {
            if vchType == Constants.TRANSFER {
                postTransferVoucherDetails(voucher1: voucher, voucher2: editVoucher2!, isUpdate: true)
                UIUtils.showSnackbar(message: "Transaction added successfully")
            } else {
                postVoucherDetails(vch: editVoucher!, isUpdate: true)
                UIUtils.showSnackbar(message: "Transaction updated successfully")
            }
        } else {
            let voucher : Hkb_voucher = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_VOUCHER, into: DbController.getContext()) as! Hkb_voucher
            
            if vchType == Constants.TRANSFER {
                let voucher2 : Hkb_voucher = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_VOUCHER, into: DbController.getContext()) as! Hkb_voucher
                postTransferVoucherDetails(voucher1: voucher, voucher2: voucher2, isUpdate: false)
                UIUtils.showSnackbar(message: "Transaction added successfully")
            } else {
                postVoucherDetails(vch: voucher, isUpdate: false)
                UIUtils.showSnackbar(message: "Transaction updated successfully")
            }
        }        
    }
    
    private func postTransactionToServer (voucher: Hkb_voucher, voucher2: Hkb_voucher?, isUpdate : Bool) {
        var vouchers = ""
        let vch = Utils.convertVchIntoDict(object: voucher)
        
        if vchType == Constants.TRANSFER {
            let vch2 = Utils.convertVchIntoDict(object: voucher2!)
            let arrayOfVch = [vch , vch2]
            vouchers = Utils.convertDictIntoJson(object: arrayOfVch)
        } else {
            vouchers = Utils.convertDictIntoJson(object: vch)
        }
        
        print("Vouchers : " , vouchers)
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        var URL = "\(Constants.BASE_URL)/transactions/save"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        var httpMethod = Alamofire.HTTPMethod.post
        let dictToEncrypt =  ["vouchers" : vouchers,
                              "device_type" : "Ios",
                              "consumer_id" : consumerId]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        if isUpdate {
            URL = "\(Constants.BASE_URL)/transactions/update"
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

                    if status == 1 {
                            voucher.is_synced = 1
                            voucher2?.is_synced = 1

                        if let attachedImg = self.imgData {
                            self.uploadReceiptNetworkCall(vchId: String(voucher.voucher_id), imgData: attachedImg, name: self.imageFileName, fileName: self.imageFileName)
                        }
                    } else {
                        voucher.is_synced = 0
                        voucher2?.is_synced = 0
                        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    }
                    
                    DbController.saveContext()
                    

                    
                case .failure(let error):
                    voucher.is_synced = 0
                    voucher2?.is_synced = 0
                    DbController.saveContext()
                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
//                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
    }
    
    private func uploadReceiptNetworkCall (vchId: String, imgData: Data, name: String, fileName: String) {
        
        Alamofire.upload(multipartFormData: { multipartFormData in
//            for (key, value) in params {
//                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
//            }
            multipartFormData.append(imgData, withName: "vch_image",fileName: fileName, mimeType: "image/png")
        },
                         to:"\(Constants.BASE_URL)/upload/transaction/receipt?consumer_id=\(LocalPrefs.getUserData()[Constants.CONSUMER_ID]!)&device_type=Ios&transaction_id=\(vchId)")
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                //code is close due to crash on nasif oorder at 16 March 09:03 PM
                
//                upload.responseJSON { response in
//                    let responseObj = JSON(response.result.value!)
//                    let status = responseObj["status"].intValue
//                    let message = responseObj["message"].stringValue
//
//                    if status == 1 {
//                        print("MessageSuccess : ", message)
//                    } else {
//                        print("MessageError : ", message)
//                    }
//
//                }
                
            case .failure(let encodingError):
                print("Upload failed : " , encodingError.localizedDescription)
            }
        }
    }
    
    private func fetchReminderTime (repeatInterval: String, day: Int) {
        let myCalendar = Calendar(identifier: .gregorian)
        let currentDate = Date()
        print("Vch Date : " , Utils.currentDateUserFormat(date: currentDate))
        
        
        if repeatInterval == "Monthly" {
            let reminderDay = day - 1
            let nextMonth = myCalendar.date(byAdding: .month, value: 1, to: currentDate)
            let interval = myCalendar.dateInterval(of: .month, for: nextMonth!)!
            let lastDay = myCalendar.dateComponents([.day], from: interval.start, to: interval.end).day!
            
            let components = myCalendar.dateComponents([.year, .month], from: nextMonth!)
            let startOfNextMonth = myCalendar.date(from: components)
            
            if reminderDay > lastDay {
                
                reminderDate = myCalendar.date(byAdding: .day, value: lastDay, to: startOfNextMonth!)!
            } else {
                reminderDate = myCalendar.date(byAdding: .day, value: reminderDay, to: startOfNextMonth!)!
            }
            
            postRecurringTransactionReminder(date: reminderDate, frequency: "Monthly", day: day)
        } else if repeatInterval == "Weekly" {
            let weekday = myCalendar.component(.weekday, from: currentDate)
            var reminderDayDifference = day - weekday
            
            if reminderDayDifference <= 0 {
                reminderDayDifference = reminderDayDifference + 7
            }
            
            reminderDate = myCalendar.date(byAdding: .day, value: reminderDayDifference, to: currentDate)!
            postRecurringTransactionReminder(date: reminderDate, frequency: "Weekly", day: day)
        } else if repeatInterval == "Daily" {
            let date = Date()
            let reminderDate = Calendar.current.date(byAdding: .day, value: 1, to: date)
            let day = Utils.getDayMonthAndYear(givenDate: Utils.currentDateDbFormat(date: reminderDate!), dayMonthOrYear: "day")
            self.postRecurringTransactionReminder(date: reminderDate!, frequency: "Daily", day: Int(day))
        }
    }
    
    private func postRecurringTransactionReminder (date: Date, frequency: String, day: Int) {
        let dateString = Utils.currentDateDbFormat(date: date)
        let reminder : Hkb_reminder = NSEntityDescription.insertNewObject(forEntityName: Constants.HKB_REMINDER, into: DbController.getContext()) as! Hkb_reminder
        reminder.categoryId = Int64(categoryId)
        reminder.title = "\(self.vchType) recurring transaction"
        reminder.rmdate = dateString
        reminder.rmday = Utils.getDayMonthAndYear(givenDate: dateString, dayMonthOrYear: "day")
        reminder.rmmonth = Utils.getDayMonthAndYear(givenDate: dateString, dayMonthOrYear: "month")
        reminder.rmyear = Utils.getDayMonthAndYear(givenDate: dateString, dayMonthOrYear: "year")
        reminder.rmtime = "00:00"
        reminder.active = 1
        reminder.recurring = frequency
        reminder.categoryId = Int64(self.categoryId)
        reminder.amount = vchAmount
//        reminder.reminderId = Int64(QueryUtils.getMaxReminderId() + 1)
        reminder.reminderId = Utils.getUniqueId()
        reminder.accountid = Int64(self.accountId)
        reminder.createdon = Utils.currentDateDbFormat(date: Date())
        reminder.rmweek = Int16(day)
        reminder.flex1 = "1"
        
        if vchType == Constants.EXPENSE {
            reminder.isexpense = 1
        } else if vchType == Constants.INCOME {
            reminder.isexpense = 0
        } else if vchType == Constants.TRANSFER {
            reminder.isexpense = 2
            reminder.categoryId = Int64(accountToId)
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Hysab Kytab"
        content.body = "Recurring transaction has been recorded"
        content.sound = UNNotificationSound.default

        let timeInterval = date.timeIntervalSinceNow
        print("Time Interval : " , Utils.currentDateUserFormat(date: date))
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest.init(identifier: String(reminder.reminderId), content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print("Error : " , error?.localizedDescription)
        }
    }
    
    private func attachReceiptAlertView () {
        self.view.endEditing(true)
        var alert = UIAlertController()
        if UIDevice.current.userInterfaceIdiom == .pad {
            alert = UIAlertController(title: "Attach receipt", message: "Select image from photos or camera to attach a transaction receipt : ", preferredStyle: UIAlertController.Style.alert)
        } else {
            alert = UIAlertController(title: "Attach receipt", message: "Select image from photos or camera to attach a transaction receipt : ", preferredStyle: UIAlertController.Style.actionSheet)
        }
        
        alert.addAction(UIAlertAction(title: "Photos", style: UIAlertAction.Style.default, handler: {action in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.mediaTypes = ["public.image"]
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Camera", style: UIAlertAction.Style.default, handler: {action in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.imagePicker.cameraCaptureMode = .photo
            self.imagePicker.modalPresentationStyle = .fullScreen
            self.present(self.imagePicker,animated: true,completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func notifyForBudgetProceed () {
        if vchType == Constants.EXPENSE {
            let tabController = self.navigationController?.viewControllers.first as? TabBarViewController
            let vchMonth = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "month")
            let vchYear = Utils.getDayMonthAndYear(givenDate: vchDate, dayMonthOrYear: "year")
            tabController?.notifyOnBudgetProgress(categoryId: categoryId, month: Int(vchMonth), year: Int(vchYear))
        }
    }
    
    @IBAction func onDateTapped(_ sender: Any) {
        let datePopup = DialogSelectDate()
        datePopup.myDelegate = self
        datePopup.customDate = Utils.convertStringToDate(dateString: vchDate)
        self.presentPopupView(popupView: datePopup)
    }
    
    @IBAction func onReceiptRemoveTapped(_ sender: Any) {
        btn_preview.isHidden = true
        btn_remove.isHidden = true
        self.vchImage = ""
        btn_receipt.setTitle("Attach Receipt", for: .normal)
    }
    
    @IBAction func onReceiptPreviewTapped(_ sender: Any) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsURL.appendingPathComponent(vchImage)
        let fetchedImage = UIImage(contentsOfFile: filePath.path)
        
        let images = [
            LightboxImage(
                image: fetchedImage!,
                text: vchImage
        )]
        
        let controller = LightboxController(images: images)
        controller.dynamicBackground = true
        present(controller, animated: true, completion: nil)
    }
    
    
    
    private func navigateToPlacesVC () {
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
                
                let placesVC = getStoryboard(name: ViewIdentifiers.SB_PLACES).instantiateViewController(withIdentifier: ViewIdentifiers.VC_PLACES) as! PlacesViewController
                placesVC.delegate = self
                self.navigationController?.pushViewController(placesVC, animated: true)
            } else if CLLocationManager.authorizationStatus() == .denied {
                let alert = UIAlertController(title: "Application needs location access", message: "The applications needs location access to select nearby places", preferredStyle: UIAlertController.Style.alert)
                alert.view.superview?.isUserInteractionEnabled = true
    
                alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: {action in
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.openURL(url)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                locationManager.requestWhenInUseAuthorization()
                locationManager.requestAlwaysAuthorization()
            }
        } else {
            UIUtils.showAlert(vc: self, message: "Please enable location services")
        }
    }
    
    @IBAction func onDescriptionTapped(_ sender: Any) {
        
    }
    
    @IBAction func onAttachReceiptTapped(_ sender: Any) {
       attachReceiptAlertView()
    }
    
    @IBAction func onLocationTapped(_ sender: Any) {
        navigateToPlacesVC()
    }
    
    @IBAction func onReceiptTapped(_ sender: Any) {
        self.view.endEditing(true)
        var alert = UIAlertController()
        if UIDevice.current.userInterfaceIdiom == .pad {
            alert = UIAlertController(title: "Attach receipt", message: "Select image from photos or camera to attach a transaction receipt : ", preferredStyle: UIAlertController.Style.alert)
        } else {
            alert = UIAlertController(title: "Attach receipt", message: "Select image from photos or camera to attach a transaction receipt : ", preferredStyle: UIAlertController.Style.actionSheet)
        }
        
        alert.view.superview?.isUserInteractionEnabled = true
     
        alert.addAction(UIAlertAction(title: "Photos", style: UIAlertAction.Style.default, handler: {action in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.mediaTypes = ["public.image"]
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Camera", style: UIAlertAction.Style.default, handler: {action in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.imagePicker.cameraCaptureMode = .photo
            self.imagePicker.modalPresentationStyle = .fullScreen
            self.present(self.imagePicker,animated: true,completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onEventTapped(_ sender: Any) {
        let eventPopup = EventSelectionPopup()
        eventPopup.delegate = self
        self.presentPopupView(popupView: eventPopup)
    }
    
    @IBAction func onAddTagTapped(_ sender: Any) {
        let addTagsPopup = AddTagsPopup()
        addTagsPopup.delegate = self
        addTagsPopup.addedTags = vchTags
        
        if vchType == Constants.INCOME || vchType == Constants.EXPENSE {
            let category = QueryUtils.fetchSingleCategory(categoryId: Int64(categoryId))
            
            if let categoryTags = category?.tags {
                addTagsPopup.categoryTags = categoryTags
            }
        }
        
        self.presentPopupView(popupView: addTagsPopup)
    }
    
    
    @IBAction func onRecurringTapped(_ sender: Any) {
        let recurringVC = getStoryboard(name: ViewIdentifiers.SB_TRANSACTION).instantiateViewController(withIdentifier: ViewIdentifiers.VC_RECURRING_TRANSACTION) as! RecurringTransactionViewController
        recurringVC.delegate = self
        self.navigationController?.pushViewController(recurringVC, animated: true)
    }
    
    @IBAction func onAddAnotherTapped(_ sender: Any) {
        addAnotherDelegate?.onAddAnotherTapped()
        self.saveVoucher()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onFinishTapped(_ sender: Any) {
        self.saveVoucher()
    }
    
    @objc private func onDeleteTapped () {
        let deletePopup = GenericPopup()
        deletePopup.btnText = "DELETE TRANSACTION"
        deletePopup.message = "This will delete the following transaction and all its data"
        deletePopup.popupTitle = "Delete this transaction"
        deletePopup.delegate = self
        self.presentPopupView(popupView: deletePopup)
    }
    
    @objc private func onEditTapped () {
        let editVC = getStoryboard(name: ViewIdentifiers.SB_TRANSACTION).instantiateViewController(withIdentifier: ViewIdentifiers.VC_TRANSACTION_LOGGING) as! TransactionLoggingViewController
        let navController = UINavigationController()
        navController.viewControllers = [editVC]
        editVC.useCaseType = self.useCaseType
        editVC.vchAmount = self.vchAmount
        editVC.vchType = self.vchType
        editVC.accountToName = accountToName
        editVC.accountName = accountName
        editVC.categoryName = categoryName
        
        if let voucherEdit = self.editVoucher {
            editVC.editVoucher = voucherEdit
        }
        navController.modalPresentationStyle = .currentContext
        self.present(navController, animated: true)
    }
}

extension TransactionDetailsViewController: DateSelectionListener, EventSelectionListener, UITextFieldDelegate, GenericPopupSelection, TagsAddListener, ReminderFrequencyListener {
    
    
    func onTagsAdded(tags: String) {
        if tags != "" {
            btn_tags.setTitle(tags, for: .normal)
            self.vchTags = tags
        }
    }

    
    func onEventSelected(eventId: Int64, eventName: String) {
        if eventId == 0 {
            let navController = UINavigationController()
            let addEventVC = getStoryboard(name: ViewIdentifiers.SB_EVENT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_EVENT)
            navController.viewControllers = [addEventVC]
            DispatchQueue.main.async {
                self.present(navController, animated: true, completion: nil)
            }
            
        } else {
            self.eventId = eventId
            self.eventName = eventName
            btn_event.setTitle(eventName, for: .normal)
        }
    }
    
    
    func onDateSelected(date: Date) {
        vchDate = Utils.currentDateDbFormat(date: date)
        btn_date.setTitle(Utils.currentDateUserFormat(date: date), for: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
            case text_field_description:
                textField.resignFirstResponder()
            default:
                textField.resignFirstResponder()
        }
        
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == text_field_description {
            self.animateTextField(up: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == text_field_description {
            self.animateTextField(up: false)
        }
    }
    
    // Delete Voucher button
    func onButtonTapped(index: Int, objectIndex: Int) {
        print("Type : " , vchType)
        if vchType == Constants.TRANSFER {
            if let voucher = editVoucher {
                voucher.active = 0
                editVoucher2?.active = 0
            }
            
            if editVoucher2 != nil && editVoucher != nil {
                if QueryUtils.getAccountSync(accountId: editVoucher!.account_id) == 1 && QueryUtils.getAccountSync(accountId: editVoucher2!.account_id) == 1 && QueryUtils.getVoucherSync(voucherId: editVoucher!.voucher_id) == 1 && QueryUtils.getVoucherSync(voucherId: editVoucher2!.voucher_id) == 1 {
                    editVoucher!.is_synced = 0
                    editVoucher2!.is_synced = 0
                    postTransactionToServer(voucher: editVoucher!, voucher2: editVoucher2!, isUpdate: true)
                } else {
                    editVoucher!.is_synced = 0
                    editVoucher2!.is_synced = 0
                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                }
                
            } else {
                UIUtils.showSnackbarNegative(message: "Something went wrong with transactions details")
            }
        } else {
            self.editVoucher?.active = 0
            if QueryUtils.getAccountSync(accountId: editVoucher!.account_id) == 1 && QueryUtils.getVoucherSync(voucherId: editVoucher!.voucher_id) == 1 && QueryUtils.getCategorySync(categoryId: editVoucher!.category_id) == 1 {
                postTransactionToServer(voucher: editVoucher!, voucher2: nil, isUpdate: true)
            } else {
                
                editVoucher!.is_synced = 0
                NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
            }
            
            
        }
        
        DbController.saveContext()
        self.navigationController?.popViewController(animated: true)
    }
    
    func onFrequencySelected(repeatInterval: String, repeatTitle: String, day: Int) {
        btn_recurring.setTitle("Repeat : \(repeatTitle)", for: .normal)
        isRecurring = true
        self.reminderDay = day
        self.repeatInterval = repeatInterval
    }
}

extension TransactionDetailsViewController: PlaceSelectionListener {
    
    func onPlaceSelected(placeName: String, placeType: String) {
        self.placeType = placeType
        self.selectedPlace = placeName
        btn_location.setTitle(placeName, for: .normal)
    }
}


extension TransactionDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // image imagePicker delegates here
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){

//    func imagePickerController(_ imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
//        imagePicker.dismiss(animated: true) {
            let chosenImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as! UIImage
         
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let date = Utils.currentDateDbFormat(date: Date())
            self.imageFileName = "HysabKytab(\(date)).png"
            let imagefilePath = documentsURL.appendingPathComponent(self.imageFileName)
            
            do {
                if let pngImage = chosenImage.jpegData(compressionQuality: 0.2) {
                    try pngImage.write(to: imagefilePath, options: .atomic)
                    self.vchImage = self.imageFileName
                    self.imgData = pngImage
                }
            } catch {
                print("Couldn't write image because " , error)
            }
            self.btn_receipt.setTitle("Receipt Attached", for: .normal)
            self.btn_remove.isHidden = false
            self.btn_preview.isHidden = false
            imagePicker.dismiss(animated: true, completion: nil)
//        }
    }
    
    func imagePickerControllerDidCancel(_ imagePicker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
