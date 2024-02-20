//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Combine
import SwiftUI


public final class Refinery<Store: RefineryStore>: ObservableObject {
    
    // MARK: Public
    
    public typealias ApplyClosure = ((Store) async -> Void)
    public typealias StoreUpdatedClosure = ((Store) async -> Int?)
    
    // MARK: Public private(set)
    
    public private(set) var currentStore = Store()
    
    // MARK: Internal
    
    @Published var estimatedItemsCount: Int?
    @Published var root: RefineryNode
    
    var showSeeResultsButton: Bool {
        storeUpdatedHandler != nil
    }
    
    // MARK: Private(set)
    
    private(set) var cancellables: [AnyCancellable] = []
    
    // MARK: Private
    
    @Published private var requestUpdate: Bool = false
    
    private var applyHandler: ApplyClosure?
    private var storeUpdatedHandler: StoreUpdatedClosure?
    
    
    // MARK: Lifecycle
    
    public init(_ title: String, @RefineryBuilder _ builder: () -> [RefineryNode]) {
        root = RefineryNode(title: title, children: builder())
        setRootObservers()
    }
    
    // MARK: Setup
    
    public func updateRootBuilder(title: String, @RefineryBuilder _ builder: () -> [RefineryNode]) {
        root = RefineryNode(title: title, children: builder())
        setRootObservers()
    }
    
    private func setRootObservers() {
        root.migrateLinks()
        root.evaluateAllLinks()
        root.objectWillChange
            .sink { [unowned self] in
                self.objectWillChange.send()
                DispatchQueue.main.async { [weak self] in
                    self?.updateStore()
                }
            }
            .store(in: &cancellables)
        
        $requestUpdate
            .debounce(for: 0.15, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] _ in self.fetchCount() })
            .store(in: &cancellables)
    }
    
    // MARK: Configuration
    
    @discardableResult
    public func onStoreUpdated(_ storeUpdatedHandler: @escaping StoreUpdatedClosure) -> Self {
        self.storeUpdatedHandler = storeUpdatedHandler
        return self
    }
    
    @discardableResult
    public func onApply(_ applyHandler: @escaping ApplyClosure) -> Self {
        self.applyHandler = applyHandler
        return self
    }
    
    // MARK: Data Storage
    
    private func updateStore() {
        for node in root.children {
            node.updateValue(in: &currentStore)
        }
        requestUpdate = true
    }
    
    private func fetchCount() {
        guard requestUpdate else {
            return
        }
        Task { @MainActor in
            estimatedItemsCount = await storeUpdatedHandler?(currentStore)
            requestUpdate = false
        }
    }
    
    // MARK: Refinery Control
    
    func apply() {
        Task { @MainActor in
            await applyHandler?(currentStore)
        }
    }
    
    func reset() {
        root.children.forEach { $0.reset() }
    }
    
    // MARK: Quick Filter Bar
    
    func quickFilterNodes() -> [RefineryNode] {
        let nodes = root.quickFilterNodes(using: [])
        return nodes.sorted(by: { lhs, rhs in
            (lhs.quickFilterBarPosition ?? 0) < (rhs.quickFilterBarPosition ?? 0)
        })
    }
    
    // MARK: Helpers
    
    public func filter(matchingID id: any RawRepresentable<Int>) -> RefineryNode? {
        root.filter(matchingID: id)
    }
}
