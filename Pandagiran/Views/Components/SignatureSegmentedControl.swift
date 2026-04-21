//
//  SignatureSegmentedControl.swift
//  Pandagiran

import Foundation

import UIKit

protocol SegmentButtonTappedListener {
    func onSegmentTapped (btnTitle: String)
}

@IBDesignable
class SignatureSegmentedControl: UIControl {
    
    var buttons = [UIButton]()
    var selector: UIView!
    
    var delegate : SegmentButtonTappedListener?
    
    var selectedSegmentIndex = 0 {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var selectedBackgroundColor: UIColor = UIColor.white {
        didSet {
            updateView()
        }
    }
    @IBInspectable var unselectedBackgroundColor: UIColor = UIColor.white {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var unselectedBtnOpacity: CGFloat = 0.3 {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    
    @IBInspectable var cornerRadius: CGFloat = 10 {
        
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var btnCornerRadius: CGFloat = 10 {
        
        didSet {
            updateView()
        }
    }
    
    
    @IBInspectable var borderColor: UIColor = .clear {
        
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var commaSeperatedButtonTitles: String = "" {
        
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var textColor: UIColor = .white {
        
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var selectedTitleColor : UIColor = Utils.hexStringToUIColor(hex: Style.color.PRIMARY_COLOR) {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var unselectedTitleColor: UIColor = .white {
        didSet {
            updateView()
        }
    }
    
    
    @IBInspectable var selectorColor: UIColor = UIColor.clear {
        
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var selectorTextColor: UIColor = Utils.hexStringToUIColor(hex: AppColors.PRIMARY_COLOR) {
        
        didSet {
            updateView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func updateView() {
        
        buttons.removeAll()
        subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        
        
        
        let buttonTitles = commaSeperatedButtonTitles.components(separatedBy: ",")
        
        for buttonTitle in buttonTitles {
            
            let button = UIButton()
            button.layer.cornerRadius = btnCornerRadius
            button.backgroundColor = unselectedBackgroundColor.withAlphaComponent(unselectedBtnOpacity)
            button.setTitle(buttonTitle, for: .normal)
            button.regularFont(fontStyle: .bold, size: Style.dimen.XS_TEXT)
            button.setTitleColor(unselectedTitleColor, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
            buttons.append(button)
            //            button.setTitleColor(button.isSelected ? UIColor.gray : selectorTextColor, for: .normal)
        }
        
        buttons[selectedSegmentIndex].setTitleColor(selectedTitleColor, for: .normal)
        buttons[selectedSegmentIndex].backgroundColor = selectedBackgroundColor
        
        let selectorWidth = frame.width / CGFloat(buttonTitles.count)
        
        let y =    (self.frame.maxY - self.frame.minY) - 3.0
        
        selector = UIView.init(frame: CGRect.init(x: 0, y: y, width: selectorWidth, height: 3.0))
        //selector.layer.cornerRadius = frame.height/2
        selector.backgroundColor = selectorColor
        addSubview(selector)
        
        // Create a StackView
        
        let stackView = UIStackView.init(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 10.0
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        // Drawing code
        
        // layer.cornerRadius = frame.height/2
        
    }
    
    
    @objc func buttonTapped(button: UIButton) {
        
        for (buttonIndex,btn) in buttons.enumerated() {
            btn.setTitleColor(unselectedTitleColor, for: .normal)
            btn.backgroundColor = unselectedBackgroundColor.withAlphaComponent(unselectedBtnOpacity)
            
            if btn.titleLabel?.text == button.titleLabel?.text {
                selectedSegmentIndex = buttonIndex
                
                let selectorStartPosition = frame.width / CGFloat(buttons.count) * CGFloat(buttonIndex)
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.selector.frame.origin.x = selectorStartPosition
                })
                btn.backgroundColor = selectedBackgroundColor
                btn.setTitleColor(selectedTitleColor, for: .normal)
            }
        }
        
        delegate?.onSegmentTapped(btnTitle: (button.titleLabel?.text)!)
        sendActions(for: .valueChanged)
        
        
        
        
    }
    
    
    func updateSegmentedControlSegs(index: Int) {
        
        for btn in buttons {
            btn.setTitleColor(textColor, for: .normal)
        }
        
        let  selectorStartPosition = frame.width / CGFloat(buttons.count) * CGFloat(index)
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.selector.frame.origin.x = selectorStartPosition
        })
        
        buttons[index].setTitleColor(selectorTextColor, for: .normal)
        
    }
    
    
    
    //    override func sendActions(for controlEvents: UIControlEvents) {
    //
    //        super.sendActions(for: controlEvents)
    //
    //        let  selectorStartPosition = frame.width / CGFloat(buttons.count) * CGFloat(selectedSegmentIndex)
    //
    //        UIView.animate(withDuration: 0.3, animations: {
    //
    //            self.selector.frame.origin.x = selectorStartPosition
    //        })
    //
    //        buttons[selectedSegmentIndex].setTitleColor(selectorTextColor, for: .normal)
    //
    //    }
    
    
    
    
    
}
