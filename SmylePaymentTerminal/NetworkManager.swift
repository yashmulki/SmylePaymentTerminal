//
//  NetworkManager.swift
//  SmylePaymentTerminal
//
//  Created by Yashvardhan Mulki on 2019-09-14.
//  Copyright © 2019 Yashvardhan Mulki. All rights reserved.
//

import Foundation
import Starscream

class NetworkManager: NSObject {
    
    var controllers: [String : MessagingProtocol] = [:]
    
    var socket: WebSocket?
    
    func configureSocket() {
       
        self.socket = WebSocket(url: URL(string: "ws://34.66.144.105/kiosk")!)
        //websocketDidConnect
        
        guard let socket = socket else {
            return
        }
        
        socket.onConnect = {
            print("websocket is connected")
        }
        //websocketDidDisconnect
        socket.onDisconnect = { (error: Error?) in
            print("websocket is disconnected: \(error?.localizedDescription)")
        }
        //websocketDidReceiveMessage
        socket.onText = { (text: String) in
            print("got some text: \(text)")
            
            if text.contains("payment") {
                
                
//                if let loyaltyEnrollController = self.controllers["loyaltyenroll"] {
//                     loyaltyEnrollController.readMessage(message: text)
//                } else if let loyaltyCancelControler = self.controllers["loyaltycancel"] {
//                     loyaltyCancelControler.readMessage(message: text)
//                } else {
                
                guard let controller = self.controllers["recognized"] else {
                    return
                }
                
                controller.readMessage(message: text)
                    
//                }
            
            } else if text.contains("Loyalty") {
                guard let controller = self.controllers["recognized"] else {
                    return
                }
                controller.readMessage(message: text)
            }
            
        }
        //websocketDidReceiveData
        socket.onData = { (data: Data) in
            print("got some data: \(data.count)")
        }
        //you could do onPong as well.
        socket.connect()
    }
    
    func sendMessage(message: String) {
        guard let socket = socket else {
            return
        }
        socket.write(string: message)
    }
    
}
