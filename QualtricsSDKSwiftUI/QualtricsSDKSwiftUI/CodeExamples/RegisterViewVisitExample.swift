//
//  RegisterViewExample.swift
//  QualtricsSDKSwiftUI
//
//  Created by Qualtrics on 25/02/2024.
//

import Foundation
import Qualtrics
import UIKit

/// This is a separate class so it's easy to read/find the right code snippet.
class RegisterViewVisitExample {
    
    /// This function will allow you to log in additional data such as intercept views/impressions.
    ///
    /// Please beware that **this will only work *if*  you**:
    ///  1. have already called `initializeProject` at least once within the app lifecycle
    ///  2. recieved the callback from `initializeProject`,
    ///  3. call `registerViewVisit`
    ///  4. evaluate the Intercept logic by calling `evaluateTargetingLogic`
    func registerViewVisit() {
        
        /// 1. Make sure that the key you're going to be using is there (usualy the viewName, in this case *RegisterViewVisitExample*).
        Qualtrics.shared.properties.setString(string: "\(self)", for: "YourViewModelName")

        /// 2. Prepare the instruction to register the visit using the right key as soon as `EvaluateProject` is called.
        Qualtrics.shared.registerViewVisit(viewName: "YourViewName")

        /// 3. Call `EvaluateProject` function in order to register the visit to your Qualtrics project.
        /// ** `Evaluate project` is a function you need to call first each time you're integrating the project into your app.**
        /// It ensures the preconditions determined in your Qualtrics project are met before allowing access to intercepts etc.
        /// Due to technical reasons there may be a delay in logging this into production servers.
        Qualtrics.shared.evaluateProject { targetingResults in

            /// targetingResults consists of *(interceptID, result)* tuples.
            /// - parameter **InterceptID**  is the id of the intercept belonging to your project
            /// - parameter **result** is the result of validation determinig if the intercept should be displayed.
            for (interceptID, result) in targetingResults {

                /// 4. Make sure the preconditiones (logic determined within the project) are met before you do anything else.
                guard result.passed() else {
                    print("Qualtrics: The evaluation for \(interceptID) failed.")
                    return;
                }
                /// 5. Since you're using SwiftUI - you need to determine the viewController / scene that will handle the popup display
                GettingRootViewControllerExample().getRootViewController(completion: { vc in
                    /// 6. Make sure the viewController (usually rootViewController) is not nil.
                    guard let vc = vc else {
                        print("Qualtrics: unable to determine rootViewController.")
                        return
                    }

                    /// 7. Display the intercept using youe viewController
                    _ = Qualtrics.shared.display(viewController: vc)
                })
            }
        }
    }
}
