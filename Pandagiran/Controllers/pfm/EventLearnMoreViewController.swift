

import UIKit

class EventLearnMoreViewController: BaseViewController {

    
    @IBOutlet weak var label_people_save_for: UILabel!
    @IBOutlet weak var label_placeholder_text: UILabel!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collection_view: UICollectionView!
    
    private let learnMoreNibName = "CategoryCell"
    private let arrayOfEvents = ["Wedding", "Travel", "Vacation"]
    
    
    override func viewDidLoad() {
        
        initVariables()
        initUI()
    }
    
    private func initVariables () {
        initNibs()
        
        collection_view.delegate = self
        collection_view.dataSource = self
    }
    
    private func initUI () {
        self.navigationItemColor = .light
        self.navigationItem.title = "Events"
        
        let rightBarIcon = UIBarButtonItem(image: UIImage(named: "ic_clear"), style: .plain, target: self, action: #selector(onRightNavIconTapped))
        self.navigationItem.rightBarButtonItem = rightBarIcon
        
        label_placeholder_text.headingFont(fontStyle: .bold, size: Style.dimen.HEADING_TEXT)
        label_people_save_for.regularFont(fontStyle: .regular, size: Style.dimen.REGULAR_TEXT)
    }
    
    private func initNibs () {
        let nibLearnMore = UINib(nibName: learnMoreNibName, bundle: nil)
        collection_view.register(nibLearnMore, forCellWithReuseIdentifier: learnMoreNibName)
    }
    
    private func navigateToAddEvent () {
        let addEventVC = getStoryboard(name: ViewIdentifiers.SB_EVENT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_EVENT) as! AddEventViewController
        self.navigationController?.pushViewController(addEventVC, animated: true)
    }
    
    @objc private func onRightNavIconTapped () {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func onAddEventTapped(_ sender: Any) {
        navigateToAddEvent()
    }
}

extension EventLearnMoreViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    override func viewDidLayoutSubviews() {
        super.updateViewConstraints()
        self.collectionViewHeight.constant = 100
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrayOfEvents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: learnMoreNibName, for: indexPath) as! CategoryCell
        
        cell.cellType = "Category"
        cell.category_title.text = arrayOfEvents[indexPath.row]
        cell.category_title.textColor = UIColor.lightGray
        cell.categoryImage.image = UIImage(named: "bt_4")?.withRenderingMode(.alwaysTemplate)
        cell.categoryImage.tintColor = UIColor.lightGray
        
//        viewDidLayoutSubviews()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let addEventVC = getStoryboard(name: ViewIdentifiers.SB_EVENT).instantiateViewController(withIdentifier: ViewIdentifiers.VC_ADD_EVENT) as! AddEventViewController
        addEventVC.eventTitle = arrayOfEvents[indexPath.row]
        self.navigationController?.pushViewController(addEventVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.collection_view.frame.width / 3.5
        return CGSize(width: width, height: 100)
    }
    
}
