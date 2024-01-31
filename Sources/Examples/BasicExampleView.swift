//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Refinery
import SwiftUI


class BasicStore: RefineryStore {
    var state: String?
}


struct BasicExampleView: View {
    
    // MARK: Private
    
    @StateObject private var viewModel = ViewModel()
    
    // MARK: View
    
    var body: some View {
        Text("Hello, World!")
    }
}

extension BasicExampleView {
    
    final class ViewModel: ObservableObject {
        
        let refinery: Refinery<BasicStore>
        let store = BasicStore()
        
        init() {
            self.refinery = Refinery(store: store) {
                Refiner(storeKey: \BasicStore.state) {
                    RefinerOption(value: "Option 1")
                    RefinerOption(value: "Option 2")
                }
            }
        }
    }
}

#Preview {
    BasicExampleView()
}
