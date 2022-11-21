//
//  WeakObjects.swift
//  DelegatePublisher
//
//  Created by 구본욱 on 2022/11/21.
//

import Foundation

class WeakObject<T: AnyObject> {
    private(set) weak var value: T?

    init(_ value: T) {
        self.value = value
    }
}

@propertyWrapper
struct WeakCollection<Element> where Element: AnyObject {
    private var storage = [WeakObject<Element>]()

    var wrappedValue: [Element] {
        get {
            storage.compactMap { $0.value }
        }
        set {
            storage = newValue.map { WeakObject($0) }
        }
    }
}
