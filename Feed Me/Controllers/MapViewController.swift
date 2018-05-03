

import UIKit
import GoogleMaps

class MapViewController: UIViewController {
  
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet private weak var mapCenterPinImage: UIImageView!
  @IBOutlet private weak var pinImageVerticalConstraint: NSLayoutConstraint!

  
    private var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant", "food"]
  private let locationManager = CLLocationManager()
  private let dataProvider = GoogleDataProvider()
  private let searchRadius: Double = 1000
  
  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    mapView.delegate = self
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let navigationController = segue.destination as? UINavigationController,
      let controller = navigationController.topViewController as? TypesTableViewController else {
        return
    }
    controller.selectedTypes = searchedTypes
    controller.delegate = self
  }
  
  private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
    
    //create GMSGeocoder object to turn a latitude longitude coord to street address
    let geocoder = GMSGeocoder()
    
    // asks geocoder to reverse geocode the coordinate passed to the method. Then verifies theres an address in response of type GMSAddress. Which is model class for addresses returned by GMSGeocoder
    geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
      self.addressLabel.unlock()
      
      guard let address = response?.firstResult(), let lines = address.lines else {
        return
      }
      
      //Sets the test of the addressLabel to address returned by  Geocoder
      self.addressLabel.text = lines.joined(separator: "\n")
      
      //before animation add padding top and bottom of map. Top padding euquals top safe area inset. bot padding equals label height
      let labelHeight = self.addressLabel.intrinsicContentSize.height
      self.mapView.padding = UIEdgeInsets(top: self.view.safeAreaInsets.top, left: 0,
                                          bottom: labelHeight, right: 0)
      
      // Once address set, animate changes in the label
      UIView.animate(withDuration: 0.25) {
        
        //Updates the lcoation pin position to match the maps padding by adjusting its vertical layout constraint
        self.pinImageVerticalConstraint.constant = ((labelHeight - self.view.safeAreaInsets.top) * 0.5)
        self.view.layoutIfNeeded()
      }
    }
  }
  
  func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
    
    //clears map of all markers
    mapView.clear()
    
    //use dataProvider to search Google for nearby places within searchRadius, filtered by users selected type
    dataProvider.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
      places.forEach {
        
        //iterate through results returned in the completion closure and create a PlaceMarker for each result
        let marker = PlaceMarker(place: $0)
        
        //set the marker's map. This line tells map to render the marker.
        marker.map = self.mapView
      }
    }
  }
  
  func randomChoice(coordinate: CLLocationCoordinate2D) {
    mapView.clear()
    
    dataProvider.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
      places.forEach {
        let marker = PlaceMarker(place: $0)
        marker.map = self.mapView
        self.mapView.selectedMarker = marker
        
        // moves camera to randomly selected marker position
        self.mapView.animate(toLocation: marker.position)
      }
    }
  }
  
  @IBAction func randomizerButton(_ sender: Any) {
    mapCenterPinImage.fadeOut(0.25)
    randomChoice(coordinate: mapView.camera.target)
    //mapView.animate(toLocation: self.mapView.selectedMarker?.position)
     //mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 13, bearing: 0, viewingAngle: 0)
  }
  
  @IBAction func refreshPlaces(_ sender: Any) {
    fetchNearbyPlaces(coordinate: mapView.camera.target)
  }

}


// MARK: - TypesTableViewControllerDelegate
extension MapViewController: TypesTableViewControllerDelegate {
  func typesController(_ controller: TypesTableViewController, didSelectTypes types: [String]) {
    searchedTypes = controller.selectedTypes.sorted()
    dismiss(animated: true)
    fetchNearbyPlaces(coordinate: mapView.camera.target)
  }
}

// MARK: - CLLocationManagerDelegate

//creates MapViewController extesion that conforms to CLLocation manager Delegate
extension MapViewController: CLLocationManagerDelegate {
  
  //didChangeAuthorization: ) called when user grants or revokes location permissions.
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    
    //Verify the user has granted you permission while the app is in use
    guard status == .authorizedWhenInUse else {
      return
    }
    // now that permissions granted ask location manager for updates on users location
    locationManager.startUpdatingLocation()
    
    //GMSMapView user location features: myLocation Enabled draws dot at users location, myLocationButton makes the button in bottom left that when tapped centers map on users location
    mapView.isMyLocationEnabled = true
    mapView.settings.myLocationButton = true
  }
  //locationManager(.. didUdateLocations) executes when location Manager receeives newLocation Data
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else {
      return
    }
    //Updates the maps camera  to center around users current location. GMSCameraPosition Class does all camera position parameters and passes to map for display
    mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 13, bearing: 0, viewingAngle: 0)
    
    // Tell locationManager you don;t want more udates. initial location is enough to work with.
    locationManager.stopUpdatingLocation()
    fetchNearbyPlaces(coordinate: location.coordinate)
  }
}

// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
  func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
    reverseGeocodeCoordinate(position.target)
  }
  
  func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    addressLabel.lock()
    
    if (gesture) {
      mapCenterPinImage.fadeIn(0.25)
      mapView.selectedMarker = nil
    }
  }
  
  func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
    
    //cast tapped marker as PlaceMarker
    guard let placeMarker = marker as? PlaceMarker else {
      return nil
    }
    
    //you create a MarkerInfoView from its nib. remember MarkerInfoView is UIView subclass
    guard let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView else {
      return nil
    }
    
    // place name to the nameLabel
    infoView.nameLabel.text = placeMarker.place.name
    
    //check for photo. if there is add it to infoView, else add generic photo.
    if let photo = placeMarker.place.photo {
      infoView.placePhoto.image = photo
    } else {
      infoView.placePhoto.image = UIImage(named: "generic")
    }
    
    return infoView
  }
  
  func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
    mapCenterPinImage.fadeOut(0.25)
    return false
  }
  
  func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
    mapCenterPinImage.fadeIn(0.25)
    mapView.selectedMarker = nil
    return false
  }
}
