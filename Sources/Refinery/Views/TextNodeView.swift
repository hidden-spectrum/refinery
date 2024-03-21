//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import SwiftUI


struct TextNodeView: View {
    
    // MARK: Internal
    
    @StateObject var node: TextNode
    
    // MARK: Lifecycle
    
    init(with node: TextNode) {
        _node = StateObject(wrappedValue: node)
    }
    
    // MARK: View
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(node.title.uppercased())
                .font(.caption)
                .offset(x: 16)
            VStack {
                TextField(node.title, text: $node.text)
                    .autocorrectionDisabled()
                    .disabled(node.searchResultSelected)
                    .overlay(alignment: .trailing) {
                        clearButton()
                            .disabled(false)
                    }
                    .frame(maxWidth: .infinity)
                searchResults()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(8)
        }
    }
    
    @ViewBuilder
    private func clearButton() -> some View {
        if !node.text.isEmpty {
            Button {
                node.clear()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private func searchResults() -> some View {
        if !node.searchResultSelected && node.searchResultsFetched {
            VStack(alignment: .leading, spacing: 12) {
                if node.searchResults.isEmpty {
                    Text("No results found")
                } else {
                    ForEach(node.searchResults, id: \.self) { organizationName in
                        searchResultRow(with: organizationName)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func searchResultRow(with text: String) -> some View {
        Divider()
        Button {
            node.searchResultSelected = true
            node.text = text
        } label: {
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
    }
}
