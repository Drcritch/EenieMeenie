
import UIKit

class popView: UIViewController {
  
  @IBOutlet var roundedView: UIView!
  
  
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.roundedView.layer.cornerRadius = 5
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  


}
