//
//  StatsViewController.swift
//  SchtreetSchmarts
//
//  Created by Trevor Schmidt on 4/30/21.
//

import UIKit
import Firebase
import FirebaseDatabase
import CoreLocation

class CustomersViewController: UIViewController {
    
    let rootRef = Database.database().reference()
    var user: User?
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var SchtreetSchmarts: UILabel!
    @IBOutlet weak var StatsLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var loading: Bool = true
    
    var customers: [Customer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard Firebase.Auth.auth().currentUser != nil else { return }
        user = Firebase.Auth.auth().currentUser
        
        tableView.delegate = self
        tableView.dataSource = self
        
        pullInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard Firebase.Auth.auth().currentUser != nil else { return }
        user = Firebase.Auth.auth().currentUser
        pullInfo()
    }
    
    private func pullInfo() {

        rootRef.child("customers").child(user!.uid).observe(.value) { [weak self] (snapshot) in
            guard let strongSelf = self else { return }
            
            guard let customersDict = snapshot.value as? [String: Any] else { return }
            
            strongSelf.customers = []
            
            for customerKey in customersDict.keys {
//                print(customerKey)
                let dateTime = customerKey
                var name = ""
                var curbNumber = ""
                var phoneNumber = ""
                var price = 0
                var style = ""
                var notes = ""
                var lat = 0.0
                var long = 0.0
                
                
                guard let infoDict = customersDict[customerKey] as? [String: Any] else { return }
                for infoKey in infoDict.keys {
                    
                    if infoKey == "name" {
                        name = infoDict[infoKey] as! String
                    } else if infoKey == "curbNumber" {
                        curbNumber = infoDict[infoKey] as! String
                    } else if infoKey == "phoneNumber" {
                        phoneNumber = infoDict[infoKey] as! String
                    } else if infoKey == "price" {
                        price = infoDict[infoKey] as! Int
                    } else if infoKey == "style" {
                        style = infoDict[infoKey] as! String
                    } else if infoKey == "notes" {
                        notes = infoDict[infoKey] as! String
                    } else if infoKey == "lat" {
                        lat = infoDict[infoKey] as! Double
                    } else if infoKey == "long" {
                        long = infoDict[infoKey] as! Double
                    }
                    
                }
                
                
                let customer = Customer(userID: strongSelf.user!.uid, dateTime: dateTime, name: name, curbNumber: curbNumber, phoneNumber: phoneNumber, price: price, style: style, notes: notes, lat: lat, long: long)
                strongSelf.customers.append(customer)
            }
            
            // order by date
            strongSelf.customers = strongSelf.customers.sorted(by: { $0.dateTime > $1.dateTime  } )
            
            strongSelf.loading = false
            strongSelf.tableView.reloadData()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        // Get info ready for reviewViewController
        case "showCustomer":
            let vc = segue.destination as! SingleCustomerViewController
            vc.customer = customers[tableView.indexPathForSelectedRow!.row]
        default:
            preconditionFailure("Unexpected segue identifier in bathroomViewController.")
        }
    }

}
extension CustomersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loading {
            return 0
        }
        return customers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomerCell
        
        if loading {
            return cell
        }
        
        let customer = self.customers[indexPath.row]
        
        cell.nameLabel.text = customer.name //"Trevor Schmidt"

        let distance = (locationManager.location?.distance(from: CLLocation(latitude: customer.lat, longitude: customer.long)))! / 1609.344
        
        cell.addressLabel.text = String(format: "%.2f miles away", distance)
        cell.styleLabel.text = "Style: " + customer.style //"Style: Original"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd, HH:mm:ss:SSSS"
        
        let date = dateFormatter.date(from: customer.dateTime)
        
        let secondDateFormatter = DateFormatter()
        secondDateFormatter.dateFormat = "MM/dd hh:mma"
        secondDateFormatter.amSymbol = "am"
        secondDateFormatter.pmSymbol = "pm"
        
        cell.dateTimeLabel.text = "Sold On: " + secondDateFormatter.string(from: date!) //05/05 12:33am"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
}
extension CustomersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
// All Location Stuff
extension CustomersViewController: CLLocationManagerDelegate {
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
}
