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
                    .disabled(node.searchCompleted)
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
                node.text = ""
                node.searchCompleted = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private func searchResults() -> some View {
        if !node.searchCompleted && !node.text.isEmpty && !node.searchResults.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(node.searchResults, id: \.self) { result in
                    Divider()
                        .foregroundColor(.blue)
                    Button {
                        node.searchCompleted = true
                        node.text = result
                    } label: {
                        Text(result)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
}
