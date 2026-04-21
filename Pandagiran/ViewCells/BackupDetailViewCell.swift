

import UIKit

class BackupDetailViewCell: UITableViewCell {

    @IBOutlet weak var recordTypeLBL: UILabel!
    @IBOutlet weak var countLBL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(recordType: String, recordCount: String){
        self.countLBL.text = recordCount
        self.recordTypeLBL.text = recordType
    }
}
