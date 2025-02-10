//
//  VideoEditorViewModel.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 06/02/2025.
//

import Foundation


final class VideoEditorViewModel {
		
	let videoURL: URL
	@Published var isPlaying: Bool = true
	@Published var isMuted: Bool = false
	let onAction: (VideoEditorAction) -> Void
	
	init(videoURL: URL, onAction: @escaping (VideoEditorAction) -> Void) {
		self.videoURL = videoURL
		self.onAction = onAction
	}
	
	func close() {
		onAction(.close)
	}
	
	func save() {
		
	}
}

enum VideoEditorAction {
	case close
}
