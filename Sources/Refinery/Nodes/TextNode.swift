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
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
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
    
    @MainActor
    func search(query: String) async {
        if query.isEmpty {
            searchResults = []
            return
        }
        let results = await searchHandler?(query) ?? []
        searchResults = results
    }
}
