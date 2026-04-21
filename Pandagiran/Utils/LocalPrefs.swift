

import Foundation

class LocalPrefs{
    
    static let CURRENT_INTERVAL : String = "CurrentInterval"
    static let USER_CURRENCY : String = "UserCurrency"
    static let USER_NAME : String = "UserName"
    static let USER_EMAIL : String = "Email"
    static let USER_PHONE : String = "Phone"
    static let USER_DETAILS : String = "UserDetails"
    static let IS_VERIFIED : String = "isVerified"
    static let IS_REGISTERED : String = "isRegistered"
    static let DECIMAL_FORMAT : String = "decimalFormat"
    static let INTERVAL_ONBOARDING : String = "IntervalOnboarding"
    static let TRANSACTION_ONBOARDING : String = "TransactionOnboarding"
    static let USER_IMAGE : String = "UserImage"
    static let DEVICE_TOKEN : String = "deviceToken"
    static let TRAVEL_MODE : String = "TravelMode"
    static let TRAVEL_MODE_DETAILS = "TravelModeDetails"
    static let FLAG_URL = "FlagUrl"
    static let IS_DATA_WIPED = "isDataWiped"
    static let PASSCODE = "passcode"
    static let LOCAL_BACKUP_TIME = "localBackupTime"
    static let ICLOUD_BACKUP_TIME = "iCloudBackupTime"
    static let REMINDER_ID = "reminderId"
    static let OVER_VIEW_VISIBILTY = "overviewVisibility"
    static let ACCOUNTS_VISIBILITY = "accountsVisibility"
    static let LAST_RECORDS_VISIBILITY = "lastRecordsVisibilty"
    static let EXPENSE_CHART_VISIBILTY = "expenseChartVisbilty"
    static let INCOME_CHART_VISIBILITY = "incomeChartVisibilty"
    static let IN_APP_VISIBILITY = "inAppVisibility"
    static let PROFESSION_TYPE = "professionType"
    static let COUNTRY_FLAG = "countryFlag"
    static let COUNTRY_NAME = "countryName"
    static let CONSUMER_ID = "consumerId"
    static let DEVICE_ID = "device_id"
    static let ALREADY_REGISTERED = "already_registered"
    static let TAB_BAR_ONBOARDING = "tabBarOnboarding"
    static let DASHBOARD_ONBOARDING = "dashboardOnboarding"
    static let DEALS_ONBOARDING = "dealsOnboarding"
    static let PFM_ONBOARDING = "pfmOnboarding"
    static let USER_INTERESTS = "userInterests"
    static let APP_WALKTHROUGH = "appWalkthrough"
    static let BACKUP_TOTAL_COUNT = "totalRecordsCount"
    static let BACKUP_SYNCED_TOTAL_COUNT = "totalSyncedRecordsCount"
    static let BUDGETS_TOTAL_COUNT = "budgetsTotal"
    static let ACCOUNTS_TOTAL_COUNT = "accountsTotal"
    static let CATEGORIES_TOTAL_COUNT = "categoriesTotal"
    static let EVENTS_TOTAL_COUNT = "eventsTotal"
    static let TRANSACTIONS_TOTAL_COUNT = "transactionTotal"
    static let SAVINGS_TOTAL_COUNT = "savingsTotal"
    static let SAVINGS_TRX_TOTAL_COUNT = "savingTrxTotal"
    static let SYNC_ACCOUNTS_TOTAL_COUNT = "syncAccountsTotal"
    static let SYNC_EVENTS_TOTAL_COUNT = "syncEventsTotal"
    static let SYNC_BUDGETS_TOTAL_COUNT = "syncBugetsTotal"
    static let SYNC_CATEGORY_TOTAL_COUNT = "syncCategoriesTotal"
    static let SYNC_SAVING_TOTAL_COUNT = "syncSavingTotal"
    static let SYNC_SAVING_TRX_TOTAL_COUNT = "syncSavingTrxTotal"
    static let SYNC_TRANSACTION_TOTAL_COUNT = "syncTransactionTotal"
    static let BACKUP_NOTIFICATION = "backUpNotification"
    static let IS_BACKUP_AVAILABLE = "Backup_Available"
    
    static func setBackupTotalCount (totalBackupCount : Int) {
        UserDefaults.standard.setValue(totalBackupCount, forKey: BACKUP_TOTAL_COUNT)
    }
    
    static func getBackupTotalCount () -> Int {
        let backupCount = UserDefaults.standard.integer(forKey: BACKUP_TOTAL_COUNT)
        return backupCount
    }
    
