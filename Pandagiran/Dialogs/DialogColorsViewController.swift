

import UIKit

class DialogColorsViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource {

    @IBOutlet weak var colorsCollection: UICollectionView!
    @IBOutlet weak var btn_cancel: UIButton!
    
    var colorsArray : Array <String> = []
    var myDelegate : ColorSelectionListener?
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()
       
    }

    func initVariables() -> Void {
        colorsArray = UIUtils.colorsArray
        
        colorsCollection.dataSource = self
        colorsCollection.delegate = self
        
        let nibColor = UINib(nibName : "ColorViewCell" , bundle : nil)
        colorsCollection.register(nibColor, forCellWithReuseIdentifier: "ColorViewCell")
    }
    
    func initUI() {
        overlayBlurredBackgroundView()
    }
    
    func overlayBlurredBackgroundView() {
        
        let blurredBackgroundView = UIVisualEffectView()
        blurredBackgroundView.frame = self.view.bounds
        blurredBackgroundView.effect = UIBlurEffect(style: .regular)
        blurredBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurredBackgroundView, at: 0)
    }
    
    // Action Listeners
    @IBAction func onCancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    
    // Delegate methods here
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = colorsCollection.dequeueReusableCell(withReuseIdentifier: "ColorViewCell", for: indexPath) as! ColorViewCell
        
        cell.color_background.backgroundColor = Utils.hexStringToUIColor(hex: colorsArray[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        myDelegate?.onColorSelected(selectedColor: colorsArray[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }

}
