//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation


public protocol RefineryStore {
    init()
}

extension RefineryStore {
    mutating func update<Value>(_ value: Value?, at keyPath: AnyKeyPath) {
        if let referenceWritableOptionalKeyPath = keyPath as? ReferenceWritableKeyPath<Self, Value?> {
            self[keyPath: referenceWritableOptionalKeyPath] = value != nil ? value : nil
        } else if let value, let referenceWritableKeyPath = keyPath as? ReferenceWritableKeyPath<Self, Value> {
            self[keyPath: referenceWritableKeyPath] = value
        } else if let writableOptionalKeyPath = keyPath as? WritableKeyPath<Self, Value?> {
            self[keyPath: writableOptionalKeyPath] = value != nil ? value : nil
        } else if let value, let writableKeyPath = keyPath as? WritableKeyPath<Self, Value> {
            self[keyPath: writableKeyPath] = value
        } else if value == nil {
            return
        } else {
            assertionFailure("storeKeyPath: \(keyPath) must point to (Reference)WritableKeyPath<\(Self.self), \(Value.self)>")
        }
    }
}
