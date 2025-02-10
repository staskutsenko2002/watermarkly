//
//  SettingsRowView.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 05/02/2025.
//

import SwiftUI

struct SettingsRowView: View {
	
	private let title: String
	private let showSeparator: Bool
	private let action: () -> Void
	
	init(title: String, showSeparator: Bool = true, action: @escaping () -> Void) {
		self.title = title
		self.showSeparator = showSeparator
		self.action = action
	}
	
    var body: some View {
		if showSeparator {
			rowView()
				 .listRowSeparator(.visible)
				 .listRowSeparatorTint(Colors.gray2.suiColor)
		} else {
			rowView()
		}
    }
	
	@ViewBuilder
	private func rowView() -> some View {
		HStack {
			Text(title)
				.foregroundStyle(Colors.white.suiColor)
				.font(.system(size: 16, weight: .medium))
			Spacer()
			Image(.chevron)
		}
		.listRowBackground(Colors.background2.suiColor)
		.contentShape(Rectangle())
		.onTapGesture {
			action()
		}
	}
}

#Preview {
	SettingsRowView(title: "Privacy Policy", showSeparator: true, action: {})
}
