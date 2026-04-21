

import UIKit
import Cosmos

protocol ReviewAddedListener {
    func onReviewAdded (review : Reviews)
}

class AddReviewViewController: BaseViewController {

    @IBOutlet weak var text_view_review: UITextView!
    @IBOutlet weak var rating_bar: CosmosView!
    @IBOutlet weak var label_deal_title: UILabel!
    @IBOutlet weak var iv_deal: UIImageView!
    
    public var deal : Deal!
    public var delegate : ReviewAddedListener?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()
    }
    
    private func initVariables () {
        text_view_review.delegate = self
    }
    
    private func initUI () {
        self.navigationItemColor = .light
        
        rating_bar.rating = 0
        rating_bar.settings.minTouchRating = 1
        text_view_review.text = "Add your review here"
        text_view_review.textColor = UIColor.lightGray
        
        iv_deal.kf.setImage(with: URL(string: deal.deal_image_link!))
        label_deal_title.text = deal.deal_title!
    }
    
    private func addReviewNetworkCall () {
        UIUtils.showLoader(view: self.view)
        let dealsNetworkHelper = DealsAndOffers()
        dealsNetworkHelper.addReviewNetworkCall(dealId: deal.deal_id!,
                                                partnerId: deal.partner_id!,
                                                review: text_view_review.text,
                                                rating: rating_bar.rating, successHandler:
            { (status, message) in
                
                if status == 1 {
                    let consumerName = LocalPrefs.getUserData()[Constants.USER_NAME]!
                    self.delegate?.onReviewAdded(review: Reviews(consumer_name: consumerName,
                                                            comments: self.text_view_review.text!))
                    UIUtils.showSnackbar(message: "Review added successfully")
                    self.navigationController?.popViewController(animated: true)
                } else {
                    UIUtils.showAlert(vc: self, message: message)
                }
                
        })
        { (error) in
            UIUtils.dismissLoader(uiView: self.view)
            UIUtils.showAlert(vc: self, message: error.localizedDescription)
        }
    }
    
    @IBAction func onSubmitTapped(_ sender: Any) {
        addReviewNetworkCall()
    }
    
    
    override func willMove(toParent parent: UIViewController?) {
        self.navigationItemColor = .dark
    }
}

extension AddReviewViewController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add your review here"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
}


