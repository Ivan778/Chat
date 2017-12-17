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

class ScanningNetworkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GCDAsyncSocketDelegate, UDPScannerDelegate {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var message: UILabel!
    
    var devices = [String]()
    var TCPSocket: GCDAsyncSocket!
    var nSocket: GCDAsyncSocket!
    
    var scanner: UDPScanner!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scanner = UDPScanner(delegate: self)
        scanner.sayHelloToOtherDevices()
        
        TCPSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
    }
    
    func foundNewUser(userAddress: String) {
        message.text = userAddress
    }
    
    @IBAction func clickedConnect(_ sender: Any) {
        TCPSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: 10, tag: 0)
        do {
            try TCPSocket.connect(toHost: textField.text!, onPort: 5678)
        } catch {
            print(error)
        }
    }
    
    @IBAction func clickedAccept(_ sender: Any) {
        TCPSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: 10, tag: 0)
        do {
            try TCPSocket.accept(onPort: 5678)
        } catch {
            print(error)
        }
    }
    @IBAction func clickedSend(_ sender: Any) {
        print("Sending...")
        //let data = textField.text!.data(using: .utf8)
        //TCPSocket.write(data!, withTimeout: -1, tag: 0)
        scanner.sayHelloToOtherDevices()
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        TCPSocket.readData(withTimeout: -1, tag: 0)
        print("Hello")
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        sock.readData(withTimeout: -1, tag: 0)
        message.text = String(data: data, encoding: String.Encoding.utf8) as String!
        print("yeah")
    }
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        message.text = newSocket.connectedHost
        
        TCPSocket = newSocket
        TCPSocket.readData(withTimeout: -1, tag: 0)
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
        
        self.performSegue(withIdentifier: "GoChattingSegue", sender: self)
    }

}

