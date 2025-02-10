//
//  View+Extensions.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 21/01/2025.
//

import SwiftUI

extension View {
	func navigationBar(title: String? = nil, backButton: ButtonModel? = nil, rightButton: ButtonModel? = nil) -> some View {
		modifier(NavigationBarModifier(title: title, backButton: backButton, rightButton: rightButton))
	}
}
