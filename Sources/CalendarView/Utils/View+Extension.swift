//
//  View+Extension.swift
//
//
//  Created by Lê Quang Trọng Tài on 12/31/23.
//

import Foundation
import SwiftUI

extension View {
    public func maxWidthAble() -> some View {
        frame(maxWidth: .infinity)
    }

    public func maxHeightAble() -> some View {
        frame(maxHeight: .infinity)
    }

    public func frameInfinity() -> some View {
        maxWidthAble().maxHeightAble()
    }

    public func marginDefault() -> some View {
        padding(.all, 16)
    }

    public func withRounderConner(_ radius: CGFloat) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius))
    }
}
