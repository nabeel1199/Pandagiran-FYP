

import UIKit

class DashboardDetailsCell: UICollectionViewCell , UICollectionViewDataSource , UICollectionViewDelegate {
    
    @IBOutlet var accountsCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setUpViews()
    }
    
    func setUpViews() {
        accountsCollectionView.dataSource = self
        accountsCollectionView.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = accountsCollectionView.dequeueReusableCell(withReuseIdentifier: "accountsCell", for: indexPath)
        cell.backgroundColor = UIColor.red
        return cell
    }
}
