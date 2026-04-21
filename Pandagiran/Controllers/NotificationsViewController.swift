//
//  NotificationsViewController.swift
//  Hysab Kytab
//
//  Created by MacBook Pro on 2/8/18.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {

    @IBOutlet weak var table_view: UITableView!
    @IBOutlet weak var label_placeholder: UILabel!
    
    private var arrayOfNotifications: Array<Hkb_notifications> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        fetchAllNotifications()
        setPlaceHolder()
    }
    
    private func initVariables () {
        let notificationCell = UINib(nibName: "NotificationViewCell", bundle: nil)
        table_view.register(notificationCell, forCellReuseIdentifier: "NotificationViewCell")
        
        table_view.dataSource = self
        table_view.delegate = self
    }
    
    private func fetchAllNotifications () {
        arrayOfNotifications = QueryUtils.fetchAllNotifications()
        print("COUNT : " , arrayOfNotifications.count)
    }
    
    private func deleteNotification (notification: Hkb_notifications , index: Int) {
        DbController.getContext().delete(notification)
        arrayOfNotifications.remove(at: index)
        setPlaceHolder()
        DbController.saveContext()
    }
    
    private func setPlaceHolder () {
        if arrayOfNotifications.count == 0 {
            label_placeholder.isHidden = false
            table_view.isHidden = true
        } else {
            label_placeholder.isHidden = true
            table_view.isHidden = false
        }
    }

    @IBAction func onBackTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
}

extension NotificationsViewController: UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = table_view.dequeueReusableCell(withIdentifier: "NotificationViewCell", for: indexPath) as! NotificationViewCell
        
        let expiryDate = Utils.convertStringToDate(dateString: arrayOfNotifications[indexPath.row].expirydate!)
        if (expiryDate.timeIntervalSinceNow.sign == .plus) {
            let index = indexPath.row
            let dateCreatedOn = Utils.convertStringToDate(dateString: arrayOfNotifications[index].createdOn!)
            
            cell.label_notification_title.text = arrayOfNotifications[index].title
            cell.label_notification_content.text = arrayOfNotifications[index].message
            cell.label_time.text = Utils.timeAgoStringFromDate(date: dateCreatedOn)
            cell.iv_notification.kf.setImage(with: URL(string: arrayOfNotifications[index].imageurl!))
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIUtils.getStoryboard(name: Constants.SB_MAIN)
        let dest = storyboard.instantiateViewController(withIdentifier: "NotificationDetailsVC") as! NotificationDetailsViewController
        dest.hkb_notification = arrayOfNotifications[indexPath.row]
        self.navigationController?.pushViewController(dest, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteNotification(notification: arrayOfNotifications[indexPath.row], index: indexPath.row)
            tableView.reloadData()
        }
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                // Your Call Here
                success(true)
            self.deleteNotification(notification: self.arrayOfNotifications[indexPath.row], index: indexPath.row)
            tableView.reloadData()
        })
        
        deleteAction.image = UIImage(named: "ic_delete")
        deleteAction.backgroundColor = UIColor.red
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
