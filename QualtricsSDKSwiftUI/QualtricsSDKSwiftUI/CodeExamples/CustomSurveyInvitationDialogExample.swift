//
//  CustomSurveyInvitationDialogExample.swift
//  QualtricsSDKSwiftUI
//
//  Created by Qualtrics on 25/02/2024.
//

import Foundation
import Qualtrics
import UIKit

/// This is a separate class so it's easy to read/find the right code snippet.
class CustomSurveyInvitationDialogExample {

    /// This function is an example how to use the custom survey invitation dialog.
    /// Please beware that **this function will only work *if* you have already called `initializeProject` at least once within the app lifecycle, and recieved the callback.**
    func customSurveyInvitationDialog() {
        /// 1. `EvaluateProject` is a function you need to call first each time you're integrating the project into your app.**
        /// It ensures the preconditions determined in your Qualtrics project are met before allowing access to intercepts etc.
        Qualtrics.shared.evaluateProject { targetingResults in

            /// targetingResults consists of *(interceptID, result)* tuples.
            /// - parameter **InterceptID**  is the id of the intercept belonging to your project
            /// - parameter **result** is the result of validation determinig if the intercept should be displayed.
            for (interceptID, result) in targetingResults {

                /// 2. Make sure the preconditiones (logic determined within the project) are met before you do anything else.
                guard result.passed() else {
                    print("Qualtrics: intercept validation failed for \(interceptID.debugDescription).")
                    return
                }

                /// 3. Since you're using SwiftUI - you need to determine the viewController / scene that will handle the popup display
                GettingRootViewControllerExample().getRootViewController(completion: { vc in

                    /// 4. Make sure the viewController you chose to display the intercept is not nil.
                    guard let vc = vc else {
                        print("Qualtrics: unable to determine rootViewController.")
                        return
                    }

                    /// 5. Record the impression for the intercept.
                    result.recordImpression()

                    /// 6. Create the custom alert.
                    let alert = UIAlertController(
                        title: "Give Feedback",
                        message: "Would you like to take a brief survey?",
                        preferredStyle: .alert
                    )
                    let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                        PresentingSurveyExample().presentSurvey(targetingResult: result)
                    })
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
                    alert.addAction(defaultAction)
                    alert.addAction(cancelAction)

                    /// 7. Make sure to use the main thread
                    DispatchQueue.main.async {

                        /// 8. Display the custom alert with your intercept
                        vc.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
    }
}
