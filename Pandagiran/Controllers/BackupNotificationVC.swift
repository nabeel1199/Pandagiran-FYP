

import UIKit

class BackupNotificationVC: UIViewController {

    @IBOutlet weak var messageLBL: UILabel!
    
    let arrayString = [
        "Hysab Kytab now offers An Auto-BAckup Option",
        "We recommend you to backup your data on Hysab Kytab Cloud. A 100% safe & secure platform that allows you to access your account from anywhere & any device",
        "We will remove the iCloud storage option in our upcoming version."
    ]

    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.messageLBL.attributedText = add(stringList: arrayString, font: messageLBL.font, bullet: "●")
            
        //            ""
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func continueButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func crossButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func add(stringList: [String],
             font: UIFont,
             bullet: String = "\u{2022}",
             indentation: CGFloat = 20,
             lineSpacing: CGFloat = 2,
             paragraphSpacing: CGFloat = 12,
             textColor: UIColor = .gray,
             bulletColor: UIColor = UIColor().hexCode(hex: AppColors.PRIMARY_COLOR)) -> NSAttributedString {

        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor]
        let bulletAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: bulletColor]

        let paragraphStyle = NSMutableParagraphStyle()
        let nonOptions = [NSTextTab.OptionKey: Any]()
        paragraphStyle.tabStops = [
            NSTextTab(textAlignment: .left, location: indentation, options: nonOptions)]
        paragraphStyle.defaultTabInterval = indentation
        //paragraphStyle.firstLineHeadIndent = 0
        //paragraphStyle.headIndent = 20
        //paragraphStyle.tailIndent = 1
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacing = paragraphSpacing
        paragraphStyle.headIndent = indentation

        let bulletList = NSMutableAttributedString()
        for string in stringList {
            let formattedString = "\(bullet)\t\(string)\n"
            let attributedString = NSMutableAttributedString(string: formattedString)

            attributedString.addAttributes(
                [NSAttributedString.Key.paragraphStyle : paragraphStyle],
                range: NSMakeRange(0, attributedString.length))

            attributedString.addAttributes(
                textAttributes,
                range: NSMakeRange(0, attributedString.length))

            let string:NSString = NSString(string: formattedString)
            let rangeForBullet:NSRange = string.range(of: bullet)
            attributedString.addAttributes(bulletAttributes, range: rangeForBullet)
            bulletList.append(attributedString)
        }

        return bulletList
    }
}
