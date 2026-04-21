

import Foundation
import CoreData

class Utils {
    static var monthArray = ["Jan" , "Feb" , "Mar" , "Apr" , "May" , "Jun" , "Jul" , "Aug" , "Sep" , "Oct" , "Nov" , "Dec"]
    static let currentMonth = getCurrentMonth()
    static let currentYear = getCurrentYear()
    static var monthlyArray : Array<MonthlyInterval> = []
    static let daysOfWeek : [Int : String] = [1 : "Mon" , 2 : "Tue" , 3 : "Wed" , 4 : "Thu" , 5 : "Fri" , 6 : "Sat" , 7 : "Sun"]
    static let reminderDays = [1 : "Sunday" , 2 : "Monday" , 3 : "Tuesday" , 4 : "Wednesday" , 5 : "Thursday" , 6 : "Friday" , 7 : "Saturday"]
    static var currentPagerIndex : Int = getCurrentMonth()
    
    
    public static func readJson(resourceName : String) -> Array<Any> {
        do {
//            if let file = Bundle.main.path(forResource: resourceName, ofType: "json") {
//                let data = try Data(contentsOf: URL(fileURLWithPath: file), options: .mappedIfSafe)
            if let file = Bundle.main.url(forResource: resourceName, withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    // json is a dictionary
                    print(object)
                } else if let object = json as? [Any] {
                    // json is an array
                    print(object)
                    print("Returning an array")
                    return object
                } else {
                    print("Error reading json : " , "JSON is invalid")
                }
            } else {
                print("Error reading json : " , "no file")
            }
        } catch {
            print("Error reading json : " , error.localizedDescription)
        }
        
