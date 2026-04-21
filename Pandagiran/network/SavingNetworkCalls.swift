

import Foundation
import Alamofire
import SwiftyJSON

class SavingNetworkCalls {
    
    static let sharedInstance = SavingNetworkCalls()
    
    public func postSavingTrxToServer (goalTrx : Hkb_goal_trx, isUpdate: Bool) {
        let savingTrx = Utils.convertVchIntoDict(object: goalTrx)
        let savingJson = Utils.convertDictIntoJson(object: savingTrx)
        
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        var URL = "\(Constants.BASE_URL)/goal/trx/save"
        let randString = Utils.getRandomString(size: 20)
        
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        let httpMethod = Alamofire.HTTPMethod.post
        let dictToEncrypt =  ["saving_trxs" : savingJson,
                              "device_type" : "Ios",
                              "consumer_id" : consumerId]
        
        if isUpdate{
            URL = "\(Constants.BASE_URL)/goal/trx/update"
        }
        
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
                    
                    if status == 1 {
                       
                            goalTrx.is_synced = 1
                        
                    } else {
                        goalTrx.is_synced = 0
                        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    }
                    DbController.saveContext()
                case .failure(let error):
                    goalTrx.is_synced = 0
                    NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                    DbController.saveContext()
                }
        }
    }
    
}
