//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import SwiftUI


public final class TextNode: RefineryNode {
    
    // MARK: Internal
    
    @Published var text: String = ""
    
    // MARK: Lifecycle
    
    public init(title: String) {
        super.init(title: title)
    }
    
    // MARK: RefineryNode
    
    override var hasSelections: Bool {
        !text.isEmpty
    }
    
    override func setupObservers() {
        super.setupObservers()
        $text
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                findRoot().evaluateAllLinks()
            }
            .store(in: &cancellables)
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
