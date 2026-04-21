

import Foundation

protocol CurrencySelectionListener {
    func onCurrencySelected (currency : String, country2dg: String , currencyFlag : String , countryName : String , decimal : Int)
}
