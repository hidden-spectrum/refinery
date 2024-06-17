//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import SwiftUI


struct SearchableTextNodeView: View {
    
    // MARK: Private
    
    @StateObject private var node: SearchableTextNode
    
    // MARK: Lifecycle
    
    init(with node: SearchableTextNode) {
        _node = StateObject(wrappedValue: node)
    }
    
    // MARK: View
    
    var body: some View {
        TextNodeView(with: node, disabled: node.searchResultSelected) {
            searchResults()
        }
    }
    
    @ViewBuilder
    private func searchResults() -> some View {
        if !node.searchResultSelected && node.searchResultsFetched {
            VStack(alignment: .leading, spacing: 12) {
                if node.searchResults.isEmpty {
                    Text("No results found")
                } else {
                    ForEach(node.searchResults, id: \.storeValue) { result in
                        searchResultRow(with: result)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func searchResultRow(with result: any SearchableTextNodeResult) -> some View {
        Divider()
        Button {
            node.selectedResult = result
            node.text = result.displayValue
        } label: {
            Text(result.displayValue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
    }
}
