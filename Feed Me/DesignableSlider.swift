
import UIKit

@IBDesignable
class DesignableSlider: UISlider {

  @IBInspectable var thumbImage: UIImage? {
    didSet {
      setThumbImage(thumbImage, for: .normal)
    }
  }

}
