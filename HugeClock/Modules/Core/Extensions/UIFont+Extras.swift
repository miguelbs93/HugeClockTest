import UIKit

extension UIFont {
    
    struct CustomFont {
        let fontFamily: String!
        
        private static let defaultFontSize: CGFloat = 12
        
        func normal(withSize size: CGFloat = CustomFont.defaultFontSize) -> UIFont? {
            return UIFont(name: "\(fontFamily!)-Normal", size: size)
        }
        
        func bold(withSize size: CGFloat = CustomFont.defaultFontSize) -> UIFont? {
            return UIFont(name: "\(fontFamily!)-Bold", size: size)
        }
    }
    
    class var appFont: CustomFont {
        CustomFont(fontFamily: "Helvetica")
    }
    
}
