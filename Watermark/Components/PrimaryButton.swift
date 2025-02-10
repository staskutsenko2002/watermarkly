//
//  PrimaryButton.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 20/01/2025.
//

import SwiftUI

struct PrimaryButton: View {
	// MARK: - Properties
	private let title: String
	private let style: PrimaryButtonStyle
	private let onPress: () -> Void
	
	init(title: String, style: PrimaryButtonStyle = .basic, onPress: @escaping () -> Void) {
		self.title = title
		self.style = style
		self.onPress = onPress
	}
	
	// MARK: - Body
    var body: some View {
		Button {
			onPress()
		} label: {
			Text(title)
				.font(.system(size: 18, weight: .medium))
				.foregroundStyle(style == .basic ? Colors.white.suiColor : Colors.gray2.suiColor)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
		}
		.frame(height: 50)
		.frame(maxWidth: .infinity)
		.background(style == .basic ? Colors.primaryPink.suiColor : Colors.background.suiColor)
		.cornerRadius(16)
		.overlay(
			RoundedRectangle(cornerRadius: 16)
				.stroke(Colors.primaryPink.suiColor, lineWidth: style == .basic ? 0 : 1)
		)
    }
}

#Preview {
	PrimaryButton(title: "Test", style: .basic, onPress: {})
}

enum PrimaryButtonStyle {
	case basic
	case bordered
}
