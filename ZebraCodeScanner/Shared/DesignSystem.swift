//
//  DesignSystem.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import SwiftUI
import UIKit

enum DesignColors {
    // Light: #F8F8FA, Dark: #1C1C1E
    static let background = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0x1C/255, green: 0x1C/255, blue: 0x1E/255, alpha: 1)
            : UIColor(red: 0xF8/255, green: 0xF8/255, blue: 0xFA/255, alpha: 1)
    })

    // Light: #1E1E1E, Dark: #FFFFFF
    static let primaryText = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? .white
            : UIColor(red: 0x1E/255, green: 0x1E/255, blue: 0x1E/255, alpha: 1)
    })

    // Light: #F0F0F0, Dark: #3A3A3C
    static let stroke = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0x3A/255, green: 0x3A/255, blue: 0x3C/255, alpha: 1)
            : UIColor(red: 0xF0/255, green: 0xF0/255, blue: 0xF0/255, alpha: 1)
    })

    // #808080 (same in both modes)
    static let secondaryText = Color(red: 0x80/255, green: 0x80/255, blue: 0x80/255)

    // Light: #EAEAEA, Dark: #3A3A3C
    static let lightText = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0x3A/255, green: 0x3A/255, blue: 0x3C/255, alpha: 1)
            : UIColor(red: 0xEA/255, green: 0xEA/255, blue: 0xEA/255, alpha: 1)
    })

    // #A8A8A8 (same in both modes)
    static let inactive = Color(red: 0xA8/255, green: 0xA8/255, blue: 0xA8/255)

    // Card/container backgrounds: Light: white, Dark: #2C2C2E
    static let cardBackground = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0x2C/255, green: 0x2C/255, blue: 0x2E/255, alpha: 1)
            : .white
    })

    // Text on primary buttons: Light: white, Dark: #1E1E1E
    static let primaryButtonText = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0x1E/255, green: 0x1E/255, blue: 0x1E/255, alpha: 1)
            : .white
    })
}
