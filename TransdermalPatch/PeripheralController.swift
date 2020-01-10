//
//  PeripheralController.swift
//  TransdermalPatch
//
//  Created by Amir on 10.01.2020.
//  Copyright © 2020 Amir Mardanov. All rights reserved.
//


import UIKit
import CoreBluetooth
import Charts

class PeripheralController: UIViewController {
    
    let characteristicCellId = "characteristicCell"
    var peripheral: CBPeripheral!
    let ecgCharacteristicUUID = CBUUID(string: "ffe1")
    let chartView = LineChartView()
    var ecgData = [Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peripheral.delegate = self
        
        title = peripheral.name
        
        view.backgroundColor = .white
        setupChart()
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupChart() {
        view.addSubview(chartView)
        
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        chartView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        chartView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        chartView.heightAnchor.constraint(equalToConstant: 450).isActive = true
        
        
        let values = (0 ..< ecgData.count).map({ (i) -> ChartDataEntry in
            let val = ecgData[i]
            return ChartDataEntry(x: Double(i), y: val)
        })
        
        
        let lineChartDataSet = LineChartDataSet(entries: values, label: "")
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        
        chartView.data = lineChartData
        
    }
}

extension PeripheralController: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let services = peripheral.services {
            
            services.forEach({ service in
                
                peripheral.discoverCharacteristics(nil, for: service)
            })
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            
            characteristics.forEach({ characteristic in
                
                if characteristic.uuid == ecgCharacteristicUUID {
                    
                    peripheral.setNotifyValue(true, for: characteristic)
                    
                    peripheral.readValue(for: characteristic)
                }
            })
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("wrote")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {
            decodeData(value: value)
        }
    }
    
    func decodeData(value: Data) {
        
        for index in 0 ..< value.count where index % 2 == 0 {
            let tempValue = Int((value[index] << 8) + value[index + 1])
            
            let doubleValue = Double(tempValue)
            
            ecgData.append(doubleValue)
            
            print(tempValue)
            
        }
    }
}
