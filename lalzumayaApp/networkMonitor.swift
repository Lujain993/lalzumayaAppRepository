//
//  networkMonitor.swift
//  lalzumayaApp
//
//  Created by Lujain Z on 22/07/2021.
//

import Foundation
import Network

final class networkMonitor{
    static let shared = networkMonitor()
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    
    public private(set) var isConnected: Bool = false
    
    private init(){
        monitor = NWPathMonitor()
    }
    
    public func startMonitoring(){
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = {[weak self] path in
            self?.isConnected = path.status != .unsatisfied
            print(self?.isConnected ?? "N/A")
        }
    }
    public func stopMonitorin(){
        monitor.cancel()
    }
}
