import UIKit

extension UIColor {
	//    use this syntax to add more custom color's names into UIColor, likes UIColor.ypBlack
  static var ypBackground: UIColor { UIColor(named: "YP Background") ?? UIColor.darkGray }
	static var ypBlack: UIColor { UIColor(named: "YP Black") ?? UIColor.black }
  static var ypBlue: UIColor { UIColor(named: "YP Blue") ?? UIColor.blue }
	static var ypGray: UIColor { UIColor(named: "YP Gray") ?? UIColor.gray }
	static var ypWhite50: UIColor { UIColor(named: "YP White (Alpha 50)") ?? UIColor.lightGray }
	static var ypWhite: UIColor { UIColor(named: "YP White") ?? UIColor.white }
}
