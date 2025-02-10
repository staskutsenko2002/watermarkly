//
//  VideoSelectionView.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 31/01/2025.
//

import SwiftUI

struct Movie: Transferable {
	let url: URL

	static var transferRepresentation: some TransferRepresentation {
		FileRepresentation(contentType: .movie) { movie in
			SentTransferredFile(movie.url)
		} importing: { received in
			let copy = URL.documentsDirectory.appending(path: "movie.mp4")

			if FileManager.default.fileExists(atPath: copy.path()) {
				try FileManager.default.removeItem(at: copy)
			}

			try FileManager.default.copyItem(at: received.file, to: copy)
			return Self.init(url: copy)
		}
	}
}

struct VideoSelectionView: View {
	
	@StateObject private var viewModel: VideoSelectionViewModel
	
	init(viewModel: VideoSelectionViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		VStack {
			Spacer()
			Text("Choose Video")
				.font(.system(size: 30, weight: .bold))
				.foregroundStyle(Colors.white.suiColor)
			Text("Choose video that you want to put watermark on")
				.font(.system(size: 16, weight: .medium))
				.foregroundStyle(Colors.gray2.suiColor)
			Spacer()
			PrimaryButton(title: "Choose") {
				viewModel.showPicker = true
			}
			.padding(.horizontal, 16)
		}
		.navigationBar(backButton: backButtonModel())
		.background(Colors.background.suiColor)
		.photosPicker(
			isPresented: $viewModel.showPicker,
			selection: $viewModel.pickerItem,
			matching: .videos)
		.tint(Colors.primaryPink.suiColor)
	}
	
	private func backButtonModel() -> ButtonModel {
		return ButtonModel(icon: Image(.closeArrow), size: 18) {
			viewModel.close()
		}
	}
}

#Preview {
	VideoSelectionView(viewModel: .init(onAction: {_ in}))
}
