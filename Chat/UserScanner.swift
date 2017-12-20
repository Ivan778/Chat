//
//  UserScanner.swift
//  Chat
//
//  Created by Иван on 20.12.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import Foundation

protocol UserScannerDelegate {
    func didGetUsersIPs(IPs: [String])
    //func didNotGetUsersIPs(IPs: Error)
}

class UserScanner {
    let host = "192.168.1.6"
    let port: String = "8082"
    
    var delegate: UserScannerDelegate!
    
    init(delegate: UserScannerDelegate) {
        self.delegate = delegate
    }
    
    func getOnlineUsersIPs() {
        let URLString = "http://" + host + ":" + port + "/getIPs"
        let url = URL(string: URLString)
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error == nil {
                let str = String(data: data!, encoding: .utf8)
                
                if let s = str {
                    var IPs = s.components(separatedBy: "\n")
                    IPs.remove(at: 0)
                    
                    self.delegate.didGetUsersIPs(IPs: IPs)
                } else {
                    self.delegate.didGetUsersIPs(IPs: [String]())
                }
            }
            
        }
        task.resume()
    }
}
