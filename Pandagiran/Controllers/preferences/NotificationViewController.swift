

import UIKit

class NotificationViewController: BaseViewController {
    
    @IBOutlet weak var noNotificationView: UIView!
    
    @IBOutlet weak var table_view_notification: UITableView!
    
    private let nibNotificationName = "NotificationViewCell"
    
    override func viewDidLoad() {
        
        self.table_view_notification.isHidden = true
        self.noNotificationView.isHidden = false
        
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

    
    override func willMove(toParent parent: UIViewController?) {
        self.navigationItemColor = .dark
    }
    
    @objc private func onBackTapped () {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension NotificationViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0
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
