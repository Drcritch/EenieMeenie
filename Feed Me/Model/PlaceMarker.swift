
import UIKit
import GooglePlaces
import GoogleMaps

class PlaceMarker: GMSMarker {
  
  //just adding property of type GooglePlace
  let place: GooglePlace
  
  //Create new designated initializer  that accepts a GogglePlace as only parameter and fully inits PlaceMarker with  position, image (iff available), and anchor for the markers position and an appearance animation. 
  init(place: GooglePlace) {
    self.place = place
    super.init()
    
    position = place.coordinate
    icon = UIImage(named: place.placeType+"_pin")
    groundAnchor = CGPoint(x: 0.5, y: 1)
    appearAnimation = .pop
  }
}
