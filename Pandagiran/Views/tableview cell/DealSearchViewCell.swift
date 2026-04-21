

import UIKit

class DealSearchViewCell: UITableViewCell {

    
    @IBOutlet weak var label_current_price: UILabel!
    
    @IBOutlet weak var label_price_before: UILabel!
    @IBOutlet weak var iv_brand_logo: UIImageView!
    @IBOutlet weak var label_brand_name: UILabel!
    @IBOutlet weak var iv_deal: UIImageView!
    @IBOutlet weak var label_product_name: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        label_product_name.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
        label_brand_name.regularFont(fontStyle: .regular, size: Style.dimen.SMALL_TEXT)
        label_price_before.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
        label_current_price.regularFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "Rs 2,500")
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        label_price_before.attributedText = attributeString
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
