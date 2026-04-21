//
//  ActivityFilterViewController.swift
//  Hysab Kytab
//
//  Created by MacBook Pro on 3/28/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit

class ActivityFilterViewController: BaseViewController {

    @IBOutlet weak var view_transaction_type: CardView!
    @IBOutlet weak var view_category: CardView!
    @IBOutlet weak var view_account: CardView!
    @IBOutlet weak var label_selected_category: UILabel!
    @IBOutlet weak var label_vch_type: UILabel!
    @IBOutlet weak var label_account: UILabel!
    @IBOutlet weak var label_max_amount: UILabel!
    @IBOutlet weak var label_min_amount: UILabel!
    @IBOutlet weak var btn_apply: GradientButton!
    @IBOutlet weak var label_transaction_type: CustomFontLabel!
    @IBOutlet weak var label_category: CustomFontLabel!
    @IBOutlet weak var label_source_account: CustomFontLabel!
    @IBOutlet weak var label_transaction: CustomFontLabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        initVariables()
        initUI()

    }
    
    private func initVariables () {
        let accountTapGest = UITapGestureRecognizer(target: self, action: #selector(onAccountTapped))
        view_account.addGestureRecognizer(accountTapGest)
        
        let categoryTapGest = UITapGestureRecognizer(target: self, action: #selector(onCategoryTapped))
        view_category.addGestureRecognizer(categoryTapGest)
        
        let transactionTypeGest = UITapGestureRecognizer(target: self, action: #selector(onTransactionTypeTapped))
        view_transaction_type.addGestureRecognizer(transactionTypeGest)
    }
    
    private func initUI () {
        label_transaction.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        label_min_amount.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_max_amount.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_source_account.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        label_account.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        label_category.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        label_selected_category.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        label_transaction_type.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        label_vch_type.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        btn_apply.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
    }

    @objc private func onAccountTapped () {
        
    }
    
    @objc private func onCategoryTapped () {
        let categoriesVC = getStoryboard(name: ViewIdentifiers.SB_TRANSACTION).instantiateViewController(withIdentifier: ViewIdentifiers.VC_CHOOSE_CATEGORY) as! ChooseCategoryViewController
        self.navigationController?.pushViewController(categoriesVC, animated: true)
    }
    
    @objc private func onTransactionTypeTapped () {
        
    }
    
    @IBAction func onApplyTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
