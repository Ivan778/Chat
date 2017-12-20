//
//  ViewController.swift
//  Chat
//
//  Created by Иван on 15.12.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import UIKit
import SwiftSocket
import CocoaAsyncSocket

class ScanningNetworkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UserScannerDelegate, SenderDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var userScanner: UserScanner!
    var devices = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        userScanner = UserScanner(delegate: self)
        let sender = Sender(delegate: self)
        if let IP = IPGetter.getWiFiAddress() {
            sender.sendIP(IP: IP)
        }
        
        _ = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.scanForUsers), userInfo: nil, repeats: true)
    }
    
    func scanForUsers() {
        userScanner.getOnlineUsersIPs()
    }
    
    // MARK: - Sender delegate methods
    func didNotSendData() {
        print("Didn't send data!!!")
    }
    
    // MARK: - UserScanner delegate methods
    func didGetUsersIPs(IPs: [String]) {
        devices = IPs
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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

}

