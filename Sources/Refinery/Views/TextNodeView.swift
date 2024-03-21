//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import SwiftUI


struct TextNodeView: View {
    
    // MARK: Internal
    
    @StateObject var node: TextNode
    
    @State var showResults: Bool = false
    
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
                    .overlay(alignment: .trailing) {
                        clearButton()
                    }
                    .frame(maxWidth: .infinity)
                searchResults()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(8)
        }
//        .onReceive(
//            node.textPublisher
//                .removeDuplicates()
//                .debounce(for: 0.25, scheduler: DispatchQueue.main)
//        ) { _ in
//            Task { await node.searchHandler?(node.text) }
//        }
        .onChange(of: node.text) { newValue in
            Task {
                await node.search(with: newValue)
                showResults = true
            }
        }
    }
    
    @ViewBuilder
    private func clearButton() -> some View {
        if !node.text.isEmpty {
            Button {
                node.text = ""
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private func searchResults() -> some View {
        if !node.text.isEmpty && !node.searchResults.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(node.searchResults, id: \.self) { result in
                    Divider()
                        .foregroundColor(.blue)
                    Text(result)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}
