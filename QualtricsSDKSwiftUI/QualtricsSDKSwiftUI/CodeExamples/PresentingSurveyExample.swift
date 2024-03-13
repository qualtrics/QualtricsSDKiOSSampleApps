//
//  PresentingSurveyExample.swift
//  QualtricsSDKSwiftUI
//
//  Created by Qualtrics on 25/02/2024.
//

import Foundation
import UIKit
import Qualtrics
import WebKit

/// This is a separate class so it's easy to read/find the right code snippet.
class PresentingSurveyExample {

    /// This is an example logic you can use to adopt the logic for SwiftUI use when you want to display an intercept
    /// - Parameters:
    ///   - targetingResult: eg. from `Qualtrics.shared.evaluateProject()` function callback
    /// Please beware that **this function will only work *if* you have already called `initializeProject` at least once within the app lifecycle, and recieved the callback.**
    func presentSurvey(targetingResult: TargetingResult) {
        /// 1. Make sure the survey URL is not broken.
        guard let urlString = targetingResult.getSurveyUrl(), let url = URL(string: urlString) else {
            print("Qualtrics: \(self) unable to get survey URL")
            return
        }

        /// 2. Since you're using SwiftUI - you need to determine the viewController / scene that will handle the popup display
        GettingRootViewControllerExample().getRootViewController { vc in

            /// 3. Make sure the viewController you chose is not nil.
            guard let vc = vc else {
                print("Qualtrics: unable to determine rootViewController.")
                return
            }

            /// 4. Create the webview you will be using in order to display the survey.
            let request = NSURLRequest(url: url)
            let webView = WKWebView()
            let surveyViewController = UIViewController()
            surveyViewController.view = webView
            let navigationController = UINavigationController(rootViewController: surveyViewController)
            surveyViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .done,
                target: nil,
                action: #selector(DismissingSurveyExample().dismissSurvey)
            )

            /// 5. Record the fact that user clicked on the survey button.
            targetingResult.recordClick()

            /// 6. Load the view.
            webView.load(request as URLRequest)

            /// 7. Display the survey to the user (using the viewController you chose)
            vc.present(navigationController, animated: true, completion: nil)
        }
    }
}
