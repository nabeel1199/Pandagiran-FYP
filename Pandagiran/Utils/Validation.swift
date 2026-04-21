

import Foundation


enum AlertMessages: String {
    case inValidEmail = "The enter a valid email"
    case emptyAmount = "Please enter the amount"
    case emptyCategory = "Please enter the category title"
    case emptyAccount = "Please enter the account title"
    case emptyGoal = "Please enter the goal title"
    case emptyReminder = "Please enter the reminder title"
    case emptyEvent = "Please enter the event title"
    case emptyCategoryId = "Please select a category"
    case emptyAccountId = "Please select an account"
    case emptytravelCurrency = "Please select the travel mode currency"
    case conversionRate = "Please enter the conversion rate"
    case emptyDate = "Please select the date"
    case dob = "Please select date of birth"
    case gender = "Please select gender"
    case persona = "Please select persona"
    
    func localized() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

enum Valid {
    case success
    case failure(Alert, AlertMessages)
}

enum Alert {        //for failure and success results
    case success
    case failure
    case error
}

enum ValidationType {
    case amount
    case email
    case accountTitle
    case categoryTitle
    case reminderTitle
    case eventTitle
    case goalTitle
    case categoryId
    case accountId
    case travelCurrency
    case conversionRate
    case dob
    case date
    case gender
    case persona
}

enum RegEx: String {
    case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" // Email
    case password = "^.{6,15}$" // Password length 6-15
    case emptyString = "^[a-zA-Z ]*$"

}

class  Validation: NSObject {
    
    public static let shared = Validation()
    
    func validate(values: (type: ValidationType, inputValue: String)...) -> Valid {
        for valueToBeChecked in values {
            switch valueToBeChecked.type {
            case .amount:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .emptyAmount)) {
                    return tempValue
                }
            case .email:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .inValidEmail)) {
                    return tempValue
                }
            case .accountTitle:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .emptyAccount)) {
                    return tempValue
                }
            case .categoryTitle:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .emptyCategory)) {
                    return tempValue
                }
            case .reminderTitle:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .emptyReminder)) {
                    return tempValue
                }
            case .eventTitle:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .emptyEvent)) {
                    return tempValue
                }
            case .goalTitle:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .emptyGoal)) {
                    return tempValue
                }
            case .categoryId:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .emptyCategoryId)) {
                    return tempValue
                }
            case .accountId:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .emptyAccountId)) {
                    return tempValue
                }
            case .travelCurrency:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .emptytravelCurrency)) {
                    return tempValue
                }
            case .conversionRate:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .conversionRate)) {
                    return tempValue
                }
            case .date:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .emptyDate)) {
                    return tempValue
                }
            case .gender:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .gender)) {
                    return tempValue
                }
            case .dob:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .dob)) {
                    return tempValue
                }
            case .persona:
                if let tempValue = isValidString((valueToBeChecked.inputValue, .persona)) {
                    return tempValue
                }
            }
        }
        return .success
    }
    
    func isValidString(_ input: (text: String, invalidAlert: AlertMessages)) -> Valid? {
        if input.text.isEmpty || input.text == "0" || input.text == "---" {
            return .failure(.error, input.invalidAlert)
        }
//        else if isValidRegEx(input.text, input.regex) != true {
//            return .failure(.error, input.invalidAlert)
//        }
        return nil
    }
    
    func isValidRegEx(_ testStr: String, _ regex: RegEx) -> Bool {
        let stringTest = NSPredicate(format:"SELF MATCHES %@", regex.rawValue)
        let result = stringTest.evaluate(with: testStr)
        return result
    }
    
    func validateFields (vc: UIViewController, text: String, unselectedField: String) -> Bool {
        if text != "0" && !text.isEmpty {
            return true
        } else {
            UIUtils.showAlert(vc: vc, message: "Please select \(unselectedField)")
            return false
        }
    }
}
