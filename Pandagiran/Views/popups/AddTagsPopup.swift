
import UIKit
import WSTagsField


class AddTagsPopup: BasePopup {

    @IBOutlet weak var tagsTextFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var et_tags: WSTagsField!
    @IBOutlet weak var tagsCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var collection_view_tags: UICollectionView!
    @IBOutlet weak var btn_apply: UIButton!
    @IBOutlet weak var popup_view: CardView!
    @IBOutlet weak var label_add_tags: CustomFontLabel!
    
    private let nibTagName = "TagViewCell"
    
    public var arrayOfTags : Array<String> = []
    public var delegate: TagsAddListener?
    public var addedTags: String = ""
    public var categoryTags: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()
        initTagsTextField()
        tagsTextFieldDelegates()
        fetchAddedTags()
        fetchTagsFromCategory()

    }

    
    private func initVariables () {
        initNib()
        collection_view_tags.delegate = self
        collection_view_tags.dataSource = self
       
    }
    
    private func initUI () {
        et_tags.layer.cornerRadius = 10.0
        et_tags.layer.borderColor = UIColor.lightGray.cgColor
        et_tags.layer.borderWidth = 1.0
        
        if let flowLayout = collection_view_tags.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    private func initTagsTextField () {
        et_tags.placeholder = "Add Tags"
        et_tags.backgroundColor = .white
        et_tags.selectedColor = .black
        et_tags.returnKeyType = .next
        et_tags.font = UIFont(name: Style.font.REGULAR_FONT, size: 14.0)
        et_tags.delegate = self
        et_tags.layer.cornerRadius = 8.0
        et_tags.layer.borderColor = UIColor.lightGray.cgColor
        et_tags.layer.borderWidth = 1.0
        et_tags.cornerRadius = 8.0
        et_tags.layoutMargins = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        et_tags.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        et_tags.keyboardType = .asciiCapable
        
//        let textField : UITextField = et_tags.subviews[0] as! UITextField
//        textField.addTarget(self, action: #selector(populateTags), for: .editingChanged)
//        tagsTextField = et_tags.subviews[0] as! UITextField
//        tags_table_view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        tags_table_view.dataSource = self
//        tags_table_view.delegate = self
//        tags_table_view.backgroundColor = UIColor.groupTableViewBackground
//        self.view_generic.addSubview(tags_table_view)
    }
    
    

    
    private func fetchAddedTags () {

        let userTags = ActivitiesDbUtils.fetchAllTags()
        
        for tag in userTags {
            let commaSeperatedTags = tag.components(separatedBy: ",")
            
            for commaSeperatedTag in commaSeperatedTags {
                if !arrayOfTags.contains(commaSeperatedTag) {
                    arrayOfTags.append(commaSeperatedTag)
                }
            }
        }
        
        if addedTags != "" {
            let tagsToAdd = addedTags.components(separatedBy: ",")
            
            for tag in tagsToAdd {
                et_tags.addTag(tag)
                
                // remove suggested tag
                for i in 0 ..< arrayOfTags.count {
                    if arrayOfTags[i] == tag {
                        arrayOfTags.remove(at: i)
                        break
                    }
                }
            }
        }
    }
    
    private func fetchTagsFromCategory () {
        if self.categoryTags != "" {
            let tagsArray = self.categoryTags.components(separatedBy: "~")
            
            for tag in tagsArray {
                if !arrayOfTags.contains(tag) {
                    arrayOfTags.append(tag)
                }
            }
        }
    }
    
    private func fetchTagsString () -> String {
    
        if et_tags.tags.count > 0 {
            var tagsArray : Array<String> = []
            
            for i in 0 ..< et_tags.tags.count {
                tagsArray.append(et_tags.tags[i].text)
            }
            
      
            
            let tagsString = tagsArray.joined(separator: ",")
            return tagsString
        } else {
            return ""
        }
    }

    private func initNib () {
        let nibTag = UINib(nibName: nibTagName, bundle: nil)
        self.collection_view_tags.register(nibTag, forCellWithReuseIdentifier: nibTagName)
    }
    
    @IBAction func onCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onApplyTapped(_ sender: Any) {
        if et_tags.text! != "" {
            et_tags.addTag(et_tags.text!)
        }
    
        let tags = fetchTagsString()
        delegate?.onTagsAdded(tags: tags)
        self.dismiss(animated: true, completion: nil)
    }
}


extension AddTagsPopup {
    
    fileprivate func tagsTextFieldDelegates () {
        et_tags.onDidRemoveTag = { _, _ in
        }
        
        et_tags.onDidSelectTagView = { _, tagView in
            self.et_tags.removeTag(tagView.displayText)
        }
        
        et_tags.onDidAddTag = { tagField, tagView in
            let randomColor = Int(arc4random_uniform(UInt32(UIUtils.colorsArray.count)))
            if let tag = self.et_tags.subviews[self.et_tags.tags.count] as? WSTagView {
                tag.tintColor = UIColor().hexCode(hex: UIUtils.colorsArray[randomColor])
            }
            
            
        }
        
        et_tags.onDidChangeHeightTo = { _, height in
            self.tagsTextFieldHeight.constant = height + 20
        }
        
        et_tags.onShouldAcceptTag = { tagField in
            if tagField.text! == "" {
                DispatchQueue.main.async {
                    self.view.endEditing(true)
                }
                
                return false
            }
            return true
        }

    }
    
}

extension AddTagsPopup: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibTagName, for: indexPath) as! TagViewCell
        
        cell.label_tag.text = arrayOfTags[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView.cellForItem(at: indexPath) != nil else {
            return
        }
    
        et_tags.addTag(arrayOfTags[indexPath.row])
        arrayOfTags.remove(at: indexPath.row)
        
        self.collection_view_tags.performBatchUpdates({
            collectionView.deleteItems(at: [indexPath])
        }) { (finished) in
            collectionView.reloadItems(at: self.collection_view_tags.indexPathsForVisibleItems)
        }
    }
    
}
