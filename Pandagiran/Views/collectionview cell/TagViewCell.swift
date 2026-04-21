

import UIKit

class TagViewCell: UICollectionViewCell {

    @IBOutlet weak var label_tag: UILabel!
    @IBOutlet weak var iv_add: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = contentView.leftAnchor.constraint(equalTo: leftAnchor)
        let rightConstraint = contentView.rightAnchor.constraint(equalTo: rightAnchor)
        let topConstraint = contentView.topAnchor.constraint(equalTo: topAnchor)
        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
    }

}
