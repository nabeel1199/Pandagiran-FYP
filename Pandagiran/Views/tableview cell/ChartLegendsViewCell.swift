

import UIKit

class ChartLegendsViewCell: UITableViewCell {

    @IBOutlet weak var label_spent: UILabel!
    @IBOutlet weak var legend_title: UILabel!
    @IBOutlet weak var iv_legend: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        legend_title.regularFont(fontStyle: .regular, size: Style.dimen.SMALL_TEXT)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let view = CardView()
        // Configure the view for the selected state
    }
    
}
