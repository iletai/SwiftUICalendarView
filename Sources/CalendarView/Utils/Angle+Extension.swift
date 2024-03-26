//
//  File.swift
//  
//
//  Created by Lê Quang Trọng Tài on 11/27/23.
//

import Foundation
import SwiftUI

public extension Angle {
    var isAlongXAxis: Bool {
        let degrees = ((Int(self.degrees.rounded()) % 360) + 360) % 360
        return degrees >= 330 || degrees <= 30 || (degrees >= 150 && degrees <= 210)
    }
}
