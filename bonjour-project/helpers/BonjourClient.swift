//

import Foundation
import UIKit
import AVKit

class BonjourClient: NSObject, BonjourConnectionDelegate {
    
    var message: Observable<Message?> = Observable(nil)
    
    @available(iOS 13.0, *)
    func connection(connection: BonjourConnection, responce res: BonjourResponse, context: String?) {
        if let context = context, context == "push" {

            guard let msg = try? Message(jsonData: res.body!) else {
                if UIImage(data: res.body!) != nil {
                    message.value = Message(sender: res.headers["image-sender"] ?? "sender", message: "", timestamp: Date(), type: .IMAGE, mediaData: res.body!)
                } else {
                    message.value = Message(sender: res.headers["image-sender"] ?? "sender", message: "", timestamp: Date(), type: .VIDEO, mediaData: res.body!)
                }
                return
            }

            message.value = msg
        } else {
            print("unhandled response \(res)")
        }
    }
}

extension Data {
    func getAVAsset() -> AVAsset {
        let directory = NSTemporaryDirectory()
        let fileName = "\(NSUUID().uuidString).mov"
        let fullURL = NSURL.fileURL(withPathComponents: [directory, fileName])
        try! self.write(to: fullURL!)
        let asset = AVAsset(url: fullURL!)
        return asset
    }
}
