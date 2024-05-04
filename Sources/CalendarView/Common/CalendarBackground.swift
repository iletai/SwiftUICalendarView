//
//  CalendarBackground.swift
//
//
//  Created by Lê Quang Trọng Tài on 5/4/24.
//

import Foundation
import SwiftUI

/// An enumeration representing the background options for a calendar view.
public enum CalendarBackground {
    /// The background is hidden.
    case hidden
    /// The background is visible with a specific opacity and color.
    case visible(CGFloat, Color)
    /// The background is an image with the specified name.
    case image(String)
}
