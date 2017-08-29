//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  ___COPYRIGHT___
//
import UIKit

/// Protocol for listenig network status change
public protocol NetworkStatusListener : class {
    func networkStatusDidChange(status: SwiftReachability.NetworkStatus)
}

final class NetworkAvailabilityManager : NSObject {
    
    static let instance = NetworkAvailabilityManager()
    let reachability = SwiftReachability(hostname: "google.com")!
    private var observers:[WeakReferance<AnyObject>] = []
    
    private override init() {
        super.init()
    }
    
    deinit {
        self.stopMonitoring()
    }
    
    @objc func reachabilityChanged(notification: Notification) {
        guard let reachability = notification.object as? SwiftReachability else {
            return
        }
        
        switch reachability.currentReachabilityStatus {
        case .notReachable:
            debugPrint("Network became unreachable")
        case .reachableViaWiFi:
            debugPrint("Network reachable through WiFi")
        case .reachableViaWWAN:
            debugPrint("Network reachable through Cellular Data")
        }
        
        for listner in self.observers {
            guard let delegate = listner.value as? NetworkStatusListener else {
                debugPrint("Observer contains a none NetworkStatusListener object")
                continue
            }
            delegate.networkStatusDidChange(status: reachability.currentReachabilityStatus)
        }
    }
    
    func startMonitoring() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NetworkAvailabilityManager.reachabilityChanged),
                                               name: reachabilityChangedNotification,
                                               object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            debugPrint("Could not start reachability notifier")
        }
    }
    
    func stopMonitoring() {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: reachabilityChangedNotification,
                                                  object: reachability)
    }
    
    func addListner(listner:AnyObject, shouldNotifyNow:Bool = false) {
        guard let validListner = listner as? NetworkStatusListener else {
            fatalError("Trying to add an object that does not conform to NetworkStatusListener protocol")
        }
        let found = self.observers.filter { containedObject -> Bool in
            containedObject.value === listner
        }
        
        guard found.isEmpty == true else {
            debugPrint("Adding object to listner ignored, because the object already exist")
            return
        }
        self.observers.append(WeakReferance(value: listner))
        if shouldNotifyNow {
            validListner.networkStatusDidChange(status: reachability.currentReachabilityStatus)
        }
    }
    
    func removeListner(listner:AnyObject) {
        guard (listner as? NetworkStatusListener) != nil else {
            fatalError("Trying to remove an object that does not conform to NetworkStatusListener protocol")
        }
        let foundListner = self.observers.filter { containedObject -> Bool in
            containedObject.value === listner
        }
        
        guard foundListner.isEmpty == false else {
            debugPrint("trying to remove an none exiting object")
            return
        }
        
        for item  in foundListner {
            item.value = nil
        }
        
        self.observers.removeNilReferance()
    }
}
