//
//  Locale+Extension.swift
//
//
//  Created by Lê Quang Trọng Tài on 12/30/23.
//

import Foundation
import SwiftDate

extension Locale: LocaleConvertible {
    static var vietnam: Locale {
        Locales.vietnamese.toLocale()
    }
}
