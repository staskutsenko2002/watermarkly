//
//  NavigationBarModifier.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 21/01/2025.
//

import SwiftUI

struct NavigationBarModifier: ViewModifier {
	// MARK: - Properties
	private let title: String?
	private let backButton: ButtonModel?
	private let rightButton: ButtonModel?
	
	// MARK: - Init
	init(title: String?, backButton: ButtonModel?, rightButton: ButtonModel?) {
		self.title = title
		self.backButton = backButton
		self.rightButton = rightButton
	}
	
	// MARK: - Body
	@ViewBuilder
	func body(content: Content) -> some View {
		VStack {
			NavigationBarView(title: title, backButton: backButton, rightButton: rightButton)
			content
		}
	}
}

struct ButtonModel {
	let icon: Image
	let size: CGFloat
	let onClick: () -> Void
	
	init(icon: Image, size: CGFloat = 20, onClick: @escaping () -> Void) {
		self.icon = icon
		self.size = size
		self.onClick = onClick
	}
}

enum BackButtonStyle {
	case arrow // for pop
	case cross // for dismiss
}
