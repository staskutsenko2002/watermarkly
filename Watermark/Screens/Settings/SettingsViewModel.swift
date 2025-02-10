//
//  SettingsViewModel.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 05/02/2025.
//

import Foundation

final class SettingsViewModel: ObservableObject {
	
	// MARK: - Public properties
	var appVersion: String {
		let version = Bundle.main.appVersion
		let build = Bundle.main.buildVersion
		
		guard let version, let build else { return "" }
		
		return "Version \(version) #\(build)"
	}
	
	// MARK: - Private properties
	private let onAction: (SettingsAction) -> Void
	
	// MARK: - init
	init(onAction: @escaping (SettingsAction) -> Void) {
		self.onAction = onAction
	}
	
	// MARK: - Public methods
	func close() {
		onAction(.close)
	}
	
	func rateApp() {
		onAction(.rateApp)
	}
	
	func openPrivacyPolicy() {
		onAction(.privacyPolicy)
	}
	
	func openTermsAndConditions() {
		onAction(.termsAndConditions)
	}
}

enum SettingsAction {
	case close
	case rateApp
	case privacyPolicy
	case termsAndConditions
}
