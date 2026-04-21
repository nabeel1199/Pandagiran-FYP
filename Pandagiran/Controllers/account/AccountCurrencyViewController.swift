//
//  AccountCurrencyViewController.swift
//  Hysab Kytab
//
//  Created by MacBook Pro on 3/21/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit

class AccountCurrencyViewController: BaseViewController {

    @IBOutlet weak var table_view_currency: UITableView!
    
    private let nibPersonName = "PersonAccountViewCell"
    
    
    override func viewDidLoad() {
        
        
        initVariables()
    }
    
    private func initVariables () {
        initNibs()
        
        table_view_currency.delegate = self
        table_view_currency.dataSource = self
    }
    
    private func initNibs () {
        let nibPerson = UINib(nibName: nibPersonName, bundle: nil)
        table_view_currency.register(nibPerson, forCellReuseIdentifier: nibPersonName)
    }
    
    
}

extension AccountCurrencyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nibPersonName, for: indexPath) as! PersonAccountViewCell
        
        cell.label_person_contact.isHidden = true
        cell.iv_person_details.isHidden = true
        cell.iv_person.image = UIImage(named: "ic_custom_radio")
        cell.iv_person.tintColor = UIColor.lightGray
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! PersonAccountViewCell
        
        cell.iv_person.tintColor = Utils.hexStringToUIColor(hex: AppColors.PRIMARY_COLOR)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! PersonAccountViewCell
        
        cell.iv_person.tintColor = UIColor.lightGray
        
        
        
    }
    
    
}
