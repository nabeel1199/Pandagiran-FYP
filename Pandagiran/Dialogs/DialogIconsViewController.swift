

import UIKit

class DialogIconsViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource {

    @IBOutlet weak var iconsCollection: UICollectionView!
    
    var iconsArray : Array<String> = []
    var myDelegate : AccountIconSelectionListener?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        iniUI()
        print("Account Icons Count : " , iconsArray.count)
        
    }
    
    func initVariables() {
        iconsArray = UIUtils.populateAccountIcons()
        
        iconsCollection.dataSource = self
        iconsCollection.delegate = self
        
        let nibIcons = UINib(nibName : "ColorViewCell" , bundle : nil)
        iconsCollection.register(nibIcons, forCellWithReuseIdentifier: "ColorViewCell")
    }
    
    func iniUI() {
        overlayBlurredBackgroundView()
    }
    

    
    func overlayBlurredBackgroundView() {
        
        let blurredBackgroundView = UIVisualEffectView()
        blurredBackgroundView.frame = self.view.bounds
        blurredBackgroundView.effect = UIBlurEffect(style: .regular)
        blurredBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurredBackgroundView, at: 0)
    }

    
    // Delegate methods
    @IBAction func onCancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iconsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = iconsCollection.dequeueReusableCell(withReuseIdentifier: "ColorViewCell", for: indexPath) as! ColorViewCell
        
        let image = UIImage(named : iconsArray[indexPath.row])?.withRenderingMode(.alwaysTemplate)
        cell.iv_icon.image = image
        cell.iv_icon.tintColor = UIColor.black
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        myDelegate?.onAccountIconSelected(boxColor: iconsArray[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
    
}