    return []
    }
    
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func getCurrentMonth () -> Int
    {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let nameOfMonth = dateFormatter.string(from: now)
        print("Name of month : " , nameOfMonth)
        return Int(nameOfMonth)!
    }
    
    static func getCurrentYear () -> Int {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let nameOfYear = dateFormatter.string(from: now)
        return Int(nameOfYear)!
    }
    
    static func getMonthFromInt(num : Int) -> String {
        var month : String = ""
        if num >= 0 && num <= 11 {
            month = monthArray[num]
        }
        
        return month
    }
    
    static func noOfPages(currentInterval : String) -> Int {
        var noOfItem : Int = 0
        if currentInterval == Constants.MONTHLY {
//             TimeIntervalUtils.getMonthlyInterval(monthlyArray: &monthlyArray)
            noOfItem = monthlyArray.count
            return noOfItem
        } else if currentInterval == Constants.HALF_YEARLY {
            noOfItem = 3
            return noOfItem
        } else if currentInterval == Constants.QUARTERLY {
            noOfItem = 4
            return noOfItem
        } else if currentInterval == Constants.YEARLY {
            noOfItem = 3
            return noOfItem
        } else {
            noOfItem = 1
            return noOfItem
        }
    }
    
    static func customSubstring (givenString : String , location : Int , endIndex : Int) -> String {
        let stringToSubString =  givenString
        let myNSString = stringToSubString as NSString
        let newStr = myNSString.substring(with: NSRange(location: location, length: endIndex))
        return newStr
    }
    
    static func getInitialPagerIndex(currentInterval : String ) -> Int {
        var index : Int
        var monthlyIndex : Int = currentMonth
//        TimeIntervalUtils.getMonthlyInterval(monthlyArray: &monthlyArray)
        if currentInterval == Constants.MONTHLY {
            for i in 0 ..< monthlyArray.count {
                if monthlyArray[i].monthNumeric == currentMonth {
                    monthlyIndex = i
                }
            }
            index = monthlyArray.count - (monthlyIndex + 1)
        } else if (currentInterval == Constants.HALF_YEARLY) {
            index = (3 - 2)
        } else if currentInterval == Constants.YEARLY {
            index = (3 - 2)
        } else if currentInterval == Constants.QUARTERLY {
            index = (4 - 3)
        } else {
            index = 0
        }
        
        return index
    }
    
    static func splitMonthsRange(range : String) -> (Int , Int) {
        var splitArray = range.split{$0 == "-"}.map(String.init)
        return (Int(splitArray[0]) ?? 0 , Int(splitArray[1]) ?? 3)
    }
    
    static func currentDateUserFormat(date : Date) -> String {
        let voucherDate : String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        voucherDate = dateFormatter.string(from: date)
        return voucherDate
    }
    
    static func formatStringDate(dateString : String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let dateToConvert = dateFormatter.date(from: dateString) {
            let dateformatted = DateFormatter()
            dateformatted.dateFormat = "dd MMM yyyy"
            return dateformatted.string(from: dateToConvert)
        } else {
            return Utils.currentDateUserFormat(date: Date())
        }
        
    }
    
    static func currentDateDbFormat(date : Date) -> String {
        let voucherDate : String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        voucherDate = dateFormatter.string(from: date)
        return voucherDate
    }
    
    static func dobFormat (date: Date) -> String {
        let formattedDate : String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
    
    static func currentDateReminderFormat(date : Date) -> String {
        let voucherDate : String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        voucherDate = dateFormatter.string(from: date)
        return voucherDate
    }
    
    static func convertStringToDate (dateString : String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let dateToConvert = dateFormatter.date(from: dateString) {
            return dateToConvert
        }
        
        return Date()
    }
    
    static func convertStringToOnlyDate(dateString : String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let dateToConvert = dateFormatter.date(from: dateString) {
            let stringDate = dateFormatter.string(from: dateToConvert)
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.date(from: stringDate)!
            return date
        }
        return Date()
    }
    
    static func getDayMonthAndYear(givenDate : String , dayMonthOrYear : String) -> Int16 {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: givenDate)
        let dateFormatted = DateFormatter()
        dateFormatted.dateFormat = "dd MMM yyyy"
        let dateformated = dateFormatted.date(from: givenDate)
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date ?? dateformated!)
        
        if dayMonthOrYear == "month" {
            return Int16(components.month!)
        } else if dayMonthOrYear == "year" {
            return Int16(components.year!)
        } else if dayMonthOrYear == "day" {
            return Int16(components.day!)
        }
        
        return 0
    }
    
    static func getDayString (today : String) -> Int {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let todayDate = formatter.date(from: today) {
            let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
            let myComponents = myCalendar.components(.weekday, from: todayDate)
            let weekDay = myComponents.weekday
            
            if weekDay! == 1 {
                return 7
            } else {
                return weekDay! - 1
            }
        } else {
            let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
            let myComponents = myCalendar.components(.weekday, from: Date())
            let weekDay = myComponents.weekday
            
            if weekDay! == 1 {
                return 7
            } else {
                return weekDay! - 1
            }
        }
        
    }

    
    static func setInitialMonthFromCollection (currentInterval : String) -> Int {
        var indexToSelect : Int = 0
        if currentInterval == Constants.MONTHLY {
//            TimeIntervalUtils.getMonthlyInterval(monthlyArray: &monthlyArray)
            for i in 0 ..< monthlyArray.count {
                if monthlyArray[i].monthNumeric == currentPagerIndex {
                    indexToSelect = i
                }
            }
            return indexToSelect
        } else if currentInterval == Constants.HALF_YEARLY {
            indexToSelect = 1
            return indexToSelect
        } else if currentInterval == Constants.QUARTERLY {
            indexToSelect = 2
            return indexToSelect
        } else if currentInterval == Constants.YEARLY {
            indexToSelect = 1
            return indexToSelect
        } else {
            indexToSelect = 0
            return indexToSelect
        }
    }
    
    static func getInitialIntervalIndex (currentInterval : String) -> Int {
        monthlyArray = TimeIntervalUtils.getMonthlyInterval()
        var indexToSelect : Int = 0
        
        switch currentInterval {
        case Constants.MONTHLY:
            indexToSelect = (monthlyArray.count - 2)
        case Constants.HALF_YEARLY:
            indexToSelect = 1
        case Constants.QUARTERLY:
            indexToSelect = 2
        case Constants.YEARLY:
            indexToSelect = 1
        default:
            indexToSelect = 0
        }
        
        return indexToSelect
    }
   
    public static func convertVchIntoDict(object : NSManagedObject) -> Dictionary<String , Any> {
        let keys = Array(object.entity.attributesByName.keys)
        let dict = object.dictionaryWithValues(forKeys: keys)

        return dict
    }
    
    public static func formatDecimalNumber(number : Double , decimal : Int) -> String {
        let formattedNumber : String?
        formattedNumber = String(format : "%.\(decimal)f" , number)

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.minimumFractionDigits = decimal
        numberFormatter.locale = Locale.current
        
        let groupedSeperatedString = numberFormatter.string(from: NSNumber(value : (number)))
        return groupedSeperatedString!
    }
    
    static func isValidEmail(vc: UIViewController,string: String, errorMsg: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let validationSuccess = emailTest.evaluate(with: string)
        
        if validationSuccess {
            return true
        } else {
            UIUtils.showAlert(vc: vc, message: errorMsg)
            return false
        }
    }
    
    static func validateString (vc: UIViewController,string: String, errorMsg: String) -> Bool {
        if string != "" {
            return true
        } else {
            UIUtils.showAlert(vc: vc, message: errorMsg)
            return false
        }
    }
    
    static func validateAmount (vc: UIViewController,amount: Double, errorMsg: String) -> Bool {
        if amount != 0 {
            return true
        } else {
            UIUtils.showAlert(vc: vc, message: errorMsg)
            return false
        }
    }
    
    static func validatePhone (vc: UIViewController,string: String, errorMsg: String) -> Bool {
        if string != ""  {
            return true
        } else {
            UIUtils.showAlert(vc: vc, message: errorMsg)
            return false
        }
    }
    
    static func validateInt (vc: UIViewController, intValue: Int64, errorMsg: String) -> Bool {
        if intValue != 0 {
            return true
        } else {
            UIUtils.showAlert(vc: vc, message: errorMsg)
            return false
        }
    }
    
    static func removeComma (numberString : String) -> Double {
        var amount : Double = 0
        let commalessString = numberString.replacingOccurrences(of: ",", with: "")
        let trimmedString = commalessString.replacingOccurrences(of: " ", with: "")
        
        if let numberToReturn = Double(trimmedString) {
            amount = numberToReturn
        }
        
        return amount
    }
    
    static func sha256(data : Data) -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(data.count), &hash)
        }
        return Data(bytes: hash)
    }
    
    static func getRandomString(size: Int) -> String {
        let alphabet: [String] = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
        var availableTiles = [String]()
        for _ in 0..<size {
            let rand = Int(arc4random_uniform(26))
            availableTiles.append(alphabet[rand])
        }
        
        let convertString = availableTiles.joined(separator: "")
        return convertString
    }
    
    static func genearateSha256 (string : String) -> String {
        let data = sha256(data: (string.data(using: .utf8))!)
        let generatedString = data.map { String(format: "%02hhx", $0) }.joined()
        return generatedString
    }
    
    static func isDateBetween(_ date1: Date, and date2: Date , middleDate : Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(middleDate)
    }
    
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    static func convertToJSONArray(moArray: [NSManagedObject]) -> Any {
        var jsonArray: [[String: Any]] = []
        for item in moArray {
            var dict: [String: Any] = [:]
            for attribute in item.entity.attributesByName {
                //check if value is present, then add key to dictionary so as to avoid the nil value crash
                if let value = item.value(forKey: attribute.key) {
                    dict[attribute.key] = value
                }
            }
            jsonArray.append(dict)
        }
        return jsonArray
    }
    
    static func formatDateExcludingTime (dateString: String) -> Date {
        var date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let dateFromString = dateFormatter.date(from: dateString.components(separatedBy: " ").first ?? "") {
            date = dateFromString
        }
        
        return date
    }
    
    static func timeAgoStringFromDate(date: Date) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        
        let now = Date()
        
        let calendar = NSCalendar.current
        let components1: Set<Calendar.Component> = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
        let components = calendar.dateComponents(components1, from: date, to: now)
        
        if components.year ?? 0 > 0 {
            formatter.allowedUnits = .year
        } else if components.month ?? 0 > 0 {
            formatter.allowedUnits = .month
        } else if components.weekOfMonth ?? 0 > 0 {
            formatter.allowedUnits = .weekOfMonth
        } else if components.day ?? 0 > 0 {
            formatter.allowedUnits = .day
        } else if components.hour ?? 0 > 0 {
            formatter.allowedUnits = [.hour]
        } else if components.minute ?? 0 > 0 {
            formatter.allowedUnits = .minute
        } else {
            formatter.allowedUnits = .second
        }
        
        let formatString = NSLocalizedString("%@ ago", comment: "Used to say how much time has passed. e.g. '2 hours ago'")
        
        guard let timeString = formatter.string(for: components) else {
            return nil
        }
        return String(format: formatString, timeString)
    }
    
    public static func getDaySuffix (day: String) -> String {
        switch (day) {
        case "1" , "21" , "31":
            return "\(day)st"
        case "2" , "22":
            return "\(day)nd"
        case "3" ,"23":
            return "\(day)rd"
        default:
            return "\(day)th"
        }
    }
    
    public static func convertDictIntoJson (object: Any) -> String {
        var reqJSONStr = ""
        
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
            reqJSONStr = String(data: jsonData, encoding: .utf8)!
            print(reqJSONStr)
        }catch{
            print("Error occured")
        }
        
        return reqJSONStr
    }
    
    static func roundCorners(view: UIView, corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        view.layer.mask = mask
    }
    
    static func convertStringToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    public static func getTimeString (date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" // for specifying the change to format hour:minute am/pm.
        return dateFormatter.string(from: date)
    }
    
    public static func getAmountNotation (amount : Double, decimal: Int) -> String {
        var annotationAmount = ""
        
        if amount >= 1000 {
            annotationAmount = "\(String(format : "%.\(decimal)f" , (amount / 1000)))K"
        } else {
            annotationAmount = String(format : "%.\(LocalPrefs.getDecimalFormat())f" , amount)
        }
        
        
        return annotationAmount
        
        
    }
    
    static func getUniqueId() -> Int64{
        let timeInterval = Date().timeIntervalSince1970
        let randomInt = Int64.random(in: 1..<1000)
        let uniqueID = Int64(timeInterval) + randomInt
        print("Self generated unique Id: \(uniqueID)")
        return uniqueID
    }
}

