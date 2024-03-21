//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import SwiftUI


struct TextNodeView: View {
    
    // MARK: Internal
    
    @StateObject var node: TextNode
    
    @State var searchCompleted: Bool = false
    
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
                    .disabled(searchCompleted)
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
        .onReceive(
            node.textPublisher
                .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
        ) { _ in
            guard !searchCompleted else {
                return
            }
            Task {
                await node.search(query: node.text)
            }
        }
//        .onChange(of: node.text) { newValue in
//            Task {
//                guard !searchCompleted else {
//                    return
//                }
//                await node.search(query: newValue)
//            }
//        }
    }
    
    @ViewBuilder
    private func clearButton() -> some View {
        if !node.text.isEmpty {
            Button {
                node.text = ""
                searchCompleted = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private func searchResults() -> some View {
        if !searchCompleted && !node.text.isEmpty && !node.searchResults.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(node.searchResults, id: \.self) { result in
                    Divider()
                        .foregroundColor(.blue)
                    Button {
                        searchCompleted = true
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
