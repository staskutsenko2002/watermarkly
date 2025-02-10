//
//  NavigationBarView.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 21/01/2025.
//

import SwiftUI

struct NavigationBarView: View {
	// MARK: - Properties
	let title: String?
	let backButton: ButtonModel?
	let rightButton: ButtonModel?
	
	// MARK: - Init
	init(title: String? = nil, backButton: ButtonModel? = nil, rightButton: ButtonModel? = nil) {
		self.title = title
		self.rightButton = rightButton
		self.backButton = backButton
	}
	
	// MARK: - Body
    var body: some View {
		Colors.background.suiColor
			.frame(height: 50)
			.overlay {
				HStack {
					if let backButton {
						makeButton(backButton)
							.padding(.trailing, 5)
					}
					if let title {
						Text(title)
							.font(.system(size: 24, weight: .bold))
							.foregroundStyle(Colors.white.suiColor)
					}
					Spacer()
					if let rightButton {
						makeButton(rightButton)
					}
				}
				.padding(.horizontal)
			}
			.background(Colors.background.suiColor)
    }
	
	@ViewBuilder
	private func makeButton(_ buttonModel: ButtonModel) -> some View {
		Button {
			buttonModel.onClick()
		} label: {
			buttonModel.icon
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: buttonModel.size, height: buttonModel.size)
		}
	}
}

#Preview {
	NavigationBarView(
		title: "Projects",
		backButton: .init(
			icon: Image(.closeCross),
			size: 18,
			onClick: {}
		),
		rightButton: .init(
			icon: Image(.plus),
			onClick: {}
		)
	)
}
