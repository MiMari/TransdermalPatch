//
//  ViewController.swift
//  TransdermalPatch
//
//  Created by Amir on 10.01.2020.
//  Copyright © 2020 Amir Mardanov. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    private let tableView = BleListTable().build()
    
    var centralManager: CBCentralManager!
    var peripheralDevice: CBPeripheral!
    var peripherals = [CBPeripheral]()
    let peipheralCellId = "peipheralCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        title = "All devices"
        addTableViewLayout()
    }
    
    func addTableViewLayout() {
        
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: peipheralCellId)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    
    func showWarningAlert(with title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
}

extension ViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            showWarningAlert(with: "Failed to scan peripherals", message: "Please, turn on the Bluetooth in settings")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let name = peripheral.name ?? "No name"
        
        if name == "Patch_57" {
            centralManager.connect(peripheral, options: nil)
            peripheralDevice = peripheral            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        print("Connected")
        
        let peripheralVC = PeripheralController()
        peripheralVC.peripheral = peripheral
        
        navigationController?.pushViewController(peripheralVC, animated: true)
        
        peripheralDevice.discoverServices(nil)
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: peipheralCellId, for: indexPath)
        
        cell.textLabel?.text = peripherals[indexPath.row].name!
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let peripheral = peripherals[indexPath.row]
        peripheralDevice = peripheral
        centralManager.connect(peripheral, options: nil)
        
    }
}
