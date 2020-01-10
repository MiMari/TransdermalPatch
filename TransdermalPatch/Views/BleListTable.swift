//
//  BleListTable.swift
//  TransdermalPatch
//
//  Created by Amir on 10.01.2020.
//  Copyright © 2020 Amir Mardanov. All rights reserved.
//

import UIKit

class BleListTable {
        
    private let table: UITableView
    
    init() {
        
        table = UITableView()
        
        table.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func build() -> UITableView {
        return table
    }
}


