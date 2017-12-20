//
//  ChatViewController.swift
//  Chat
//
//  Created by Иван on 15.12.17.
//  Copyright © 2017 IvanCode. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GCDAsyncSocketDelegate, SenderDelegate, UITextFieldDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    var TCPsocket: GCDAsyncSocket!
    var socketSaved: GCDAsyncSocket!
    let port: UInt16 = 8081
    
    var sender: Sender!
    var sendToIP: String!
    var messages = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        messageTextField.delegate = self
        
        setDoneOnKeyboard()
        
        sender = Sender(delegate: self)
        
        TCPsocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        TCPsocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: 0)
        do {
            try TCPsocket.accept(onPort: port)
            socketSaved = TCPsocket
        } catch {
            print(error)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if IPGetter.getWiFiAddress() != nil {
            messages.append("Me: \(textField.text!)")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            sender.sendMessage(message: textField.text!, to: sendToIP, from: IPGetter.getWiFiAddress()!)
        }
        
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        TCPsocket.disconnect()
        socketSaved.disconnect()
    }
    
    // MARK: - Sender delegate methods
    func didNotSendData(error: NSError) {
        presentAlert(title: "Error!", message: "Couldn't send message.")
    }
    
    // MARK: - GCDAsyncSocket delegate methods
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        sock.readData(withTimeout: -1, tag: 0)
        let message = String(data: data, encoding: .utf8)
        
        if message != nil {
            let mess = (message!).components(separatedBy: "|-|")
            messages.append("\(mess[1]): \(mess[0])")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        TCPsocket = newSocket
        TCPsocket.readData(withTimeout: -1, tag: 0)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        TCPsocket = socketSaved
    }
    
    // MARK: - KeyboardToolbar customize methods
    func setDoneOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        self.messageTextField.inputAccessoryView = keyboardToolbar
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - TableView delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        let row = indexPath.row
        
        let label = cell.viewWithTag(1001) as! UILabel
        label.text = (messages[row])
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

}
