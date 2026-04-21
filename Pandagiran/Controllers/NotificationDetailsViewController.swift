

import UIKit

class NotificationDetailsViewController: BaseViewController {

    @IBOutlet weak var iv_notification: UIImageView!
    @IBOutlet weak var label_time: UILabel!
    @IBOutlet weak var label_title: UILabel!
    @IBOutlet weak var tv_content: UITextView!
    @IBOutlet weak var btn_action: UIButton!
    
    var hkb_notification: Hkb_notifications?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    private func initUI () {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_back"), style: .plain, target: self, action: #selector(onBackTapped))
        
        let dateCreatedOn = Utils.convertStringToDate(dateString: (hkb_notification?.createdOn)!)
        label_time.text = Utils.timeAgoStringFromDate(date: dateCreatedOn)
        iv_notification.kf.setImage(with: URL(string: (hkb_notification?.imageurl!)!))
        label_title.text = hkb_notification?.title!
        tv_content.text = hkb_notification?.message!
        btn_action.setTitle(hkb_notification?.buttontext!, for: .normal)
    }
    
    private func showUrl () {
        guard let url = URL(string: (hkb_notification?.imageurl!)!) else { return }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    private func invite () {
        let text = "Hey! I'm using Hysab Kytab to track my finances. Download the app now and give it a try! \n https://vs8nc.app.goo.gl/invite"
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: false, completion: nil)
    }

    @IBAction func onNotificationActionTapped(_ sender: Any) {
        if hkb_notification?.codetype == 0 || hkb_notification?.codetype == 4 {
            self.dismiss(animated: true, completion: nil)
        } else if hkb_notification?.codetype == 1 {
            showUrl()
        } else if hkb_notification?.codetype == 2 {
            invite()
        } else if hkb_notification?.codetype == 3 {
            let dest = storyboard?.instantiateViewController(withIdentifier: "SavingDetailsVC")
            self.navigationController?.pushViewController(dest!, animated: true)
        } else if hkb_notification?.codetype == 5 {
            let dest = storyboard?.instantiateViewController(withIdentifier: "MainVC")
            self.present(dest!, animated: true, completion: nil)
        }
    }
    
    
    @objc private func onBackTapped () {
        self.dismiss(animated: true, completion: nil)
    }
}
