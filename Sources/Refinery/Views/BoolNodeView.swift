//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import SwiftUI


struct BoolNodeView: View {
    
    // MARK: Internal
    
    @StateObject var node: BoolNode
    
    // MARK: Lifecycle
    
    init(with node: BoolNode) {
        _node = StateObject(wrappedValue: node)
    }
    
    // MARK: View
    
    var body: some View {
        Toggle(node.title, isOn: $node.isSelected)
    }
}
