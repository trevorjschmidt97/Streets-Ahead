//
//  SettingsViewController.swift
//  SchtreetSchmarts
//
//  Created by Trevor Schmidt on 4/30/21.
//

import UIKit
import Firebase
import SpreadsheetView
import FirebaseDatabase

class StatsViewController: UIViewController {
    
    let rootRef = Database.database().reference()
    
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl! // knocks vs dms vs sales
    @IBOutlet weak var segmentedControl: UISegmentedControl! // day v week v month v year
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var usernames: [String:String] = [:]
    var columnTitles = ["Name", "Knocks", "DMs", "Sales"]
    var leaders: [Leader] = []
    var currentTime = 0
    var currentSort = 2
    var loading = true
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spreadsheetView.register(MyCell.self, forCellWithReuseIdentifier: MyCell.identifier)
        spreadsheetView.delegate = self
        spreadsheetView.dataSource = self
        
        leftView.backgroundColor = navigationController?.navigationBar.barTintColor
        leftView.layer.opacity = 0.85
        leftView.isOpaque = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        spinner.startAnimating()
        pullUsernames()
        setup(with: currentTime)
    }
    
    private func pullUsernames() {
        rootRef.child("usernames").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let strongSelf = self else { return }
            guard let usernamesDict = snapshot.value as? [String:String] else { return }
            
            strongSelf.usernames = usernamesDict
        }
    }
    
    private func setup(with time: Int) {
        spinner.startAnimating()
        let currentDate = Date()
        let year = yearFormatter.string(from: currentDate)
        let month = monthFormatter.string(from: currentDate)
        let week = weekFormatter.string(from: currentDate)
        let day = dayFormmatter.string(from: currentDate)
        
        loading = true
        leaders.removeAll()
        spreadsheetView.reloadData()
        // day
        if time == 0 {
            rootRef.child("stats").child("normal").child(year).child(month).child(day).observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let strongSelf = self else { return }
                guard let userDict = snapshot.value as? [String:Any] else {
                    // no data for the day yet
                    DispatchQueue.main.async {
                        strongSelf.loading = false
                        strongSelf.spreadsheetView.reloadData()
                        strongSelf.spinner.stopAnimating()
                    }
                    return
                }
                
                var unsortedLeaders: [Leader] = []
                
                for userID in userDict.keys {
                    // create a user
                    let username = strongSelf.usernames[userID]
                    var sales = 0
                    var dms = 0
                    var knocks = 0
                    
                    if let knocksDict = userDict[userID] as? [String:Any] {
                        for knock in knocksDict.keys {
                            
                            if let knockInfoDict = knocksDict[knock] as? [String:Any] {
                                for knockInfo in knockInfoDict.keys {
                                    
                                    if knockInfo == "status" {
                                        if knockInfoDict[knockInfo] as! String == "Sold" {
                                            knocks += 1
                                            dms += 1
                                            sales += 1
                                        } else if knockInfoDict[knockInfo] as! String == "Not Interested" {
                                            dms += 1
                                        }
                                        
                                    } else if knockInfo == "previousKnocks" {
                                        if let previousKnocksDict = knockInfoDict[knockInfo] as? [String:String] {
                                            for _ in previousKnocksDict.keys {
                                                knocks += 1
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    let leader: Leader = Leader(username: username!, sales: sales, dms: dms, knocks: knocks)
                    unsortedLeaders.append(leader)
                }
                // sort on sales
                if strongSelf.currentSort == 0 {
                    strongSelf.leaders = unsortedLeaders.sorted(by: { $0.knocks > $1.knocks })
                } else if strongSelf.currentSort == 1 {
                    strongSelf.leaders = unsortedLeaders.sorted(by: { $0.dms > $1.dms })
                } else if strongSelf.currentSort == 2 {
                    strongSelf.leaders = unsortedLeaders.sorted(by: { $0.sales > $1.sales })
                }
                DispatchQueue.main.async {
                    strongSelf.loading = false
                    strongSelf.spreadsheetView.reloadData()
                    strongSelf.spinner.stopAnimating()
                }
            }
        // week
        } else if time == 1 {
            rootRef.child("stats").child("week").child(year).child(week).observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let strongSelf = self else { return }
                
                guard let userDict = snapshot.value as? [String:Any] else {
                    DispatchQueue.main.async {
                        strongSelf.loading = false
                        strongSelf.spreadsheetView.reloadData()
                        strongSelf.spinner.stopAnimating()
                    }
                    return
                }
                
                var unsortedLeaders: [Leader] = []
                
                for userID in userDict.keys {
                    // create a leader
                    let username = strongSelf.usernames[userID]
                    var sales = 0
                    var dms = 0
                    var knocks = 0
                    
                    if let knocksDict = userDict[userID] as? [String:Any] {
                        for knock in knocksDict.keys {
                            
                            if let knockInfoDict = knocksDict[knock] as? [String:Any] {
                                for knockInfo in knockInfoDict.keys {
                                    
                                    if knockInfo == "status" {
                                        if knockInfoDict[knockInfo] as! String == "Sold" {
                                            knocks += 1
                                            dms += 1
                                            sales += 1
                                        } else if knockInfoDict[knockInfo] as! String == "Not Interested" {
                                            dms += 1
                                        }
                                    } else if knockInfo == "previousKnocks" {
                                        if let previousKnocksDict = knockInfoDict[knockInfo] as? [String:String] {
                                            knocks += previousKnocksDict.count
                                        }
                                    }
                                }
                            }
                        }
                    }
                    unsortedLeaders.append(Leader(username: username!, sales: sales, dms: dms, knocks: knocks))
                }
                if strongSelf.currentSort == 0 {
                    strongSelf.leaders = unsortedLeaders.sorted(by: { $0.knocks > $1.knocks })
                } else if strongSelf.currentSort == 1 {
                    strongSelf.leaders = unsortedLeaders.sorted(by: { $0.dms > $1.dms })
                } else if strongSelf.currentSort == 2 {
                    strongSelf.leaders = unsortedLeaders.sorted(by: { $0.sales > $1.sales })
                }
                DispatchQueue.main.async {
                    strongSelf.loading = false
                    strongSelf.spreadsheetView.reloadData()
                    strongSelf.spinner.stopAnimating()
                }
            }
        //month
        } else if time == 2 {
            rootRef.child("stats").child("normal").child(year).child(month).observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let strongSelf = self else { return }
                
                guard let dayDict = snapshot.value as? [String:Any] else {
                    DispatchQueue.main.async {
                        strongSelf.loading = false
                        strongSelf.spreadsheetView.reloadData()
                        strongSelf.spinner.stopAnimating()
                    }
                    return
                }
                
                var unsortedLeaders: [Leader] = []
                
                var knownLeaders: [String:Leader] = [:]
                
                for day in dayDict.keys {
                    if let userDict = dayDict[day] as? [String:Any] {
                        for userID in userDict.keys {
                            // create a leader
                            let username = strongSelf.usernames[userID]
                            var sales = 0
                            var dms = 0
                            var knocks = 0
                            
                            if let knocksDict = userDict[userID] as? [String:Any] {
                                for knock in knocksDict.keys {
                                    
                                    if let knockInfoDict = knocksDict[knock] as? [String:Any] {
                                        for knockInfo in knockInfoDict.keys {
                                            
                                            if knockInfo == "status" {
                                                if knockInfoDict[knockInfo] as! String == "Sold" {
                                                    knocks += 1
                                                    dms += 1
                                                    sales += 1
                                                } else if knockInfoDict[knockInfo] as! String == "Not Interested" {
                                                    dms += 1
                                                }
                                            } else if knockInfo == "previousKnocks" {
                                                if let previousKnocksDict = knockInfoDict[knockInfo] as? [String:String] {
                                                    knocks += previousKnocksDict.count
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            if knownLeaders[username!] == nil {
                                knownLeaders[username!] = Leader(username: username!, sales: sales, dms: dms, knocks: knocks)
                            } else {
                                let temp = knownLeaders[username!]
                                temp?.sales += sales
                                temp?.dms += dms
                                temp?.knocks += knocks
                                knownLeaders[username!] = temp
                            }
                        }
                    }
                }
                for user in knownLeaders.keys {
                    unsortedLeaders.append(knownLeaders[user]!)
                }
                if strongSelf.currentSort == 0 {
                    strongSelf.leaders = unsortedLeaders.sorted(by: { $0.knocks > $1.knocks })
                } else if strongSelf.currentSort == 1 {
                    strongSelf.leaders = unsortedLeaders.sorted(by: { $0.dms > $1.dms })
                } else if strongSelf.currentSort == 2 {
                    strongSelf.leaders = unsortedLeaders.sorted(by: { $0.sales > $1.sales })
                }
                DispatchQueue.main.async {
                    strongSelf.loading = false
                    strongSelf.spreadsheetView.reloadData()
                    strongSelf.spinner.stopAnimating()
                }
                
            }
            // year
        } else if time == 3 {
            rootRef.child("stats").child("normal").child(year).observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let strongSelf = self else { return }
                
                guard let monthDict = snapshot.value as? [String:Any] else {
                    DispatchQueue.main.async {
                        strongSelf.loading = false
                        strongSelf.spreadsheetView.reloadData()
                        strongSelf.spinner.stopAnimating()
                    }
                    return
                }
                
                var unsortedLeaders: [Leader] = []
                var knownLeaders: [String:Leader] = [:]
                
                for month in monthDict.keys {
                    if let dayDict = monthDict[month] as? [String:Any] {
                        for day in dayDict.keys {
                            if let userDict = dayDict[day] as? [String:Any] {
                                for userID in userDict.keys {
                                    // create a leader
                                    let username = strongSelf.usernames[userID]
                                    var sales = 0
                                    var dms = 0
                                    var knocks = 0
                                    
                                    if let knocksDict = userDict[userID] as? [String:Any] {
                                        for knock in knocksDict.keys {
                                            
                                            if let knockInfoDict = knocksDict[knock] as? [String:Any] {
                                                for knockInfo in knockInfoDict.keys {
                                                    
                                                    if knockInfo == "status" {
                                                        if knockInfoDict[knockInfo] as! String == "Sold" {
                                                            dms += 1
                                                            sales += 1
                                                        } else if knockInfoDict[knockInfo] as! String == "Not Interested" {
                                                            dms += 1
                                                        }
                                                    } else if knockInfo == "previousKnocks" {
                                                        if let previousKnocksDict = knockInfoDict[knockInfo] as? [String:String] {
                                                            knocks += previousKnocksDict.count
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    if knownLeaders[username!] == nil {
                                        knownLeaders[username!] = Leader(username: username!, sales: sales, dms: dms, knocks: knocks)
                                    } else {
                                        let temp = knownLeaders[username!]
                                        temp?.sales += sales
                                        temp?.dms += dms
                                        temp?.knocks += knocks
                                        knownLeaders[username!] = temp
                                    }
                                }
                            }
                        }
                    }
                }
                
                for user in knownLeaders.keys {
                    unsortedLeaders.append(knownLeaders[user]!)
                }
                if strongSelf.currentSort == 0 {
                    strongSelf.leaders = unsortedLeaders.sorted(by: { $0.knocks > $1.knocks })
                } else if strongSelf.currentSort == 1 {
                    strongSelf.leaders = unsortedLeaders.sorted(by: { $0.dms > $1.dms })
                } else if strongSelf.currentSort == 2 {
                    strongSelf.leaders = unsortedLeaders.sorted(by: { $0.sales > $1.sales })
                }
                DispatchQueue.main.async {
                    strongSelf.loading = false
                    strongSelf.spreadsheetView.reloadData()
                    strongSelf.spinner.stopAnimating()
                }
            }
        }
    }

    // day v week ...
    @IBAction func segmentedControlChanged(_ sender: Any) {
        currentTime = segmentedControl.selectedSegmentIndex
        setup(with: segmentedControl.selectedSegmentIndex)
    }
    
    // knocks v dms v sales
    @IBAction func sortedSegmentedControlChanged(_ sender: Any) {
        spinner.startAnimating()
        currentSort = sortSegmentedControl.selectedSegmentIndex

        if currentSort == 0 {
            leaders = leaders.sorted(by: { $0.knocks > $1.knocks })
        } else if currentSort == 1 {
            leaders = leaders.sorted(by: { $0.dms > $1.dms })
        } else if currentSort == 2 {
            leaders = leaders.sorted(by: { $0.sales > $1.sales })
        }
        
        spreadsheetView.reloadData()
        spinner.stopAnimating()
    }
    
    
    @IBAction func signOutButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Careful", message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] (_) in
            guard let strongSelf = self else {
                return
            }
            
            do {
                try Firebase.Auth.auth().signOut()
                
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            } catch {
                return
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
}

extension StatsViewController: SpreadsheetViewDelegate {
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: MyCell.identifier, for: indexPath) as! MyCell

        // if its the header
        if indexPath.row == 0 {
            cell.setup(with: columnTitles[indexPath.column])
        // else
        } else {
            if leaders.count != 0 {
                let currentLeader = leaders[indexPath.row - 1]
                
                var returnString = ""
                if indexPath.column == 0 {
                    // get numbers
                    returnString = String(indexPath.row) + ": " + currentLeader.username
                } else if indexPath.column == 1 {
                    returnString = String(currentLeader.knocks)
                } else if indexPath.column == 2 {
                    returnString = String(currentLeader.dms)
                } else if indexPath.column == 3 {
                    returnString = String(currentLeader.sales)
                }
                
                cell.setup(with: returnString)
            } else {
                if indexPath.column == 0 {
                    if loading {
                        cell.setup(with: "Loading...")
                    } else {
                        cell.setup(with: "No Leaders Yet")
                    }
                } else {
                    cell.setup(with: "")
                }
            }
        }
        
        return cell
    }
}

extension StatsViewController: SpreadsheetViewDataSource {
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return columnTitles.count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        if leaders.count == 0 {
            return 2
        }
        return leaders.count + 1
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        var multiplyer = 1
        var constant = 0
        
        if column == 0 {
            multiplyer = 2
            constant = 6
        }
        
        return view.bounds.width / 5 * CGFloat(multiplyer) - CGFloat(constant)
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return 35
    }
}


class MyCell: Cell {
    static let identifier = "MyCellIdentifier"
    
    private let label = UILabel()
    
    public func setup(with text: String) {
        label.text = text
        label.backgroundColor = .systemBackground
        label.textColor = UIColor.label
        label.textAlignment = .center
        contentView.addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }
}
