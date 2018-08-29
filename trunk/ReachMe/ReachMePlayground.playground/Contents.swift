
import UIKit
import PlaygroundSupport

extension UILabel {
    
    func addImageWith(name: String, behindText: Bool) {
        let path = Bundle.main.path(forResource: "ok", ofType: "png")

        let attachment = NSTextAttachment()
        attachment.image = UIImage.init(named: path!)
        let attachmentString = NSAttributedString(attachment: attachment)
        attachment.bounds = CGRect(x: 0, y: -3, width: 15, height: 15)

        guard let txt = self.text else {
            return
        }
        
        if behindText {
            let strLabelText = NSMutableAttributedString(string: txt)
            strLabelText.append(NSAttributedString(string: "  "))
            strLabelText.append(attachmentString)
            self.attributedText = strLabelText
        } else {
            let strLabelText = NSAttributedString(string: txt)
            let mutableAttachmentString = NSMutableAttributedString(attributedString: attachmentString)
            mutableAttachmentString.append(NSAttributedString(string: "  "))
            mutableAttachmentString.append(strLabelText)
            self.attributedText = mutableAttachmentString
        }
    }
    
    func removeImage() {
        let text = self.text
        self.attributedText = nil
        self.text = text
    }
}

class Poster: UIView {
    
    var text: String? {
        didSet {
            textLabel?.text = text
            textLabel?.addImageWith(name: "Charge_OK", behindText: false)
        }
    }
    
    private var textLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        didLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        didLoad()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    func didLoad() {
        textLabel = UILabel()
        textLabel?.textColor = .red
        textLabel?.textAlignment = .left
        textLabel?.font = UIFont.boldSystemFont(ofSize: 12.0)
        textLabel?.frame = frame
        addSubview(textLabel!)
        
    //    layer.cornerRadius = frame.height / 2
      //  backgroundColor = .blue
    }
}

class Hero {
    var name: String
    var mainSuperPower: String
    var superPowers: [String]
    
    init(name: String, mainPower: String) {
        self.name = name
        self.mainSuperPower = mainPower
        
        superPowers = [String]()
        superPowers.append(mainPower)
    }
}

extension Hero: CustomPlaygroundDisplayConvertible {
    var playgroundDescription: Any {
        let poster = Poster(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 34)))
        poster.text = name
        return poster
    }
}

let thor = Hero(name: "Sachin", mainPower: "Thunder")
let ironMan = Hero(name: "Bapi", mainPower: "Brain")

