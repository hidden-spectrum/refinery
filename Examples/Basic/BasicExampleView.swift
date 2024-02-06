//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Refinery
import SwiftUI


struct BasicExampleView: View {
    
    // MARK: Private
    
    @State private var displayRefinery = false
    
    @StateObject private var viewModel = ViewModel()
    
    // MARK: View
    
    var body: some View {
        Button("Show Refinery") {
            displayRefinery.toggle()
        }
        .popover(isPresented: $displayRefinery, content: {
            RefineryView(with: viewModel.refinery, displayRefinery: $displayRefinery)
        })
    }
}


#Preview {
    BasicExampleView()
}
