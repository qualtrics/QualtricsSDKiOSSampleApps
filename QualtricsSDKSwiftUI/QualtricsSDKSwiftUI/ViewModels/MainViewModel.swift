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
    @ObservedObject private var qualtricsProjectInfo = QualtricsProjectInfo.shared

    /// This function is the basic way to integrate qualtrics into your app
    public func evaluateProjectButtonTapped() {
        /// 1. Since you're using SwiftUI - you need to determine the viewController / scene that will handle the popup display
        self.getRootViewController { vc in
            /// 2. Make sure your rootViewController is not nil (this may happen if the application is in the background, or just came back from it)
            guard let vc = vc else {
                print("Qualtrics: failed to find the rootViewController")
                return
            }
            /// 3. Evaluate project is a function you need to call first each time you're integrating the project into your app.
            /// Without calling evaluateProject you will not be able to execute other functionalities because we need to make sure
            /// the preconditions determined in your Qualtrics project are met before allowing access to intercepts etc.
            Qualtrics.shared.evaluateProject { targetingResults in
                /// targetingResults consists of interceptID, and result pairs.
                /// The **InterceptIDs** are the id of the intercepts belonging to your project, while **result** is the result of validation
                /// determinig if the intercept should be displayed.
                for (interceptID, result) in targetingResults {
                    /// 4. Make sure the preconditiones (logic determined within the project) are met, and you should display the intercept.
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
    /// Please beware that this function will only worh **after** you have called *evaluateProject* at least once within the app lifecycle.
    public func evaluateInterceptButtonTapped() {
        /// 1. Since you're using SwiftUI - you need to determine the viewController / scene that will handle the popup display
        self.getRootViewController { vc in
            /// 2. Make sure your rootViewController is not nil (this may happen if the application is in the background, or just came back from it)
            guard let vc = vc else {
                print("Qualtrics: failed to find the rootViewController")
                return
            }
            /// 3. Call evaluateIntercept with the InterceptID that you want
            Qualtrics.shared.evaluateIntercept(for: "YourInterceptID") { targetingResult in
                /// Since this function handles only one intercept at the time there is no need to return the interceptIDs like in evaluateProject callback.
                ///  - the **targetingResult** is a value of *TargetingResult* type that will allow you to determine if the intercept has met the
                ///  conditions under chich it is to be displayed in your app.
                ///  You can do that simply by calling the *.passed()* function like in the line below.
                guard targetingResult.passed() else {
                    print("Qualtrics: The intercept evaluation for went wrong.")
                    return;
                }
                /// 4. Now that you know that everything is in its place you can display the intercept by simply calling:
                _ = Qualtrics.shared.display(viewController: vc)
            }
        }
    }

    /// This function will allow you to integrate your own intercept with RequestAppleReview. That way you may be able to collect more valuable data.
    public func requestReviewWithQualtrics() {
        /// 1. The first step is to 
        Qualtrics.shared.evaluateIntercept(for: "yourInterceptID") { [weak self] targetingResult in
            guard targetingResult.passed() else {
                print("Qualtrics: unable to ask for AppReview.")
                return;
            }
            self?.getCurrentWindowScene(completion: { scene in
                guard let scene = scene else {
                    print("Qualtrics: unable to find the appriopriate UIWindowScene.")
                    return
                }
                SKStoreReviewController.requestReview(in: scene)
            })
        }
    }

    public func registerViewVisit() {
        Qualtrics.shared.properties.setString(string: "\(self)", for: "YourViewModelName")
        Qualtrics.shared.registerViewVisit(viewName: "YourViewName")
        Qualtrics.shared.evaluateProject { [weak self] targetingResults in
            for (interceptID, result) in targetingResults {
                guard result.passed() else {
                    print("Qualtrics: The evaluation for \(interceptID) failed.")
                    return;
                }
                self?.getRootViewController(completion: { vc in
                    guard let vc = vc else {
                        print("Qualtrics: unable to determine rootViewController.")
                        return
                    }
                    _ = Qualtrics.shared.display(viewController: vc)
                })
            }
        }
    }

    public func addEmbeddedText() {
        Qualtrics.shared.properties.setString(string: "YourEmbeddedDataValue", for: "YourEmbeddedDataKey")
    }

    public func simpleCustomSurvayInvitationDialog() {
        Qualtrics.shared.evaluateProject { [weak self] targetingResults in
            for (interceptID, result) in targetingResults {
                guard result.passed() else {
                    print("Qualtrics: intercept validation failed for \(interceptID.debugDescription).")
                    return
                }
                self?.getRootViewController(completion: { vc in
                    guard let vc = vc else {
                        print("Qualtrics: unable to determine rootViewController.")
                        return
                    }
                    result.recordImpression()
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
                    DispatchQueue.main.async {
                        vc.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
    }

    public func giveFeedbackPromptBypassButtonTapped() {
        Qualtrics.shared.evaluateProject { [weak self] targetingResults in
            for (_, targetingResult) in targetingResults {
                guard targetingResult.passed(), let url = targetingResult.getSurveyUrl() else {
                    print("Qualtrics: validation of \(targetingResult) failed.")
                    return
                }
                targetingResult.recordImpression()
                DispatchQueue.main.async {
                    self?.getRootViewController(completion: { vc in
                        guard let vc = vc else {
                            print("Qualtrics: unable to find the rootViewController")
                            return
                        }
                        let surveyViewController = QualtricsSurveyViewController(url: url)
                        surveyViewController.modalPresentationStyle = .overCurrentContext
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
//
//
//        }
//    }

    private func presentSurvey(targetingResult: TargetingResult) {
        guard let urlString = targetingResult.getSurveyUrl(), let url = URL(string: urlString) else {
            print("Qualtrics: \(self) unable to get survay URL")
            return
        }
        self.getRootViewController { [weak self] vc in
            guard let vc = vc else {
                print("Qualtrics: unable to determine rootViewController.")
                return
            }
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
            targetingResult.recordClick()
            webView.load(request as URLRequest)
            vc.present(navigationController, animated: true, completion: nil)
        }
    }

    @objc private func dismissSurvey() {
        DispatchQueue.main.async { [weak self] in
            self?.getRootViewController(completion: { vc in
                guard let vc = vc else {
                    print("Qualtrics: unable to find the rootViewController")
                    return
                }
                vc.dismiss(animated: true, completion: nil)
            })
        }
    }

    private func getRootViewController(completion: @escaping (UIViewController?) -> Void) {
        DispatchQueue.main.async {
            guard let keyWindow = UIApplication.shared.windows.first(where: \.isKeyWindow), let vc = keyWindow.rootViewController else {
                print("Qualtrics: Unable to determine the window that should be used to display intercepts")
                return completion(nil)
            }
            return completion(vc)
        }
    }

    private func getCurrentWindowScene(completion: @escaping (UIWindowScene?) -> Void) {
        DispatchQueue.main.async {
            return completion(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        }
    }
}
