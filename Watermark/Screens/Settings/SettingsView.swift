//
//  SettingsView.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 05/02/2025.
//

import SwiftUI

struct SettingsView: View {
	
	@StateObject private var viewModel: SettingsViewModel
	
	init(viewModel: SettingsViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
    var body: some View {
		VStack {
			List {
				SettingsRowView(title: "Rate the app", showSeparator: false, action: {
					viewModel.rateApp()
				})
				SettingsRowView(title: "Terms and Conditions", action: {
					viewModel.openTermsAndConditions()
				})
				SettingsRowView(title: "Privacy Policy", showSeparator: false, action: {
					viewModel.openPrivacyPolicy()
				})
			}
			.scrollContentBackground(.hidden)
			.overlay(alignment: .bottom) {
				Text(viewModel.appVersion)
					.foregroundStyle(Colors.gray2.suiColor)
			}
		}
		.navigationBar(title: "Settings", backButton: .init(icon: Image(.closeArrow), onClick: {
			viewModel.close()
		}))
		.background(Colors.background.suiColor)
    }
}

#Preview {
	SettingsView(viewModel: .init(onAction: { _ in }))
}
