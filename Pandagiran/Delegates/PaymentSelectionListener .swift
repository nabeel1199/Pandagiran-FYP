

import Foundation

protocol PaymentSelectionListener {
    func onPaymentMethodSelected (walletName: String, walletId: String)
}
