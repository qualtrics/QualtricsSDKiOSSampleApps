//
//  GiveFeedbackPromptBypassExample.swift
//  QualtricsSDKSwiftUI
//
//  Created by Qualtrics on 25/02/2024.
//

import Foundation
import UIKit
import Qualtrics

/// This is a separate class so it's easy to read/find the right code snippet.
class GiveFeedbackPromptBypassExample {

    /// This function will allow you to display the survey without triggering the intercept/popup first.
    /// It's recommended if you implement a button that should point the user directly to the feedback form.
    /// Please beware that **this function will only work *if* you have already called `initializeProject` at least once within the app lifecycle, and recieved the callback.**
    func giveFeedbackPromptBypassButtonTapped() {

        /// 1. **`EvaluateProject()` is a function you need to call first each time you're integrating the project into your app.**
        /// It ensures the preconditions determined in your Qualtrics project are met before allowing access to intercepts etc.
        Qualtrics.shared.evaluateProject { targetingResults in

            /// targetingResults consists of *(interceptID, result) tuples.
            /// - parameter **InterceptID**  is the id of the intercept belonging to your project
            /// - parameter **result** is the result of validation determinig if the intercept should be displayed.
            for (_, targetingResult) in targetingResults {

                /// 2. Make sure the preconditiones (logic determined within the project) are met before you do anything else.
                guard targetingResult.passed(), let url = targetingResult.getSurveyUrl() else {
                    print("Qualtrics: validation of \(targetingResult) failed.")
                    return
                }

                /// 3. Record the impression to your Qualtrics project.
                targetingResult.recordImpression()

                /// 4. Make sure to use the main thread.
                DispatchQueue.main.async {

                    /// 5. Since you're using SwiftUI - you need to determine the viewController / scene that will handle the popup display
                    GettingRootViewControllerExample().getRootViewController(completion: { vc in

                        /// 6. Make sure that the viewController of your choice is not nil.
                        guard let vc = vc else {
                            print("Qualtrics: unable to find the rootViewController")
                            return
                        }

                        /// 7. Create an instance of *QualtricsSurveyViewController* with your url
                        let surveyViewController = QualtricsSurveyViewController(url: url)
                        surveyViewController.modalPresentationStyle = .overFullScreen

                        /// 8. Display the feedback form using your viewController
                        vc.present(surveyViewController, animated: true, completion: nil)
                    })
                }
            }
        }
    }
}
