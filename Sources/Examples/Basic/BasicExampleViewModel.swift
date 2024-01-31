//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import Foundation
import Refinery
import SwiftUI


extension BasicExampleView {
    
    final class ViewModel: ObservableObject {
        
        // MARK: Internal
        
        let refinery: Refinery<BasicStore>
        let store = BasicStore()
        
        static let stateOptions = ["CA", "TX"]
        
        // MARK: Lifecycle
        
        init() {
            self.refinery = Refinery(store: store) {
                SelectRefiner("State", storeKey: \BasicStore.state, mode: .single) {
                    for option in Self.stateOptions {
                        RefinerOption(option, value: option)
                    }
                }
                .hidden()
            }
        }
    }
}
