import UIKit

extension UIColor {
    func toHexString(includeAlpha: Bool = false) -> String {
        guard let components = cgColor.components else { return "#000000" }
        let r = Int(components[0] * 255)
        let g = Int(components.count > 1 ? components[1] * 255 : 0)
        let b = Int(components.count > 2 ? components[2] * 255 : 0)
        let a = Int((components.count > 3 ? components[3] : 1) * 255)
        return includeAlpha ? String(format: "#%02X%02X%02X%02X", r, g, b, a) :
                              String(format: "#%02X%02X%02X", r, g, b)
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")

        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)

        let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgbValue & 0x0000FF) / 255

        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
