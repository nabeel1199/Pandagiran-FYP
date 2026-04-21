

import Foundation
import Alamofire
import SwiftyJSON

class APIManager {
    static let sharedInstance = APIManager()
    
    // MARK: - Verify Session API Call
    
    public func verifySession(completion: @escaping ServiceResponse) {
        
        let consumerId = LocalPrefs.getUserData()["branch_id"]!
        let URL = "\(Constants.BASE_URL_SYNC)/consumers/verify/device"
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        let httpMethod = Alamofire.HTTPMethod.post
        let dictToEncrypt =  ["device_id" : LocalPrefs.getDeviceId(),
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
                    if response.response?.statusCode == 400{
                        completion(response.response?.statusCode ?? 0, message, nil)
                    } else {
                        completion(status, message, nil)
                    }
                    
                case .failure(let error):
                    print(error)
                    let status = 0
                    let message = "Failed"
                    
                    if error.localizedDescription == "The Internet connection appears to be offline." {
                        completion(2, message, nil)
                    } else {
                        completion(response.response?.statusCode ?? 0, message, nil)
                    }
                    
                }
                
            }
    }
        
}
