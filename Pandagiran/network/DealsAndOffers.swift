

import Foundation
import Alamofire
import SwiftyJSON

class DealsAndOffers {
    
    
    public func fetchSimilarDeals ( dealId: String,
                                    successHandler : @escaping (Array<FlyerDeal>, Int , String) -> Void,
                                    failureHandler: @escaping (Error) -> Void) {
        
        let consumerId = LocalPrefs.getUserData()[Constants.CONSUMER_ID]!
        let URL = "\(Constants.BASE_URL)/flyer/deal/similar/offers?consumer_id=\(consumerId)&device_type=Ios&deal_id=\(dealId)"
        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        
        
        
        Alamofire.request(URL, method: .get , encoding : URLEncoding.httpBody , headers: headers)
            .responseJSON { response in
                print("Response : " , response)

                switch response.result {
                case .success:
                     let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    var arrayOfDeals : Array<FlyerDeal> = []
                    
                    if status == 1 {
                        let dataArray = responseObj["data"].arrayValue
                        
                        for dataObj in dataArray {
                            let dealJsonObj = dataObj.dictionaryObject
                            
                            
                            do {
                                let data = try JSONSerialization.data(withJSONObject: dealJsonObj!, options: .prettyPrinted)
                                let deal = try JSONDecoder().decode(FlyerDeal.self, from: data)
                                arrayOfDeals.append(deal)
                            } catch {
                                print("ERROR : " , error)
                            }
                        }
                        
                        successHandler(arrayOfDeals, status, message)
                        
                    } else {
                        successHandler([], status, message)
                    }
                    
                    
                case .failure(let error):
                    failureHandler(error)
                }
        }
    }
    
    public func fetchPopularOffers (interests: String,
                                    offset: Int,
                                    successHandler : @escaping (Array<Deal>, Int , String) -> Void,
                                    failureHandler: @escaping (Error) -> Void) {
        
        let consumerId = LocalPrefs.getUserData()[Constants.CONSUMER_ID]!
        let URL = "\(Constants.BASE_URL)/deals/popular/?consumer_id=\(consumerId)&device_type=Ios&interests=\(interests)&offset=\(offset)"
        let decodedUrl = URL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636",
                                           "device_id" : LocalPrefs.getDeviceId()]
        
        
        
