//

import Foundation
import CocoaAsyncSocket

@available(iOS 13.0, *)
class BonjourServer : NSObject, BonjourServiceDelegate, ObservableObject {
    @Published public var clients = [GCDAsyncSocket]()
    @Published public var isRunning = false
    public var message: Observable<Message?> = Observable(nil)
    
    func serviceClientsDidChange(_ service: BonjourService) {
        clients = service.clients
    }

    func serviceRunningStateDidChange(_ service: BonjourService) {
        isRunning = service.isRunning
    }    

    func service(_ service: BonjourService, onCall: String, params: [String : Any], socket: GCDAsyncSocket, context: String) {
        switch(onCall) {
        case "foo":
            let delay = params["delay"] as? Double ?? 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                service.respond(to: socket, context: context, result: ["result": "How are you? \(delay)"])
            }
        default:
            service.respond(to: socket, context: context, result: ["error": "invalid function name"],
                            statusText: "404 Not found")
        }
    }
    
    func service(_ service: BonjourService, onRequest req: BonjourRequest, socket: GCDAsyncSocket, context: String) {
        var res = BonjourResponse(context: context)
        switch(req.path) {
        case "/":
            do {
                let msg = try! Message(jsonData: req.body!)
                message.value = msg
            }
        case "/image" where req.method == .Post:
            guard (try? Message(jsonData: req.body!)) != nil else {
                if UIImage(data: req.body!) != nil {
                    message.value = Message(sender: req.headers["image-sender"] ?? "sender", message: "", timestamp: Date(), type: .IMAGE, mediaData: req.body!)
                } else {
                    //a video
                    message.value = Message(sender: req.headers["image-sender"] ?? "sender", message: "", timestamp: Date(), type: .VIDEO, mediaData: req.body!)
                }
                return
            }
        default:
            res.setBody(string: "<html><body>Page Not Found</body></html>")
            res.statusText = "404 Not Found"
        }
        service.send(responce: res, to: socket)
    }
}
