////
////  UserGlobals.swift
////  SchtreetSchmarts
////
////  Created by Trevor Schmidt on 5/12/21.
////
//
//import Foundation
//import FirebaseDatabase
//
//class UserGlobals {
//    static var dayKnocks = 0
//    static var dayDMs = 0
//    static var daySales = 0
//    static var dayRev = 0
//    
//    static var weekKnocks = 0
//    static var weekDMs = 0
//    static var weekSales = 0
//    static var weekRev = 0
//    
//    static var monthKnocks = 0
//    static var monthDMs = 0
//    static var monthSales = 0
//    static var monthRev = 0
//    
//    static var yearKnocks = 0
//    static var yearDMs = 0
//    static var yearSales = 0
//    static var yearRev = 0
//    
//    public static func initializeDay(year: String, month: String, day: String, userID: String) {
//        let dayRef = Database.database().reference().child("stats").child("day")
//        
//        dayRef.child(year).child(month).child(day).child(userID).setValue([
//            "knocks": 0,
//            "dms": 0,
//            "sales": 0,
//            "rev": 0
//        ])
//    }
//    
//    public static func initializeWeek(year: String, week: String, userID: String) {
//        let weekRef = Database.database().reference().child("stats").child("week")
//        
//        weekRef.child(year).child(week).child(userID).setValue([
//            "knocks": 0,
//            "dms": 0,
//            "sales": 0,
//            "rev": 0
//        ])
//    }
//    
//    public static func initializeMonth(year: String, month: String, userID: String) {
//        let monthRef = Database.database().reference().child("stats").child("month")
//        
//        monthRef.child(year).child(month).child(userID).setValue([
//            "knocks": 0,
//            "dms": 0,
//            "sales": 0,
//            "rev": 0
//        ])
//    }
//    
//    public static func initializeYear(year: String, userID: String) {
//        let yearRef = Database.database().reference().child("stats").child("year")
//        
//        yearRef.child(year).child(userID).setValue([
//            "knocks": 0,
//            "dms": 0,
//            "sales": 0,
//            "rev": 0
//        ])
//    }
//}
////private func pullUserInfo() {
////    // this is where I will get all the info of the user's knock counts
////    
////    // Check to see if user has info on the day
////    let currentDate = Date()
////    let year = yearFormatter.string(from: currentDate)
////    let month = monthFormatter.string(from: currentDate)
////    let week = weekFormatter.string(from: currentDate)
////    let day = dayFormmatter.string(from: currentDate)
////    
////    // Day info
////    rootRef.child("day").child(year).child(month).child(day).child(user!.uid).observeSingleEvent(of: .value) { [weak self] snapshot in
////        guard let dayDict = snapshot.value as? [String:Int] else {
////            // nothing there
////            DispatchQueue.main.async {
////                UserGlobals.initializeDay(year: year, month: month, day: day, userID: (self?.user!.uid)!)
////            }
////            return
////        }
////        var dayKnocks = 0
////        var dayDMs = 0
////        var daySales = 0
////        var dayRev = 0
////        
////        for daykey in dayDict.keys {
////            if daykey == "knocks" {
////                dayKnocks = dayDict[daykey]!
////            } else if daykey == "dms" {
////                dayDMs = dayDict[daykey]!
////            } else if daykey == "sales" {
////                daySales = dayDict[daykey]!
////            } else if daykey == "rev" {
////                dayRev = dayDict[daykey]!
////            }
////        }
////        
////        DispatchQueue.main.async {
////            UserGlobals.dayKnocks = dayKnocks
////            UserGlobals.dayDMs = dayDMs
////            UserGlobals.daySales = daySales
////            UserGlobals.dayRev = dayRev
////        }
////    }
////    
////    // Week info
////    rootRef.child("week").child(year).child(week).child(user!.uid).observeSingleEvent(of: .value) { [weak self] snapshot in
////        guard let weekDict = snapshot.value as? [String:Int] else {
////            // Nothing there
////            DispatchQueue.main.async {
////                UserGlobals.initializeWeek(year: year, week: week, userID: (self?.user!.uid)!)
////            }
////            return
////        }
////        
////        var weekKnocks = 0
////        var weekDMs = 0
////        var weekSales = 0
////        var weekRev = 0
////        
////        for weekkey in weekDict.keys {
////            if weekkey == "knocks" {
////                weekKnocks = weekDict[weekkey]!
////            } else if weekkey == "dms" {
////                weekDMs = weekDict[weekkey]!
////            } else if weekkey == "sales" {
////                weekSales = weekDict[weekkey]!
////            } else if weekkey == "rev" {
////                weekRev = weekDict[weekkey]!
////            }
////        }
////        
////        DispatchQueue.main.async {
////            UserGlobals.weekKnocks = weekKnocks
////            UserGlobals.weekDMs = weekDMs
////            UserGlobals.weekSales = weekSales
////            UserGlobals.weekRev = weekRev
////        }
////    }
////    
////    //month
////    rootRef.child("month").child(year).child(month).child(user!.uid).observeSingleEvent(of: .value) { [weak self] snapshot in
////        guard let monthDict = snapshot.value as? [String:Int] else {
////            // Nothing there
////            DispatchQueue.main.async {
////                UserGlobals.initializeMonth(year: year, month: month, userID: (self?.user!.uid)!)
////            }
////            return
////        }
////        
////        var monthKnocks = 0
////        var monthDMs = 0
////        var monthSales = 0
////        var monthRev = 0
////        
////        for monthkey in monthDict.keys {
////            if monthkey == "knocks" {
////                monthKnocks = monthDict[monthkey]!
////            } else if monthkey == "dms" {
////                monthDMs = monthDict[monthkey]!
////            } else if monthkey == "sales" {
////                monthSales = monthDict[monthkey]!
////            } else if monthkey == "rev" {
////                monthRev = monthDict[monthkey]!
////            }
////        }
////        
////        DispatchQueue.main.async {
////            UserGlobals.monthKnocks = monthKnocks
////            UserGlobals.monthDMs = monthDMs
////            UserGlobals.monthSales = monthSales
////            UserGlobals.monthRev = monthRev
////        }
////    }
////    
////    //Year
////    rootRef.child("year").child(year).child(user!.uid).observeSingleEvent(of: .value) { [weak self] snapshot in
////        guard let yearDict = snapshot.value as? [String:Int] else {
////            // Nothing there
////            DispatchQueue.main.async {
////                UserGlobals.initializeYear(year: year, userID: (self?.user!.uid)!)
////            }
////            return
////        }
////        
////        var yearKnocks = 0
////        var yearDMs = 0
////        var yearSales = 0
////        var yearRev = 0
////        
////        for yearkey in yearDict.keys {
////            if yearkey == "knocks" {
////                yearKnocks = yearDict[yearkey]!
////            } else if yearkey == "dms" {
////                yearDMs = yearDict[yearkey]!
////            } else if yearkey == "sales" {
////                yearSales = yearDict[yearkey]!
////            } else if yearkey == "rev" {
////                yearRev = yearDict[yearkey]!
////            }
////        }
////        
////        DispatchQueue.main.async {
////            UserGlobals.yearKnocks = yearKnocks
////            UserGlobals.yearDMs = yearDMs
////            UserGlobals.yearSales = yearSales
////            UserGlobals.yearRev = yearRev
////        }
////    }
////}
