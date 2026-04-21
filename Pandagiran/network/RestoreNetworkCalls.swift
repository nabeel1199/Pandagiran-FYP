

import Foundation
import Alamofire
import SwiftyJSON

typealias RecordServiceResponse = (_ success: Int, _ responseMessage: String, _ ServiceResponse: JSON) -> Void
typealias RecordServiceResponseData = (_ response: Data?, _ error: NSError?) -> Void
class RestoreNetworkCalls{
    
    static let sharedInstance = RestoreNetworkCalls()
    
    func getTotalRecords(completion: @escaping RecordServiceResponse){
        let consumerId = LocalPrefs.getConsumerId()

        let URL = "\(Constants.BASE_URL_RESTORE)/restore/count?consumerId=\(consumerId)&deviceType=Ios"
        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "Content-Type" : "application/x-www-form-urlencoded",
                                           "device_id" : LocalPrefs.getDeviceId()]

        #if DEBUG
        print(URL)
        #endif

        Alamofire.request(URL, method: .get, headers: headers)
            .responseString { response in
                print("Response : " , response)
                switch response.result {
                case .success:
                    let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
//                    let responseData = responseObj["data"].arrayObject
                    print(responseObj)
                    
                    completion(status, message, responseObj)
                case .failure(let error):
                    print("error \(error)")
                    let status = 0
                    let message = "Failed"
//                    completion(status, message, nil)
                }
        }
    }
    
    func getWorkFlowRecord(workFlow: String, count: Int, completion: @escaping RecordServiceResponse){
        let consumerId = LocalPrefs.getConsumerId()

        let URL = "\(Constants.BASE_URL_RESTORE)/restore/workflow?deviceType=Ios&count=\(count)&consumerId=\(consumerId)&workflow=\(workFlow)"

        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "Content-Type" : "application/x-www-form-urlencoded",
                                           "device_id" : LocalPrefs.getDeviceId()]
        
        #if DEBUG
        print(URL)
        #endif

        Alamofire.request(URL, method: .get, headers: headers)
            .responseString { response in
                print("Response : " , response)
                switch response.result {
                case .success:
                    let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
//                    let responseData = responseObj["data"].arrayObject
                    print(responseObj)
                    
                    completion(status, message, responseObj)
                case .failure(let error):
                    print("error \(error.localizedDescription)")
                    let status = 0
                    let message = "The request timed out."
                    let response = "The request timed out."
                    let json = JSON(response.convertToString)
                    UIUtils.showSnackbarNegative(message: error.localizedDescription)
                    completion(status, message, json)
                }
        }
    }
    
    func getWorkFlowRecordData(workFlow: String, count: Int, completion: @escaping RecordServiceResponseData){
        let consumerId = LocalPrefs.getConsumerId()
//        let URL = "\(Constants.BASE_URL)/restore/count?consumerId=\(consumerId)&device_type=Ios"
        let URL = "\(Constants.BASE_URL_RESTORE)/restore/workflow?deviceType=Ios&count=\(count)&consumerId=\(consumerId)&workflow=\(workFlow)"
//        let URL = "http://10.251.0.55:3000/restore/workflow?deviceType=Ios&count=\(count)&consumerId=\(consumerId)&workflow=\(workFlow)"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "Content-Type" : "application/x-www-form-urlencoded",
                                           "device_id" : LocalPrefs.getDeviceId()]
        
        #if DEBUG
        print(URL)
        #endif

        Alamofire.request(URL, method: .get, headers: headers)
            .responseString { response in
                print("Response : " , response)
                switch response.result {
                case .success:
                    let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
//                    let responseData = responseObj["data"].arrayObject
                    print(responseObj)
                    
                    let responseData = decryptedObj.data(using: .utf8)!
                    completion(responseData, nil)
                case .failure(let error):
                    print("error \(error)")
                    let status = 0
                    let message = "Failed"
                    UIUtils.showSnackbarNegative(message: error.localizedDescription)
//                    completion(status, message, nil)
                }
        }
    }
    
    func getWipAllData(isRestore: Bool, completion: @escaping RecordServiceResponse){
        let consumerId = LocalPrefs.getConsumerId()

        let URL = "\(Constants.BASE_URL)/consumers/wipe/data"

        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")

        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        
        var dictToEncrypt : [String:Any] =  ["device_type" : "Ios",
                                             "use_case" : "",
                                            "consumer_id" : consumerId]
        
        if isRestore{
            dictToEncrypt =  ["device_type" : "Ios",
                              "use_case" : "restore",
                              "consumer_id" : consumerId]
        }
        
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        
        #if DEBUG
        print(URL)
        #endif
        
         Alamofire.request(URL, method: .post, parameters: params, encoding: URLEncoding.httpBody , headers : headers)
            .responseJSON { response in
                print("Response : " , response)
                switch response.result {
                case .success:
                    
                    let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
//                    let status = 1
//                    let message = "Data Wiped Successfully"
                    print("ResponseStatus : " , status,  message)
//                    UIUtils.showSnackbar(message: message)
                    completion(status, message, responseObj)
                case .failure(let error):
                    print("error \(error)")
                    let status = 0
                    let message = "Failed"
//                    let responseString = JSON("Failed to Wipe Data From Server").stringValue
//                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
//                    let responseObj = JSON.init(parseJSON: decryptedObj)
//                    completion(status, message, responseObj)
                }
        }
    }
}
