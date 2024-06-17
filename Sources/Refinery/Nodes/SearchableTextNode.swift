//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Combine
import Foundation


public protocol SearchableTextNodeResult {
    var storeValue: String { get }
    var displayValue: String { get }
}


public final class SearchableTextNode: TextNode {
    
    // MARK: Public
    
    public typealias SearchHandler = (String) async -> [any SearchableTextNodeResult]
    
    // MARK: Internal
    
    @Published var searchResultsFetched: Bool = false
    @Published var selectedResult: (any SearchableTextNodeResult)?
    @Published var searchResults: [any SearchableTextNodeResult] = []
    
    let textPublisher = PassthroughSubject<String, Never>()
    
    var searchResultSelected: Bool {
        selectedResult != nil
    }
    
    // MARK: Private
    
    private var searchHandler: SearchHandler
    
    // MARK: Lifecycle
    
    public init(_ title: String, searchHandler: @escaping SearchHandler) {
        self.searchHandler = searchHandler
        super.init(title)
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
    
    override func updateValue<Store>(in store: inout Store) where Store: RefineryStore {
        guard let storeKeyPath else {
            return
        }
        store.update(selectedResult?.storeValue, at: storeKeyPath)
    }
    
    override func reset() {
        super.reset()
        clear()
    }
    
    // MARK: TextNode
    
    override func clear() {
        super.clear()
        searchResultsFetched = false
        selectedResult = nil
        searchResults = []
    }
    
    // MARK: Search
    
    @MainActor
    func search(query: String) async {
        if selectedResult != nil {
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
