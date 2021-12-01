

import Foundation

enum MESSAGE_TYPE: Int {
    case TEXT = 1
    case IMAGE = 2
    case VIDEO = 3
}

struct Message {

    static let SENDER_KEY = "sender"
    static let MESSAGE_KEY = "message"
    static let TIMESTAMP_KEY = "timestamp"
    static let MESSAGE_TYPE_KEY = "messageType"
    static let MEDIA_DATA_KEY = "data"
    
    let sender: String
    let message: String
    let timestamp: Date
    let type: MESSAGE_TYPE
    let mediaData: Data?
    
    init(sender: String, message: String, timestamp: Date, type: MESSAGE_TYPE, mediaData: Data? = nil) {
        self.sender = sender
        self.message = message
        self.timestamp = timestamp
        self.type = type
        self.mediaData = mediaData
    }
    
    init(jsonData: Data) throws {
        var sender = ""
        var message = ""
        var timestamp = Date()
        var type: MESSAGE_TYPE = .TEXT
        var data: Data? = nil
        if let dict = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as? NSDictionary {
            sender = dict[Message.SENDER_KEY] as? String ?? ""
            message = dict[Message.MESSAGE_KEY] as? String ?? ""
            type = dict[Message.MESSAGE_TYPE_KEY] as? MESSAGE_TYPE ?? MESSAGE_TYPE.TEXT
            if let interval = dict[Message.TIMESTAMP_KEY] as? TimeInterval {
                timestamp = Date(timeIntervalSince1970: interval / 1000)
            }
            data = dict[Message.MEDIA_DATA_KEY] as? Data ?? nil
        } else {
            print("Error")
        }
        self.sender = sender
        self.message = message
        self.timestamp = timestamp
        self.type = type
        self.mediaData = data
    }
    
    func toDict() throws -> Dictionary<String, Any> {
        var dict = Dictionary<String, Any>()
        dict[Message.SENDER_KEY] = self.sender
        dict[Message.MESSAGE_KEY] = self.message
        dict[Message.MESSAGE_TYPE_KEY] = self.type.rawValue
        dict[Message.TIMESTAMP_KEY] = (Int) (self.timestamp.timeIntervalSince1970 * 1000)
        return dict
    }

    func toJsonData() throws -> Data {
        let object = try toDict()
        return try JSONSerialization.data(withJSONObject: object, options: .fragmentsAllowed)
    }
}
