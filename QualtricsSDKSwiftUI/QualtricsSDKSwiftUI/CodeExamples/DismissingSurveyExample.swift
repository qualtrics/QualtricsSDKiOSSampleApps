//
//  DismissingSurveyExample.swift
//  QualtricsSDKSwiftUI
//
//  Created by Qualtrics on 25/02/2024.
//

import Foundation
import UIKit
import Qualtrics

/// This is a separate class so it's easy to read/find the right code snippet.
class DismissingSurveyExample {

    /// This is a function that will dismiss the survey if the user clicks on *cancel* button
    @objc func dismissSurvey() {

        /// 1. Make sure to run this on the main thread
        DispatchQueue.main.async {

            /// 2. Since you're using SwiftUI - you need to determine the viewController / scene that will handle the popup display
            GettingRootViewControllerExample().getRootViewController(completion: { vc in

                /// 3. Make sure the viewController you chose is not nil.
                guard let vc = vc else {
                    print("Qualtrics: unable to find the rootViewController")
                    return
                }

                /// 4. Use the viewController to dismiss the view.
                vc.dismiss(animated: true, completion: nil)
            })
        }
    }
}
