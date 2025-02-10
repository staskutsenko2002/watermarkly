//
//  VideoSelectionViewModel.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 31/01/2025.
//

import SwiftUI
import PhotosUI
import Combine

final class VideoSelectionViewModel: ObservableObject {
	// MARK: - Properties
	@Published var showPicker = false
	@Published var pickerItem: PhotosPickerItem?
	private var cancellables = Set<AnyCancellable>()
	
	var onAction: (VideoSelectionAction) -> Void
	
	// MARK: - Init
	init(onAction: @escaping (VideoSelectionAction) -> Void) {
		self.onAction = onAction
		$pickerItem.sink { [weak self] _ in
			self?.processVideoSelection()
		}
		.store(in: &cancellables)
	}
	
	func close() {
		onAction(.close)
	}
	func processVideoSelection() {
		Task.init {
			guard let url = try? await getVideoURL() else { return }
			await MainActor.run {
				onAction(.next(url))
			}
		}
	}
	
	func getVideoURL() async throws -> URL? {
		guard let pickerItem else { return nil }
		
		do {
			guard let movie = try await pickerItem.loadTransferable(type: Movie.self) else { return nil }
			
			let fileURL = movie.url
			let tempDirectory = FileManager.default.temporaryDirectory
			let tempFileURL = tempDirectory.appendingPathComponent(fileURL.lastPathComponent)
			
			if FileManager.default.fileExists(atPath: tempFileURL.path) {
				try FileManager.default.removeItem(at: tempFileURL)
			}
			try FileManager.default.copyItem(at: fileURL, to: tempFileURL)
			return tempFileURL
		} catch {
			throw NSError(domain: "UnsupportedType", code: -1, userInfo: [NSLocalizedDescriptionKey: "The selected item is not a video."])
		}
	}
}

enum VideoSelectionAction {
	case close
	case next(URL)
}
