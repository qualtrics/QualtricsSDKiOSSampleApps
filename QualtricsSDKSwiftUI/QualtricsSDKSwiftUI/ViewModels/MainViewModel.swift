//
//  MainViewModel.swift
//  QualtricsSDKSwiftUI
//
//  Created by Natalie Niziolek on 06/02/2023.
//

import Foundation
import Qualtrics
import UIKit
import SwiftUI
import StoreKit
import WebKit
import UserNotifications

class MainViewModel: ObservableObject {
    /// The line below is a neat way to store the projectID, brandID, and other data you may need in one place so it's easier to modify later on.
    @ObservedObject private var qualtricsProjectInfo = QualtricsProjectInfo.shared

    /// **This function is the basic way to integrate qualtrics into your app**
    public func evaluateProjectButtonTapped() {
        /// 1. Since you're using SwiftUI - you need to determine the viewController / scene that will handle the popup display
        self.getRootViewController { vc in
            /// 2. Make sure your rootViewController is not nil (this may happen if the application is in the background, or just came back from it.)
            guard let vc = vc else {
                print("Qualtrics: failed to find the rootViewController")
                return
            }
            /// 3. **Evaluate project is a function you need to call first each time you're integrating the project into your app.**
            /// It ensures the preconditions determined in your Qualtrics project are met before allowing access to intercepts etc.
            Qualtrics.shared.evaluateProject { targetingResults in
                /// targetingResults consists of *(interceptID, result) tuples.
                /// - parameter **InterceptID**  is the id of the intercept belonging to your project
                /// - parameter **result** is the result of validation determinig if the intercept should be displayed.
                for (interceptID, result) in targetingResults {
                    /// 4. Make sure the preconditiones (logic determined within the project) are met before you display the intercept.
                    guard result.passed() else {
                        print("Qualtrics: The intercept evaluation for \(interceptID) went wrong.")
                        return;
                    }
                    /// 5. Dysplay the intercept using the rootViewController.
                    _ = Qualtrics.shared.display(viewController: vc)
                }
            }
        }
    }
    
    /// Evaluate intercept is your go-to function when you want to display a singular intercept.
    /// Please beware that **this function will only worh *after* you have called *evaluateProject* at least once within the app lifecycle.**
    public func evaluateInterceptButtonTapped() {
        /// 1. Since you're using SwiftUI - you need to determine the viewController / scene that will handle the popup display
        self.getRootViewController { vc in
            /// 2. Make sure your rootViewController is not nil (this may happen if the application is in the background, or just came back from it.)
            guard let vc = vc else {
                print("Qualtrics: failed to find the rootViewController")
                return
            }
            /// 3. Call evaluateIntercept with the InterceptID that you want to display
            Qualtrics.shared.evaluateIntercept(for: "YourInterceptID") { targetingResult in
                /// This function handles only one intercept at the time, so it returns a singular object of *TargetingResult* type
                ///  - parameter **targetingResult**  will allow you to determine if the intercept has met the  predefined conditions under chich it is to be displayed in your app.
                ///  Those preconditions are set within your Qualtrics project.
                guard targetingResult.passed() else {
                    print("Qualtrics: The intercept evaluation for went wrong.")
                    return;
                }
                /// 4. Display the intercept using the rootViewController
                _ = Qualtrics.shared.display(viewController: vc)
            }
        }
    }

