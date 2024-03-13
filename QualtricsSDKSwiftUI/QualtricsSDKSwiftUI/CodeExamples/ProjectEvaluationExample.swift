//
//  ProjectEvaluationExample.swift
//  QualtricsSDKSwiftUI
//
//  Created by Qualtrics on 25/02/2024.
//

import Foundation
import UIKit
import Qualtrics

/// This is a separate class so it's easy to read/find the right code snippet.
class ProjectEvaluationExample {

    /// **This function is the basic way to integrate qualtrics into your app**
    func evaluateProjectButtonTapped() {

        /// 1. Since you're using SwiftUI - you need to determine the viewController / scene that will handle the popup display
        GettingRootViewControllerExample().getRootViewController { vc in

            /// 2. Make sure your *rootViewController* is not nil (this may happen if the application is in the background, or just came back from it.)
            guard let vc = vc else {
                print("Qualtrics: failed to find the rootViewController")
                return
            }

            /// 3. **`EvaluateProject` is a function you need to call first each time you're integrating the project into your app.**
            /// It ensures the preconditions determined in your Qualtrics project are met before allowing access to intercepts etc.
            Qualtrics.shared.evaluateProject { targetingResults in

                /// targetingResults consists of *(interceptID, result)* tuples.
                /// - parameter **InterceptID**  is the id of the intercept belonging to your project
                /// - parameter **result** is the result of validation determinig if the intercept should be displayed.
                for (interceptID, result) in targetingResults {

                    /// 4. Make sure the preconditiones (logic determined within the project) are met before you display the intercept.
                    guard result.passed() else {
                        print("Qualtrics: The intercept evaluation for \(interceptID) went wrong.")
                        return;
                    }

                    /// 5. Display the intercept using the rootViewController.
                    _ = Qualtrics.shared.display(viewController: vc)
                }
            }
        }
    }
}
