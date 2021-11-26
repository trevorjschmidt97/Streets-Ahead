//
//  SignUpViewController.swift
//  SchtreetSchmarts
//
//  Created by Trevor Schmidt on 4/30/21.
//

import UIKit
import Firebase
import FirebaseDatabase
import CoreLocation
import MapKit

class SignUpViewController: UIViewController {
    // firebase
    var user: User?
    let rootRef = Database.database().reference()
    
    // Text Fields
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var curbNumberTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var styleTF: UITextField!
    @IBOutlet weak var notesTF: UITextField!
    
    // Map View
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    // Buttons
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    var currentPrice = 20
    
    //dumb
    let dateFormatter = DateFormatter()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = FirebaseAuth.Auth.auth().currentUser
        
        nameTF.delegate = self
        curbNumberTF.delegate = self
        phoneTF.delegate = self
        styleTF.delegate = self
        notesTF.delegate = self
    
        styleTF.text = "Original"
        
        dateFormatter.dateFormat = "YYYY-MM-dd, HH:mm:ss:SSSS"
        
        // Map stuff
        
        mapView.showsUserLocation = true
        let maptype = Int(UserDefaults.standard.string(forKey: "maptype") ?? "2")
        
        if maptype == 0 {
            mapView.mapType = .standard
        } else if maptype == 1 {
            mapView.mapType = .satellite
        } else if maptype == 2 {
            mapView.mapType = .hybrid
        }
        // Location
        checkLocationServices()
        // Show user
        zoomToUser()
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        costLabel.isUserInteractionEnabled = true
        costLabel.addGestureRecognizer(doubleTapGesture)
        
        let tripleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTripleTap(_:)))
        tripleTapGesture.numberOfTapsRequired = 3
        costLabel.isUserInteractionEnabled = true
        costLabel.addGestureRecognizer(tripleTapGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func dismissKeyboard (_ sender: Any) {
        nameTF.resignFirstResponder()
        curbNumberTF.resignFirstResponder()
        phoneTF.resignFirstResponder()
        styleTF.resignFirstResponder()
        notesTF.resignFirstResponder()
    }
    @objc func didDoubleTap(_ gesture: UITapGestureRecognizer) -> Void {
        costLabel.text = "$20.00"
        currentPrice = 20
    }
    @objc func didTripleTap(_ gesture: UITapGestureRecognizer) -> Void {
        costLabel.text = "$30.00"
        currentPrice = 30
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        // Ensure all data is filled in
        guard !nameTF.text!.isEmpty,
              !curbNumberTF.text!.isEmpty,
              !styleTF.text!.isEmpty else {
            
            alertError()
            return
        }
        
        // Get info
        let currentDate = Date()
        let timestamp = dateFormatter.string(from: currentDate)
        let year = yearFormatter.string(from: currentDate)
        let month = monthFormatter.string(from: currentDate)
        let week = weekFormatter.string(from: currentDate)
        let day = dayFormmatter.string(from: currentDate)
        let lat = mapView.region.center.latitude
        let long = mapView.region.center.longitude
        

        // customers
        self.rootRef.child("customers").child((self.user!.uid)).child(timestamp).setValue([
            "name": self.nameTF.text! as Any,
            "curbNumber": self.curbNumberTF.text! as Any,
            "phoneNumber": self.phoneTF.text! as Any,
            "price": self.currentPrice as Int,
            "style": self.styleTF.text! as Any,
            "notes": self.notesTF.text! as Any,
            "hasPic": false,
            "status": "Sold",
            "lat" : lat as Any,
            "long" : long as Any
        ])
        
        // annotations
        self.rootRef.child("annotations").child((self.user!.uid)).child(timestamp).setValue([
            "name": self.nameTF.text! as Any,
            "curbNumber": self.curbNumberTF.text! as Any,
            "phoneNumber": self.phoneTF.text! as Any,
            "price": self.currentPrice as Int,
            "style": self.styleTF.text! as Any,
            "notes": self.notesTF.text! as Any,
            "hasPic": false,
            "status": "Sold",
            "lat" : lat as Any,
            "long" : long as Any
        ])
        
        // stats
            // normal
        self.rootRef.child("stats").child("normal").child(year).child(month).child(day).child((self.user!.uid)).child(timestamp).setValue([
            "name": self.nameTF.text! as Any,
            "curbNumber": self.curbNumberTF.text! as Any,
            "phoneNumber": self.phoneTF.text! as Any,
            "price": self.currentPrice as Int,
            "style": self.styleTF.text! as Any,
            "notes": self.notesTF.text! as Any,
            "hasPic": false,
            "status": "Sold",
            "lat" : lat as Any,
            "long" : long as Any
        ])
            // week
        self.rootRef.child("stats").child("week").child(year).child(week).child((self.user!.uid)).child(timestamp).setValue([
            "name": self.nameTF.text! as Any,
            "curbNumber": self.curbNumberTF.text! as Any,
            "phoneNumber": self.phoneTF.text! as Any,
            "price": self.currentPrice as Int,
            "style": self.styleTF.text! as Any,
            "notes": self.notesTF.text! as Any,
            "hasPic": false,
            "status": "Sold",
            "lat" : lat as Any,
            "long" : long as Any
            ])
  
        alertSuccess()
    }
    
    func alertError() {
        let alert = UIAlertController(title: "Whoops", message: "Name, Curb Number, and Style are required before submitting", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    func alertSuccess() {
        let alert = UIAlertController(title: "Congrats", message: "Customer successfully added", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel,handler: { [weak self] (_) in
            guard let strongSelf = self else { return }
            
            strongSelf.clearButtonPressed(strongSelf)
        }))
        present(alert, animated: true)
    }
    
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        nameTF.text = ""
        curbNumberTF.text = ""
        phoneTF.text = ""
        costLabel.text = "$20.00"
        styleTF.text = "Original"
        currentPrice = 20
        notesTF.text = ""
        
        dismissKeyboard(self)
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if textField == nameTF {
            curbNumberTF.becomeFirstResponder()
        } else if textField == curbNumberTF {
            phoneTF.becomeFirstResponder()
        } else if textField == phoneTF {
            styleTF.becomeFirstResponder()
        } else if textField == styleTF {
            notesTF.becomeFirstResponder()
        }
        
        return true
    }
}

extension SignUpViewController: CLLocationManagerDelegate {
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
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(viewRegion, animated: true)
        }
    }
}