    static func setSyncedBackupTotalCount (totalBackupCount : Int) {
        UserDefaults.standard.setValue(totalBackupCount, forKey: BACKUP_SYNCED_TOTAL_COUNT)
    }
    
    static func getSyncedBackupTotalCount () -> Int {
        let backupCount = UserDefaults.standard.integer(forKey: BACKUP_SYNCED_TOTAL_COUNT)
        return backupCount
    }
    
    static func setAccountsTotalCount (count : Int) {
        UserDefaults.standard.setValue(count, forKey: ACCOUNTS_TOTAL_COUNT)
    }
    
    static func getAccountsTotalCount () -> Int {
        let backupCount = UserDefaults.standard.integer(forKey: ACCOUNTS_TOTAL_COUNT)
        return backupCount
    }
    
    static func setSyncAccountsTotalCount (count : Int) {
        UserDefaults.standard.setValue(count, forKey: SYNC_ACCOUNTS_TOTAL_COUNT)
    }
    
    static func getSyncAccountsTotalCount () -> Int {
        let backupCount = UserDefaults.standard.integer(forKey: SYNC_ACCOUNTS_TOTAL_COUNT)
        return backupCount
    }
    
    static func setTransactionTotal (count : Int) {
        UserDefaults.standard.setValue(count, forKey: TRANSACTIONS_TOTAL_COUNT)
    }
    
    static func getTransactionTotal () -> Int {
        let backupCount = UserDefaults.standard.integer(forKey: TRANSACTIONS_TOTAL_COUNT)
        return backupCount
    }
    
    static func setSyncTransactionTotalCount (count : Int) {
        UserDefaults.standard.setValue(count, forKey: SYNC_TRANSACTION_TOTAL_COUNT)
    }
    
    static func getSyncTransactionTotalCount () -> Int {
        let backupCount = UserDefaults.standard.integer(forKey: SYNC_TRANSACTION_TOTAL_COUNT)
        return backupCount
    }
    
    static func setBudgetsTotal (count : Int) {
        UserDefaults.standard.setValue(count, forKey: BUDGETS_TOTAL_COUNT)
    }
    
    static func getBudgetsTotal () -> Int {
        let backupCount = UserDefaults.standard.integer(forKey: BUDGETS_TOTAL_COUNT)
        return backupCount
    }
    
    static func setSyncBudgetsTotalCount (count : Int) {
        UserDefaults.standard.setValue(count, forKey: SYNC_BUDGETS_TOTAL_COUNT)
    }
    
    static func getSyncBudgetsTotalCount () -> Int {
        let backupCount = UserDefaults.standard.integer(forKey: SYNC_BUDGETS_TOTAL_COUNT)
        return backupCount
    }
    
    static func setEventsTotal (count : Int) {
        UserDefaults.standard.setValue(count, forKey: EVENTS_TOTAL_COUNT)
    }
    
    static func getEventsTotal () -> Int {
        let backupCount = UserDefaults.standard.integer(forKey: EVENTS_TOTAL_COUNT)
        return backupCount
    }
    
    static func setSyncEventsTotalCount (count : Int) {
        UserDefaults.standard.setValue(count, forKey: SYNC_EVENTS_TOTAL_COUNT)
    }
    
    static func getSyncEventsTotalCount () -> Int {
        let backupCount = UserDefaults.standard.integer(forKey: SYNC_EVENTS_TOTAL_COUNT)
        return backupCount
    }
    
    static func setSavingsTotal (count : Int) {
        UserDefaults.standard.setValue(count, forKey: SAVINGS_TOTAL_COUNT)
    }
    
    static func getSavingsTotal () -> Int {
        let backupCount = UserDefaults.standard.integer(forKey: SAVINGS_TOTAL_COUNT)
        return backupCount
    }
    
    static func setSyncSavingTotalCount (count : Int) {
        UserDefaults.standard.setValue(count, forKey: SYNC_SAVING_TOTAL_COUNT)
    }
    
    static func getSyncSavingTotalCount () -> Int {
        let backupCount = UserDefaults.standard.integer(forKey: SYNC_SAVING_TOTAL_COUNT)
        return backupCount
    }
    
    static func setSavingTrxTotal (count : Int) {
        UserDefaults.standard.setValue(count, forKey: SAVINGS_TRX_TOTAL_COUNT)
    }
    
    static func getSavingTrxTotal () -> Int {
        let backupCount = UserDefaults.standard.integer(forKey: SAVINGS_TRX_TOTAL_COUNT)
        return backupCount
    }
    
