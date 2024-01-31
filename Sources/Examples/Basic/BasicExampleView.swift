//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Refinery
import SwiftUI


struct BasicExampleView: View {
    
    // MARK: Private
    
    @StateObject private var viewModel = ViewModel()
    
    // MARK: View
    
    var body: some View {
        Text("Hello, World!")
    }
}


#Preview {
    BasicExampleView()
}
