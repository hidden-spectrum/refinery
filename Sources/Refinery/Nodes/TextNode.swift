//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Combine
import Foundation
import SwiftUI


public final class TextNode: RefineryNode {
    
    // MARK: Public
    
    public typealias SearchHandler = (String) async -> [String]
    
    // MARK: Internal
    
    @Published var searchResultsFetched: Bool = false
    @Published var searchResultSelected: Bool = false
    @Published var searchResults: [String] = []
    @Published var text: String = ""
    
    let textPublisher = PassthroughSubject<String, Never>()
    
    // MARK: Private
    
    private var searchHandler: SearchHandler?
    
    // MARK: Lifecycle
    
    public init(_ title: String) {
        super.init(title: title)
        $text
            .removeDuplicates()
            .debounce(for: .seconds(0.25), scheduler: RunLoop.main)
            .sink { [unowned self] query in
                Task { @MainActor in
                    await self.search(query: query)
                }
            }
            .store(in: &cancellables)
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
    
    // MARK: Search
    
    public func searchable(handler searchHandler: @escaping SearchHandler) -> Self {
        self.searchHandler = searchHandler
        return self
    }
    
    func clear() {
        text = ""
        searchResultsFetched = false
        searchResultSelected = false
        searchResults = []
    }
    
    @MainActor
    func search(query: String) async {
        guard let searchHandler else {
            return
        }
        
        if searchResultSelected {
            return
        }
        if query.isEmpty {
            searchResults = []
            searchResultsFetched = false
            return
        }
        let results = await searchHandler(query)
        searchResults = Array(results.prefix(5))
        searchResultsFetched = true
    }
}
