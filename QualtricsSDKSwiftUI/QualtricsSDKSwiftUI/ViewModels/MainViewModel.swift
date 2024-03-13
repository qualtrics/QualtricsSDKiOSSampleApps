//
//  MainViewModel.swift
//  QualtricsSDKSwiftUI
//
//  Created by Qualtrics on 06/02/2023.
//

import Foundation
import Qualtrics
import UIKit
import SwiftUI
import WebKit
import UserNotifications

class MainViewModel: ObservableObject {
    /// The line below is a neat way to store the *projectID*, *brandID*, and other data you may need in one place so it's easier to modify later on.
    private var qualtricsProjectInfo = QualtricsProjectInfo.shared

    @Published var showingErrorAlert = false
    @Published var errorAlertTitle = ""
    @Published var errorAlertMessage = ""

    /// **This function is the basic way to integrate qualtrics into your app.**
    func evaluateProjectButtonTapped() {
        ProjectEvaluationExample().evaluateProjectButtonTapped()
    }
    
    /// Evaluate intercept is your go-to function when you want to display a singular intercept.
    /// Please beware that **this function will only work *if* you have already called `initializeProject` at least once within the app lifecycle, and recieved the callback.**
    func evaluateInterceptButtonTapped() {
        InterceptEvaluationExample().evaluateInterceptButtonTapped()
    }

    /// This function will allow you to integrate **your own intercept** with `RequestAppleReview` (App Store review). That way you may be able to collect more valuable data.
    /// Please beware that **this function will only work *if* you have already called `initializeProject` at least once within the app lifecycle, and recieved the callback.**
    func requestReviewWithQualtrics() {
        ReviewRequestExample().requestReviewWithQualtrics()
    }

    /// This function will allow you to log in additional data such as intercept views/impressions.
    ///
    /// Please beware that **this will only work *if*  you**:
    ///  1. have already called `initializeProject` at least once within the app lifecycle
    ///  2. recieved the callback from `initializeProject`,
    ///  3. call `registerViewVisit`
    ///  4. evaluate the Intercept logic by calling `evaluateTargetingLogic`
    func registerViewVisit() {
        RegisterViewVisitExample().registerViewVisit()
    }

    /// This function will allow you to log embedded text to your Qualtrics project.
    /// Please beware that **this function will only work *if* you have already called `initializeProject` at least once within the app lifecycle, and recieved the callback.**
    func addEmbeddedText() {
        AddEmbeddedTextExample().addEmbeddedText()
    }

    /// This function is an example how to use the custom survey invitation dialog.
    /// Please beware that **this function will only work *if* you have already called `initializeProject` at least once within the app lifecycle, and recieved the callback.**
    func customSurveyInvitationDialog() {
        CustomSurveyInvitationDialogExample().customSurveyInvitationDialog()
    }

    /// This function will allow you to display the survey without triggering the intercept/popup first.
    /// It's recommended if you implement a button that should point the user directly to the feedback form.
    /// Please beware that **this function will only work *if* you have already called `initializeProject` at least once within the app lifecycle, and recieved the callback.**
    func giveFeedbackPromptBypassButtonTapped() {
        GiveFeedbackPromptBypassExample().giveFeedbackPromptBypassButtonTapped()
    }
    
    /// This funciton will request the notification permisison to be granted. You need to call this function before you can use Notifications in your app.
    func requestNotificationPermission() {
        RequestNotificationPermissionExample().requestNotificationPermission()
    }
}
