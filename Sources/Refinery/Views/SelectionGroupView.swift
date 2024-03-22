//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import SwiftUI


struct SelectionGroupView: View {

    // MARK: Private
    
    @Environment(\.style) private var style
    
    @StateObject private var selectionGroup: SelectionGroup
    
    private let context: DisplayContext
    
    private var displayTitle: String {
        selectionGroup.selectedChildren.first?.title ?? "Select"
    }

    // MARK: Lifecycle

    init(for selectionGroup: SelectionGroup, context: DisplayContext = .fullView) {
        _selectionGroup = StateObject(wrappedValue: selectionGroup)
        self.context = context
    }
    
    // MARK: View
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(selectionGroup.title.uppercased())
                .font(style.captionFont)
                .offset(x: 16)
            Group {
                switch selectionGroup.style {
                case .inline:
                    inlineGroup()
                case .menu:
                    menuGroup()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(style.fieldBackgroundColor)
            .cornerRadius(8)    
        }
    }
    
    // MARK: Inline
    
    @ViewBuilder
    private func inlineGroup() -> some View {
        ForEach(selectionGroup.boolChildren) { option in
            optionRow(with: option)
        }
    }
    
    @ViewBuilder
    private func menuGroup() -> some View {
        Menu {
            ForEach(selectionGroup.boolChildren) { node in
                Button {
                    node.isSelected.toggle()
                } label: {
                    optionView(for: node)
                }
            }
        } label: {
            Text(displayTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    private func optionView(for node: BoolNode) -> some View {
        HStack {
            Text(node.title)
            Spacer()
            if node.isSelected {
                Image(systemName: "checkmark")
                    .font(.caption)
            }
        }
    }
    
    @ViewBuilder
    private func optionRow(with node: BoolNode) -> some View {
        optionView(for: node)
            .frame(minHeight: 24)
            .contentShape(Rectangle())
            .onTapGesture {
                node.isSelected.toggle()
            }
    }
}
