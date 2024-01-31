//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import SwiftUI


struct BoolNodeView: View {
    
    // MARK: Internal
    
    @ObservedObject var node: BoolNode
    
    // MARK: Lifecycle
    
    init(with node: BoolNode) {
        self.node = node
    }
    
    // MARK: View
    
    var body: some View {
        HStack {
            Text("BoolNodeView")
        }
    }
}
