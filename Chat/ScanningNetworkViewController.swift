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

extension UIViewController {
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

class ScanningNetworkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UserScannerDelegate, SenderDelegate, GCDAsyncSocketDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var TCPsocket: GCDAsyncSocket!
    var socketSaved: GCDAsyncSocket!
    let port: UInt16 = 8081
    
    var userScanner: UserScanner!
    var sender: Sender!
    var devices = [String]()
    var selectedRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        TCPsocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        TCPsocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: 0)
        do {
            try TCPsocket.accept(onPort: port)
            socketSaved = TCPsocket
        } catch {
            print(error)
        }
        
        userScanner = UserScanner(delegate: self)
        sender = Sender(delegate: self)
        if let IP = IPGetter.getWiFiAddress() {
            sender.sendIP(IP: IP)
        }
        
        userScanner.getOnlineUsersIPs()
        // Reload connected users info every 5 seconds
        _ = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.scanForUsers), userInfo: nil, repeats: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoChattingSegue" {
            let cVC = segue.destination as! ChatViewController
            if selectedRow >= 0 {
                cVC.sendToIP = devices[selectedRow]
                TCPsocket.disconnect()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        do {
            try TCPsocket.accept(onPort: port)
        } catch {
            print(error)
        }
    }
    
    @IBAction func clickedSend(_ sender: Any) {
        self.sender.sendMessage(message: "Hello, World!", to: IPGetter.getWiFiAddress()!, from: IPGetter.getWiFiAddress()!)
    }
    
    func scanForUsers() {
        userScanner.getOnlineUsersIPs()
    }
    
    // MARK: - GCDAsyncSocket delegate methods
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        sock.readData(withTimeout: -1, tag: 0)
        let message = String(data: data, encoding: .utf8)
        
        if message != nil {
            let mess = (message!).components(separatedBy: "|-|")
            presentAlert(title: "New message", message: "\"\(mess[0])\" from \(mess[1])")
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        TCPsocket = newSocket
        TCPsocket.readData(withTimeout: -1, tag: 0)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        TCPsocket = socketSaved
    }
    
    // MARK: - Sender delegate methods
    func didNotSendData(error: NSError) {
        print(error)
    }
    
    // MARK: - UserScanner delegate methods
    func didGetUsersIPs(IPs: [String]) {
        if devices != IPs {
            devices = IPs
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - TableView delegate methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IPCell", for: indexPath)
        let row = indexPath.row
        
        let label = cell.viewWithTag(1000) as! UILabel
        if devices[row] != IPGetter.getWiFiAddress() {
            label.text = (devices[row])
        } else {
            label.text = ("Me: \(devices[row])")
        }
        
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "GoChattingSegue", sender: self)
        selectedRow = indexPath.row
        DispatchQueue.main.async {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }

}

