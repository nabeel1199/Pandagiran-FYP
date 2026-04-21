

import UIKit
import WebKit

class BuyNowViewController: BaseViewController {

    private var web_view: WKWebView!
    
    public var dealUrl = ""
    
    override func loadView() {
        
        let webConfiguration = WKWebViewConfiguration()
        web_view = WKWebView(frame: .zero,
                             configuration: webConfiguration)
        

        web_view.configuration.preferences.javaScriptEnabled = true
        web_view.isUserInteractionEnabled = true
        
        let url = URL(string: dealUrl)
        web_view.load(URLRequest(url: url!))
            
        
        view = web_view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()



    }
    


}
