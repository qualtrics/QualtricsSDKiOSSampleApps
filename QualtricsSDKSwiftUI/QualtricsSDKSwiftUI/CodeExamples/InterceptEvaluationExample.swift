//
//  InterceptEvaluationExample.swift
//  QualtricsSDKSwiftUI
//
//  Created by Qualtrics on 25/02/2024.
//

import Foundation
import Qualtrics
import UIKit

/// This is a separate class so it's easy to read/find the right code snippet.
class InterceptEvaluationExample {

    /// Evaluate intercept is your go-to function when you want to display a singular intercept.
    /// Please beware that **this function will only work *if* you have already called `initializeProject` at least once within the app lifecycle, and recieved the callback.**
    func evaluateInterceptButtonTapped() {
        /// 1. Since you're using SwiftUI - you need to determine the viewController / scene that will handle the popup display
        GettingRootViewControllerExample().getRootViewController { vc in

            /// 2. Make sure your rootViewController is not nil (this may happen if the application is in the background, or just came back from it.)
            guard let vc = vc, let yourInterceptId = QualtricsProjectInfo.shared.interceptID else {
                print("Qualtrics: failed to find the rootViewController or InterceptId is a nil")
                return
            }

            /// 3. Call `evaluateIntercept` with the *InterceptID* that you want to display
            Qualtrics.shared.evaluateIntercept(for: yourInterceptId) { targetingResult in

                /// This function handles only one intercept at the time, so it returns a singular object of *TargetingResult* type
                ///  - parameter **targetingResult**  will allow you to determine if the intercept has met the  predefined conditions under chich it is to be displayed in your app.
                ///  Those preconditions are set within your Qualtrics project.
                guard targetingResult.passed() else {
                    print("Qualtrics: The intercept evaluation went wrong.")
                    return;
                }

                /// 4. Display the intercept using the rootViewController
                _ = Qualtrics.shared.display(viewController: vc)
            }
        }
    }
}
