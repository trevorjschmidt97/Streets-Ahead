//
//  KnockViewController.swift
//  SchtreetSchmarts
//
//  Created by Trevor Schmidt on 5/3/21.
//

import UIKit
import Firebase
import FirebaseDatabase

class KnockViewController: UIViewController {
    // Firebase
    let rootRef = Database.database().reference()
    var user: User? = nil
    
    // Knock Key
    var dateString: String?
    
    // Outlets
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var previousKnocksTextView: UITextView!
    
    @IBOutlet weak var pickerView: UIPickerView!
    let pickerInfo = [
        "Not Home",
        "Already Have It",
        "Renting",
        "Not Interested",
        "Come Back Later"
    ]
    
    // Info
    var status: String = ""
    var notes: String = ""
    var previousKnocks: String = ""
    
    //dumb
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
        
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        // Verify user is signed in
        guard Firebase.Auth.auth().currentUser != nil else { return }
        user = Firebase.Auth.auth().currentUser
        
        notesTextView!.layer.borderWidth = 1
        notesTextView!.layer.borderColor = UIColor.systemBlue.cgColor
        
        previousKnocksTextView.layer.borderWidth = 1
        previousKnocksTextView!.layer.borderColor = UIColor.systemBlue.cgColor
        previousKnocksTextView.isEditable = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        pullInfo()
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        notesTextView.resignFirstResponder()
    }
    
    private func pullInfo() {
        // go into that annotation
        rootRef.child("annotations").child(user!.uid).child(dateString!).observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let strongSelf = self else { return }
            
            guard let dataDict = snapshot.value as? [String: Any] else { return }
            
            for dataKey in dataDict.keys {
                if dataKey == "status" {
                    strongSelf.status = dataDict[dataKey] as! String
                } else if dataKey == "notes" {
                    strongSelf.notes = dataDict[dataKey] as! String
                } else if dataKey == "previousKnocks" {
                    guard let knocksDict = dataDict[dataKey] as? [String: String] else { return }
                    
                    let sortedKeys = Array(knocksDict.keys.sorted(by: >))
                    
                    // Datetime
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "YYYY-MM-dd, HH:mm:ss:SSSS"
                    let secondDateFormatter = DateFormatter()
                    secondDateFormatter.dateFormat = "MM/dd/YY hh:mma"
                    secondDateFormatter.amSymbol = "am"
                    secondDateFormatter.pmSymbol = "pm"

                    for key in sortedKeys {
                        let date = dateFormatter.date(from: key)
                        let betterDate = secondDateFormatter.string(from: date!)
                        strongSelf.previousKnocks += betterDate + ": " + knocksDict[key]! + "\n"
                    }
                }
            }
            
            strongSelf.notesTextView.text = strongSelf.notes
            strongSelf.previousKnocksTextView.text = strongSelf.previousKnocks
            
            if strongSelf.status == "Not Home" {
                strongSelf.pickerView.selectRow(0, inComponent: 0, animated: false)
            } else if strongSelf.status == "Already Have It" {
                strongSelf.pickerView.selectRow(1, inComponent: 0, animated: false)
            } else if strongSelf.status == "Renting" {
                strongSelf.pickerView.selectRow(2, inComponent: 0, animated: false)
            } else if strongSelf.status == "Not Interested" {
                strongSelf.pickerView.selectRow(3, inComponent: 0, animated: false)
            } else if strongSelf.status == "Come Back Later" {
                strongSelf.pickerView.selectRow(4, inComponent: 0, animated: false)
            } 
        }
    }
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        let date = dateFormatter.date(from: dateString!)
        let year = yearFormatter.string(from: date!)
        let month = monthFormatter.string(from: date!)
        let week = weekFormatter.string(from: date!)
        let day = dayFormmatter.string(from: date!)
        
        // Notes
        notes = notesTextView.text
        rootRef.child("annotations").child(user!.uid).child(dateString!).child("notes").setValue(notes)
        rootRef.child("stats").child("normal").child(year).child(month).child(day).child(user!.uid).child(dateString!).child("notes").setValue(notes)
        rootRef.child("stats").child("week").child(year).child(week).child(user!.uid).child(dateString!).child("notes").setValue(notes)
        
        //status
        let newStatus = pickerInfo[pickerView.selectedRow(inComponent: 0)]
        rootRef.child("annotations").child(user!.uid).child(dateString!).child("status").setValue(newStatus)
        rootRef.child("stats").child("normal").child(year).child(month).child(day).child(user!.uid).child(dateString!).child("status").setValue(newStatus)
        rootRef.child("stats").child("week").child(year).child(week).child(user!.uid).child(dateString!).child("status").setValue(newStatus)
        
        // previousKnocks
        if status != newStatus {
            let timestamp = dateFormatter.string(from: Date())
            rootRef.child("annotations").child(user!.uid).child(dateString!).child("previousKnocks").child(timestamp).setValue(newStatus)
            rootRef.child("stats").child("normal").child(year).child(month).child(day).child(user!.uid).child(dateString!).child("previousKnocks").child(timestamp).setValue(newStatus)
            rootRef.child("stats").child("week").child(year).child(week).child(user!.uid).child(dateString!).child("previousKnocks").child(timestamp).setValue(newStatus)
        }
            
        dismiss(animated: true) {
            if let parent = self.presentingViewController as? MapViewController {
                parent.reloadPins(self)
            }
        }
    }
    
    @IBAction func deletePinTapped(_ sender: Any) {
        let date = dateFormatter.date(from: dateString!)
        let year = yearFormatter.string(from: date!)
        let month = monthFormatter.string(from: date!)
        let week = weekFormatter.string(from: date!)
        let day = dayFormmatter.string(from: date!)
        
        rootRef.child("annotations").child(user!.uid).child(dateString!).setValue(nil)
        
        rootRef.child("stats").child("normal").child(year).child(month).child(day).child(user!.uid).child(dateString!).setValue(nil)
        rootRef.child("stats").child("week").child(year).child(week).child(user!.uid).child(dateString!).setValue(nil)
        
        dismiss(animated: true) {
            if let parent = self.presentingViewController as? MapViewController {
                parent.reloadPins(self)
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        let date = dateFormatter.date(from: dateString!)
        let year = yearFormatter.string(from: date!)
        let month = monthFormatter.string(from: date!)
        let week = weekFormatter.string(from: date!)
        let day = dayFormmatter.string(from: date!)
        
        if status != "Sold" {
            notes = notesTextView.text
            rootRef.child("annotations").child(user!.uid).child(dateString!).child("notes").setValue(notes)
            rootRef.child("stats").child("normal").child(year).child(month).child(day).child(user!.uid).child(dateString!).child("notes").setValue(notes)
            rootRef.child("stats").child("week").child(year).child(week).child(user!.uid).child(dateString!).child("notes").setValue(notes)
        }
        
        dismiss(animated: true) {
            if let parent = self.presentingViewController as? MapViewController {
                parent.reloadPins(self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! MapViewController
        
        destVC.annotations = []
    }
}

extension KnockViewController: UIPickerViewDelegate {
    
}
extension KnockViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerInfo.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerInfo[row]
    }
}