    static func setSyncSavingTrxTotalCount (count : Int) {
        UserDefaults.standard.setValue(count, forKey: SYNC_SAVING_TRX_TOTAL_COUNT)
    }
    
    static func getSyncSavingTrxTotalCount () -> Int {
        let backupCount = UserDefaults.standard.integer(forKey: SYNC_SAVING_TRX_TOTAL_COUNT)
        return backupCount
    }
    
    static func setCategoriesTotal (count : Int) {
        UserDefaults.standard.setValue(count, forKey: CATEGORIES_TOTAL_COUNT)
    }
    
    static func getCategoriesTotal () -> Int {
        let backupCount = UserDefaults.standard.integer(forKey: CATEGORIES_TOTAL_COUNT)
        return backupCount
    }
    
    static func setSyncCategoriesTotalCount (count : Int) {
        UserDefaults.standard.setValue(count, forKey: SYNC_CATEGORY_TOTAL_COUNT)
    }
    
    static func getSyncCategoriesTotalCount () -> Int {
        let backupCount = UserDefaults.standard.integer(forKey: SYNC_CATEGORY_TOTAL_COUNT)
        return backupCount
    }
    
    static func setCurrentInterval (currentInterval : String) {
        UserDefaults.standard.setValue(currentInterval, forKey: CURRENT_INTERVAL)
    }
//    static func setChartCurrentInterval (currentInterval : String) {
//        UserDefaults.standard.setValue(currentInterval, forKey: CURRENT_INTERVAL)
//    }
//    static func getChartCurrentInterval () -> String {
//        let currentInterval = UserDefaults.standard.string(forKey: CURRENT_INTERVAL)
//        return currentInterval!
//    }
    static func getCurrentInterval () -> String {
        let currentInterval = UserDefaults.standard.string(forKey: CURRENT_INTERVAL)
        return currentInterval!
    }
    
    static func setUserCurrency (userCurrency : String) {
        UserDefaults.standard.setValue(userCurrency, forKey: USER_CURRENCY)
    }
    
    static func getUserCurrency () -> String {
        let userCurrency = UserDefaults.standard.string(forKey: USER_CURRENCY)
        return userCurrency!
    }
    
    static func setUserName (userName : String) {
        UserDefaults.standard.setValue(userName, forKey: USER_NAME)
    }
    
    static func getUserName () -> String {
        let userName = UserDefaults.standard.string(forKey: USER_NAME)
        return userName ?? ""
    }
    
    static func setUserEmail (userEmail : String) {
        UserDefaults.standard.setValue(userEmail, forKey: USER_EMAIL)
    }
    
    static func getUserEmail () -> String {
        let userEmail = UserDefaults.standard.string(forKey: USER_EMAIL)
        return userEmail ?? LocalPrefs.getUserData()[Constants.EMAIL]!
    }
    
    static func setConsumerId (userId : Int64) {
        UserDefaults.standard.setValue(userId, forKey: CONSUMER_ID)
    }
    
    static func getConsumerId () -> Int64 {
        let userId = UserDefaults.standard.integer(forKey: CONSUMER_ID)
        return Int64(userId)
    }
    
    
    static func setDeviceId (deviceId : String) {
        UserDefaults.standard.setValue(deviceId, forKey: DEVICE_ID)
    }
    
    static func getDeviceId () -> String {
        let deviceId = UserDefaults.standard.string(forKey: DEVICE_ID)
        return deviceId ?? ""
    }
    
    static func setAlreadyRegistered (registered : Bool) {
        UserDefaults.standard.setValue(registered, forKey: ALREADY_REGISTERED)
    }
    
    static func getAlreadyRegistered () -> Bool {
        let alreadyRegistered = UserDefaults.standard.bool(forKey: ALREADY_REGISTERED)
        return alreadyRegistered
    }
    
    static func setUserPhone (userPhone : String) {
        UserDefaults.standard.setValue(userPhone, forKey: USER_PHONE)
    }
    
    static func getUserPhone () -> String {
        UserDefaults.standard.register(defaults: [USER_PHONE : ""])
        let userPhone = UserDefaults.standard.string(forKey: USER_PHONE)
        return userPhone!
    }
    
    static func setDeviceToken (deviceToken : String) {
        UserDefaults.standard.setValue(deviceToken, forKey: DEVICE_TOKEN)
    }
    
    static func getDeviceToken () -> String {
        let deviceToken = UserDefaults.standard.string(forKey: DEVICE_TOKEN)
        return deviceToken!
    }
    
