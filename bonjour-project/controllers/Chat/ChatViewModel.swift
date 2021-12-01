//
//  ChatViewModel.swift
//  bonjour-project
//
//  Created by Fitzgerald Afful on 22/11/2021.
//

import Foundation

class ChatViewModel {

    var host = false
    var service: NetService?
    var username: String?

    var connection: BonjourConnection?
    let client = BonjourClient()
    var hostServer: BonjourServer?
    var bonjourService: BonjourService?
    var hostName: String?

    var messagesList: Observable<[Message]> =  Observable([Message]())

    func connectToService() {
        connection = BonjourConnection(service!, uName: username!)
        connection?.delegate = client
        connection?.connect()
    }

    func sendMessageFromServer(_ message: Message) {
        if let socket = hostServer!.clients.first {
            do {
                let messageData = try! message.toJsonData()
                var res = BonjourResponse(context: "push")
                res.setBody(data: messageData)
                bonjourService?.send(responce: res, to: socket)
                messagesList.value.append(message)
            }
        }
    }

    func sendMessageFromClient(_ message: Message) {
        do {
            let messageData = try! message.toJsonData()
            var req = BonjourRequest(path: "/", method: .Post)
            req.setBody(data: messageData)
            connection!.send(req: req)
            messagesList.value.append(message)
        }
    }

    func sendDataFromServer(_ message: Message) {
        if let socket = hostServer!.clients.first {
            do {
                var res = BonjourResponse(context: "push")
                res.setBody(data: message.mediaData!)
                res.setValue(message.sender, forHTTPHeaderField: "image-sender")
                res.setValue(message.message, forHTTPHeaderField: "image-message")
                res.setValue(message.timestamp.formatted(), forHTTPHeaderField: "image-timestamp")
                res.setValue("\(message.type.rawValue)", forHTTPHeaderField: "image-type")
                bonjourService?.send(responce: res, to: socket)
                messagesList.value.append(message)
            }
        }
    }

    func sendDataFromClient(_ message: Message) {
        do {
            var req = BonjourRequest(path: "/image", method: .Post)
            req.setBody(data: message.mediaData!, type: "image/png")
            req.setValue(message.sender, forHTTPHeaderField: "image-sender")
            req.setValue(message.message, forHTTPHeaderField: "image-message")
            req.setValue(message.timestamp.formatted(), forHTTPHeaderField: "image-timestamp")
            req.setValue("\(message.type.rawValue)", forHTTPHeaderField: "image-type")
            connection!.send(req: req)
            messagesList.value.append(message)
        }
    }
}
