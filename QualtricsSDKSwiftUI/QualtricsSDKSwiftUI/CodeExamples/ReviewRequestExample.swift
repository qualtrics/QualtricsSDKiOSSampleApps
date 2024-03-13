//
//  ReviewRequestExample.swift
//  QualtricsSDKSwiftUI
//
//  Created by Qualtrics on 25/02/2024.
//

import Foundation
import Qualtrics
import UIKit
import StoreKit

/// This is a separate class so it's easy to read/find the right code snippet.
class ReviewRequestExample {

    /// This function will allow you to integrate **your own intercept** with `RequestAppleReview` (App Store review). That way you may be able to collect more valuable data.
    /// Please beware that **this function will only work *if* you have already called `initializeProject` at least once within the app lifecycle, and recieved the callback.**
    public func requestReviewWithQualtrics() {
        
        guard let yourInterceptId = QualtricsProjectInfo.shared.interceptID else {
            print("Qualtrics: interceptId is a nil.")
            return
        }

        /// 1. Call the `evaluateProject()` with the interceptID you want to connect here.
        Qualtrics.shared.evaluateIntercept(for: yourInterceptId) { targetingResult in

            /// 2. Make sure the preconditions defined in your Qualtrics projects are met.
            guard targetingResult.passed() else {
                print("Qualtrics: unable to ask for AppReview.")
                return;
            }

            /// 3.  Since you're using SwiftUI - you need to determine the viewController / scene that will handle the popup display
            GettingCurrentWindowSceneExample().getCurrentWindowScene(completion: { scene in

                /// 4. Make sure the scene you're using is not nil.
                guard let scene = scene else {
                    print("Qualtrics: unable to find the appriopriate UIWindowScene.")
                    return
                }

                /// 5. Request the review.
                SKStoreReviewController.requestReview(in: scene)
            })
        }
    }
}
