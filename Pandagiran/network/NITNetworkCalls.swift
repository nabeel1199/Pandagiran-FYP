

import Foundation
import Alamofire
import SwiftyJSON

//typealias NITServiceResponse = (_ success: Int, _ responseMessage: String, _ ServiceResponse: JSON?) -> Void

class NITNetworkCalls{
    
   static let sharedInstance = NITNetworkCalls()
    
    var alamoFireManager : SessionManager?
    
    let headers : [String : String] = ["Authorization" : "Bearer b24f45b02df2bb9398ede80d7adf19cd8004310b6592c4e13574796fa636a51b231c5be4926e860524bdee5f7d2ec614699f69974568633f2dc77c18c3865f83e39fcb6433cc9247e6c45db8bc901ae5de46284820512d137907b754f1f9a397ecbf1b3126335015e682c789febd300410c812be6a25a9f7608ec5845ec29a98"]
    
//    let params = ["Name":"Test User",
//                  "Email":"user@example.com",
//                  "Phone":"123456789",
//                  "CNIC":"123456789",
//                  "City":"Karachi",
//                  "investment_form":"1"]
    
    func getPartnerData(successHandler : @escaping (Nit?) -> Void,
                        failureHandler: @escaping (Error) -> Void) {
//
        let url = "\(Constants.HK_NIT_BASE_URL)/api/partners?populate=PartnerImage"
        Alamofire.request(url, method: .get, headers: headers)
            .responseJSON{
            response in
            print("Response NIT: \(response) and url: \(url)")
            switch response.result {
            case let .success(value):
            if let jsonData = try? JSONSerialization.data(withJSONObject: value, options: .prettyPrinted) {
                let responseObject = Nit.decode(data: jsonData)
                print("Respose object:",responseObject)
                successHandler(responseObject)
              } else {
                  let err = "Data Malformed"
                  failureHandler(err as! Error)
                print("data malformed")

              }
                
            case let .failure(error):
                failureHandler(error)
                print("NIT Error: \(error.localizedDescription)")

            }
        }
        
    }
    
    func getInformationPlan(investmentId: Int,
                            successHandler: @escaping (Investment_plan?) -> Void,
                            failureHandler: @escaping (Error) -> Void){
        
//        let url = "\(Constants.HK_NIT_BASE_URL)/api/investment-plans?filter[partner][id][$eq]=\(investmentId)&populate=logo"
        let url = "\(Constants.HK_NIT_BASE_URL)/api/investment-plans?filters[partner][id][$eq]=\(investmentId)&populate=logo"
        Alamofire.request(url, method: .get, headers: headers).responseJSON{
           response in
            print("Investment-Plan Response:", response)
            switch response.result{
            case let .success(value):
                if let jsonData = try? JSONSerialization.data(withJSONObject: value, options: .prettyPrinted) {
                    let responseObject = Investment_plan.decode(data: jsonData)
                    successHandler(responseObject)
                  } else {
                      let err = "Data Malformed"
                      failureHandler(err as! Error)
                    print("data malformed")

                  }
            case let .failure(error):
                failureHandler(error)
                print("NIT Error: \(error.localizedDescription)")

            }
        }
        
    }
    
    func getInformationForm(successHandler: @escaping (InvestmentFormModel?) -> Void,
                            failureHandler: @escaping (Error) -> Void){
        
//        let url = "\(Constants.HK_NIT_BASE_URL)/api/investment-forms?populate=*&filters[investment_plan][id][$eq]=\(investmentTypeId)"
        let url = "\(Constants.HK_NIT_BASE_URL)/api/investment-forms?populate=*"
       print(url)
        Alamofire.request(url, method: .get, headers: headers).responseJSON{
           response in
            print("Investment-Form Response:", response)
            switch response.result{
            case let .success(value):
                if let jsonData = try? JSONSerialization.data(withJSONObject: value, options: .prettyPrinted) {
                    let responseObject = InvestmentFormModel.decode(data: jsonData)
                    print("ResponseObject:\(responseObject)")
                    successHandler(responseObject)
                  } else {
                      let err = "Data Malformed"
                      failureHandler(err as! Error)
                    print("data malformed")

                  }
            case let .failure(error):
                failureHandler(error)
                print("NIT Error: \(error.localizedDescription)")

            }
        }
        
    }
    
    
    func postFormInformation(formData: Any,
                            successHandler: @escaping (InvestmentFormModel?) -> Void,
                            failureHandler: @escaping (Error) -> Void){
        
        let params = ["data": formData]
        print(params)
       
        
        let url = "\(Constants.HK_NIT_BASE_URL)/api/responses"
        Alamofire.request(url, method: .post, parameters: params, headers: headers).responseJSON{
           response in
            print("Investment-Form Response:", response)
            switch response.result{
            case let .success(value):
                if let jsonData = try? JSONSerialization.data(withJSONObject: value, options: .prettyPrinted) {
                    let responseObject = InvestmentFormModel.decode(data: jsonData)
                    print("Post ResponseObject:\(responseObject)")
                    successHandler(responseObject)
                  } else {
                      let err = "Data Malformed"
                      failureHandler(err as! Error)
                    print("data malformed")

                  }
            case let .failure(error):
                failureHandler(error)
                print("NIT Error: \(error.localizedDescription)")

            }
        }
        
    }
    
    
}
