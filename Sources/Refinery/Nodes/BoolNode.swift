//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import os.log


public final class BoolNode: RefineryNode {
    
    // MARK: Internal
    
    @Published var isAllOption: Bool = false
    @Published var isSelected: Bool = false {
        didSet {
            findRoot().initialLinkEvaluation()
            
        }
    }
    
    // MARK: Private
    
    let logger = Logger(subsystem: "io.hiddenspectrum.refinery", category: "BoolNode")
    
    // MARK: Lifecycle
    
    public init(title: String, isAllOption: Bool = false) {
        self.isAllOption = isAllOption
        super.init(title: title)
    }
    
    // MARK: Node Config
    
    override func evaluateNonStandardLink(_ link: NodeLink, targetNode: RefineryNode) {
        switch (link.condition, link.action) {
        case (.selected, .show):
            targetNode.isVisible = isSelected
        case (.selected, .hide):
            targetNode.isVisible = !isSelected
        default:
            logger.warning("Unhandled link: \(link.debugDescription)")
        }
    }
    
    override func reset() {
        // todo
    }
    
    override func updateValue<Store>(in store: inout Store) where Store: RefineryStore {
        guard let storeKeyPath else {
            return
        }
        store.update(isSelected, at: storeKeyPath)
    }
}
