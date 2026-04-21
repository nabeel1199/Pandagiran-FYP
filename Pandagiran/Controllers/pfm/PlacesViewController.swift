

import UIKit
import GooglePlaces
import GoogleMaps


protocol PlaceSelectionListener {
    func onPlaceSelected (placeName: String, placeType: String)
}


class PlacesViewController: BaseViewController {

    @IBOutlet weak var search_bar: UISearchBar!
    @IBOutlet weak var view_nearby_places: UIView!
    @IBOutlet weak var view_suggested_places: UIView!
    @IBOutlet weak var table_view_nearby_height: NSLayoutConstraint!
    @IBOutlet weak var table_view_suggested_height: NSLayoutConstraint!
    @IBOutlet weak var table_view_suggested: UITableView!
    @IBOutlet weak var table_view_nearby: UITableView!
    
    private let nibPlacesName = "NavigationViewCell"
    private var nearbyPlaceArray : Array<GMSPlace> = []
    private var suggestPlaceArray : Array<(place: String, type: String)> = []
    private var placesClient: GMSPlacesClient!
    private var locationManager : CLLocationManager!
    private var latitude : Double = 0
    private var longitude : Double = 0
    private let loadingView = UIView()
    private let spinner = UIActivityIndicatorView()
    private let loadingLabel = UILabel()
    
    public var delegate : PlaceSelectionListener?

    
    override func viewDidLoad() {
        super.viewDidLoad()


        initVariables()
        initUI()
        fetchSuggestedPlaces()
        fetchNearbyPlaces()

    }
    
    private func initVariables () {
        let nibPlace = UINib(nibName: nibPlacesName, bundle: nil)
        table_view_nearby.register(nibPlace, forCellReuseIdentifier: nibPlacesName)
        table_view_suggested.register(nibPlace, forCellReuseIdentifier: nibPlacesName)
        
        table_view_suggested.delegate = self
        table_view_suggested.dataSource = self
        
        table_view_nearby.delegate = self
        table_view_nearby.dataSource = self
        
        placesClient = GMSPlacesClient.shared()
        
        search_bar.delegate = self
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    private func initUI () {
        search_bar.backgroundImage = UIImage()
        search_bar.isTranslucent = false
        search_bar.barTintColor = UIColor().hexCode(hex: Style.color.SECONDARY_COLOR)
        

    }
    
    private func fetchSuggestedPlaces () {
        suggestPlaceArray = ActivitiesDbUtils.fetchPlaces()
        
        if suggestPlaceArray.count == 0 {
            view_suggested_places.isHidden = true
        }
    }
    
    private func fetchNearbyPlaces () {
        table_view_nearby.separatorStyle = .none
        self.setLoadingScreen()
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            
            if let error = error {
                self.removeLoadingScreen()
                self.view_nearby_places.isHidden = true
                print("Current Place error: \(error.localizedDescription)")
                return
            }

            
            if let placesLikelihoodList = placeLikelihoodList {
                for likelihood in placesLikelihoodList.likelihoods {
                    self.nearbyPlaceArray.append(likelihood.place)
                }
            }
            
            self.table_view_nearby.separatorStyle = .singleLine
            self.removeLoadingScreen()
            self.table_view_nearby.reloadData()
            
            if self.nearbyPlaceArray.count == 0 {
                self.view_nearby_places.isHidden = true
            } else {
                self.view_nearby_places.isHidden = false
            }
        })
    }
    
    private func setLoadingScreen() {
        
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (table_view_nearby.frame.width / 2) - (width / 2)
        let y = (table_view_nearby.frame.height / 2) - (height / 2) - (navigationController?.navigationBar.frame.height)!
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        loadingLabel.textColor = .gray
        loadingLabel.textAlignment = .center
        loadingLabel.text = "Loading nearby places..."
        loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
        
        spinner.style = .gray
        spinner.frame = CGRect(x: -30, y: 0, width: 30, height: 30)
        spinner.startAnimating()
        
        loadingView.addSubview(spinner)
        loadingView.addSubview(loadingLabel)
        
        table_view_nearby.addSubview(loadingView)
        
    }
    
    // Remove the activity indicator from the main view
    private func removeLoadingScreen() {
        
        // Hides and stops the text and the spinner
        spinner.stopAnimating()
        spinner.isHidden = true
        loadingLabel.isHidden = true
        
    }


}

extension PlacesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == table_view_suggested
        {
            return suggestPlaceArray.count
        }
        else
        {
            return nearbyPlaceArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: nibPlacesName, for: indexPath) as! NavigationViewCell
        
        cell.imageView?.image = UIImage(named: "ic_marker_pickup")
        
        if tableView == table_view_suggested
        {
            let placeTuple = suggestPlaceArray[indexPath.row]
            cell.label_sub_text.isHidden = true
            cell.label_nav_text.text = placeTuple.place
        }
        else
        {
            let place = nearbyPlaceArray[indexPath.row]
            cell.label_sub_text.isHidden = false
            cell.label_nav_text.text = place.name!
            cell.label_sub_text.text = place.formattedAddress!
            cell.label_sub_text.numberOfLines = 2
        }
        
        
        cell.selectionStyle = .none
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == table_view_suggested
        {
            let placeTuple = suggestPlaceArray[indexPath.row]
            delegate?.onPlaceSelected(placeName: placeTuple.place, placeType: placeTuple.type)
        }
        else
        {
            let place = nearbyPlaceArray[indexPath.row]
            let placeType = place.types!.joined(separator: ",")
            delegate?.onPlaceSelected(placeName: place.name!, placeType: placeType)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == table_view_suggested
        {
            table_view_suggested_height.constant = table_view_suggested.contentSize.height
        }
        else
        {
            table_view_nearby_height.constant = table_view_nearby.contentSize.height
        }
    }
}

extension PlacesViewController : UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.view.endEditing(true)
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
//        autocompleteController.colo
        
//        autocompleteController.autocompleteBoundsMode = GMSAutocompleteBoundsMode.bias
        
        let locationCordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let bounds = GMSCoordinateBounds(coordinate: locationCordinates, coordinate: locationCordinates)
        
    
        autocompleteController.autocompleteBounds = bounds
        
        present(autocompleteController, animated: true, completion: nil)
        
        return false
    }
}

extension PlacesViewController : GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        var placeName = ""
        var placeType = ""
        
        if let place = place.name {
            placeName = place
        }
        
        if let type = place.types {
            placeType = type.joined(separator: ",")
        }
        
        delegate?.onPlaceSelected(placeName: placeName, placeType: placeType)
        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

extension PlacesViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        latitude = (location?.coordinate.latitude)!
        longitude = (location?.coordinate.longitude)!
    }
}

