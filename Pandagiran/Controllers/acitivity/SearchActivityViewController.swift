//
//  SearchActivityViewController.swift
//  Hysab Kytab
//
//  Created by MacBook Pro on 3/28/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit

class SearchActivityViewController: BaseViewController {

    
    @IBOutlet weak var table_view_search: UITableView!
    
    private let nibTransactionName = "TransactionViewCell"
    
    override func viewDidLoad() {

        initVariables()
        initUI()
    }
    
    private func initVariables () {
        initNibs()
        
        table_view_search.delegate = self
        table_view_search.dataSource = self
    }
    
    private func initUI () {
        let closeBtn = UIBarButtonItem(image: UIImage(named: "ic_clear"), style: .plain, target: self, action: #selector(onCloseTapped))
        self.navigationItem.leftBarButtonItem = closeBtn
        
        self.navigationItemColor = .light
        
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.placeholder = "Search"
        navigationItem.titleView = searchBar
        
    }
    
    private func initNibs () {
        let nibTransaction = UINib(nibName: nibTransactionName, bundle: nil)
        table_view_search.register(nibTransaction, forCellReuseIdentifier: nibTransactionName)
    }
    
    @objc private func onCloseTapped () {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        
    }
    

}

extension SearchActivityViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table_view_search.dequeueReusableCell(withIdentifier: nibTransactionName, for: indexPath) as! TransactionViewCell
        
        
        
        cell.selectionStyle = .none
        return cell
    }
    
    
}
