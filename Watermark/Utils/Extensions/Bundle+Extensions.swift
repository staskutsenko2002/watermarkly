//
//  Bundle+Extensions.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 06/02/2025.
//

import Foundation

extension Bundle {
	var appVersion: String? {
		return infoDictionary?["CFBundleShortVersionString"] as? String
	}
	
	var buildVersion: String? {
		return infoDictionary?["CFBundleVersion"] as? String
	}
}