        Alamofire.request(decodedUrl!, method: .get , encoding : URLEncoding.httpBody , headers: headers)
            .responseJSON { response in
                print("Response : " , response)
                
                switch response.result {
                case .success:
                     let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    var arrayOfDeals : Array<Deal> = []
                    
                    if status == 1 {
                        let dataArray = responseObj["data"].arrayValue
                        
                        for dataObj in dataArray {
                            let dealJsonObj = dataObj.dictionaryObject
                            
                            
                            do {
                                let data = try JSONSerialization.data(withJSONObject: dealJsonObj!, options: .prettyPrinted)
                                let deal = try JSONDecoder().decode(Deal.self, from: data)
                                arrayOfDeals.append(deal)
                            } catch {
                                print("ERROR : " , error)
                            }
                        }
                        
                        successHandler(arrayOfDeals, status, message)
                        
                    } else {
                        successHandler([], status, message)
                    }
                    
                    
                case .failure(let error):
                    failureHandler(error)
                }
        }
    }
    
    public func fetchRecommendedDeals (interests: String,
                                       offset: Int,
                                       successHandler : @escaping (Array<Deal>, Int , String) -> Void,
                                       failureHandler: @escaping (Error) -> Void) {
        
        let consumerId = LocalPrefs.getUserData()[Constants.CONSUMER_ID]!
        let URL = "\(Constants.BASE_URL)/deals/recommended/deals?consumer_id=\(consumerId)&device_type=Ios&interests=\(interests)&offset=\(offset)"
        let decodedUrl = URL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
        
        
        Alamofire.request(decodedUrl!, method: .get , encoding : URLEncoding.httpBody , headers: headers)
            .responseJSON { response in
                print("Response : " , response)
                
                switch response.result {
                case .success:
                     let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    var arrayOfDeals : Array<Deal> = []
                    
                    if status == 1 {
                        let dataArray = responseObj["data"].arrayValue
                        
                        for dataObj in dataArray {
                            let dealJsonObj = dataObj.dictionaryObject
                            
                            
                            do {
                                let data = try JSONSerialization.data(withJSONObject: dealJsonObj!, options: .prettyPrinted)
                                let deal = try JSONDecoder().decode(Deal.self, from: data)
                                arrayOfDeals.append(deal)
                            } catch {
                                print("ERROR : " , error)
                            }
                        }
                        
                        successHandler(arrayOfDeals, status, message)
                        
                    } else {
                        successHandler([], status, message)
                    }
                    
                    
                case .failure(let error):
                    failureHandler(error)
                }
        }
    }
    
    public func addToWishlistNetworkCall (dealId : String,
                                          use_case : String,
                                          successHandler : @escaping (Int , String) -> Void,
                                          failureHandler: @escaping (Error) -> Void) {
        
        let consumerId = LocalPrefs.getUserData()[Constants.CONSUMER_ID]!
        let URL = "\(Constants.BASE_URL)/flyer/deal/add/wishlist"
        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
        let dictToEncrypt : [String:Any] =  ["consumer_id" : consumerId,
                                             "device_type" : "Ios",
                                             "deal_id" : dealId,
                                             "case" : use_case]
        let encryptedParams = try! Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        
        Alamofire.request(URL, method: .post , parameters : params , encoding : URLEncoding.httpBody , headers: headers)
            .responseJSON { response in
                print("Response : " , response)
                
                switch response.result {
                case .success:
                     let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    
//                    if status == 1 {
//                        self.configureWishlistButton(isSelected: true)
//                        UIUtils.showSnackbar(message: "Added to wishlist")
//                    } else {
//                        UIUtils.showAlert(vc: self, message: message)
//                    }
                    
                    successHandler(status, message)
                    
                    
                case .failure(let error):
                   failureHandler(error)
                }
        }
    }
    
    public func addDealToWishlistNetworkCall (dealId : String,
                                              partnerId : String,
                                              use_case : String,
                                              successHandler : @escaping (Int , String) -> Void,
                                              failureHandler: @escaping (Error) -> Void) {
        
        let consumerId = LocalPrefs.getUserData()[Constants.CONSUMER_ID]!
        let URL = "\(Constants.BASE_URL)/deals/add/wishlist"
        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
        let dictToEncrypt : [String:Any] =  ["consumer_id" : consumerId,
                                             "device_type" : "Ios",
                                             "deal_id" : dealId,
                                             "partner_id" : partnerId,
                                             "case" : use_case]
        let encryptedParams = try! Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        
        Alamofire.request(URL, method: .post , parameters : params , encoding : URLEncoding.httpBody , headers: headers)
            .responseJSON { response in
                print("Response : " , response)
                
                switch response.result {
                case .success:
                     let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    

                    successHandler(status, message)
                    
                    
                case .failure(let error):
                    failureHandler(error)
                }
        }
    }
    
    public func likeFlyerDealNetworkCall (dealId : String,
                                          successHandler : @escaping (Int , String) -> Void,
                                          failureHandler: @escaping (Error) -> Void) {
        
        let consumerId = LocalPrefs.getUserData()[Constants.CONSUMER_ID]!
        let URL = "\(Constants.BASE_URL)/flyer/like"
        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
        let dictToEncrypt : [String:Any] =  ["consumer_id" : consumerId,
                                             "device_type" : "Ios",
                                             "deal_id" : dealId]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        
        Alamofire.request(URL, method: .post , parameters : params , encoding : URLEncoding.httpBody , headers: headers)
            .responseJSON { response in
                print("Response : " , response)
                
                switch response.result {
                case .success:
                     let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    
                    
                    successHandler(status, message)
                    
                    
                case .failure(let error):
                    failureHandler(error)
                }
        }
    }
    
    
    public func likeDealNetworkCall (dealId : String,
                                     partnerId : String,
                                     successHandler : @escaping (Int , String) -> Void,
                                     failureHandler: @escaping (Error) -> Void) {
        
        let consumerId = LocalPrefs.getUserData()[Constants.CONSUMER_ID]!
        let URL = "\(Constants.BASE_URL)/deals/like"
        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
        let dictToEncrypt =  ["consumer_id" : consumerId,
                              "device_type" : "Ios",
                              "deal_id" : dealId,
                              "partner_id" : partnerId]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        Alamofire.request(URL, method: .post , parameters : params , encoding : URLEncoding.httpBody , headers: headers)
            .responseJSON { response in
                print("Response : " , response)
                
                switch response.result {
                case .success:
                     let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
 
                    
                    successHandler(status, message)
                    
                    
                case .failure(let error):
                    failureHandler(error)
                }
        }
    }
    
    public func fetchLikedDealsAndReviews (dealId : String,
                                           partnerId : String,
                                           categoryName : String,
                                           subCategoryName : String,
                                           brandName : String,
                                           successHandler : @escaping (Array<Deal>, Array<Reviews> , Int, Int , String) -> Void,
                                           failureHandler: @escaping (Error) -> Void) {
        
        
        let consumerId = LocalPrefs.getUserData()[Constants.CONSUMER_ID]!
        let URL = "\(Constants.BASE_URL)/deals/meta"
        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
        let dictToEncrypt =  ["consumer_id" : consumerId,
                              "device_type" : "Ios",
                              "deal_id" : dealId,
                              "partner_id" : partnerId,
                              "category_name" : categoryName,
                              "sub_category_name" : subCategoryName,
                              "brand_name" : brandName]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        
        Alamofire.request(URL, method: .post , parameters : params , encoding : URLEncoding.httpBody , headers: headers)
            .responseJSON { response in
                print("Response : " , response)
                
                switch response.result {
                case .success:
                     let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    
                    var wishlistCount = 0
                    var arrayOfDeals : Array<Deal> = []
                    var arrayOfReviews : Array<Reviews> = []
                    
                    if status == 1 {
                        let data = responseObj["data"].dictionaryValue
                        let offerJsonArray = data["offers"]?.arrayValue
                        let reviewsJsonArray = data["reviews"]?.arrayValue
                        wishlistCount = data["offer_in_wishlist_count"]!.intValue
                        
                        for offerJson in offerJsonArray! {
                            let offerObj = offerJson.dictionaryObject
                            
                            do {
                                let data = try JSONSerialization.data(withJSONObject: offerObj!, options: .prettyPrinted)
                                let deal = try JSONDecoder().decode(Deal.self, from: data)
                                arrayOfDeals.append(deal)
                            } catch {
                                print("ERROR : " , error)
                            }
                        }
                        
                        for reviewJson in reviewsJsonArray! {
                            let reviewObj = reviewJson.dictionaryObject
                            
                            do {
                                let data = try JSONSerialization.data(withJSONObject: reviewObj!, options: .prettyPrinted)
                                let review = try JSONDecoder().decode(Reviews.self, from: data)
                                arrayOfReviews.append(review)
                            } catch {
                                print("ERROR : " , error)
                            }
                        }
                    }
                    
                    successHandler(arrayOfDeals, arrayOfReviews, wishlistCount, status, message)
                    
    
                case .failure(let error):
                    failureHandler(error)
                }
        }
    }
    
    public func addReviewNetworkCall (dealId : String,
                                      partnerId : String,
                                      review : String,
                                      rating : Double,
                                      successHandler : @escaping (Int , String) -> Void,
                                      failureHandler: @escaping (Error) -> Void) {
        
        let consumerId = LocalPrefs.getUserData()[Constants.CONSUMER_ID]!
        let consumerName = LocalPrefs.getUserData()[Constants.USER_NAME]!
        let URL = "\(Constants.BASE_URL)/deals/rate"
        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
        let dictToEncrypt : [String:Any] =  ["consumer_id" : consumerId,
                              "consumer_name" : consumerName,
                              "device_type" : "Ios",
                              "deal_id" : dealId,
                              "partner_id" : partnerId,
                              "review" : review,
                              "rating" : rating]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        Alamofire.request(URL, method: .post , parameters : params , encoding : URLEncoding.httpBody , headers: headers)
            .responseJSON { response in
                print("Response : " , response)
                
                switch response.result {
                case .success:
                     let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    
                    
                    successHandler(status, message)
                    
                    
                case .failure(let error):
                    failureHandler(error)
                }
        }
    }
    
    public func fetchSearchResultsAndLikedDeals (search_query : String,
                                                 offset : Int,
                                                 successHandler : @escaping (Array<Deal>, Array<String>, Int , String) -> Void,
                                                 failureHandler: @escaping (Error) -> Void) {
        
        let consumerId = LocalPrefs.getUserData()[Constants.CONSUMER_ID]!
        let consumerName = LocalPrefs.getUserData()[Constants.USER_NAME]!
        let URL = "\(Constants.BASE_URL)/deals/search"
        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
     
        let dictToEncrypt : [String:Any] =  ["consumer_id" : consumerId,
                                             "consumer_name" : consumerName,
                                             "device_type" : "Ios",
                                             "search_query" : search_query,
                                             "offset" : offset]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        Alamofire.request(URL, method: .post , parameters : params , encoding : URLEncoding.httpBody , headers: headers)
            .responseJSON { response in
                print("Response : " , response)
                
                switch response.result {
                case .success:
                    let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    
                    var arrayOfDeals : Array<Deal> = []
                    var searchArray : Array<String> = []
                    
                    if status == 1 {
                        let data = responseObj["data"].dictionaryValue
                        
                        let likeDealsJsonArray = data["liked_deals"]?.arrayValue
                        let searchQueryJsonArray = data["previous_searches"]?.arrayValue
                        let searchDealsJsonArray = data["search"]?.arrayValue
                        
                        for searchQueryJsonObj in searchQueryJsonArray! {
                            let searchQuery = searchQueryJsonObj["query"].stringValue
                            searchArray.append(searchQuery)
                        }
                        
                        for likeDealJsonObj in likeDealsJsonArray! {
                            let dealObj = likeDealJsonObj.dictionaryObject
                            
                            do {
                                let data = try JSONSerialization.data(withJSONObject: dealObj!, options: .prettyPrinted)
                                let deal = try JSONDecoder().decode(Deal.self, from: data)
                                arrayOfDeals.append(deal)
                            } catch {
                                print("ERROR : " , error)
                            }
                        }
                        
                        for searchDealJsonObj in searchDealsJsonArray! {
                            let searchDealObj = searchDealJsonObj.dictionaryObject
                            
                            do {
                                let data = try JSONSerialization.data(withJSONObject: searchDealObj!, options: .prettyPrinted)
                                let deal = try JSONDecoder().decode(Deal.self, from: data)
                                arrayOfDeals.append(deal)
                            } catch {
                                print("ERROR : " , error)
                            }
                        }
                    }

                    successHandler(arrayOfDeals, searchArray, status, message)
                    
                    
                case .failure(let error):
                    failureHandler(error)
                }
        }
    }
    
    public func fetchAllOffers (interests: String,
                                url: String,
                                offset: Int,
                                price_range: String,
                                discount: Int,
                                sort: Int,
                                successHandler : @escaping (Array<Deal>, Int , String) -> Void,
                                failureHandler: @escaping (Error) -> Void) {
        
        let consumerId = LocalPrefs.getUserData()[Constants.CONSUMER_ID]!
        let URL = "\(Constants.BASE_URL)\(url)?consumer_id=\(consumerId)&device_type=Ios&interests=\(interests)&offset=\(offset)&price_range=\(price_range)&discount=\(discount)&sort=\(sort)"
        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
        
        
        Alamofire.request(URL, method: .get , encoding : URLEncoding.httpBody , headers: headers)
            .responseJSON { response in
                print("Response : " , response)
                
                switch response.result {
                case .success:
                     let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    var arrayOfDeals : Array<Deal> = []
                    
                    if status == 1 {
                        let dataArray = responseObj["data"].arrayValue
                        
                        for dataObj in dataArray {
                            let dealJsonObj = dataObj.dictionaryObject
                            
                            
                            do {
                                let data = try JSONSerialization.data(withJSONObject: dealJsonObj!, options: .prettyPrinted)
                                let deal = try JSONDecoder().decode(Deal.self, from: data)
                                arrayOfDeals.append(deal)
                            } catch {
                                print("ERROR : " , error)
                            }
                        }
                        
                        successHandler(arrayOfDeals, status, message)
                        
                    } else {
                        successHandler([], status, message)
                    }
                    
                    
                case .failure(let error):
                    failureHandler(error)
                }
        }
    }
    
    public func searchBrandsNetworkCall (search_query: String,
                                         successHandler : @escaping (Array<String>, Int , String) -> Void,
                                         failureHandler: @escaping (Error) -> Void) {
        
        let consumerId = LocalPrefs.getUserData()[Constants.CONSUMER_ID]!
        let URL = "\(Constants.BASE_URL)/deals/brand/search/?consumer_id=\(consumerId)&device_type=Ios&search_query=\(search_query)"
        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
        
        
        Alamofire.request(URL, method: .get , encoding : URLEncoding.httpBody , headers: headers)
            .responseJSON { response in
                print("Response : " , response)
                
                switch response.result {
                case .success:
                     let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    var arrayOfBrands : Array<String> = []
                    
                    if status == 1 {
                        let brandArray = responseObj["data"].arrayValue
                        
                        for brandJsonObj in brandArray {
                            let brandName = brandJsonObj["brand_name"].stringValue
                            arrayOfBrands.append(brandName)
                        }
                    }
                    
                    successHandler(arrayOfBrands, status, message)
                    
                    
                case .failure(let error):
                    failureHandler(error)
                }
        }
    }
    
    public func fetchCategoryAndRetailersNewtorkCall (type: String,
                                                      successHandler : @escaping (Array<String>, Int , String) -> Void,
                                                      failureHandler: @escaping (Error) -> Void) {
        
        let consumerId = LocalPrefs.getUserData()[Constants.CONSUMER_ID]!
        let URL = "\(Constants.BASE_URL)/flyer/search/meta?consumer_id=\(consumerId)&device_type=Ios"
        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
        
        
        Alamofire.request(URL, method: .get , encoding : URLEncoding.httpBody , headers: headers)
            .responseJSON { response in
                print("Response : " , response)
                
                switch response.result {
                case .success:
                     let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    var arrayOfCategory : Array<String> = []
                    
                    if status == 1 {
                        let data = responseObj["data"].dictionaryValue
                        
                        if type == "Category" {
                            let categoryJsonArray = data["categories"]?.arrayValue
                            
                            for categoryJsonObj in categoryJsonArray! {
                                let category = categoryJsonObj["category"].stringValue
                                arrayOfCategory.append(category)
                            }
                        } else {
                            let retailerJsonArray = data["retailers"]?.arrayValue
                            
                            for retailerJsonObj in retailerJsonArray! {
                                let retailer = retailerJsonObj["retailer"].stringValue
                                arrayOfCategory.append(retailer)
                            }
                        }
                    }
        
                       
                    
                    successHandler(arrayOfCategory, status, message)
                    
                    
                case .failure(let error):
                    failureHandler(error)
                }
        }
    }
    
    public func fetchAllFlyerOffersNetworkCall (url: String,
                                           offset: Int,
                                           price_range: String,
                                           retailer_name: String,
                                           category: String,
                                           expiry: Int64,
                                           sort: Int,
                                           successHandler : @escaping (Array<FlyerDeal>, Int , String) -> Void,
                                           failureHandler: @escaping (Error) -> Void) {
        
        let URL = "\(Constants.BASE_URL)\(url)?consumer_id=1&device_type=Ios&price_range=\(price_range)&sort=\(sort)&category=\(category)&offset=\(offset)&retailer_name=\(retailer_name)&expiry=\(expiry)"
        let decodedUrl = URL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
        
        
        Alamofire.request(decodedUrl!, method: .get , encoding : URLEncoding.httpBody , headers: headers)
            .responseJSON { response in
                print("Response : " , response)
                
                switch response.result {
                case .success:
                     let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    var arrayOfDeals : Array<FlyerDeal> = []
                    
                    if status == 1 {
                        let dataArray = responseObj["data"].arrayValue
                        
                        for dataObj in dataArray {
                            let dealJsonObj = dataObj.dictionaryObject
                            
                            
                            do {
                                let data = try JSONSerialization.data(withJSONObject: dealJsonObj!, options: .prettyPrinted)
                                let deal = try JSONDecoder().decode(FlyerDeal.self, from: data)
                                arrayOfDeals.append(deal)
                            } catch {
                                print("ERROR : " , error)
                            }
                        }
                        
                        successHandler(arrayOfDeals, status, message)
                        
                    } else {
                        successHandler([], status, message)
                    }
                    
                    
                case .failure(let error):
                    failureHandler(error)
                }
        }
    }
    
    public func searchFlyerDealsNetworkCall (search_query : String,
                                             offset : Int,
                                             successHandler : @escaping (Array<FlyerDeal>, Array<String>, Int , String) -> Void,
                                             failureHandler: @escaping (Error) -> Void) {
        
        let consumerId = LocalPrefs.getUserData()[Constants.CONSUMER_ID]!
        let URL = "\(Constants.BASE_URL)/flyers/offers/search"
        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
        let dictToEncrypt : [String:Any] =  ["consumer_id" : consumerId,
                                             "device_type" : "Ios",
                                             "search_query" : search_query,
                                             "offset" : offset]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        Alamofire.request(URL, method: .post , parameters : params , encoding : URLEncoding.httpBody , headers: headers)
            .responseJSON { response in
                print("Response : " , response)
                
                switch response.result {
                case .success:
                     let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    
                    var arrayOfDeals : Array<FlyerDeal> = []
                    var searchArray : Array<String> = []
                    
                    if status == 1 {
                        let data = responseObj["data"].dictionaryValue
                        
                        let likeDealsJsonArray = data["liked_deals"]?.arrayValue
                        let searchQueryJsonArray = data["previous_searches"]?.arrayValue
                        let searchDealsJsonArray = data["search"]?.arrayValue
                        
                        for searchQueryJsonObj in searchQueryJsonArray! {
                            let searchQuery = searchQueryJsonObj["query"].stringValue
                            searchArray.append(searchQuery)
                        }
                        
                        for likeDealJsonObj in likeDealsJsonArray! {
                            let dealObj = likeDealJsonObj.dictionaryObject
                            
                            do {
                                let data = try JSONSerialization.data(withJSONObject: dealObj!, options: .prettyPrinted)
                                let deal = try JSONDecoder().decode(FlyerDeal.self, from: data)
                                arrayOfDeals.append(deal)
                            } catch {
                                print("ERROR : " , error)
                            }
                        }
                        
                        for searchDealJsonObj in searchDealsJsonArray! {
                            let searchDealObj = searchDealJsonObj.dictionaryObject
                            
                            do {
                                let data = try JSONSerialization.data(withJSONObject: searchDealObj!, options: .prettyPrinted)
                                let deal = try JSONDecoder().decode(FlyerDeal.self, from: data)
                                arrayOfDeals.append(deal)
                            } catch {
                                print("ERROR : " , error)
                            }
                        }
                    }
                    
                    successHandler(arrayOfDeals, searchArray, status, message)
                    
                    
                case .failure(let error):
                    failureHandler(error)
                }
        }
    }
    
    public func likeFlyerOfferNetworkCall (flyer_id : String,
                                           offer_id : String,
                                           successHandler : @escaping (Int , String) -> Void,
                                           failureHandler: @escaping (Error) -> Void) {
        
        let consumerId = LocalPrefs.getUserData()[Constants.CONSUMER_ID]!
        let URL = "\(Constants.BASE_URL)/flyers/offers/like"
        
        let randString = Utils.getRandomString(size: 20)
        let sha256 = Utils.genearateSha256(string: "\(randString)\(Constants.API_ACCESS_KEY)")
        let headers : [String : String] = ["auth-mac" : "leltqtjmdemgquqfqwln",
                                           "auth-token" : "7513f48395fca348b20cc898dfb3c53ae563da38aaf9393345c449f5df1a4636"]
        
        let dictToEncrypt : [String:Any] =  ["consumer_id" : consumerId,
                                             "device_type" : "Ios",
                                             "flyer_id" : flyer_id,
                                             "offer_id" : offer_id]
        let encryptedParams = Utils.convertDictIntoJson(object: dictToEncrypt).aesEncrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
        let params = ["u" : encryptedParams]
        
        Alamofire.request(URL, method: .post , parameters : params , encoding : URLEncoding.httpBody , headers: headers)
            .responseJSON { response in
                print("Response : " , response)
                
                switch response.result {
                case .success:
                     let responseString = JSON(response.result.value!).stringValue
                    let decryptedObj = responseString.aesDecrypt(key: Constants.ENCRYPTION_KEY, iv: Constants.ENCRYPTION_IV!)
                    let responseObj = JSON.init(parseJSON: decryptedObj)
                    let status = responseObj["status"].intValue
                    let message = responseObj["message"].stringValue
                    
                    
                    successHandler(status, message)
                    
                    
                case .failure(let error):
                    failureHandler(error)
                }
        }
    }
}
