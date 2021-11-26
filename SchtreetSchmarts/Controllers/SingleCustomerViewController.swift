//
//  SingleCustomerViewController.swift
//  SchtreetSchmarts
//
//  Created by Trevor Schmidt on 5/5/21.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import MessageUI
import CoreLocation
import MapKit

class SingleCustomerViewController: UIViewController {
    
    let rootRef = Database.database().reference()
    var user: User?
    
    var customer: Customer!
    
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var curbNumberTF: UITextField!
    @IBOutlet weak var styleTF: UITextField!
    @IBOutlet weak var costTF: UITextField!
    @IBOutlet weak var notesTF: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    
    let dateFormatter: DateFormatter = {
        var df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd, HH:mm:ss:SSSS"
        return df
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard Firebase.Auth.auth().currentUser != nil else { return }
        user = Firebase.Auth.auth().currentUser
        
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        setup()
    }
    
    private func setup() {
        nameTF.delegate = self
        phoneTF.delegate = self
        curbNumberTF.delegate = self
        styleTF.delegate = self
        costTF.delegate = self
        notesTF.delegate = self
        
        // Date time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd, HH:mm:ss:SSSS"

        let date = dateFormatter.date(from: customer.dateTime)

        let secondDateFormatter = DateFormatter()
        secondDateFormatter.dateFormat = "MM/dd/YY hh:mma"
        secondDateFormatter.amSymbol = "am"
        secondDateFormatter.pmSymbol = "pm"

        dateTimeLabel.text = "Sold on: " + secondDateFormatter.string(from: date!)
        
        nameTF.text = customer.name
        phoneTF.text = customer.phoneNumber
        curbNumberTF.text = customer.curbNumber
        styleTF.text = customer.style
        costTF.text = String(customer.price)
        notesTF.text = customer.notes
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: customer.lat, longitude: customer.long)
        annotation.title = customer.name
        annotation.subtitle = secondDateFormatter.string(from: date!)
        
        mapView.addAnnotation(annotation)
        mapView.showsUserLocation = true
        
        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: customer.lat, longitude: customer.long), span: MKCoordinateSpan(latitudeDelta: 0.0015, longitudeDelta: 0.0015)), animated: true)
    }
    
//    private func downloadImage() {
//        let imageRef = Storage.storage().reference().child(Firebase.Auth.auth().currentUser?.uid ?? "").child(customer.dateTime + ".png")
//
//        imageRef.downloadURL { url, error in
//            guard url == url, error == nil else {
//                return
//            }
//
//            URLSession.shared.dataTask(with: url!) { data, _, error in
//                guard data == data, error == nil else { return }
//
//                let image = UIImage(data: data!)
//
//                DispatchQueue.main.async {
//                    self.imageView.image = image
//                }
//            }.resume()
//        }
//    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        nameTF.resignFirstResponder()
        phoneTF.resignFirstResponder()
        curbNumberTF.resignFirstResponder()
        styleTF.resignFirstResponder()
        costTF.resignFirstResponder()
        notesTF.resignFirstResponder()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updatePressed(_ sender: Any) {
        // Ensure everything is filled in
        guard !nameTF.text!.isEmpty,
              !curbNumberTF.text!.isEmpty,
              !styleTF.text!.isEmpty,
              !costTF.text!.isEmpty else {
            
            return
        }
        let dateString = customer.dateTime
        let date = dateFormatter.date(from: dateString)
        let year = yearFormatter.string(from: date!)
        let month = monthFormatter.string(from: date!)
        let week = weekFormatter.string(from: date!)
        let day = dayFormmatter.string(from: date!)
        let lat = mapView.region.center.latitude
        let long = mapView.region.center.longitude
        
        //customers
        self.rootRef.child("customers").child((self.user!.uid)).child((self.customer.dateTime)).setValue([
            "name": self.nameTF.text! as Any,
            "curbNumber": self.curbNumberTF.text! as Any,
            "phoneNumber": self.phoneTF.text! as Any,
            "price": Int(self.costTF.text!)! as Int,
            "style": self.styleTF.text! as Any,
            "notes": self.notesTF.text! as Any,
            "status": "Sold",
            "lat" : lat as Any,
            "long" : long as Any
        ])

        // annotations
        self.rootRef.child("annotations").child((self.user!.uid)).child((self.customer.dateTime)).setValue([
            "name": self.nameTF.text! as Any,
            "curbNumber": self.curbNumberTF.text! as Any,
            "phoneNumber": self.phoneTF.text! as Any,
            "price": Int(self.costTF.text!)! as Int,
            "style": self.styleTF.text! as Any,
            "notes": self.notesTF.text! as Any,
            "status": "Sold",
            "lat" : lat as Any,
            "long" : long as Any
        ])
        
        // stats
        self.rootRef.child("stats").child("normal").child(year).child(month).child(day).child((self.user!.uid)).child(dateString).setValue([
            "name": self.nameTF.text! as Any,
            "curbNumber": self.curbNumberTF.text! as Any,
            "phoneNumber": self.phoneTF.text! as Any,
            "price": Int(self.costTF.text!)! as Int,
            "style": self.styleTF.text! as Any,
            "notes": self.notesTF.text! as Any,
            "status": "Sold",
            "lat" : lat as Any,
            "long" : long as Any
        ])
        self.rootRef.child("stats").child("week").child(year).child(week).child((self.user!.uid)).child(dateString).setValue([
            "name": self.nameTF.text! as Any,
            "curbNumber": self.curbNumberTF.text! as Any,
            "phoneNumber": self.phoneTF.text! as Any,
            "price": Int(self.costTF.text!)! as Int,
            "style": self.styleTF.text! as Any,
            "notes": self.notesTF.text! as Any,
            "status": "Sold",
            "lat" : lat as Any,
            "long" : long as Any
        ])
            
        
        dismiss(animated: true, completion: nil)
    }
    
