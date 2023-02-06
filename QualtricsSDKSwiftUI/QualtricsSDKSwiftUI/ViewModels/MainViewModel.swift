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

class MainViewModel: ObservableObject {
    @ObservedObject private var qualtricsProjectInfo = QualtricsProjectInfo.shared

    public func evaluateProjectButtonTapped() {
        guard let vc = getRootViewController() else {
            print("Qualtrics: \(self) failed to find the rootViewController")
            return
        }
        Qualtrics.shared.evaluateProject { targetingResults in
            for (interceptID, result) in targetingResults {
                guard result.passed() else {
                    print("Qualtrics: \(self) The intercept evaluation for \(interceptID) went wrong.")
                    return;
                }
                _ = Qualtrics.shared.display(viewController: vc)
            }
        }
    }

    public func evaluateInterceptButtonTapped() {
        guard let vc = getRootViewController() else {
            print("Qualtrics: \(self) failed to find the rootViewController")
            return
        }
        // this doesn't work if the evaluateProject hasn't been called at least once before
        Qualtrics.shared.evaluateIntercept(for: "SI_2cbvwImx9Zo90N0") { targetingResult in
            guard targetingResult.passed() else {
                print("Qualtrics: \(self) The intercept evaluation for went wrong.")
                return;
            }
            _ = Qualtrics.shared.display(viewController: vc)
        }
    }

    private func getRootViewController() -> UIViewController? {
        guard let keyWindow = UIApplication.shared.windows.first(where: \.isKeyWindow), let vc = keyWindow.rootViewController else {
            print("Qualtrics: \(self): Unable to determine the window that should be used to display intercepts")
            return nil;
        }
        return vc
    }
}
