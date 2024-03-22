//
//  Copyright © 2024 Hidden Spectrum, LLC.
//

import SwiftUI


public struct RefineryStyle {
    
    // MARK: Internal
    
    public var backgroundColor: Color?
    public var bodyFont: Font?
    public var fieldBackgroundColor: Color?
    public var captionFont: Font?
    
    // MARK: Lifecycle
    
    public init() {
    }
}


struct RefineryStyleKey: EnvironmentKey {
    static let defaultValue: RefineryStyle = RefineryStyle()
}

extension EnvironmentValues {
    var style: RefineryStyle {
        get { self[RefineryStyleKey.self] }
        set { self[RefineryStyleKey.self] = newValue }
    }
}