//    @IBAction func updateImagePressed(_ sender: Any) {
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            let picker = UIImagePickerController()
//            picker.sourceType = .camera
//            picker.delegate = self
//            picker.allowsEditing = true
//
//            present(picker, animated: true, completion: nil)
//        } else {
//            let alert = UIAlertController(title: "Whoops", message: "There's no camera on this device", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
//            present(alert, animated: true)
//        }
//    }
    
    
    @IBAction func deleteCustomerPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Careful", message: "Are you sure you want to delete this customer?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self] (_) in
            guard let strongSelf = self else { return }
            
            let dateString = strongSelf.customer.dateTime
            let date = strongSelf.dateFormatter.date(from: dateString)
            let year = strongSelf.yearFormatter.string(from: date!)
            let month = strongSelf.monthFormatter.string(from: date!)
            let week = strongSelf.weekFormatter.string(from: date!)
            let day = strongSelf.dayFormmatter.string(from: date!)
            
            // delete customer
            strongSelf.rootRef.child("customers").child(strongSelf.user!.uid).child(dateString).setValue(nil)
            
            strongSelf.rootRef.child("annotations").child(strongSelf.user!.uid).child(dateString).setValue(nil)
            
            strongSelf.rootRef.child("stats").child("normal").child(year).child(month).child(day).child(strongSelf.user!.uid).child(dateString).setValue(nil)
            strongSelf.rootRef.child("stats").child("week").child(year).child(week).child(strongSelf.user!.uid).child(dateString).setValue(nil)
            
            strongSelf.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func textNumber(_ sender: Any) {
        let recipients = phoneTF.text!//Phone Numbers
        let messageBody = "Hey, thanks so much for the business!"
        let sms: String = "sms://open?addresses=\(recipients)&body=\(messageBody)"
        let smsEncoded = sms.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        let url = URL(string: smsEncoded!)
        UIApplication.shared.open(url!)
    }
    
}
extension SingleCustomerViewController: UITextFieldDelegate {
    // ensure numbers only
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == costTF || textField == phoneTF || textField == curbNumberTF {
            let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
            return string.rangeOfCharacter(from: invalidCharacters) == nil
        }
        return true
    }
    
    // return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == nameTF {
            phoneTF.becomeFirstResponder()
        } else if textField == phoneTF {
            curbNumberTF.becomeFirstResponder()
        } else if textField == curbNumberTF {
            styleTF.becomeFirstResponder()
        } else if textField == styleTF {
            costTF.becomeFirstResponder()
        } else if textField == costTF {
            notesTF.becomeFirstResponder()
        }
        
        return true
    }
}
//extension SingleCustomerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    // finished taking picture
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
//        guard let imageData = image.pngData() else { return }
//        let imageRef = Storage.storage().reference().child(Firebase.Auth.auth().currentUser?.uid ?? "").child(customer.dateTime + ".png")
//        imageRef.putData(imageData)
//        self.custHasImage = true
//        rootRef.child("customers").child(user!.uid).child(customer.dateTime).child("hasPic").setValue(true)
//        DispatchQueue.main.async {
//            self.downloadImage()
//        }
//        picker.dismiss(animated: true, completion: nil)
//    }
//    // after image picked
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//}
extension SingleCustomerViewController: MFMessageComposeViewControllerDelegate {
    // after text sent
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
