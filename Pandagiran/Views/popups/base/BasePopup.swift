
import UIKit

class BasePopup: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

       initUI()
    }
    
    private func initUI () {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)

    }
    
    public func animateView(popup_view: UIView) {
        popup_view.alpha = 0;
        popup_view.frame.origin.y = popup_view.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            popup_view.alpha = 1.0;
            popup_view.frame.origin.y = popup_view.frame.origin.y - 50
        })
    }
    
    @objc private func onViewTapped () {
//        self.dismiss(animated: true, completion: nil)
    }
    

}
