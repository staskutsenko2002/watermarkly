//
//  ViewController.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 17/01/2025.
//

import UIKit
import Photos
import PhotosUI

final class InitialViewController: UIViewController {
	// MARK: - UI
	private let logoLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = StringConstants.watermarkTitle
		label.font = .systemFont(ofSize: 24, weight: .bold)
		label.textColor = .black
		return label
	}()
	
	private let chooseVideoButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle(StringConstants.chooseVideo, for: .normal)
		button.setTitleColor(.systemBlue, for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
		return button
	}()
	
	// MARK: - Private properties
	private let videoEditor = VideoEditorManager()
	
	// MARK: - Life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		setupConstraints()
	}
}

// MARK: - Setup methods
private extension InitialViewController {
	func setupUI() {
		view.backgroundColor = .white
		chooseVideoButton.addTarget(self, action: #selector(didPressChooseVideo), for: .touchUpInside)
	}
	
	func setupConstraints() {
		view.addSubview(logoLabel)
		view.addSubview(chooseVideoButton)
		
		NSLayoutConstraint.activate([
			logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			logoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
			
			chooseVideoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			chooseVideoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
		])
	}
}

// MARK: - Private methods
private extension InitialViewController {
	func handleLibraryCall() {
		Task.init {
			let isAccessAllowed = await requestLibraryAccess()
			
			if isAccessAllowed {
				showLibrary()
			} else {
				showAccessDeniedAlert()
			}
		}
	}
	
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
	
	func showAccessDeniedAlert() {
		let alert = UIAlertController(title: StringConstants.libraryAccessFailedTitle, message: StringConstants.libraryAccessFailedMessage, preferredStyle: .alert)
		let settingsAction = UIAlertAction(title: StringConstants.goToSettings, style: .default) { _ in
			UIApplication.openSettings()
		}
		let okAction = UIAlertAction(title: StringConstants.okay, style: .cancel)
		
		alert.addAction(settingsAction)
		alert.addAction(okAction)
		present(alert, animated: true)
	}
	
	func showLibrary() {
		// быстрее ли код если писать let name: String = "Stas" или let name = "Stas"
		var configuration = PHPickerConfiguration()
		configuration.selectionLimit = 1
		configuration.filter = .videos
		
		let libraryController = PHPickerViewController(configuration: configuration)
		libraryController.delegate = self
		present(libraryController, animated: true)
	}
	
	func createVideo(result: PHPickerResult) {
		Task.init {
			do {
				guard let inputURL = try await getVideoURL(result) else { return }
				await videoEditor.createVideo(inputURL: inputURL)
			} catch {
				print("ERROR: \(error)")
			}
		}
	}
	
	func getVideoURL(_ result: PHPickerResult) async throws -> URL? {
		let itemProvider = result.itemProvider

		if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
			return try await withCheckedThrowingContinuation { continuation in
				itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { fileURL, error in
					if let error = error {
						continuation.resume(throwing: error)
						return
					}
					
					guard let fileURL = fileURL else {
						continuation.resume(throwing: NSError(domain: "FileError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve file URL"]))
						return
					}

					let tempDirectory = FileManager.default.temporaryDirectory
					let tempFileURL = tempDirectory.appendingPathComponent(fileURL.lastPathComponent)
					
					do {
						if FileManager.default.fileExists(atPath: tempFileURL.path) {
							try FileManager.default.removeItem(at: tempFileURL)
						}
						try FileManager.default.copyItem(at: fileURL, to: tempFileURL)
						continuation.resume(returning: tempFileURL)
					} catch {
						continuation.resume(throwing: error)
					}
				}
			}
		} else {
			throw NSError(domain: "UnsupportedType", code: -1, userInfo: [NSLocalizedDescriptionKey: "The selected item is not a video."])
		}
	}
}

// MARK: - Selectors
@objc private extension InitialViewController {
	func didPressChooseVideo() {
		handleLibraryCall()
	}
}

// MARK: - PHPickerViewControllerDelegate
extension InitialViewController: PHPickerViewControllerDelegate {
	func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
		guard let result = results.first else {
			dismiss(animated: true)
			return
		}
		
		createVideo(result: result)
		dismiss(animated: true)
		print(results)
	}
}
