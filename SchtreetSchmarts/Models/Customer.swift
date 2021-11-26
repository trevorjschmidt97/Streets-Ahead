//
//  Customer.swift
//  SchtreetSchmarts
//
//  Created by Trevor Schmidt on 5/5/21.
//

import UIKit

class Customer {
    
    var userID: String
    var dateTime: String
    var name: String
    var curbNumber: String
    var phoneNumber: String
    var price: Int
    var style: String
    var notes: String
    var lat: Double
    var long: Double
    
    init(userID: String,
         dateTime: String,
         name: String,
         curbNumber: String,
         phoneNumber: String,
         price: Int,
         style: String,
         notes: String,
         lat: Double,
         long: Double) {
        self.userID = userID
        self.dateTime = dateTime
        self.name = name
        self.curbNumber = curbNumber
        self.phoneNumber = phoneNumber
        self.price = price
        self.style = style
        self.notes = notes
        self.lat = lat
        self.long = long
    }
}
