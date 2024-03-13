//
//  GettingRootViewController.swift
//  QualtricsSDKSwiftUI
//
//  Created by Qualtrics on 25/02/2024.
//

import Foundation
import Qualtrics
import UIKit

/// This is a separate class so it's easy to read/find the right code snippet.
class GettingRootViewControllerExample {

    /// This is an example implementation of a function that will determine the viewController that is currently presenting views in the app.
    /// Before using this implementation please make note that this will only work if there are no multiple scenes displayed at once in your app (eg on iPad).
    func getRootViewController(completion: @escaping (UIViewController?) -> Void) {
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
