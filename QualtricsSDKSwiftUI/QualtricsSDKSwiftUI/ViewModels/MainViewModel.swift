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
    
    @Published var showingErrorAlert = false
    @Published var errorAlertTitle = ""
    @Published var errorAlertMessage = ""

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
                        self.handleErrorAlert(
                            title: "Intercept evaluation went wrong",
                            additional: result.getError()?.getErrorMessage()
                        )
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
            Qualtrics.shared.evaluateIntercept(for: "yourInterceptID") { targetingResult in
                /// This function handles only one intercept at the time, so it returns a singular object of *TargetingResult* type
                ///  - parameter **targetingResult**  will allow you to determine if the intercept has met the  predefined conditions under chich it is to be displayed in your app.
                ///  Those preconditions are set within your Qualtrics project.
                guard targetingResult.passed() else {
                    self.handleErrorAlert(
                        title: "Intercept evaluation went wrong",
                        additional: "- Set yourInterceptID \n" + (targetingResult.getError()?.getErrorMessage() ?? "")
                    )
                    print("Qualtrics: The intercept evaluation went wrong.")
                    return;
                }
                /// 4. Display the intercept using the rootViewController
                _ = Qualtrics.shared.display(viewController: vc)
            }
        }
    }

    /// This function will allow you to integrate **your own intercept** with RequestAppleReview (App Store review). That way you may be able to collect more valuable data.
    public func requestReviewWithQualtrics() {
        /// 1. Call the *evaluateProject()* with the interceptID you want to connect here.
        Qualtrics.shared.evaluateIntercept(for: "yourInterceptID") { [weak self] targetingResult in
            /// 2. Make sure the preconditions defined in your Qualtrics projects are met.
            guard targetingResult.passed() else {
                print("Qualtrics: unable to ask for AppReview.")
                self?.handleErrorAlert(
                    title: "Unable to ask for AppReview",
                    additional: "- Set yourInterceptID \n" + (targetingResult.getError()?.getErrorMessage() ?? "")
                )
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
                    self?.handleErrorAlert(
                        title: "Intercept evaluation failed \nregisterViewVisit()",
                        additional: "- Set interceptIDs (optional) \n" + (result.getError()?.getErrorMessage() ?? "")
                    )
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

    /// This function is an example how to use the custom survey invitation dialog.
    public func simpleCustomSurveyInvitationDialog() {
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
                    self?.handleErrorAlert(
                        title: "Intercept validation failed",
                        additional: result.getError()?.getErrorMessage()
                    )
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
                    self?.handleErrorAlert(
                        title: "Validation of \(targetingResult) failed",
                        additional: targetingResult.getError()?.getErrorMessage()
                    )
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
                        /// 7. Create an instance of *QualtricsSurveyViewController* with your url
                        let surveyViewController = QualtricsSurveyViewController(url: url)
                        surveyViewController.modalPresentationStyle = .overCurrentContext
                        /// 8. Display the feedback form using your viewController
                        vc.present(surveyViewController, animated: true, completion: nil)
                    })
                }
            }
        }
    }

    /// This is an example logic you can use to adopt the logic for SwiftUI use when you want to display an intercept
    /// - Parameters:
    ///   - targetingResult: Should be provided in the *.passed()* function callback
    private func presentSurvey(targetingResult: TargetingResult) {
        /// 1. Make sure the survey URL is not broken.
        guard let urlString = targetingResult.getSurveyUrl(), let url = URL(string: urlString) else {
            print("Qualtrics: \(self) unable to get survey URL")
            self.handleErrorAlert(
                title: "Unable to get survey URL",
                additional: targetingResult.getError()?.getErrorMessage()
            )
            return
        }
        /// 2. Since you're using SwiftUI - you need to determine the viewController / scene that will handle the popup display
        self.getRootViewController { [weak self] vc in
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
                target: self,
                action: #selector(self?.dismissSurvey)
            )
            /// 5. Record the fact that user clicked on the survey button.
            targetingResult.recordClick()
            /// 6. Load the view.
            webView.load(request as URLRequest)
            /// 7. Display the survey to the user (using the viewController you chose)
            vc.present(navigationController, animated: true, completion: nil)
        }
    }
    
    /// This funciton will request the notification permisison to be granted. You need to call this function before you can use Notifications in your app.
    public func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                print("Qualtrics: notification authorisation request failed with error: \(error).")
                return
            }
            print("Qualtrics: Notifications permission granted.")
        }
    }

    /// This is a function that will dismiss the survey if the user clicks on *cancel* button
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

    /// This is an example implementation of a function that will determine the right UIWindowScene that is currently being used in the foreground of the app.
    private func getCurrentWindowScene(completion: @escaping (UIWindowScene?) -> Void) {
        /// 1. Make sure to run this on the main thread.
        DispatchQueue.main.async {
            /// 2. Return the scene that is currently first on the list.
            return completion(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        }
    }
    
    /**
     This is a helper function to check and alert for errors specific to the Qualtrics SDK
      - Parameters:
        - title: Passed to *errorAlertTitle*
        - additional: Optional message added at the end of the *errorAlertMessage*
     */
    private func handleErrorAlert(title: String, additional: String? = nil) {
        var message = ""
        if qualtricsProjectInfo.brandID.isEmpty || qualtricsProjectInfo.brandID == "YourBrandID" {
            message += "\n- Set brandID"
        }
        if qualtricsProjectInfo.projectID.isEmpty || qualtricsProjectInfo.projectID == "YourProjectID" {
            message += "\n- Set projectID"
        }
        if (additional != nil) {
            message += "\n" + additional!
        }
        showErrorAlertWithMessage(errorTitle: title, errorMessage: message)
    }
    
    /**
     This is a helper function to trigger an alert with a given title and message
      - Parameters:
        - errorTitle: Displayed as an alert title
        - errorMessage: Displayed as an alert message
     */
    private func showErrorAlertWithMessage(errorTitle: String, errorMessage: String) {
        DispatchQueue.main.async {
            self.errorAlertTitle = errorTitle
            self.errorAlertMessage = errorMessage
            self.showingErrorAlert.toggle()
        }
    }
}
