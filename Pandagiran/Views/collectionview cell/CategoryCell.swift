

import UIKit

class CategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var bg_view: CircularView!
    @IBOutlet weak var category_title: UILabel!
    
    public var cellType = "Category"
    
    
    override var isSelected: Bool {
        didSet {
            switch cellType {
            case "Category":
                // if cellType = Category
                if self.isSelected {
                    bg_view.layer.borderWidth = 2.0
                    bg_view.layer.shadowOpacity = 0.3
                    bg_view.layer.borderColor = UIColor().hexCode(hex: Style.color.PRIMARY_COLOR).cgColor
                    category_title.textColor = UIColor.black
                    categoryImage.tintColor = UIColor().hexCode(hex: Style.color.PRIMARY_COLOR)
                }
                else
                {
                    category_title.textColor = UIColor.lightGray
                    bg_view.layer.shadowOpacity = 0.0
                    bg_view.layer.borderColor = UIColor.lightGray.cgColor
                    bg_view.layer.borderWidth = 1
                    categoryImage.tintColor = UIColor.lightGray
                }
                
            default:
                // if cellType = Account
                if self.isSelected {
                    contentView.layer.borderColor = Utils.hexStringToUIColor(hex: AppColors.PRIMARY_COLOR).cgColor
                    contentView.layer.borderWidth = 2.0
                }
                else
                {
                    contentView.layer.borderColor = UIColor.lightGray.cgColor
                    contentView.layer.borderWidth = 1.0
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        category_title.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let screenWidth = UIScreen.main.bounds.width
        let targetSize = CGSize(width: screenWidth / 5, height: 75)
        
        let autoLayoutSize = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: autoLayoutSize)
        
        // Assign the new size to the layout attributes
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }

    public func configureAccountsWithItemCells (account: Hkb_account) {
        var accountType = ""
        
        if let title = account.title {
            category_title.text = account.title
        }
        
        if let type = account.acctype {
            accountType = type
        }
       
        if let accountIcon = account.boxicon {
            if accountType != "Bank" {
//                let image = UIImage(named: accountIcon)?.withRenderingMode(.alwaysTemplate)
//                categoryImage.image = image
                if let image = UIImage(named: accountIcon){
                    categoryImage.image = image.withRenderingMode(.alwaysTemplate)
                } else {
                    categoryImage.image = UIImage(named: "accounts")?.withRenderingMode(.alwaysTemplate)
                }
                categoryImage.tintColor = UIColor.lightGray
            } else {
//                let image = UIImage(named: accountIcon)
//                categoryImage.image = image
                if let image = UIImage(named: accountIcon){
                    categoryImage.image = image
                } else {
                    categoryImage.image = UIImage(named: "accounts")
                }
                
            }
        }
        
        contentView.layer.cornerRadius = 8
        category_title.textColor = UIColor.black
//        bg_view.layer.borderWidth = 0
//        bg_view.shadowOpacity = 0

        if isSelected {
            contentView.layer.borderColor = UIColor().hexCode(hex: Style.color.PRIMARY_COLOR).cgColor
            contentView.layer.borderWidth = 2.0
        } else {
            contentView.layer.borderColor = UIColor.lightGray.cgColor
            contentView.layer.borderWidth = 1.0
        }
    }
    
    public func configureCategoryWithItemCells (category: Hkb_category) {
//        let cellImage = UIImage(named: category.box_icon!)?.withRenderingMode(.alwaysTemplate)
        category_title.text = category.title
        if let image = UIImage(named: category.box_icon ?? "category"){
            categoryImage.image = image.withRenderingMode(.alwaysTemplate)
        } else {
            categoryImage.image = UIImage(named: "category")?.withRenderingMode(.alwaysTemplate)
        }
//        categoryImage.image = cellImage
        
        if isSelected {
            bg_view.layer.borderColor = Utils.hexStringToUIColor(hex: AppColors.PRIMARY_COLOR).cgColor
            bg_view.layer.borderWidth = 2.0
            bg_view.layer.shadowOpacity = 0.3
            category_title.textColor = UIColor.black
            categoryImage.tintColor = Utils.hexStringToUIColor(hex: AppColors.PRIMARY_COLOR)
        } else {
            contentView.layer.borderWidth = 0
            category_title.textColor = UIColor().hexCode(hex: Style.color.LIGHT_TEXT)
            bg_view.layer.shadowOpacity = 0.0
            bg_view.layer.borderWidth = 1
            categoryImage.tintColor = UIColor().hexCode(hex: Style.color.LIGHT_TEXT)
        }
    }
    
    public func configureSavingCategoryWithItemCells (category: Category) {
//        let cellImage = UIImage(named: category.box_icon!)?.withRenderingMode(.alwaysTemplate)
        if let image = UIImage(named: category.box_icon ?? "category"){
            categoryImage.image = image.withRenderingMode(.alwaysTemplate)
        } else {
            categoryImage.image = UIImage(named: "category")?.withRenderingMode(.alwaysTemplate)
        }
        category_title.text = category.title
//        categoryImage.image = cellImage
    }
    
   
}
