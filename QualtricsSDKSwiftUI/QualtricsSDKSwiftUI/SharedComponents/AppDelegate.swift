//
//  AppDelegate.swift
//  QualtricsSDKSwiftUI
//
//  Created by Natalie Niziolek on 21/02/2023.
//

import Foundation
import UIKit
import Qualtrics

/// We need to implement AppDelegate in order to use notifications.
class AppDelegate: NSObject, UIApplicationDelegate {
    /// 1. Assign the UNUserNotificationCenter a delegate
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            UNUserNotificationCenter.current().delegate = self
            return true
        }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    /// Set up a function that will recieve the notifications.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("Qualtrics: Notification received \(notification.description)")
        completionHandler([.banner, .sound])
    }
    
    /// Set up a function that will handle the notification that has just been recieved.
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        /// 1. Make sure to set up the right view controller first
        self.getRootViewController(completion: { vc in
            /// 2. Ensure the view controller is not nil
            guard let vc = vc else {
                print("Qualtrics: the root view controller is nil. Cannot place notification.")
                return
            }
            /// 3. Call the Qualtrics API to handle notification.
            let _ = Qualtrics.shared.handleLocalNotification(notification, displayOn: vc)
        })
    }

    /// This is an example implementation of a function that will determine the viewController that is currently presenting views in the app.
    /// Before using this implementation please make note that this will only work if there are no multiple scenes displayed at once in your app (eg on iPad).
    private func getRootViewController(completion: @escaping (UIViewController?) -> Void) {
        /// 1. Make sure to use the main thread
        DispatchQueue.main.async {
            /// 2. Find the right window, and rootViewController.
            /// Please beware that this will only work if there are no multiple windows displayed at once (eg on iPads).
            /// If you have multiple windows on your iPad design, then find, and manage it using *UIWindosScene*.
            guard let keyWindow = UIApplication.shared.windows.first(where: \.isKeyWindow), let vc = keyWindow.rootViewController else {
                print("Qualtrics: Unable to determine the window that should be used to display intercepts")
                return completion(nil)
            }
            /// 3. Return the viewController you chose.
            return completion(vc)
        }
    }
}
