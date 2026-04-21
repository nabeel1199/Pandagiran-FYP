

import UIKit


class NITTableViewCell: UITableViewCell {

    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var viewMore: UIButton!
    
    
   var lbl: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    

}
