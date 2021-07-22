//
//  ViewController.swift
//  lalzumayaApp
//
//  Created by Lujain Z on 20/07/2021.
//

import UIKit
import Starscream

class homeViewController: UIViewController, WebSocketDelegate {
    
    var socket: WebSocket!
    let server = WebSocketServer()
    var socketConnected = false
    let AlertService = alertService()
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var conectButton: UIButton!
    @IBOutlet weak var connectionStatusLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if networkMonitor.shared.isConnected{
            print("connected")
        }else{
            let alertVC = AlertService.alert(title: "No Internet Connection", message: "Check your network settings and try agin.")
            present(alertVC, animated: true)
        }
        
        connectionStatusLabel.text = "Disconnected to webscoket"
        
    }
    
    @IBAction func connectTapped(_ sender: Any) {
        
        if socketConnected {
            socket.disconnect()
            conectButton.setTitle("Connect", for: .normal)
            connectionStatusLabel.text = "Disconnected to webscoket."
        } else {
            var request = URLRequest(url: URL(string: "wss://echo.websocket.org/")!)
            request.timeoutInterval = 5
            socket = WebSocket(request: request)
            socket.delegate = self
            
            socket.connect()
            connectionStatusLabel.text = "Connected to webscoket!!"
            conectButton.setTitle("Disconnect", for: .normal)
        }
    }
    
    @IBAction func sendMessageTapped(_ sender: Any) {
        if socketConnected{
            socket.write(string: messageTextField.text!)
            messageTextField.text = ""
        }
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            socketConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            socketConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            let alertVC = AlertService.alert(title: "Received text!", message: string)
            present(alertVC, animated: true)
            print("Received text: \(string)")
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            socketConnected = false
        case .error(let error):
            socketConnected = false
            handleError(error)
        }
    }
    
    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            print("websocket encountered an error: \(e.message)")
        } else if let e = error {
            print("websocket encountered an error: \(e.localizedDescription)")
        } else {
            print("websocket encountered an error")
        }
    }
}

