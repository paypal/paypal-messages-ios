import UIKit

extension UIColor {

    static let colorBlue600 = UIColor(red: 0.00, green: 0.44, blue: 0.73, alpha: 1)
    static let colorGrey700 = UIColor(red: 0.17, green: 0.18, blue: 0.18, alpha: 1)

    convenience init(hexString: String) {
        let hexString: String = (hexString as NSString).trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString as String)

        if hexString.hasPrefix("#") {
            scanner.currentIndex = scanner.string.index(after: scanner.currentIndex)
        }
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)

        let mask = 0x000000FF
        let redValue = Int(color >> 16) & mask
        let greenValue = Int(color >> 8) & mask
        let blueValue = Int(color) & mask

        let red = CGFloat(redValue) / 255.0
        let green = CGFloat(greenValue) / 255.0
        let blue = CGFloat(blueValue) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
