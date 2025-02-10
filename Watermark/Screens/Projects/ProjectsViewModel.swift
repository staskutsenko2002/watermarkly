//
//  ProjectsViewModel.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 22/01/2025.
//

import Foundation
import Combine

extension ProjectsViewModel {
	enum State: Equatable {
		static func == (lhs: ProjectsViewModel.State, rhs: ProjectsViewModel.State) -> Bool {
			switch (lhs, rhs) {
			case (.empty, .empty):
				return true
			case (.loading, .loading):
				return true
			case (let .loaded(leftModels), let .loaded(rightModels)):
				return leftModels == rightModels
			default:
				return false
			}			
		}
		
		case empty
		case loading
		case loaded([ProjectCellModel])
		
	}
}

final class ProjectsViewModel: ObservableObject {
	// MARK: - Private properties
	private let onAction: (ProjectsAction) -> Void
	
	private let libraryManager: PhotoLibraryManager
	private let dataBaseManager: DataBaseManager
	
	// MARK: - Public properties
	@Published var isLibraryAccessAlertPresented = false
	@Published var isAlertPresented = false
	@Published var alertText = ""
	@Published var selectedItem: ProjectCellModel?
	@Published var state: State = .loading
	
	// MARK: - Init
	init(libraryManager: PhotoLibraryManager, dataBaseManager: DataBaseManager, onAction: @escaping (ProjectsAction) -> Void) {
		self.libraryManager = libraryManager
		self.dataBaseManager = dataBaseManager
		self.onAction = onAction
		loadProjects()
	}
	
	// MARK: - Public methods
	func openProject(id: String) {
		onAction(.openProject(id))
	}
	
	func openSettings() {
		onAction(.openSettings)
	}
	
	func loadProjects() {
		let projects: [Project] = dataBaseManager.load()
		
		let projectCellModels = projects.compactMap { project -> ProjectCellModel? in
			guard let id = project.id else { return nil }
			let createDate = (project.createDate ?? Date()).toShortFormat()
			return ProjectCellModel(id: id, url: URL(string: "https://fps.cdnpk.net/images/home/subhome-ai.webp?w=649&h=649")!, name: project.name ?? "", date: createDate)
		}
		
		state = projectCellModels.isEmpty ? .empty : .loaded(projectCellModels)
	}
	
	func removeProject(withId id: String) {
		guard case let .loaded(projects) = state, let index = projects.firstIndex(where: { $0.id == id }) else { return }
		var newProjects = projects
		let model = newProjects.remove(at: index)
		dataBaseManager.delete(id: model.id, type: Project.self)
		state = .loaded(newProjects)
	}
	
	func updateProject(withId id: String, toName name: String) {
		guard case let .loaded(projects) = state, let index = projects.firstIndex(where: { $0.id == id }) else { return }
		var newProjects = projects
		newProjects[index].name = name
		dataBaseManager.updateProject(id: id, name: name)
		state = .loaded(newProjects)
	}
	
	@MainActor
	func addProject() async {
		guard state != .loading, await validateAccessToLibrary() else {
			isLibraryAccessAlertPresented = true
			return
		}
		
//		let projectCellModel = ProjectCellModel(id: UUID().uuidString, url: URL(string: "https://fps.cdnpk.net/images/home/subhome-ai.webp?w=649&h=649")!, name: "New Project", date: Date().toShortFormat())
//		
//		dataBaseManager.createProject(id: projectCellModel.id, name: projectCellModel.name)
//		
//		switch state {
//		case .empty:
//			state = .loaded([projectCellModel])
//		case .loading:
//			break
//		case .loaded(let models):
//			var updatedProjects = models
//			updatedProjects.append(projectCellModel)
//			state = .loaded(updatedProjects)
//		}
		
		onAction(.createProject)
	}
}

// MARK: - Private methods
private extension ProjectsViewModel {
	func validateAccessToLibrary() async -> Bool {
		return await libraryManager.requestLibraryAccess()
	}
}

enum ProjectsAction {
	case createProject
	case openProject(String)
	case openSettings
}
