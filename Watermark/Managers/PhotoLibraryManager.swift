//
//  PhotoLibraryManager.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 23/01/2025.
//

import Photos

final class PhotoLibraryManager {
	
	@MainActor
	func requestLibraryAccess() async -> Bool {
		let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
		
		switch status {
		case .notDetermined:
			let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
			return status == .authorized || status == .limited
			
		case .restricted, .denied:
			return false
		case .authorized, .limited:
			return true
		default:
			return false
		}
	}
}
