

import UIKit
import Kingfisher

class DialogNotification: UIViewController {

    @IBOutlet weak var iv_notification: UIImageView!
    @IBOutlet weak var label_notification_title: UILabel!
    @IBOutlet weak var label_notification_text: UILabel!
    
    var myDelegate: NotificationDetailsTapListeners?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    private func initUI () {
        overlayBlurredBackgroundView()
        
        let notification : Hkb_notifications = getNotificationDetails()
        iv_notification.kf.setImage(with: URL(string: notification.imageurl!))
        label_notification_title.text = notification.title!
        label_notification_text.text = notification.message!
    }
    
    func overlayBlurredBackgroundView() {
        let blurredBackgroundView = UIVisualEffectView()
        blurredBackgroundView.frame = self.view.bounds
        blurredBackgroundView.effect = UIBlurEffect(style: .regular)
        blurredBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurredBackgroundView, at: 0)
    }
    
    func getNotificationDetails () -> Hkb_notifications {
        let notification : Hkb_notifications = QueryUtils.fetchSingleNotification(notificationId: QueryUtils.getMaxNotificationId())
        return notification
    }

    @IBAction func onMoreInfoTapped(_ sender: Any) {
        myDelegate?.onMoreInfoTapped(notification: getNotificationDetails())
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
