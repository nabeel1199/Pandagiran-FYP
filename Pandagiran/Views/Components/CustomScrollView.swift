

import Foundation

class CustomScrollView : UIScrollView , UIGestureRecognizerDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        super.delegate = self as? UIScrollViewDelegate
        delegate = self as? UIScrollViewDelegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        super.delegate = self as? UIScrollViewDelegate
        delegate = self as? UIScrollViewDelegate
//        fatalError("init(coder:) has not been implemented")
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    
    
}
