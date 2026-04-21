

import UIKit

class DialogAccountType: UIViewController {

    @IBOutlet weak var table_view: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var accountTypeArray = ["Person/Other" , "Cash" , "Bank"]
    var iconsArray = ["ic_person" , "bt_87" , "ic_account"]
    var myDelegate: AccountTypeSelectionListener?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initUI()
    }
    
    private func initVariables () {
        table_view.delegate = self
        table_view.dataSource = self
        
        let nibType = UINib(nibName : "VoucherAccountViewCell" , bundle : nil)
        table_view.register(nibType, forCellReuseIdentifier: "VoucherAccountsViewCell")
    }
    
    private func initUI () {
//        tableViewHeight.constant = table_view.contentSize.height
        overlayBlurredBackgroundView()
    }
    
    func overlayBlurredBackgroundView() {
        let blurredBackgroundView = UIVisualEffectView()
        blurredBackgroundView.frame = self.view.bounds
        blurredBackgroundView.effect = UIBlurEffect(style: .regular)
        blurredBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurredBackgroundView, at: 0)
    }
    
    @IBAction func onCancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension DialogAccountType : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accountTypeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = table_view.dequeueReusableCell(withIdentifier: "VoucherAccountsViewCell", for: indexPath) as! VoucherAccountViewCell
        
        cell.accountTitle.text = accountTypeArray[indexPath.row]
        cell.accountImage.image = UIImage(named: iconsArray[indexPath.row])?.withRenderingMode(.alwaysTemplate)
        cell.accountImage.tintColor = UIColor.purple
        cell.bgView.layer.borderColor = UIColor.purple.cgColor
        
        
        tableViewHeight.constant = tableView.contentSize.height + 8
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myDelegate?.onAccountTypeSelected(type: accountTypeArray[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
}
