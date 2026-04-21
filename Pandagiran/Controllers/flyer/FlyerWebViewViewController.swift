

import UIKit
import WebKit
import JavaScriptCore
import SwiftyJSON

class FlyerWebViewViewController: BaseViewController, WKUIDelegate, WKScriptMessageHandler, WKNavigationDelegate {

    
    let contentController = WKUserContentController()
    var web_view: WKWebView!
    
    public var flyerId = ""
    public var flyerName = "Flyer"
    
    override func loadView() {
        
        let webConfiguration = WKWebViewConfiguration()
        contentController.add(self, name: "test")
        webConfiguration.userContentController = contentController
        web_view = WKWebView(frame: .zero,
                             configuration: webConfiguration)
        
        web_view.uiDelegate = self
        web_view.navigationDelegate = self
        web_view.configuration.preferences.javaScriptEnabled = true
        web_view.isUserInteractionEnabled = true
        
        let consumerId = LocalPrefs.getConsumerId()
        let url = URL(string: "\(Constants.BASE_URL)/web/offer/maps?consumer_id=\(consumerId)&device_type=Ios&flyer_id=\(flyerId)")
        web_view.load(URLRequest(url: url!))
    

        
        view = web_view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.navigationItem.title = flyerName
        
        let searchItem = UIBarButtonItem(image: UIImage(named: "ic_search"), style: .plain, target: self, action: #selector(onSearchTapped))
        self.navigationItem.rightBarButtonItem =  searchItem
    }
    
    @objc private func onSearchTapped () {
        let flyerSearchVC = getStoryboard(name: ViewIdentifiers.SB_FLYER).instantiateViewController(withIdentifier: ViewIdentifiers.VC_FLYER_SEARCH) as! FlyerSearchViewController
        self.navigationController?.pushViewController(flyerSearchVC, animated: true)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        print("BODY : " , message.body)
        
//        if let dict = Utils.convertStringToDictionary(text: message.body as! String) {
            let dealObj = JSON(message.body).dictionaryObject
            let data = JSON(message.body).stringValue.data(using: .utf8)
//            let retailerJson = dealObj["retailer"]!.dictionaryObject
//            let flyerJson = dealObj["flyer"]!.dictionaryObject
        
        print("DATA : " , data)
        
            do {
                let deal = try JSONDecoder().decode(FlyerDeal.self, from: data!)
                
                print("DEAL : " , deal.id, deal.title, deal.flyer?.img)
                
                let flyerVC = getStoryboard(name: ViewIdentifiers.SB_FLYER).instantiateViewController(withIdentifier: ViewIdentifiers.VC_FLYER_DETAILS) as! FlyerDealDetailsViewController
                flyerVC.flyerDeal = deal
                self.navigationController?.pushViewController(flyerVC, animated: true)
                
            } catch {
                print("ERROR : ", error)
            }
            
//        }
        
    }
    
}




