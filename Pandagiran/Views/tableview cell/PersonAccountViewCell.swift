

import UIKit

class PersonAccountViewCell: UITableViewCell {

    @IBOutlet weak var iv_person: UIImageView!
    @IBOutlet weak var label_person_name: UILabel!
    @IBOutlet weak var label_person_contact: UILabel!
    @IBOutlet weak var iv_person_details: TintedImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configureBankWithItem (bank: Bank) {
        let bankImage = UIImage(named: bank.bank_icon!)
        iv_person.image = bankImage
        label_person_name.text = bank.bank_title!
        
    }
}
