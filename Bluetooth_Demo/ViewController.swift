//
//  ViewController.swift
//  Bluetooth_Demo
//
//  Created by Amr Omran on 05/01/2018.
//  Copyright © 2018 Amr Omran. All rights reserved.
//


import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate, UITableViewDataSource {

  
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var switchBtn: UISwitch!
    @IBOutlet weak var cardView: UIView!
    
    var bluetoothList: Array<String> = []
    var bluetoothPerepheralList: Array<CBPeripheral> = []
    
    var centralManager = CBCentralManager()
    var peripheralManager: CBPeripheralManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()

        switchBtn.isOn = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        centralManager.delegate = self
    }
    
/**
    CBCentralManager Delegate Methods
 */
    
    // get the state of the bluetooth of the iPhone
    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        switch central.state {
        case .poweredOn:
            print("power on")
            switchBtn.isEnabled = true
            
        case .poweredOff:
            print("power off")
            switchBtn.isEnabled = false
        
            bluetoothList.removeAll()
            bluetoothPerepheralList.removeAll()
            tableView.reloadData()
            
        default:
            print("The State is Unknown")
        }
    }
    
    // discover the peripheral devices
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        bluetoothList.append(peripheral.name ?? "No Name Device")
        bluetoothPerepheralList.append(peripheral)
        tableView.reloadData()
    }

    // the status of the connection between the iPhone and the Peripherals
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected")
        peripheral.delegate = self // set the peripheral's delegate to self after connected
        peripheral.discoverServices(nil)
        centralManager.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Not Connected")
    }
    
    
    
/**
 CBPeripheral Delegate Methods
 */
    
    // ask device for service
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            print(error!.localizedDescription)
            return
        } else {
            let services = peripheral.services
            print("Services Found: \(String(describing: services!.count))\nServices: \(String(describing: services!))")
            services?.forEach { peripheral.discoverCharacteristics(nil, for: $0) } // ask for characteristics
        }
    }
    
    // ask device for Characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print(error!.localizedDescription)
            return
        } else {
            let characteristics = service.characteristics
            print("Characteristics Found: \(characteristics!.count) characteristics")
            characteristics?.forEach { peripheral.readValue(for: $0)}
        }
    }
    
    // Receive the result of reading Characteristics
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print(error!.localizedDescription)
            return
        } else {
           print(characteristic.uuid)
        }
    }
    
/**
 CBPeripheralManager to adverise
 */

    
    
    
/**
     Search and Stop Methods
*/
    
    @IBAction func searchStopBtn(_ sender: Any) {
        let switchBtn = sender as! UISwitch
        if switchBtn.isOn {
            bluetoothList.removeAll()
            bluetoothPerepheralList.removeAll()
            tableView.reloadData()
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            centralManager.stopScan()
        }
    }
 
/**
     UITableView Methods
 **/

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        cell.label.text = bluetoothList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bluetoothList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bluetoothPerepheral = bluetoothList[indexPath.row]
        let perepheralDevice = bluetoothPerepheralList[indexPath.row]
        connect(perepheralName: bluetoothPerepheral, perepheral: perepheralDevice)
    }
    
/**
 AlertController
 */

    
    func connect(perepheralName: String, perepheral: CBPeripheral) {
        let alertController = UIAlertController(title: "Connect", message: "Do you want to connect to \(perepheralName)", preferredStyle: .alert)
        let connectBtn = UIAlertAction(title: "Connect", style: .default) { (action) in
            
            self.centralManager.connect(perepheral, options: nil)
            alertController.dismiss(animated: true, completion: nil)
        }
        
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(connectBtn)
        alertController.addAction(cancelBtn)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func initView() {
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.5
        cardView.layer.shadowOffset = CGSize.zero
        cardView.layer.shadowRadius = 2
    }
}



// UITableViewCell Class

class TableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    
}
