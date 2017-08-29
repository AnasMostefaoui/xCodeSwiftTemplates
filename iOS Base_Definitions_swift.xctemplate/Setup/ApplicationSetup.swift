//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  ___COPYRIGHT___
//

import Foundation
import UIKit

final class ApplicationSetup {

    static let instance = ApplicationSetup()
    private var didSetup:Bool = false
    
    private init() {

    }
    
    func setup(launchOptions:[UIApplicationLaunchOptionsKey: Any]?) {
        guard didSetup == false else {
            fatalError("The Application has already been setup")
        }

        // do any setup here
        
        NetworkAvailabilityManager.instance.setup()

        didSetup = true
    }
}
