//
//  NotificationViewController.swift
//  Hysab Kytab
//
//  Created by MacBook Pro on 4/2/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit

class NotificationViewController: BaseViewController {
    
    
    @IBOutlet weak var table_view_notification: UITableView!
    
    private let nibNotificationName = "NotificationViewCell"
    
    override func viewDidLoad() {

        initVariables()
        initUI()
    }

    private func initVariables () {
        initNibs()
        
        table_view_notification.delegate = self
        table_view_notification.dataSource = self
    }
    
    private func initUI () {
        self.navigationItemColor = .light
        self.navigationItem.title = "Notifications"
    }
    
    private func initNibs () {
        let nibNotification = UINib(nibName: nibNotificationName, bundle: nil)
        table_view_notification.register(nibNotification, forCellReuseIdentifier: nibNotificationName)
    }

    
    override func willMove(toParentViewController parent: UIViewController?) {
        self.navigationItemColor = .dark
    }
}

extension NotificationViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nibNotificationName, for: indexPath) as! NotificationViewCell
        
        let stringValue = "Nora Gray paid you Rs 5,000"
        let attributedString = NSMutableAttributedString(string: stringValue)
        attributedString.setColorForText(textForAttribute: "Nora Gray", withColor: UIColor().hexCode(hex: Style.color.DARK_TEXT))
        attributedString.setColorForText(textForAttribute: "paid you Rs 5,000", withColor: UIColor().hexCode(hex: Style.color.LIGHT_TEXT))
        cell.label_notification_title.attributedText = attributedString
        
        
        cell.selectionStyle = .none
        return cell
    }
    
    
}
