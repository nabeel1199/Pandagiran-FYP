

import Foundation
import TTGSnackbar

enum ImageViewRotation {
    case upsideDown
    case normal
}

class UIUtils {
    static var indicator: UIActivityIndicatorView = UIActivityIndicatorView()
    static var container: UIView = UIView()
    static var loadingView: UIView = UIView()
    public static var colorsArray : Array<String> = ["#f44336" , "#e91e63" , "#9c27b0" , "#673ab7" , "#3f51b5" , "#2196f3" , "#03a9f4" , "#00bcd4" , "#009688" , "#ffeb3b" , "#ffc107" , "#ff5722" , "#795548" , "#616161" , "#607d8b" , "#33691e" , "#00c853" , "#cddc39" , "#01579b" , "#2962ff"]
    public static var accountIconsArray : Array<String> = []
    
    public static func addNavigationIcon(navigationItem : UINavigationItem , iconName : String , action : String , position : String) {
        let button = UIBarButtonItem(image: UIImage(named: iconName), style: .plain, target: self, action: nil)
        if position == "right" {
            navigationItem.rightBarButtonItem = button
        } else {
            navigationItem.leftBarButtonItem = button
        }
        
    }
    
    public static func showAlert (vc : UIViewController , message : String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated: true , completion: nil)
    
        
    }
    
    public static func showSnackbar (message : String) {
        let snackbar = TTGSnackbar(message: message, duration: .middle)
//        snackbar.backgroundColor = Utils.hexStringToUIColor(hex: AppColors.hk_green)
        snackbar.icon = UIImage(named : "ic_done")?.withRenderingMode(.alwaysTemplate)
        snackbar.tintColor = UIColor.white
        snackbar.show()
    }
    
    public static func showSnackbarNegative (message : String) {
        let snackbar = TTGSnackbar(message: message, duration: .short)
        snackbar.backgroundColor = UIColor.red
        snackbar.icon = UIImage(named : "ic_warning")?.withRenderingMode(.alwaysTemplate)
        snackbar.tintColor = UIColor.white
        snackbar.show()
    }
    
    public static func viewGone(view : UIView) {
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0))
    }
    
    public static func removeTopConstraint (view: UIView) {
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0))
    }
    
    public static func adjustViewHeight(view : UIView , height : Int) {
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(height)))
    }
    
    public static func activitiesBgColor (view : UIView , currentInterval : String , monthOrDay : Int) {
        if currentInterval == Constants.MONTHLY {
            // if interval is monthly , day colors will be shown
//            view.backgroundColor = Utils.hexStringToUIColor(hex: AppColors.dayColors()[monthOrDay]!)
        } else {
            // else month colors to be shown
//            view.backgroundColor = Utils.hexStringToUIColor(hex: AppColors.monthColors()[Utils.getMonthFromInt(num: monthOrDay - 1)]!)
        }
    }
    
    public static func populateAccountIcons () -> Array<String> {
        var accountIconsArray : Array <String> = []
        for i in 1 ... 108 {
            accountIconsArray.append("bt_\(i)")
            print("bt_\(i)")
        }
        
        return accountIconsArray
    }
    
    public static func getStoryboard (name: String) -> UIStoryboard {
        let board = UIStoryboard(name : name , bundle : nil)
        return board
    }
    
    public static func showLoader (view : UIView) {
        container.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height)
//        container.backgroundColor = UIColor(white: 0, alpha: 0.5)
        container.backgroundColor = UIColor.clear
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        loadingView.center = container.center
        loadingView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        loadingView.clipsToBounds = true
//        loadingView.backgroundColor = UIColor.clear
        loadingView.layer.cornerRadius = 10
        
        indicator.style = UIActivityIndicatorView.Style.whiteLarge
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0)
        indicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        loadingView.addSubview(indicator)
        container.addSubview(loadingView)
        view.addSubview(container)
        indicator.startAnimating()
    }
    
    public static func dismissLoader(uiView: UIView) {
        indicator.stopAnimating()
        container.removeFromSuperview()
    }
    
    public static func rotateImage (imageView: UIView, angle: ImageViewRotation) {
        UIView.animate(withDuration: 0.5, animations: {
            switch angle {
            case .upsideDown:
                imageView.transform = CGAffineTransform(rotationAngle: (180.0 * .pi) / 180.0)
            case .normal:
                imageView.transform = CGAffineTransform(rotationAngle: 0)
            }
            
        })
    }
    
    public static func getStruckThroughText (text: String) -> NSMutableAttributedString {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: text)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        attributeString.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor.red, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }


}

extension UIView {
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
}
