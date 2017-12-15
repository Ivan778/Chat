//
//  ViewController.swift
//  Chat
//
//  Created by Иван on 15.12.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import UIKit

import MMLanScan

class ViewController: UIViewController, MMLANScannerDelegate, UITableViewDelegate, UITableViewDataSource {
    var lanScanner: MMLANScanner!
    var devices = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    
    public func lanScanDidFailedToScan() {
        
    }

    public func lanScanDidFinishScanning(with status: MMLanScannerStatus) {
        
    }

    public func lanScanDidFindNewDevice(_ device: Device!) {
        devices.append(device.ipAddress)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // My Mac IP = 192.168.1.108
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lanScanner = MMLANScanner(delegate: self)
        self.lanScanner.start()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - TableView delegate methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IPCell", for: indexPath)
        let row = indexPath.row
        
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = (devices[row])
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
    }

}

