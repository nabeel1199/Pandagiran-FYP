

import UIKit


protocol GenericPopupSelection {
    func onButtonTapped(index: Int, objectIndex: Int)
}

class GenericPopup: BasePopup {

    @IBOutlet weak var label_popup_title: CustomFontLabel!
    
    @IBOutlet weak var popup_view: CardView!
    @IBOutlet weak var stack_view: UIStackView!
    @IBOutlet weak var label_popup_msg: UILabel!
    
    
    public var objectIndex = 0
    public var message = ""
    public var popupTitle = ""
    public var btnText = ""
    public var delegate: GenericPopupSelection?
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        populateButtons()

    }
    
    private func initUI () {
        label_popup_title.text = popupTitle
        label_popup_msg.text = message

    }
    
    private func populateButtons () {
        let btnArray = btnText.components(separatedBy: ",")
        
        for i in 0 ..< btnArray.count {
            let button = UIButton()
            button.setTitle(btnArray[i], for: .normal)
            button.layer.cornerRadius = 5.0
            button.tag = i
            button.regularFont(fontStyle: .bold, size: Style.dimen.REGULAR_TEXT)
            button.backgroundColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
            button.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
            stack_view.addArrangedSubview(button)
        }
    }

    @objc private func onButtonTapped (sender: UIButton) {
        delegate?.onButtonTapped(index: sender.tag, objectIndex: objectIndex)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
