//
//  RequestNotificationPermissionExample.swift
//  QualtricsSDKSwiftUI
//
//  Created by Qualtrics on 25/02/2024.
//

import Foundation
import UIKit

/// This is a separate class so it's easy to read/find the right code snippet.
class RequestNotificationPermissionExample {

    /// This funciton will request the notification permisison to be granted. You need to call this function before you can use Notifications in your app.
    public func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                print("Qualtrics: notification authorisation request failed with error: \(error).")
                return
            }
            print("Qualtrics: Notifications permission granted.")
        }
    }
}
