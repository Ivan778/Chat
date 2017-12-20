//
//  Sender.swift
//  Chat
//
//  Created by Иван on 20.12.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import Foundation

protocol SenderDelegate {
    //func didSendData()
    func didNotSendData()
}

class Sender {
    let host = "localhost"
    let port: String = "8082"
    
    var delegate: SenderDelegate!
    
    init(delegate: SenderDelegate) {
        self.delegate = delegate
    }
    
    func sendIP(IP: String) {
        let json: [[String: Any]] = [["IP": IP]]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // create post request
        let url = URL(string: "http://" + host + ":" + port + "/sendIP")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                self.delegate.didNotSendData()
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
                
            }
        }
        
        task.resume()
    }
    
}
