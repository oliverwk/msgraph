//
//  SettingsBundleHelper.swift
//
//  Created by Olivier Wittop Koning on 03/06/2021.
//

import Foundation

class SettingsBundleHelper {
    struct SettingsBundleKeys {
        static let debug_msg = "debug_toggle"
    }
    class func checkAndExecuteSettings() {
        print(SettingsBundleKeys.debug_msg)
        if SettingsBundleKeys.debug_msg {
            UserDefaults.standard.set(true, forKey: "debug_msg")
        }
    }
}
