import UIKit
import PlaygroundSupport

/*
 1. 多個 NSAttributedString 串接
 2. 客製點擊反應 ex:  Hi I am [@Clyde], nice to meet you. 點擊 @Clyde 會有其他action
    2a. 新增 NSAttributedString.Key
    2b. location 轉換
        gesture tap location 轉換成 (NSTextContainer, NSTextStorage, NSLayoutManager) location,
    2c. fetch custom attribute value by location if exist
 3. 注意實際的Rect 與 Container Rect 不同, 字不一定從左上開始, 可能中間靠右, 需要做計算！才能獲得正確location
 */


@resultBuilder
struct AttributedStringBuilder {
    /*
     allow to
     let attrs = NSAttributedString {
        attr1
        attr2
        attr3
     }
     */
    static func buildBlock(_ strings: NSAttributedString...) -> NSAttributedString {
        strings.reduce(into: NSMutableAttributedString()) { $0.append($1) }
    }
}

extension NSAttributedString {
    convenience init(@AttributedStringBuilder _ build: () -> NSAttributedString) {
        self.init(attributedString: build())
    }
}

// Custom a NSAttributedString key and value
typealias LabelLink = (text: String, handler: (() -> ()))
extension NSAttributedString.Key {
    static let custom = NSAttributedString.Key("CustomAttribute")
}

extension UITapGestureRecognizer {
    func didTapCustomAttributeWord() -> LabelLink? {
        
        guard let label = self.view as? UILabel, let attributedText = label.attributedText else {
            return nil
        }
        
        // Configure NSTextContainer
        let textContainer = NSTextContainer(size: label.bounds.size)
        textContainer.lineFragmentPadding = 0.0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode
        
        // Configure NSLayoutManager and add the text container
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        
        // Configure NSTextStorage and apply the layout manager
        let storage = NSTextStorage(attributedString: attributedText)
        storage.addLayoutManager(layoutManager)
        
        // get the tapped character location
        let locationOfTouchInLabel = self.location(in: self.view)
        
        // account for text alignment and insets
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        var alignmentOffset: CGFloat!
        switch label.textAlignment {
        case .left, .natural, .justified:
            alignmentOffset = 0.0
        case .center:
            alignmentOffset = 0.5
        case .right:
            alignmentOffset = 1.0
        }
        let xOffset = ((label.bounds.size.width - textBoundingBox.size.width) * alignmentOffset) - textBoundingBox.origin.x
        let yOffset = ((label.bounds.size.height - textBoundingBox.size.height) / 2) - textBoundingBox.origin.y
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - xOffset, y: locationOfTouchInLabel.y - yOffset)
        
        // figure out which character was tapped
        let characterIndex = layoutManager.characterIndex(for: locationOfTouchInTextContainer,
                                                              in: textContainer,
                                                             fractionOfDistanceBetweenInsertionPoints: nil)
        if characterIndex < storage.length {
            if let link = attributedText.attribute(.custom,
                                                   at: characterIndex,
                                                   effectiveRange: nil) as? LabelLink {
                return link
            }
        }
        
        return nil
    }
}

class ContainerView: UIView {
    let lable = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLabel() {
        self.backgroundColor = .red
        addSubview(lable)
        
        lable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lable.topAnchor.constraint(equalTo: self.topAnchor),
            lable.leftAnchor.constraint(equalTo: self.leftAnchor),
            lable.rightAnchor.constraint(lessThanOrEqualTo: self.rightAnchor),
            lable.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        lable.backgroundColor = .yellow
        
        let prefix = NSAttributedString(string: "Hi this is ",
                                      attributes: [.font: UIFont.systemFont(ofSize: 10, weight: .regular),
                                                   .foregroundColor: UIColor.black])
        
        
        let link: LabelLink = ("@Clyde", {
            debugPrint("link handler trigger")
        })
        let name = NSAttributedString(string: "@Clyde",
                                      attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .regular),
                                                   .foregroundColor: UIColor.blue,
                                                   .custom: link])
        
        let suffix = NSAttributedString(string: " show time",
                                      attributes: [.font: UIFont.systemFont(ofSize: 10, weight: .regular),
                                                   .foregroundColor: UIColor.black])
        
       
        let attString = NSAttributedString {
            prefix
            name
            suffix
        }
        
        lable.attributedText = attString
        lable.numberOfLines = 0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        lable.addGestureRecognizer(tap)
        lable.isUserInteractionEnabled = true
        
    }
    
    @objc
    private func tapped(_ tap: UITapGestureRecognizer) {
        guard tap.state == .ended else { return }
        
        if let link = tap.didTapCustomAttributeWord() {
            debugPrint("did tap \(link.text)")
            link.handler()
            return
        }
    }
    
}

let v = ContainerView.init(frame: .init(x: 0, y: 0, width: 100, height: 100))

PlaygroundPage.current.liveView = v


