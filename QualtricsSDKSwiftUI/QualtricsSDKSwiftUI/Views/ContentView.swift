//
//  ContentView.swift
//  QualtricsSDKSwiftUI
//
//  Created by Qualtrics on 02/02/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Spacer()
            Button("Evaluate Project") {
                viewModel.evaluateProjectButtonTapped()
            }
            Button("Evaluate Intercept") {
                viewModel.evaluateInterceptButtonTapped()
            }
            Button("Request AppStore Review") {
                viewModel.requestReviewWithQualtrics()
            }
            Button("Custom Dialog") {
                viewModel.customSurveyInvitationDialog()
            }
            Button("Evaluate But Bypass Prompt") {
                viewModel.giveFeedbackPromptBypassButtonTapped()
            }
            Button("Request Notification Permission") {
                viewModel.requestNotificationPermission()
            }
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.registerViewVisit()
            viewModel.addEmbeddedText()
        }
        .alert(viewModel.errorAlertTitle, isPresented: $viewModel.showingErrorAlert, actions: {}, message: {
            Text(viewModel.errorAlertMessage)
        })
    }
}
