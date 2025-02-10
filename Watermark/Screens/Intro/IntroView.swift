//
//  IntroView.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 20/01/2025.
//

import SwiftUI

struct IntroView: View {
	
	@StateObject private var viewModel = IntroViewModel()
	
    var body: some View {
		VStack {
			Spacer()
			Text("Watermarkly")
				.font(.system(size: 30, weight: .bold))
				.foregroundStyle(Colors.white.suiColor)
			Spacer()
			PrimaryButton(title: "Get started") {
				viewModel.getStarted()
			}
			.padding(.horizontal, 16)
		}
		.background(Colors.background.suiColor)
    }
}

#Preview {
	IntroView()
}