    static func setCurrencyFlag (currencyFlag : String) {
        UserDefaults.standard.setValue(currencyFlag, forKey: FLAG_URL)
    }
    
    static func getCurrencyFlag () -> String {
        let currencyFlag = UserDefaults.standard.string(forKey: FLAG_URL)
        return currencyFlag!
    }
    
    static func setPasscode (passcode : String?) {
        UserDefaults.standard.setValue(passcode, forKey: PASSCODE)
    }
    
    static func getPasscode () -> String {
        let passcode = UserDefaults.standard.string(forKey: PASSCODE)
        return passcode!
    }
    
    static func setLocalBackupTime (backupTime : String?) {
        UserDefaults.standard.setValue(backupTime, forKey: LOCAL_BACKUP_TIME)
    }
    
    static func getLocalBackupTime () -> String {
        let backupTime = UserDefaults.standard.string(forKey: LOCAL_BACKUP_TIME)
        return backupTime!
    }
    
    static func setiCloudBackupTime (backupTime : String?) {
        UserDefaults.standard.setValue(backupTime, forKey: ICLOUD_BACKUP_TIME)
    }
    
    static func getiCloudBackupTime () -> String {
        let backupTime = UserDefaults.standard.string(forKey: ICLOUD_BACKUP_TIME)
        return backupTime!
    }
    
    static func setProfessionType (professionType : String) {
        UserDefaults.standard.setValue(professionType, forKey: PROFESSION_TYPE)
    }
    
    static func getProfessionType () -> String {
        let professionType = UserDefaults.standard.string(forKey: PROFESSION_TYPE)
        return professionType!
    }
    
    static func setCountryFlag (countryFlag : String) {
        UserDefaults.standard.setValue(countryFlag, forKey: COUNTRY_FLAG)
    }
    
    static func getCountryFlag () -> String {
        UserDefaults.standard.register(defaults: [COUNTRY_FLAG : ""])
        let countryFlag = UserDefaults.standard.string(forKey: COUNTRY_FLAG)
        return countryFlag!
    }
    
    static func setCountryName (countryName : String) {
        UserDefaults.standard.setValue(countryName, forKey: COUNTRY_NAME)
    }
    
    static func getCountryName () -> String {
        UserDefaults.standard.register(defaults: [COUNTRY_NAME : "N/A"])
        let countryName = UserDefaults.standard.string(forKey: COUNTRY_NAME)
        return countryName!
    }
    
    static func setReminderId (reminderId : Int?) {
        UserDefaults.standard.setValue(reminderId, forKey: REMINDER_ID)
    }
    
    static func getReminderId () -> Int {
        let reminderId = UserDefaults.standard.integer(forKey: REMINDER_ID)
        return reminderId
    }
    
    
    public static func setIsTabbarOnboardingShown (isShown : Bool) {
        UserDefaults.standard.setValue(isShown, forKey: TAB_BAR_ONBOARDING)
    }
    
    public static func getIsTabbarOnboardingShown() -> Bool {
        let onboardingShown = UserDefaults.standard.bool(forKey: TAB_BAR_ONBOARDING)
        return onboardingShown
    }
    
    public static func setIsDashboardOnboardingShown (isShown : Bool) {
        UserDefaults.standard.setValue(isShown, forKey: DASHBOARD_ONBOARDING)
    }
    
    public static func getIsDashboardOnboardingShown() -> Bool {
        let onboardingShown = UserDefaults.standard.bool(forKey: DASHBOARD_ONBOARDING)
        return onboardingShown
    }
    
    public static func setIsDealsOnboardingShown (isShown : Bool) {
        UserDefaults.standard.setValue(isShown, forKey: DEALS_ONBOARDING)
    }
    
    public static func getIsDealsOnboardingShown() -> Bool {
        let onboardingShown = UserDefaults.standard.bool(forKey: DEALS_ONBOARDING)
        return onboardingShown
    }
    
    public static func setIsPfmOnboardingShown (isShown : Bool) {
        UserDefaults.standard.setValue(isShown, forKey: PFM_ONBOARDING)
    }
    
    public static func getIsPfmOnboardingShown() -> Bool {
        let onboardingShown = UserDefaults.standard.bool(forKey: PFM_ONBOARDING)
        return onboardingShown
    }
    
   
    
    static func setInappVisibility (visibilty : Bool) {
        UserDefaults.standard.setValue(visibilty, forKey: IN_APP_VISIBILITY)
    }
    
