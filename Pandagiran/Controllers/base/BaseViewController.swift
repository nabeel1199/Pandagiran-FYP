

import UIKit
import SideMenu

public enum UINavItemColor: Int {
    case light
    case dark
    case gradient
}

public enum UIViewBackgroundColor: Int {
    case normal
    case dark
    case gradient
    case white
}

@IBDesignable
class BaseViewController: UIViewController {
    
    private let menu_button = UIBarButtonItem()
    
    public var navigationItemColor: UINavItemColor = .dark {
        didSet {
            preferredNavigationColor()
        }
    }
    
    public var viewBackgroundColor: UIViewBackgroundColor = .normal {
        didSet {
            setBackgroundColor()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    

        preferredNavigationColor()
        setBackgroundColor()
        hideKeyboardWhenTappedAround()
        print("Navigation Controller Count: \(navigationController?.viewControllers.count)")
    }

    private func preferredNavigationColor () {
        
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            //            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.configureWithTransparentBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.backgroundColor = UIColor.black
            self.navigationController?.navigationBar.standardAppearance = navBarAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        } else {
            print("Set")
            UINavigationBar.appearance().tintColor = UIColor.white
            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
            UINavigationBar.appearance().barTintColor = UIColor.black
        }
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000.0, vertical: 0.0), for: .default)

        switch navigationItemColor {
        case .light:
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            self.viewBackgroundColor = .white
            break
        case .dark:
            self.navigationController?.navigationBar.barTintColor = UIColor.black
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        case .gradient:
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            self.navigationController?.navigationBar.tintColor = UIColor.white
            gradientNavBar()
            break
        }
    }
    
    private func setBackgroundColor () {
        switch viewBackgroundColor {
        case .normal:
            view.backgroundColor = Utils.hexStringToUIColor(hex: "#f9f9f9")
        case .dark:
            view.backgroundColor = UIColor.black
        case .gradient:
            let image = getImageFrom(gradientLayer: getThemeGradient())
            view.backgroundColor = UIColor(patternImage: image!)
            break
        case .white:
            view.backgroundColor = .white
            break
        }
    }
    
    
    func getImageFrom(gradientLayer:CAGradientLayer) -> UIImage? {
        var gradientImage:UIImage?
        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }
        UIGraphicsEndImageContext()
        return gradientImage
    }
    
    private func gradientNavBar () {
        if let navigationBar = self.navigationController?.navigationBar {
            let gradient = getThemeGradient()
            var bounds = navigationBar.bounds
            bounds.size.height += UIApplication.shared.statusBarFrame.size.height
       
            
            if let image = getImageFrom(gradientLayer: gradient) {
                navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
            }
        }
    }
    
    private func getThemeGradient () -> CAGradientLayer {
        let colors = ["#FF000000" , "#FFFFFFFF"]
        
        let gradient = CAGradientLayer()
        gradient.frame = self.view.bounds
  
        gradient.startPoint = CGPoint(x: 0.0, y: 0)
        gradient.endPoint = CGPoint(x: 1.0, y: 0)
        gradient.colors = [Utils.hexStringToUIColor(hex: colors[0]).cgColor, Utils.hexStringToUIColor(hex: colors[1]).cgColor]
        
        return gradient
    }
    
    public func getStoryboard (name: String) -> UIStoryboard {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        return storyboard
    }
    
    public func presentPopupView (popupView: UIViewController) {
        popupView.providesPresentationContextTransitionStyle = true
        popupView.definesPresentationContext = true
        popupView.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        popupView.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(popupView, animated: true, completion: nil)
    }
    
    public func animateTextField(up: Bool) {
        let movementDistance:CGFloat = -130
        let movementDuration: Double = 0.3
        
        var movement:CGFloat = 0
        if up
        {
            movement = movementDistance
        }
        else
        {
            movement = -movementDistance
        }
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    public func addSideMenu () {
        let menuButton = UIBarButtonItem(image: UIImage(named: "drawer_icon"), style: .plain, target: self, action: #selector(onSideMenuTapped))
        self.navigationItem.leftBarButtonItem = menuButton
        
        let sideMenu = getStoryboard(name: ViewIdentifiers.SB_MAIN).instantiateViewController(withIdentifier: ViewIdentifiers.VC_SIDE_MENU)
        let menu = UISideMenuNavigationController(rootViewController: sideMenu)
        
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuLeftNavigationController = menu
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        SideMenuManager.default.menuFadeStatusBar = false
    }
    
    
    @objc private func onSideMenuTapped () {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
