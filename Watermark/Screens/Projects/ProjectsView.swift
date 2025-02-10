//
//  ProjectsView.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 21/01/2025.
//

import SwiftUI

struct ProjectsView: View {
	
	@StateObject private var viewModel: ProjectsViewModel
	
	init(viewModel: ProjectsViewModel) {
		self._viewModel = StateObject(wrappedValue: viewModel)
	}
	
    var body: some View {
		VStack {
			switch viewModel.state {
			case .empty:
				emptyListView()
					.padding(.horizontal, 16)
			case .loading:
				emptyListView()
					.padding(.horizontal, 16)
			case .loaded(let projects):
				projectsListView(projects: projects)
					.padding(.horizontal, 16)
			}
		}
		.navigationBar(title: "Projects", rightButton: .init(icon: Image(.settings), size: 22, onClick: {
			viewModel.openSettings()
		}))
		.overlay(alignment: .bottom, content: {
			newProjectButton()
		})
		.background(Colors.background.suiColor)
		.alert("Rename project", isPresented: $viewModel.isAlertPresented) {
			TextField("Name", text: $viewModel.alertText)
			Button("Save", action: {
				guard let selectedItem = viewModel.selectedItem, !viewModel.alertText.isEmpty else { return }
				viewModel.updateProject(withId: selectedItem.id, toName: viewModel.alertText)
				viewModel.alertText = ""
				viewModel.selectedItem = nil
			})
			Button("Cancel", role: .cancel, action: {
				viewModel.alertText = ""
				viewModel.selectedItem = nil
			})
		}
		.alert("Photo Library", isPresented: $viewModel.isLibraryAccessAlertPresented) {
			Button("Go to Settings", action: {
				UIApplication.openSettings()
			})
			Button("Okay") {}
		} message: {
			Text("Update library access in the app settings")
		}
    }
	
	@ViewBuilder
	private func emptyListView() -> some View {
		Colors.background.suiColor
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.overlay {
				VStack(spacing: 10) {
					Text("You have no projects for the moment")
						.foregroundStyle(Colors.gray2.suiColor)
						.font(.system(size: 20, weight: .semibold))
					Text("Press \"New Project\" in order to create one")
						.foregroundStyle(Colors.grayText.suiColor)
						.font(.system(size: 14, weight: .medium))
				}
				
			}
	}
	
	@ViewBuilder
	private func projectsListView(projects: [ProjectCellModel]) -> some View {
		let colums = [
			GridItem(.flexible(), spacing: 16),
			GridItem(.flexible(), spacing: 16)
		]
		ScrollView {
			LazyVGrid(columns: colums, spacing: 10) {
				ForEach(projects, id: \.id) { model in
					ProjectCellView(model: model)
						.transition(.asymmetric(insertion: .scale, removal: .identity))
						.contextMenu {
							Button() {
								
							} label: {
								Label("Share", systemImage: "square.and.arrow.up")
							}
							Button {
								viewModel.alertText = model.name
								viewModel.selectedItem = model
								viewModel.isAlertPresented = true
							} label: {
								Label("Rename", systemImage: "pencil")
							}
							Button(role: .destructive) {
								withAnimation {
									viewModel.removeProject(withId: model.id)
								}
							} label: {
								Label("Delete", systemImage: "trash")
							}
						}
				}
			}
		}
	}
	
	@ViewBuilder
	private func newProjectButton() -> some View {
		Button {
			Task(priority: .userInitiated) {
				await viewModel.addProject()
			}
		} label: {
			Colors.primaryPink.suiColor
				.frame(width: 160, height: 44)
				.cornerRadius(30)
				.overlay {
					Text("New Project")
						.font(.system(size: 16, weight: .bold))
						.foregroundStyle(Colors.white.suiColor)
				}
				
		}
	}
}

#Preview {
	ProjectsView(viewModel: .init(libraryManager: .init(), dataBaseManager: DataBaseManagerImpl.shared, onAction: { _ in }))
}
