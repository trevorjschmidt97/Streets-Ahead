//
//  ViewController.swift
//  SchtreetSchmarts
//
//  Created by Trevor Schmidt on 4/30/21.
//

import UIKit
import MapKit
import Firebase
import FirebaseDatabase

class MapViewController: UIViewController {
    // Firebase
    var user: User? = nil
    let rootRef = Database.database().reference()
    
    var customers: [Customer] = []
    var usernames: [String:String] = [:]

    // Data
    var annotations = [MKPointAnnotation]()

    // Dumb stuff
    let locationManager = CLLocationManager()
    let dateFormatter: DateFormatter = {
        var dateFormmaterr = DateFormatter()
        dateFormmaterr.dateFormat = "YYYY-MM-dd, HH:mm:ss:SSSS"
        return dateFormmaterr
    }()
    
    let yearFormatter: DateFormatter = {
        var df = DateFormatter()
        df.dateFormat = "YYYY"
        return df
    }()
    
    let monthFormatter: DateFormatter = {
        var df = DateFormatter()
        df.dateFormat = "M"
        return df
    }()
    
    let weekFormatter: DateFormatter = {
        var df = DateFormatter()
        df.dateFormat = "w"
        return df
    }()
    
    let dayFormmatter: DateFormatter = {
        var df = DateFormatter()
        df.dateFormat = "dd"
        return df
    }()
    
    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var customersSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Firebase
        validateUser()
        
        // Map
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = .hybrid
        
        let maptype = Int(UserDefaults.standard.string(forKey: "maptype") ?? "2")
        
        if maptype == 0 {
            mapView.mapType = .standard
        } else if maptype == 1 {
            mapView.mapType = .satellite
        } else if maptype == 2 {
            mapView.mapType = .hybrid
        }
        
        segmentedControl.selectedSegmentIndex = maptype!
        
