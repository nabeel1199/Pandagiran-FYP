

import UIKit

class ChooseCategoryViewController: BaseViewController {
    
    @IBOutlet weak var collection_view_categories: UICollectionView!
    
    private let nibCategoryName = "CategoryCell"
    private var categoriesArray : Array<Hkb_category> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        
        initUI()
        initVariables()

    }
    
    private func initUI () {
    }
    
    
    private func initVariables () {
        initNibs()
        
        collection_view_categories.delegate = self
        collection_view_categories.dataSource = self
        
        categoriesArray = QueryUtils.fetchCategories(type: "ALL")
        
    }
    
    private func initNibs () {
        let nibCategories = UINib(nibName: nibCategoryName, bundle: nil)
        collection_view_categories.register(nibCategories, forCellWithReuseIdentifier: nibCategoryName)
//        collection_view_categories.register(CategoryHeader.self, forCellWithReuseIdentifier: "CategoryHeader")
    
        
    }

    
}

extension ChooseCategoryViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibCategoryName, for: indexPath) as! CategoryCell
        
        cell.bg_view.layer.borderColor = UIColor.black.cgColor
        cell.bg_view.layer.borderWidth = 2.0
        cell.bg_view.backgroundColor = UIColor.clear
        cell.categoryImage.tintColor = UIColor.lightGray
        cell.category_title.text = categoriesArray[indexPath.row].title
        let image = UIImage(named: categoriesArray[indexPath.row].box_icon!)?.withRenderingMode(.alwaysTemplate)
        cell.categoryImage.image = image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / 3.5
        let height: CGFloat = 75
        return CGSize(width: width, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.navigationController?.popViewController(animated: true)
    }
   
}

