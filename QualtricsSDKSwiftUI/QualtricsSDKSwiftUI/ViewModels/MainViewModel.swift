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

class MainViewModel: ObservableObject {
    @ObservedObject private var qualtricsProjectInfo = QualtricsProjectInfo.shared

    public func evaluateProjectButtonTapped() {
        self.getRootViewController { vc in
            guard let vc = vc else {
                print("Qualtrics: failed to find the rootViewController")
                return
            }
            Qualtrics.shared.evaluateProject { targetingResults in
                for (interceptID, result) in targetingResults {
                    guard result.passed() else {
                        print("Qualtrics: The intercept evaluation for \(interceptID) went wrong.")
                        return;
                    }
                    _ = Qualtrics.shared.display(viewController: vc)
                }
            }
        }
    }

    public func evaluateInterceptButtonTapped() {
        self.getRootViewController { vc in
            guard let vc = vc else {
                print("Qualtrics: failed to find the rootViewController")
                return
            }
            // this doesn't work if the evaluateProject hasn't been called at least once before
            // TODO: replace the interceptID below
            Qualtrics.shared.evaluateIntercept(for: "SI_2cbvwImx9Zo90N0") { targetingResult in
                guard targetingResult.passed() else {
                    print("Qualtrics: The intercept evaluation for went wrong.")
                    return;
                }
                _ = Qualtrics.shared.display(viewController: vc)
            }
        }
    }

    public func requestReviewWithQualtrics() {
        // TODO: replace the interceptID below
        Qualtrics.shared.evaluateIntercept(for: "SI_2cbvwImx9Zo90N0") { [weak self] targetingResult in
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

    @objc func dismissSurvey() {
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
