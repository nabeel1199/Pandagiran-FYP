

import Foundation
import Alamofire
import SwiftyJSON

typealias ServiceResponse = (_ success: Int, _ responseMessage: String, _ error: AFError?) -> Void
class VoucherNetworkCalls {
    
    static let sharedInstance = VoucherNetworkCalls()
   
    public func postVoucher (voucher: Hkb_voucher, voucher2: Hkb_voucher?, isUpdate : Bool) {
        var vouchers = ""
        let vch = Utils.convertVchIntoDict(object: voucher)
        
        if voucher.vch_type == Constants.TRANSFER {
            let vch2 = Utils.convertVchIntoDict(object: voucher2!)
            let arrayOfVch = [vch , vch2]
            vouchers = Utils.convertDictIntoJson(object: arrayOfVch)
        } else {
            vouchers = Utils.convertDictIntoJson(object: vch)
        }
        
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
                print("AccountPostHeader: \(response.response?.allHeaderFields)")
                print("Response : " , response)
                switch response.result {
                case .success:
                    let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    
                    if status == 1 {
                            voucher.is_synced = 1
                            voucher2?.is_synced = 1
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
                }
        }
    }
    
    
    // MARK: - Backup Voucher API Call
    public func backupVoucher(voucher: Hkb_voucher, completion: @escaping ServiceResponse) {
        var vouchers = ""
        let vch = Utils.convertVchIntoDict(object: voucher)
        
        vouchers = Utils.convertDictIntoJson(object: vch)
        
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        let URL = "\(Constants.BASE_URL_SYNC)/transactions/save"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        let httpMethod = Alamofire.HTTPMethod.post
        let dictToEncrypt =  ["vouchers" : vouchers,
                              "device_type" : "Ios",
                              "consumer_id" : consumerId]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        //        let params = ["u" : dictToEncrypt]
        
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
                    
                    if status == 1 {
                        voucher.is_synced = 1
                    } else {
                        if message == "Record Already Exist" {
                            voucher.is_synced = 1
                        } else {
                            voucher.is_synced = 0
//                            NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                        }
                        
                    }
                    print(message)
                    DbController.saveContext()
                    completion(status, message, nil)
                case .failure(let error):
                    print(error)
                    let status = 0
                    let message = "Failed"
                    voucher.is_synced = 0
                    DbController.saveContext()
//                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    completion(status, message, nil)
                }
        }
    }
    
    // MARK: - Backup Accounts API Call
    public func backupAccounts (account : Hkb_account, completion: @escaping ServiceResponse) {
        let accountDetails = Utils.convertVchIntoDict(object: account)
        let accountJson = Utils.convertDictIntoJson(object: accountDetails)
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        let URL = "\(Constants.BASE_URL_SYNC)/account/save"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        
        let httpMethod = Alamofire.HTTPMethod.post
        let dictToEncrypt =  ["accounts" : accountJson,
                              "device_type" : "Ios",
                              "consumer_id" : consumerId]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
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
                        account.is_synced = 1
                    } else {
                        if message == "Record Already Exist" {
                            account.is_synced = 1
                        } else {
                            account.is_synced = 0
//                            NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                        }
                        
                    }
                    
                    DbController.saveContext()
                    completion(status, message, nil)
                    
                case .failure(let error):
                    account.is_synced = 0
                    print(error)
                    let status = 0
                    let message = "Failed"
                    DbController.saveContext()
//                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    completion(status, message, nil)
                    
                }
        }
    }
    
    // MARK: - Backup Category API Call
    public func backupCategory (category : Hkb_category, completion: @escaping ServiceResponse) {
        let categoryDetails = Utils.convertVchIntoDict(object: category)
        let categoryJson = Utils.convertDictIntoJson(object: categoryDetails)
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        let URL = "\(Constants.BASE_URL_SYNC)/category/save"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        let httpMethod = Alamofire.HTTPMethod.post
        let dictToEncrypt =  ["categories" : categoryJson,
                              "device_type" : "Ios",
                              "consumer_id" : consumerId]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        //        let params = ["u" : dictToEncrypt]
        
        
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
                        category.is_synced = 1
                    } else {
                        if message == "Record Already Exist" {
                            category.is_synced = 1
                        } else {
                            category.is_synced = 0
//                            NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                        }
                        
                    }
                    
                    DbController.saveContext()
                    completion(status, message, nil)
                    
                case .failure(let error):
                    category.is_synced = 0
                    print(error)
                    let status = 0
                    let message = "Failed"
                    DbController.saveContext()
//                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    completion(status, message, nil)
                }
        }
    }
    
    // MARK: - Backup Events API Call
    public func backupEvents (event : Hkb_event, completion: @escaping ServiceResponse) {
        let eventDetails = Utils.convertVchIntoDict(object: event)
        let eventsJson = Utils.convertDictIntoJson(object: eventDetails)
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        let URL = "\(Constants.BASE_URL_SYNC)/event/save"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        
        let httpMethod = Alamofire.HTTPMethod.post
        let dictToEncrypt =  ["events" : eventsJson,
                              "device_type" : "Ios",
                              "consumer_id" : consumerId]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
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
                        if message == "Record Already Exist" {
                            event.is_synced = 1
                        } else {
                            event.is_synced = 0
//                            NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                        }
                        
                    }
                    
                    DbController.saveContext()
                    completion(status, message, nil)
                    
                case .failure(let error):
                    event.is_synced = 0
                    print(error)
                    let status = 0
                    let message = "Failed"
                    DbController.saveContext()
//                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    completion(status, message, nil)
                    //                    UIUtils.showAlert(vc: self, message: error.localizedDescription)
                }
        }
    }
    
    // MARK: - Backup Goals API Call
    public func backupGoal (goal : Hkb_goal, completion: @escaping ServiceResponse) {
        let goalDetails = Utils.convertVchIntoDict(object: goal)
        let goalsJson = Utils.convertDictIntoJson(object: goalDetails)
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        let URL = "\(Constants.BASE_URL_SYNC)/saving/save"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        
        let httpMethod = Alamofire.HTTPMethod.post
        let dictToEncrypt =  ["savings" : goalsJson,
                              "device_type" : "Ios",
                              "consumer_id" : consumerId]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
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
                    
                    if status == 1 {
                        goal.is_synced = 1
                    } else {
                        if message == "Record Already Exist" {
                            goal.is_synced = 1
                        } else {
                            goal.is_synced = 0
//                            NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                        }
                        
                    }
                    
                    DbController.saveContext()
                    completion(status, message, nil)
                    
                case .failure(let error):
                    goal.is_synced = 0
                    print(error)
                    let status = 0
                    let message = "Failed"
                    DbController.saveContext()
//                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    completion(status, message, nil)
                    
                }
        }
    }
    
    // MARK: - Backup Budget API Call
    public func backupBudget (budget : Hkb_budget, completion: @escaping ServiceResponse) {
        let budgetDetails = Utils.convertVchIntoDict(object: budget)
        let budgetJson = Utils.convertDictIntoJson(object: budgetDetails)
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        let URL = "\(Constants.BASE_URL_SYNC)/budget/save"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        
        let httpMethod = Alamofire.HTTPMethod.post
        let dictToEncrypt =  ["budgets" : budgetJson,
                              "device_type" : "Ios",
                              "consumer_id" : consumerId]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
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
                    
                    if status == 1 {
                        budget.is_synced = 1
                    } else {
                        if message == "Record Already Exist" {
                            budget.is_synced = 1
                        } else {
                            budget.is_synced = 0
//                            NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                        }
                    }
                    
                    DbController.saveContext()
                    completion(status, message, nil)
                    
                case .failure(let error):
                    budget.is_synced = 0
                    print(error)
                    let status = 0
                    let message = "Failed"
                    DbController.saveContext()
//                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    completion(status, message, nil)
                    
                }
        }
    }
    
    // MARK: - Backup Goals Transaction API Call
    public func backupGoalSavingTrx (goalTrx : Hkb_goal_trx, completion: @escaping ServiceResponse) {
        let savingTrx = Utils.convertVchIntoDict(object: goalTrx)
        let savingJson = Utils.convertDictIntoJson(object: savingTrx)
        
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        let URL = "\(Constants.BASE_URL_SYNC)/goal/trx/save"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        let httpMethod = Alamofire.HTTPMethod.post
        let dictToEncrypt =  ["saving_trxs" : savingJson,
                              "device_type" : "Ios",
                              "consumer_id" : consumerId]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
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
                    
                    if status == 1 {
                        goalTrx.is_synced = 1
                    } else {
                        if message == "Record Already Exist" {
                            goalTrx.is_synced = 1
                        } else {
                            goalTrx.is_synced = 0
//                            NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                        }
                    }
                    
                    DbController.saveContext()
                    completion(status, message, nil)
                    
                case .failure(let error):
                    goalTrx.is_synced = 0
                    print(error)
                    let status = 0
                    let message = "Failed"
                    DbController.saveContext()
//                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    completion(status, message, nil)
                }
        }
    }
    
    func stopTheDamnRequests(){
        BackupAlertView.isSyncing = false
        if #available(iOS 9.0, *) {
            Alamofire.SessionManager.default.session.getAllTasks { (tasks) in
                tasks.forEach{ $0.cancel() }
            }
        } else {
            Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
                sessionDataTask.forEach { $0.cancel() }
                uploadData.forEach { $0.cancel() }
                downloadData.forEach { $0.cancel() }
            }
        }
    }
}
