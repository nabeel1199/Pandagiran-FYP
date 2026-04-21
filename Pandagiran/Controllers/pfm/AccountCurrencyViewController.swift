

import UIKit
import SwiftyJSON
import FirebaseAnalytics


protocol CountryCodeSelection {
    
    func onCountryCodeSelected (countryName : String,
                                countryCurrency : String,
                                dialCode: Int64,
                                countryFlag: String,
                                country2dg: String)
}

class AccountCurrencyViewController: BaseViewController {

    @IBOutlet weak var et_search: UISearchBar!
    @IBOutlet weak var table_view_currency: UITableView!
    

    var currencyArray : Array<UserCurrency> = []
    var currencyData : Array<UserCurrency> = []
    var currencyAR : Array<UserCurrencies> = []
    var currencyDat : Array<UserCurrencies> = []
   
    public var isCountryOpted = false
    public var isDialCodeOpted = false
    public var myDelegate : CurrencySelectionListener?
    public var countryCodeDelegate : CountryCodeSelection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVariables()
        
        if isCountryOpted {
            fetchCountries()
        } else {
            fetchCurrencies()
        }
        
    }
    
    private func initVariables () {
        et_search.delegate = self
        
        let nibCurrency = UINib(nibName: "NavigationViewCell", bundle: nil)
        table_view_currency.register(nibCurrency, forCellReuseIdentifier: "NavigationViewCell")
        
        table_view_currency.delegate = self
        table_view_currency.dataSource = self
    }
    
    
    func fetchCurrencies() {
        let jsonObj = Utils.readJson(resourceName: "core_country")
       
        for currency in jsonObj{
            let objc = JSON(currency)
            let urlCode = objc["country_iso_code_2dg"].stringValue
            let currencyObj = UserCurrency()
            currencyObj.currency3dg = objc["country_iso_code_3dg"].stringValue
            currencyObj.currencyFlag = "http://bo.hysabkytab.com/HK_data_pics/country_flags/\(urlCode.lowercased()).png"
            currencyObj.currencyName = objc["country_name"].stringValue
            currencyObj.currencyPrecision = objc["currency_precision"].intValue
            currencyObj.currency2dg = objc["country_iso_code_2dg"].stringValue
            currencyObj.dialCode = objc["dial_code"].int64Value
            currencyArray.append(currencyObj)
        }
        
        currencyData = currencyArray
        
        
    }
    
    private func fetchCountries () {
        let jsonObj = Utils.readJson(resourceName: "countries")
        
        for currency in jsonObj{
            let objc = JSON(currency)
            let urlCode = objc["country_iso_code_2dg"].stringValue
            let currencyObj = UserCurrency()
            currencyObj.currency3dg = objc["country_iso_code_3dg"].stringValue
            currencyObj.currencyFlag = "http://bo.hysabkytab.com/HK_data_pics/country_flags/\(urlCode.lowercased()).png"
            currencyObj.currencyName = objc["country_name"].stringValue
            currencyObj.currency2dg = objc["country_iso_code_2dg"].stringValue
            currencyObj.currencyPrecision = objc["currency_precision"].intValue
            currencyObj.dialCode = objc["dial_code"].int64Value
            currencyArray.append(currencyObj)
        }
        
        currencyData = currencyArray
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    
}

extension AccountCurrencyViewController : UITableViewDelegate , UITableViewDataSource, UISearchBarDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NavigationViewCell") as! NavigationViewCell
        let flagUrl = URL(string: currencyArray[indexPath.row].currencyFlag!)
        
   
        
        if isDialCodeOpted {
            cell.label_nav_text.text = "\(currencyArray[indexPath.row].currencyName!) (+\(currencyArray[indexPath.row].dialCode!))"
        } else {
            cell.label_nav_text.text = "\(currencyArray[indexPath.row].currencyName!) (\(currencyArray[indexPath.row].currency3dg!))"
        }
        
        cell.navImage.kf.setImage(with: flagUrl)
        cell.navImage.contentMode = .scaleToFill
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isDialCodeOpted {
            let country = currencyArray[indexPath.row]
            countryCodeDelegate?.onCountryCodeSelected(countryName: country.currencyName!,
                                                       countryCurrency: country.currency3dg!,
                                                       dialCode: country.dialCode!,
                                                       countryFlag: country.currencyFlag!,
                                                       country2dg: country.currency2dg!)
        }
        else
        {
            myDelegate?.onCurrencySelected(currency: currencyArray[indexPath.row].currency3dg!, country2dg: currencyArray[indexPath.row].currency2dg!, currencyFlag: currencyArray[indexPath.row].currencyFlag!, countryName: currencyArray[indexPath.row].currencyName!, decimal: currencyArray[indexPath.row].currencyPrecision!)
            Analytics.logEvent("currency", parameters: ["currency" : currencyArray[indexPath.row].currency3dg!])
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        currencyArray = currencyData.filter {
            return $0.currency3dg?.range(of : searchText, options: .caseInsensitive) != nil || $0.currencyName?.range(of : searchText, options: .caseInsensitive) != nil
        }
        
        if et_search.text?.count == 0 {
            currencyArray = currencyData
        }
        
        table_view_currency.reloadData()
    }

}
