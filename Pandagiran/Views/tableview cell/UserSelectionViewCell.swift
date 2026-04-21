

import UIKit

class UserSelectionViewCell: UITableViewCell {

    @IBOutlet weak var iv_edit: TintedImageView!
    @IBOutlet weak var iv_visibility: UIImageView!
    @IBOutlet weak var bg_view: CardView!
    @IBOutlet weak var label_profession_type: UILabel!
    @IBOutlet weak var iv_user: TintedImageView!
    
    public var cellType : String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if cellType == "" {
            if selected {
                
                bg_view.backgroundColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
                label_profession_type.textColor = UIColor.white
                iv_user.tintColor = UIColor.white
                
            } else {
                bg_view.backgroundColor = UIColor.groupTableViewBackground
                label_profession_type.textColor = UIColor.black
                iv_user.tintColor = UIColor.black
                
            }
        }
       
    }
    
    public func configureCategoryWithItem (category : Hkb_category) {
        label_profession_type.text = category.title!
        print("Cat Name: \(category.title!), Cat Icon Name: \(category.box_icon!)")
//        iv_user.image = UIImage(named: category.box_icon!)?.withRenderingMode(.alwaysOriginal)
        if let image = UIImage(named: category.box_icon ?? "category"){
            iv_user.image = image.withRenderingMode(.alwaysTemplate)
        } else {
            iv_user.image = UIImage(named: "category")?.withRenderingMode(.alwaysTemplate)
        }
        iv_visibility.isHidden = false
        
        if category.active == 0 {
            let image = UIImage(named: "ic_visibility_off")
            iv_visibility.image = image
            iv_visibility.tintColor = UIColor.lightGray
        } else {
            let image = UIImage(named: "ic_visibility")
            iv_visibility.image = image
            iv_visibility.tintColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
        }
        
        if category.parent_category_id != 0 {
            iv_edit.isHidden = false
        } else {
            iv_edit.isHidden = true
        }
    }
}
