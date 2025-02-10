//
//  UIApplication+Extensions.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 19/01/2025.
//

import UIKit

extension UIApplication {
	static func openSettings() {
		guard let settingsURL = URL(string: openSettingsURLString), shared.canOpenURL(settingsURL)
		else {
			print("ERROR: Cannot open settingsURL")
			return
		}
		shared.open(settingsURL, options: [:])
	}
	
	static func openAppStore() {
		let appStoreURLString = "https://apps.apple.com"
		guard let appStoreURL = URL(string: appStoreURLString), shared.canOpenURL(appStoreURL) else {
			print("ERROR: Cannot open appStoreURL")
			return
		}
		shared.open(appStoreURL, options: [:])
	}
	
	static func openPrivacyPolicy() {
		
	}
	
	static func openTermsAndConditions() {
		
	}
}
