//
//  AppDelegate.swift
//  QualtricsSDKSwiftUI
//
//  Created by Qualtrics on 21/02/2023.
//

import Foundation
import UIKit
import Qualtrics

/// We need to implement `AppDelegate` in order to use Notifications.
class AppDelegate: NSObject, UIApplicationDelegate {
    /// 1. Assign the *UNUserNotificationCenter * a delegate
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            UNUserNotificationCenter.current().delegate = self
            return true
        }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    /// Set up a function that will recieve the Notifications.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("Qualtrics: Notification received \(notification.description)")
        completionHandler([.banner, .sound])
    }
    
    /// Set up a function that will handle the Notification that has just been recieved.
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        /// 1. Make sure to set up the right view controller first
        GettingRootViewControllerExample().getRootViewController(completion: { vc in
            /// 2. Ensure the view controller is not nil
            guard let vc = vc else {
                print("Qualtrics: the root view controller is nil. Cannot place notification.")
                return
            }
            /// 3. Call the Qualtrics API to handle notification.
            let _ = Qualtrics.shared.handleLocalNotification(notification, displayOn: vc)
        })
    }
}
