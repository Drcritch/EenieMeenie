
import UIKit

@IBDesignable
class DesignableView: UIView {

  @IBInspectable var cornerRadius: CGFloat = 15{
    didSet {
      self.layer.cornerRadius = cornerRadius
    }
    
  }
  @IBInspectable var borderWidth: CGFloat = 2{
    didSet {
      self.layer.borderWidth = borderWidth
    }
    
  }
  @IBInspectable var borderColor: UIColor = UIColor.orange{
    didSet {
      self.layer.borderColor = UIColor.orange
      
    }
    
  }

}/Users/critch/Desktop/Feed_Me_Completed copy/Feed Me/DesignableView.swift
