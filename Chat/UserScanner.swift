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
    let host = "localhost"
    let port: String = "8082"
    
    var delegate: UserScannerDelegate!
    
    init(delegate: UserScannerDelegate) {
        self.delegate = delegate
    }
    
    func getOnlineUsersIPs() {
        let URLString = "http://" + host + ":" + port + "/getIPs"
        let url = URL(string: URLString)
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            let str = String(data: data!, encoding: .utf8)!
            var IPs = str.components(separatedBy: "\n")
            IPs.remove(at: 0)
            
            self.delegate.didGetUsersIPs(IPs: IPs)
        }
        task.resume()
    }
}
