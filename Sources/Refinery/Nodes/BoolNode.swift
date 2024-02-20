//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import os.log


public final class BoolNode: RefineryNode {
    
    // MARK: Internal
    
    @Published var isAllOption: Bool = false
    @Published var isSelected: Bool = false
    
    // MARK: Intenral private(set)
    
    private(set) var storeValue: String?
    
    // MARK: Private
    
    private let logger = Logger(subsystem: "io.hiddenspectrum.refinery", category: "BoolNode")
    
    private var initialState: Bool = false
    
    // MARK: Lifecycle
    
    public init(title: String, isAllOption: Bool = false) {
        self.isAllOption = isAllOption
        self.storeValue = title.lowercased()
        super.init(title: title)
    }
    
    // MARK: RefineryNode
    
    override func setupObservers() {
        super.setupObservers()
        if parent is SelectionGroup {
            return
        }
        $isSelected
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                findRoot().evaluateAllLinks()
            }
            .store(in: &cancellables)
    }
    
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
        isSelected = initialState
    }
    
    override func updateValue<Store>(in store: inout Store) where Store: RefineryStore {
        guard let storeKeyPath else {
            return
        }
        store.update(isSelected, at: storeKeyPath)
    }
    
    // MARK: Config
    
    public func initialSelection() -> Self {
        isSelected = true
        initialState = true
        return self
    }
    
    public func value<T>(_ rawRepresentable: T) -> Self where T: RawRepresentable, T.RawValue == String {
        storeValue = rawRepresentable.rawValue
        return self
    }
    
    public func value(_ value: String) -> Self {
        storeValue = value
        return self
    }
}