    /// This function will allow you to integrate **your own intercept** with RequestAppleReview. That way you may be able to collect more valuable data.
    public func requestReviewWithQualtrics() {
        /// 1. Call the *evaluateProject()* with the interceptID you want to connect here.
        Qualtrics.shared.evaluateIntercept(for: "yourInterceptID") { [weak self] targetingResult in
            /// 2. Make sure the preconditions defined in your Qualtrics projects are met.
            guard targetingResult.passed() else {
                print("Qualtrics: unable to ask for AppReview.")
                return;
            }
            /// 3.  Since you're using SwiftUI - you need to determine the viewController / scene that will handle the popup display
            self?.getCurrentWindowScene(completion: { scene in
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

    /// This function will allow you to log in additional data such as intercept views/impressions.
    public func registerViewVisit() {
        /// 1. Make sure that the key you're going to be using is there (usualy the viewName).
        Qualtrics.shared.properties.setString(string: "\(self)", for: "YourViewModelName")
        /// 2. Prepare the instruction to register the visit using the right key as soon as *EvaluateProject* is called.
        Qualtrics.shared.registerViewVisit(viewName: "YourViewName")
        /// 3. Call **EvaluateProject** function in order to register the visit to your Qualtrics project.
        /// **Evaluate project is a function you need to call first each time you're integrating the project into your app.**
        /// It ensures the preconditions determined in your Qualtrics project are met before allowing access to intercepts etc.
        /// Due to technical reasons there may be a delay in logging this into production servers.
        Qualtrics.shared.evaluateProject { [weak self] targetingResults in
            /// targetingResults consists of *(interceptID, result) tuples.
            /// - parameter **InterceptID**  is the id of the intercept belonging to your project
            /// - parameter **result** is the result of validation determinig if the intercept should be displayed.
            for (interceptID, result) in targetingResults {
                /// 4. Make sure the preconditiones (logic determined within the project) are met before you do anything else.
                guard result.passed() else {
                    print("Qualtrics: The evaluation for \(interceptID) failed.")
                    return;
                }
                /// 5. Since you're using SwiftUI - you need to determine the viewController / scene that will handle the popup display
                self?.getRootViewController(completion: { vc in
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

    /// This function will allow you to log embedded text to your Qualtrics project.
    /// Please beware that this will be executed once **EvaluateProject()** function is called.
    public func addEmbeddedText() {
        /// 1. Prepare the instruction to register the visit using the right key as soon as *EvaluateProject* is called.
        Qualtrics.shared.properties.setString(string: "YourEmbeddedDataValue", for: "YourEmbeddedDataKey")
        /// 2. Once **EvaluateProject()** function is called the properties will be updated to the Qualtrics project.
    }

    /// This function is an example how to use the custom survay invitation dialog.
    public func simpleCustomSurvayInvitationDialog() {
        /// 1. **Evaluate project is a function you need to call first each time you're integrating the project into your app.**
        /// It ensures the preconditions determined in your Qualtrics project are met before allowing access to intercepts etc.
        Qualtrics.shared.evaluateProject { [weak self] targetingResults in
            /// targetingResults consists of *(interceptID, result) tuples.
            /// - parameter **InterceptID**  is the id of the intercept belonging to your project
            /// - parameter **result** is the result of validation determinig if the intercept should be displayed.
            for (interceptID, result) in targetingResults {
                /// 2. Make sure the preconditiones (logic determined within the project) are met before you do anything else.
                guard result.passed() else {
                    print("Qualtrics: intercept validation failed for \(interceptID.debugDescription).")
                    return
                }
                /// 3. Since you're using SwiftUI - you need to determine the viewController / scene that will handle the popup display
                self?.getRootViewController(completion: { vc in
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
                        self?.presentSurvey(targetingResult: result)
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

    /// This function will allow you to display the survey without triggering the intercept/popup first.
    /// It's recommended if you implement a button that should point the user directly to the feedback form.
    public func giveFeedbackPromptBypassButtonTapped() {
        /// 1. **Evaluate project is a function you need to call first each time you're integrating the project into your app.**
        /// It ensures the preconditions determined in your Qualtrics project are met before allowing access to intercepts etc.
        Qualtrics.shared.evaluateProject { [weak self] targetingResults in
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
                    self?.getRootViewController(completion: { vc in
                        /// 6. Make sure that the viewController of your choice is not nil.
                        guard let vc = vc else {
                            print("Qualtrics: unable to find the rootViewController")
                            return
                        }
                        /// 7. Create an instance of *QualtricsSurvayViewController* with your url
                        let surveyViewController = QualtricsSurveyViewController(url: url)
                        surveyViewController.modalPresentationStyle = .overCurrentContext
                        /// 8. Display the feedback form using your viewController
                        vc.present(surveyViewController, animated: true, completion: nil)
                    })
                }
            }
        }
    }

    // MARK: WIP
//    public func localNotificationButtonTapped() {
//        self.getCurrentWindowScene { [weak self] scene in
//            guard let scene = scene, let window = scene.keyWindow else {
//                print("Qualtrics: unable to get the key Window")
//                return
//            }
//          // TODO: fill in the notifications instructions
//
//        }
//    }

    /// This is an example logic you can use to adopt the logic for SwiftUI use when you want to display an intercept
    /// - Parameters: *targetingResult* is of **TargetingResult** type, and should be provided in the *.passed()* function callback
    private func presentSurvey(targetingResult: TargetingResult) {
        /// 1. Make sure the survay URL is not broken.
        guard let urlString = targetingResult.getSurveyUrl(), let url = URL(string: urlString) else {
            print("Qualtrics: \(self) unable to get survay URL")
            return
        }
        /// 2. Since you're using SwiftUI - you need to determine the viewController / scene that will handle the popup display
        self.getRootViewController { [weak self] vc in
            /// 3. Make sure the viewController you chose is not nil.
            guard let vc = vc else {
                print("Qualtrics: unable to determine rootViewController.")
                return
            }
            /// 4. Create the webview you will be using in order to display the survay.
            let request = NSURLRequest(url: url)
            let webView = WKWebView()
            let surveyViewController = UIViewController()
            surveyViewController.view = webView
            let navigationController = UINavigationController(rootViewController: surveyViewController)
            surveyViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(self?.dismissSurvey)
            )
            /// 5. Record the fact that user clicked on the survay button.
            targetingResult.recordClick()
            /// 6. Load the view.
            webView.load(request as URLRequest)
            /// 7. Display the survay to the user (using the viewController you chose)
            vc.present(navigationController, animated: true, completion: nil)
        }
    }

    /// This is a function that will dismiss the survay if the user clicks on *cancel* button
    @objc private func dismissSurvey() {
        /// 1. Make sure to run this on the main thread
        DispatchQueue.main.async { [weak self] in
            /// 2. Since you're using SwiftUI - you need to determine the viewController / scene that will handle the popup display
            self?.getRootViewController(completion: { vc in
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

    /// This is an example implementation of a function that will determinr the right UIWiewScene that are currently used in the foreground of the app.
    private func getCurrentWindowScene(completion: @escaping (UIWindowScene?) -> Void) {
        /// 1. Make sure to run this on the main thread.
        DispatchQueue.main.async {
            /// 2. Return the scene that is currently first on the list.
            return completion(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        }
    }
}