    static func getInappVisibility() -> Bool {
        let inappVisibility = UserDefaults.standard.bool(forKey: IN_APP_VISIBILITY)
        return inappVisibility
    }
    
    static func setUserData(userDetails : [String : String]) {
        UserDefaults.standard.setValue(userDetails, forKeyPath: USER_DETAILS)
    }
    
    static func getUserData() -> [String : String] {
        return UserDefaults.standard.dictionary(forKey: USER_DETAILS) as! [String : String]
    }
    
    
    
    static func setIsVerified(isVerified : Bool) {
        UserDefaults.standard.setValue(isVerified, forKeyPath: IS_VERIFIED)
    }
    
    static func getIsVerified() -> Bool {
        return UserDefaults.standard.bool(forKey: IS_VERIFIED)
    }
    
    static func setIsRegistered(isRegistered : Bool) {
        UserDefaults.standard.setValue(isRegistered, forKeyPath: IS_REGISTERED)
    }
    
    static func getIsRegistered() -> Bool {
        return UserDefaults.standard.bool(forKey: IS_REGISTERED)
    }
    
    static func setIsBackupAvailable(isAvailable : Bool) {
        UserDefaults.standard.setValue(isAvailable, forKeyPath: IS_BACKUP_AVAILABLE)
    }
    
    static func getIsBackupAvailable() -> Bool {
        return UserDefaults.standard.bool(forKey: IS_BACKUP_AVAILABLE)
    }
    
    static func setDecimalFormat(decimalFormat : Int) {
        UserDefaults.standard.setValue(decimalFormat, forKeyPath: DECIMAL_FORMAT)
    }
    
    static func getDecimalFormat() -> Int {
        return UserDefaults.standard.integer(forKey: DECIMAL_FORMAT)
    }
    
    static func setIsIntervalOnboardingShown(isShown : Bool) {
        UserDefaults.standard.setValue(isShown, forKeyPath: INTERVAL_ONBOARDING)
    }
    
    static func getIsIntervalOnboardingShown () -> Bool {
        return UserDefaults.standard.bool(forKey: INTERVAL_ONBOARDING)
    }
    
    static func setIsTransactionOnboardingShown(isShown : Bool) {
        UserDefaults.standard.setValue(isShown, forKeyPath: TRANSACTION_ONBOARDING)
    }
    
    static func getIsTransactionOnboardingShown () -> Bool {
        return UserDefaults.standard.bool(forKey: TRANSACTION_ONBOARDING)
    }
    
    static func setUserImage (data : Data) {
        UserDefaults.standard.set(data, forKey: USER_IMAGE)
    }
    
    static func getUserImage () -> Data {
        return UserDefaults.standard.object(forKey: USER_IMAGE) as! Data
    }
    
    static func setIsTravelMode(isTravelModeOn : Bool) {
        UserDefaults.standard.setValue(isTravelModeOn, forKeyPath: TRAVEL_MODE)
    }
    
    static func getIsTravelMode() -> Bool {
        return UserDefaults.standard.bool(forKey: TRAVEL_MODE)
    }
    
    static func setIsDataWiped(isDataWiped : Bool) {
        UserDefaults.standard.setValue(isDataWiped, forKeyPath: IS_DATA_WIPED)
    }
    
    static func getIsDataWiped() -> Bool {
        return UserDefaults.standard.bool(forKey: IS_DATA_WIPED)
    }
    
    static func setTravelModeDetails(travelModeDetails : [String : String]) {
        UserDefaults.standard.setValue(travelModeDetails, forKeyPath: TRAVEL_MODE_DETAILS)
    }
    
    static func getTravelModeDetails() -> [String : String] {
        return UserDefaults.standard.dictionary(forKey: TRAVEL_MODE_DETAILS) as! [String : String]
    }
    
    static func checkForNil (key : String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    static func setUserInterests (userInterets : String) {
        UserDefaults.standard.setValue(userInterets, forKey: USER_INTERESTS)
    }
    
    static func getUserInterests () -> String {
        UserDefaults.standard.register(defaults: [USER_INTERESTS : "N/A"])
        let userInterests = UserDefaults.standard.string(forKey: USER_INTERESTS)
        return userInterests!
    }

    static func setUpdateMessage(isShown : Bool) {
        UserDefaults.standard.setValue(isShown, forKeyPath: BACKUP_NOTIFICATION)
    }
    
    static func getUpdateMessage () -> Bool {
        return UserDefaults.standard.bool(forKey: BACKUP_NOTIFICATION)
    }
    
}
