//
//  View+Extension.swift
//
//
//  Created by Lê Quang Trọng Tài on 12/31/23.
//

import Foundation
import SwiftUI

extension View {
    func maxWidthAble() -> some View {
        frame(maxWidth: .infinity)
    }

    func maxHeightAble() -> some View {
        frame(maxHeight: .infinity)
    }

    func frameInfinity() -> some View {
        self
            .maxWidthAble()
            .maxHeightAble()
    }
}
