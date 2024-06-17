//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import SwiftUI


struct TextNodeView<Content: View>: View {
    
    // MARK: Private
    
    @Environment(\.style) var style
    
    @StateObject private var node: TextNode
    
    typealias LowerContent = () -> Content
    
    private let disabled: Bool
    private let lowerContent: LowerContent
    
    // MARK: Lifecycle
    
    init(with node: TextNode, disabled: Bool, @ViewBuilder lowerContent: @escaping LowerContent = { EmptyView() }) {
        _node = StateObject(wrappedValue: node)
        self.disabled = disabled
        self.lowerContent = lowerContent
    }
    
    // MARK: View
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(node.title.uppercased())
                .font(style.captionFont)
                .offset(x: 16)
            VStack {
                TextField(node.title, text: $node.text)
                    .autocorrectionDisabled()
                    .disabled(disabled)
                    .overlay(alignment: .trailing) {
                        clearButton()
                            .disabled(false)
                            .offset(x: 4)
                    }
                    .frame(maxWidth: .infinity)
                lowerContent()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(style.fieldBackgroundColor)
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
}
