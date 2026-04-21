

import Foundation
import Firebase
import FirebaseDatabase

class Constants {
    
    // Storyboard Names
    public static let SB_MAIN = "Main"
    public static let SB_SINGUP = "Signup"
    public static let SB_TAB_BAR = "TabBar"
    
    
    // Time Intervals
    static let MONTHLY : String = "Monthly"
    static let YEARLY : String = "Yearly"
    static let HALF_YEARLY : String = "Half yearly"
    static let QUARTERLY : String = "Quarterly"
    static let ALL_TIME : String = "All Time"
    
    // Db Tables
    static let HKB_VOUCHER : String = "Hkb_voucher"
    static let HKB_CATEGORY : String = "Hkb_category"
    static let HKB_ACCOUNT : String = "Hkb_account"
    static let HKB_SAVING : String = "Hkb_goal"
    static let HKB_SAVING_TRX : String = "Hkb_goal_trx"
    static let HKB_BUDGET : String = "Hkb_budget"
    static let HKB_REMINDER : String = "Hkb_reminder"
    static let HKB_NOTIFICATIONS : String = "Hkb_notifications"
    static let HKB_EVENT : String = "Hkb_event"
    static let HKB_ACTIVITY : String = "Hkb_activity"
    
    // Hkb_notification message constants
    static let NO_BUDGET : String = "zero"
    static let BUDGET_80 : String = "eighty"
    static let BUDGET_100 : String = "hundred"
    
    
    // Day , month and year constants
    static let DAY : String = "day"
    static let MONTH : String = "month"
    static let YEAR : String = "year"
    
    // Voucher Types
    static let EXPENSE : String = "Expense"
    static let INCOME : String = "Income"
    static let TRANSFER : String = "Transfer"
    
    // Firebase Constants
    static let rootRef = Database.database().reference(withPath : "hk_app")
    
    static let API_ACCESS_KEY : String = "yGDj5RN8$>TpvrQmRgA&)R8is[IfH"
    static let MIXPANEL_TOKEN : String = "d7d94b0cb7f0e6c71070394c80a6bd07"
    
    // Travel mode details
    static let TRAVEL_START_DATE : String = "startDate"
    static let TRAVEL_END_DATE : String = "endDate"
    static let TRAVEL_CURRENCY_TO : String = "currencyTo"
    static let TRAVEL_CURRENCY_FROM : String = "currencyFrom"
    static let TRAVEL_CONVERSION_RATE : String = "conversionRate"
    static let TRAVEL_TRAVEL_TO : String = "travelTo"
    
    // App static variables
    static var IS_RESTORE : Bool = false
    static var IS_LOCAL_RESTORE = false
    static var BASE_URL = "https://services.hysabkytab.app:1400" //LIVE
//    static var BASE_URL = "http://35.238.46.115:1337" // Backup Google Testing UAT
    static var BASE_URL_SYNC = "https://services.hysabkytab.app:1400" //LIVE
//    static var BASE_URL_SYNC = "http://35.238.46.115:1337" //UAT
    static var BASE_URL_RESTORE = "https://services.hysabkytab.app:3000" //LIVE
//    static var BASE_URL_RESTORE = "http://35.238.46.115:3000" //UAT
    
    static var HK_NIT_BASE_URL = "http://35.237.181.250:1337"
    
    static var HK_NIT_PARTNERS = "http://35.237.181.250:1337/api/partners?populate=PartnerImage"
    
    static var ENCRYPTION_KEY = "34BC51A6046A624881701EFD17115CBA"
    static var ENCRYPTION_IV = String(bytes: [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x00], encoding: .utf8)
    
    static let TEXT_FIELD_HSPACE: CGFloat = 6.0
    static let MINIMUM_TEXTFIELD_WIDTH: CGFloat = 56.0
    static let STANDARD_ROW_HEIGHT: CGFloat = 25.0
    
    
    // Strings Temp
    static let TAGS_HELP = "Under this option you tag places. Example hyperstar for grocery, Khaadi for clothing, Dolmen mall for shopping and ginsoy for eating out."
    static let CATEGORY_HELP = "Under this option you can select the most suitable category for your required need. You can add, edit and delete as many categories as you want."
    static let ACCOUNT_HELP = "Under this option you can pay your amount from cash, bank, or any other account that you want to select."
    static let PLACE_HELP = "Pandaguran will automatically trace nearby places."
    static let REMINDER_HELP = "Under this option Pandagiran not only send reminders but also do the auto posting. Which means it will not just remind you but will do the job for you."
    static let ATTACH_RECEIPT_HELP = "Under this option you can attach receipts. So even If you lose your actual receipts you will still have your receipts saved with Pandagiran."
    static let NULL_TEXT = "Unknown Account"
    static let DEFAULT_COLOR = "#2EB0B4"
    
    // User Data
    public static let CONSUMER_ID = "branch_id"
    public static let GENDER = "gender"
    public static let EMAIL = "email"
    public static let TOKEN = "token"
    public static let USER_NAME = "user_name"
    public static let USER_PHONE = "phone"
    public static let CURRENCY = "currency"
    public static let USER_DOB = "dob"
    public static let USER_TYPE = "persona"
    public static let USER_ID = "user_id"
    public static let BACKUP_AVAILABLE = "backup_available"
    // Dynamic Links
    public static let APP_LINK = "https://www.example.com/"
    public static let APP_DOMAIN_LINK = "hysabkytab.page.link"
    
    
}
