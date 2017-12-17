//
//  UDPScanner.swift
//  Chat
//
//  Created by Иван on 17.12.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

@objc protocol UDPScannerDelegate {
    @objc func foundNewUser(userAddress: String)
    @objc optional func userDisconnected(userAddress: String)
}

class UDPScanner: NSObject, GCDAsyncUdpSocketDelegate {
    var socket: GCDAsyncUdpSocket!
    let password = "ChatAppByIvanushka7798".data(using: .utf8)
    let port = 50000 as UInt16
    
    var count = 0
    
    var delegate: UDPScannerDelegate!
    
    init(delegate: UDPScannerDelegate) {
        super.init()
        
        self.delegate = delegate
        
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try socket.bind(toPort: port)
            try socket.joinMulticastGroup("239.0.0.0")
            //try socket.enableBroadcast(true)
            try socket.beginReceiving()
        } catch {
            print(error)
        }
    }
    
    func sayHelloToOtherDevices() {
        socket.send(password!, toHost: "239.0.0.0", port: port, withTimeout: 5, tag: 0)
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        print("Got it \(count): \(String(data: data, encoding: .utf8) as Any)")
        count += 1
        
        if data == password {
            delegate.foundNewUser(userAddress: String(data: data, encoding: .utf8)!)
        }
    }
}
