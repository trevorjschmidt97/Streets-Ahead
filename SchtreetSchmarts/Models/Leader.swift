//
//  Leader.swift
//  SchtreetSchmarts
//
//  Created by Trevor Schmidt on 5/17/21.
//

import UIKit


class Leader {
    var username: String
    var sales: Int
    var dms: Int
    var knocks: Int
    
    init(username: String, sales: Int, dms: Int, knocks: Int) {
        self.username = username
        self.sales = sales
        self.dms = dms
        self.knocks = knocks
    }
}
