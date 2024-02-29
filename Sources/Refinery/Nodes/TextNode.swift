//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import SwiftUI


public final class TextNode: RefineryNode {
    
    // MARK: Internal
    
    @Published var text: String = ""
    
    // MARK: Lifecycle
    
    public init(_ title: String) {
        super.init(title: title)
    }
    
    // MARK: RefineryNode
    
    override var hasValue: Bool {
        !text.isEmpty
    }
    
    override var isInInitialState: Bool {
        !hasValue
    }
    
    override func updateValue<Store>(in store: inout Store) where Store: RefineryStore {
        guard let storeKeyPath else {
            return
        }
        let storeValue = text.isEmpty ? nil : text
        store.update(storeValue, at: storeKeyPath)
    }
    
    override func reset() {
        text = ""
    }
}
