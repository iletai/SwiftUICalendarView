//
//  CalendarView+Object.swift
//
//
//  Created by iletai on 30/11/2023.
//

import Foundation
import SwiftUI

public extension CalendarView {
    /// `Direction` determines the direction of the swipe gesture
    enum Direction {
        /// Swiping  from left to right
        case forward
        /// Swiping from right to left
        case backward
    }

    /// Define Status Enum Of Background Calendar
    enum BackgroundCalendar {
        /// Disable Background
        case hidden
        /// Visible (First: Radius Corner, Second: Background Color)
        case visible(CGFloat, Color)
    }

}
