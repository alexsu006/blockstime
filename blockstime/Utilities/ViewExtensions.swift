//
//  ViewExtensions.swift
//  LegoTimePlanner
//
//  Created by Claude on 2025-11-02.
//

import SwiftUI

extension View {
    /// 條件性地應用 modifier
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