        // Location
        checkLocationServices()
        // Show user
        zoomToUser()
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
        // Add ability to drop pins
        let pressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gestureRecognizer:)))
        pressRecognizer.minimumPressDuration = 0.3
        mapView.addGestureRecognizer(pressRecognizer)
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateUser()
        reloadPins(self)
        checkLocationServices()
        zoomToUser()
        pullUsernames()
    }
    
    private func pullUsernames() {
        rootRef.child("usernames").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let strongSelf = self else { return }
            
            guard let users = snapshot.value as? [String:String] else { return }
            
            for user in users.keys {
                strongSelf.usernames[user] = users[user]
            }
        }
    }
    
    private func validateUser() {
        if Firebase.Auth.auth().currentUser == nil{
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
        user = Firebase.Auth.auth().currentUser
    }
    
    public func reloadPins(_ sender: Any) {
        mapView.removeAnnotations(mapView.annotations)
        annotations = [MKPointAnnotation]()
        pullAnnotationsFromDB()
    }
    
    @IBAction func segmentedControlChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        case 2:
            mapView.mapType = .hybrid
        default:
            break
        }
        
        UserDefaults.standard.setValue(segmentedControl.selectedSegmentIndex, forKey: "maptype")
    }
    @IBAction func pinSegmentedControlChanged(_ sender: Any) {
        switch customersSegmentedControl.selectedSegmentIndex {
        case 0:
            mapView.removeAnnotations(mapView.annotations)
            pullAnnotationsFromDB()
        case 1:
            mapView.removeAnnotations(mapView.annotations)
            pullCustomersFromDB()
        default:
            break
        }
    }
    private func pullAnnotationsFromDB() {
        pullPinsFromDB()
        pullCustomersFromDB()
    }
    
    private func pullCustomersFromDB() {
        rootRef.child("customers").observe(.value) { [weak self] snapshot in
            guard let strongSelf = self else { return }
            
            guard let users = snapshot.value as? [String:Any] else { return }
            
            for user in users.keys {
                
                if let dbAnnotations = users[user] as? [String: Any] {
                    
                    
                    for eachAnnotation in dbAnnotations.keys {
                        let dateTimeString = eachAnnotation
                        
                        let annotation = MKPointAnnotation()
                        
                        let userID = user
                        var latitude: Double = 0.0
                        var longitude: Double = 0.0
                        var status: String = ""
                        var name = ""
                        var curbNumber = ""
                        var phoneNumber = ""
                        var price = 0
                        var style = ""
                        var notes = ""
                        var lat = 0.0
                        var long = 0.0

                        if let annotationInfoDict = dbAnnotations[eachAnnotation] as? [String: Any] {
                            for annotationInfo in annotationInfoDict.keys {
                                if annotationInfo == "lat" {
                                    latitude = annotationInfoDict[annotationInfo] as! Double
                                } else if annotationInfo == "long" {
                                    longitude = annotationInfoDict[annotationInfo] as! Double
                                } else if annotationInfo == "status" {
                                    status = annotationInfoDict[annotationInfo] as! String
                                } else if annotationInfo == "name" {
                                    name = annotationInfoDict[annotationInfo] as! String
                                } else if annotationInfo == "curbNumber" {
                                    curbNumber = annotationInfoDict[annotationInfo] as! String
                                } else if annotationInfo == "phoneNumber" {
                                    phoneNumber = annotationInfoDict[annotationInfo] as! String
                                } else if annotationInfo == "price" {
                                    price = annotationInfoDict[annotationInfo] as! Int
                                } else if annotationInfo == "style" {
                                    style = annotationInfoDict[annotationInfo] as! String
                                } else if annotationInfo == "notes" {
                                    notes = annotationInfoDict[annotationInfo] as! String
                                } else if annotationInfo == "lat" {
                                    lat = annotationInfoDict[annotationInfo] as! Double
                                } else if annotationInfo == "long" {
                                    long = annotationInfoDict[annotationInfo] as! Double
                                }
                            }
                        }
                        
                        let customer = Customer(userID: userID, dateTime: dateTimeString, name: name, curbNumber: curbNumber, phoneNumber: phoneNumber, price: price, style: style, notes: notes, lat: lat, long: long)

                        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        annotation.title = status
                        annotation.subtitle = dateTimeString
                        
                        DispatchQueue.main.async {
                            strongSelf.customers.append(customer)
                            strongSelf.annotations.append(annotation)
                            strongSelf.mapView.addAnnotation(annotation)
                        }
                    }
                }
            }
        }
    }
    
    private func pullPinsFromDB() {
        rootRef.child("annotations").child(user!.uid).observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let strongSelf = self else { return }
            
            guard let dbAnnotations = snapshot.value as? [String:Any] else { return }
                    
            for eachAnnotation in dbAnnotations.keys {
                let dateTimeString = eachAnnotation
                
                let annotation = MKPointAnnotation()
                
                var latitude: Double = 0.0
                var longitude: Double = 0.0
                var status: String = ""

                if let annotationInfoDict = dbAnnotations[eachAnnotation] as? [String: Any] {
                    for annotationInfo in annotationInfoDict.keys {
                        if annotationInfo == "lat" {
                            latitude = annotationInfoDict[annotationInfo] as! Double
                        } else if annotationInfo == "long" {
                            longitude = annotationInfoDict[annotationInfo] as! Double
                        } else if annotationInfo == "status" {
                            status = annotationInfoDict[annotationInfo] as! String
                        }
                    }
                }
                
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                annotation.title = status
                annotation.subtitle = dateTimeString
                
                DispatchQueue.main.async {
                    strongSelf.annotations.append(annotation)
                    strongSelf.mapView.addAnnotation(annotation)
                }
            }
        }
    }


    // Add Annotation
    @objc private func addAnnotation(gestureRecognizer:UIGestureRecognizer) {
        if user == nil {
            user = Firebase.Auth.auth().currentUser
        }
        
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            
            let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            let currentDate = Date()
            let datestring = dateFormatter.string(from: currentDate)
            let year = yearFormatter.string(from: currentDate)
            let month = monthFormatter.string(from: currentDate)
            let week = weekFormatter.string(from: currentDate)
            let day = dayFormmatter.string(from: currentDate)
            
            // add to annotations
            rootRef.child("annotations").child(user!.uid).child(datestring).setValue([
                "lat" : coordinates.latitude,
                "long" : coordinates.longitude,
                "previousKnocks" : [
                    datestring: "Not Home"
                ],
                "status" : "Not Home",
                "notes" : ""
            ])
            
            // add to stats
            rootRef.child("stats").child("normal").child(year).child(month).child(day).child(user!.uid).child(datestring).setValue([
                "lat" : coordinates.latitude,
                "long" : coordinates.longitude,
                "previousKnocks" : [
                    datestring: "Not Home"
                ],
                "status" : "Not Home",
                "notes" : ""
            ])
            
            rootRef.child("stats").child("week").child(year).child(week).child(user!.uid).child(datestring).setValue([
                "lat" : coordinates.latitude,
                "long" : coordinates.longitude,
                "previousKnocks" : [
                    datestring: "Not Home"
                ],
                "status" : "Not Home",
                "notes" : ""
            ])
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = "Not Home"
            annotation.subtitle = datestring
            
            annotations.append(annotation)
            mapView.addAnnotation(annotation)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showKnock") {
            let kvc = segue.destination as! KnockViewController
            
            kvc.dateString = ((sender as! MKAnnotationView).annotation!.subtitle!!)
        } else if segue.identifier == "showSold" {
            let scvc = segue.destination as! SingleCustomerViewController
            
            let datetime = mapView.selectedAnnotations.first?.subtitle!!
            
            for customer in customers {
                if customer.dateTime == datetime {
                    scvc.customer = customer
                    break
                }
            }
        }
    }
    
    @IBAction func unwindToMap(_ sender: UIStoryboardSegue) {
        validateUser()
        reloadPins(self)
    }
    
}

