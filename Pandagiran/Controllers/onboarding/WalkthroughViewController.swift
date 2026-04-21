

import UIKit


protocol WalkthroughCompletionListener {
    func didFinishWalkthrough ()
}

class WalkthroughViewController: BaseViewController {

    
    @IBOutlet weak var page_control: UIPageControl!

    @IBOutlet weak var collection_view_onboarding: UICollectionView!
    
    private var onboardingArray : Array<Onboarding> = []
    private var indexToSelect = 0
    
    public var delegate : WalkthroughCompletionListener?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initVariables()
        initUI()
        onboardingFeatures()
    }
    
    
    
    private func navigateToTermsAndConditions () {

    }
    
    private func initVariables() {
        collection_view_onboarding.delegate = self
        collection_view_onboarding.dataSource = self
    }
    
    private func initUI () {
        self.viewBackgroundColor = .white
        self.navigationItemColor = .light
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SKIP", style: .plain, target: self, action: #selector(onSkipTapped))
    }
    
    private func onboardingFeatures () {
        var onboarding = Onboarding(featureImage: "walkthrough_1", featureTitle: "Your Feedback Matters!", featureMessage: "Hysab Kytab is here with a fresh look and new features based on the valuable feedback provided by our users.")
        onboardingArray.append(onboarding)
        
        onboarding = Onboarding(featureImage: "walkthrough_2", featureTitle: "Your Feedback Matters!", featureMessage: "Hysab Kytab is here with a fresh look and new features based on the valuable feedback provided by our users.")
        onboardingArray.append(onboarding)
        
        onboarding = Onboarding(featureImage: "walkthrough_3", featureTitle: "WHAT'S NEW!", featureMessage: "The all new HK comes with an option to manage all your debts, so that you always remember who owes you how much!")
        onboardingArray.append(onboarding)
        
        onboarding = Onboarding(featureImage: "walkthrough_4", featureTitle: "WHAT'S NEW!", featureMessage: "Tags work just like a sub-category in Hysab kytab. So, if you want segmentation, you can use tags!")
        onboardingArray.append(onboarding)
        
    }
    
    @objc private func onSkipTapped () {
        delegate?.didFinishWalkthrough()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onNextTapped(_ sender: Any) {
        if indexToSelect == 4 {
            delegate?.didFinishWalkthrough()
            self.dismiss(animated: true, completion: nil)
        } else {
            DispatchQueue.main.async {
        
                self.collection_view_onboarding.selectItem(at: IndexPath(item: self.indexToSelect, section: 0), animated: true, scrollPosition: [.centeredHorizontally])
                self.page_control.currentPage = self.indexToSelect
            }
        }
    }
}

extension WalkthroughViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onboardingArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection_view_onboarding.dequeueReusableCell(withReuseIdentifier: "OnboardingViewCell", for: indexPath) as! OnboardingViewCell
        
        let onboarding = onboardingArray[indexPath.row]
        cell.iv_onboarding.image = UIImage( named : onboarding.featureImage)
        cell.iv_onboarding.contentMode = .scaleAspectFill
        cell.label_title.text = onboarding.featureTitle
        cell.label_message.text = onboarding.featureMessage
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = self.view.frame.width
        let cellHeight = collectionView.frame.height
        return CGSize(width : cellWidth , height : cellHeight)
    }
    

    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        indexToSelect = indexPath.row + 1
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = self.collection_view_onboarding.frame.size.width
        page_control.currentPage = Int(self.collection_view_onboarding.contentOffset.x / pageWidth)
    }
}
