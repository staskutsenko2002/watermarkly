//
//  AppCoordinator.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 31/01/2025.
//

import UIKit
import SwiftUI

enum ShortcutAction: String {
	case createProject = "Create"
}

protocol Coordinator {
	func start()
}

protocol Shortcutable {
	func performShortcutAction(_ action: ShortcutAction)
}

final class AppCoordinator: Coordinator, Shortcutable {
	
	private let window: UIWindow
	private let navigationController: UINavigationController
	
	init(window: UIWindow) {
		self.window = window
		self.navigationController = UINavigationController()
	}
	
	func start() {
		let viewModel = ProjectsViewModel(
			libraryManager: .init(),
			dataBaseManager: DataBaseManagerImpl.shared,
			onAction: { [weak self] action in self?.handleProjectsAction(action) }
		)
		let view = ProjectsView(viewModel: viewModel)
		let viewController = UIHostingController(rootView: view)
		navigationController.isNavigationBarHidden = true
		navigationController.setViewControllers([viewController], animated: false)
		window.rootViewController = navigationController
		window.makeKeyAndVisible()
	}
	
	func performShortcutAction(_ action: ShortcutAction) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			switch action {
			case .createProject:
				self.openVideoSelection()
			}
		}
	}
}

// MARK: - Private functions
private extension AppCoordinator {
	
	@objc func didPop() {
		pop(animated: true)
	}
	
	func dismiss(animated: Bool) {
		navigationController.dismiss(animated: animated)
	}
	
	func pop(animated: Bool) {
		navigationController.popViewController(animated: true)
	}
	
	func popToRoot(animated: Bool) {
		navigationController.popToRootViewController(animated: true)
	}
}

// MARK: - Opening
private extension AppCoordinator {
	func openProject(_ projectId: String) {
		
	}
	
	func openVideoEditor(url: URL) {
		let viewModel = VideoEditorViewModel(
			videoURL: url,
			onAction: { [weak self] action in self?.handleVideoEditorAction(action) }
		)
		let viewController = VideoEditorViewController(viewModel: viewModel)
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func openVideoSelection() {
		let viewModel = VideoSelectionViewModel(onAction: { [weak self] action in self?.handleVideoSelectionAction(action)})
		let view = VideoSelectionView(viewModel: viewModel)
		let viewController = UIHostingController(rootView: view)
		viewController.modalPresentationStyle = .overFullScreen
		viewController.modalTransitionStyle = .coverVertical
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func openSettings() {
		let viewModel = SettingsViewModel(onAction: { [weak self] action in self?.handleSettingsAction(action) })
		let view = SettingsView(viewModel: viewModel)
		let viewController = UIHostingController(rootView: view)
		navigationController.pushViewController(viewController, animated: true)
	}
}

// MARK: - Action Handling
private extension AppCoordinator {
	func handleVideoEditorAction(_ action: VideoEditorAction) {
		switch action {
		case .close:
			popToRoot(animated: true)
		}
	}
	
	func handleVideoSelectionAction(_ action: VideoSelectionAction) {
		switch action {
		case .close:
			pop(animated: true)
		case .next(let url):
			openVideoEditor(url: url)
		}
	}

	func handleProjectsAction(_ action: ProjectsAction) {
		switch action {
		case .createProject:
			openVideoSelection()
		case .openProject(let projectId):
			openProject(projectId)
		case .openSettings:
			openSettings()
		}
	}

	func handleSettingsAction(_ action: SettingsAction) {
		switch action {
		case .close:
			self.pop(animated: true)
		case .rateApp:
			UIApplication.openAppStore()
		case .privacyPolicy:
			UIApplication.openPrivacyPolicy()
		case .termsAndConditions:
			UIApplication.openTermsAndConditions()
		}
	}
}
