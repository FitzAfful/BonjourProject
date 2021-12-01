//
//  BonjourConnection.swift
//  mmRemote
//
//  Created by SATOSHI NAKAJIMA on 12/26/20.
//

import Foundation

extension NetService : Identifiable {
}

@available(iOS 13.0, *)
public class BonjourBrowser: NSObject, ObservableObject {
    let type: String
    private var serviceBrowser = NetServiceBrowser()
    public var services: Observable<[NetService]> = Observable([NetService]())
    
    public init(_ type: String) {
        self.type = type
    }

    public func start() {
        print("Bonjour service did start)")
        services.value.removeAll()
        serviceBrowser.delegate = self
        serviceBrowser.schedule(in: .main, forMode: .common)
        serviceBrowser.searchForServices(ofType: type, inDomain: "local.")
    }
}

@available(iOS 13.0, *)
extension BonjourBrowser : NetServiceBrowserDelegate {
    public func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("BonjourBrowser:netServiceBrowser:didFind \(service)")
        services.value.append(service)
    }
    
    public func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        services.value = services.value.filter { $0 != service }
        print("BonjourBrowser:netServiceBroser:didRemove \(service), \(services.value.count)")
    }
    
    public func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        print("BonjourBrowser:netServiceBrowserDidStopSearch")
    }
    
    public func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("BonjourBrowser:netServiceBrowser:didNotSearch \(errorDict)")
    }
}
