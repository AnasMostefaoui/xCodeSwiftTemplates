//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  ___COPYRIGHT___
//
import UIKit

final class WeakReferance<T: AnyObject> {
    weak var value : T?
    init (value: T) {
        self.value = value
    }
}

extension Array where Element:WeakReferance<AnyObject> {
    mutating func removeNilReferance () {
        self = self.filter { nil != $0.value }
    }
}