// - Mark: Extensions
// Map View Delegate
extension MapViewController: MKMapViewDelegate {

    // View For Annotation, this is where we put the different colored pins
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView: MKAnnotationView?
        
        annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
        
        if annotationView == nil {
            // create the view
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
            annotationView?.canShowCallout = false
        } else {
            annotationView?.annotation = annotation
        }
        
        
        if annotation.title == "Not Home" {
            annotationView?.image = UIImage(named: "bluePin")
        } else if annotation.title == "Come Back Later" {
            annotationView?.image = UIImage(named: "greenPin")
        } else if annotation.title == "Sold" {
            annotationView?.image = UIImage(named: "greenFlag")
        } else {
            annotationView?.image = UIImage(named: "pinkPin")
        }
        
        return annotationView
    }
    
    // Did select map annotation, show knock stuff
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard !(view.annotation is MKUserLocation) else { return }
        
        if view.annotation?.title == "Sold" {
            for customer in customers {
                if customer.dateTime == view.annotation?.subtitle {
//                    if customer.userID == user?.uid {
//                        performSegue(withIdentifier: "showSold", sender: view)
//                    } else {
                        // show that customer is not the user's
                    let alert = UIAlertController(title: customer.name, message: "Sold by " + usernames[customer.userID]!, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                        present(alert, animated: true)
//                    }
                }
            }
        } else {
            performSegue(withIdentifier: "showKnock", sender: view)
        }
    }
}
// All Location Stuff
extension MapViewController: CLLocationManagerDelegate {
    private func checkLocationServices() {
        // If location services are enables device wide...
        if CLLocationManager.locationServicesEnabled() {
            // Set up location stuff
            setUpLocationManager()
            
            // Proceed the program to this function
            checkLocationAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        } else { // This happens when the user turns off location device wide in the settings
            // TODO: Show alert to user to turn on location
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
        zoomToUser()
    }
    private func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // Checks to ensure we have the correct location authorization
    private func checkLocationAuthorization() {
        if user != nil {
        
            switch  CLLocationManager.authorizationStatus(){
                case .authorizedWhenInUse:
                    // This is what we want
                    // Proceed the program
                    zoomToUser()
                    break
                case .authorizedAlways:
                    // Don't really care for this
                    // We will never ask for it, so there's no way the user can have this option
                    // I just put this case in here so I can use this funct in other apps
                    break
                case .notDetermined:
                    // They have not authorized location, therefore we request
                    locationManager.requestWhenInUseAuthorization()
                    break
                case .denied:
                    // Happens when the user has said that they do not want to share location with the app
                    locationManager.requestWhenInUseAuthorization()
                    break
                case .restricted:
                    let alert = UIAlertController(title: "Location Services disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)

                    present(alert, animated: true, completion: nil)
                    return
                    // Happens when there are content restrictions on the phone, Such as parent restrictions or something, May not be able to change it
                default:
    //                print("Default in check location services")
                    break
            }
        }
    }
    
    public func zoomToUser() {
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 300, longitudinalMeters: 300)
            mapView.setRegion(viewRegion, animated: true)
        }
    }
}
extension Date {
    var dayOfYear: Int {
        return Calendar.current.ordinality(of: .day, in: .year, for: self)!
    }
}
