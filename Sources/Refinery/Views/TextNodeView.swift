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
        Section(
            header: Text(node.title).font(.caption)
        ) {
            TextField(node.title, text: $node.text)
                .autocorrectionDisabled()
                .overlay(alignment: .trailing) {
                    clearButton()
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
}
