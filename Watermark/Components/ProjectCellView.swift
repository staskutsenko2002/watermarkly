//
//  ProjectCellView.swift
//  Watermark
//
//  Created by Stanislav KUTSENKO on 21/01/2025.
//

import SwiftUI

struct ProjectCellModel: Equatable {
	let id: String
	let url: URL
	var name: String
	let date: String
}

struct ProjectCellView: View {
	// MARK: - Properties
	private let model: ProjectCellModel
	
	// MARK: - init
	init(model: ProjectCellModel) {
		self.model = model
	}
	
	// MARK: - body
    var body: some View {
		VStack(alignment: .leading) {
			AsyncImage(url: model.url) { image in
					image
						.resizable()
						.aspectRatio(contentMode: .fit)
						
				} placeholder: {
					Color.gray
				}
				.frame(height: 120)
				.cornerRadius(12)
				.overlay(
					RoundedRectangle(cornerRadius: 12)
						.stroke(Colors.primaryPink.suiColor, lineWidth: 1)
				)
			
			Text(model.name)
				.foregroundStyle(Colors.white.suiColor)
				.font(.system(size: 14, weight: .medium))
				.lineLimit(1)
				.padding(.leading, 5)
			Text(model.date)
				.foregroundStyle(Colors.gray2.suiColor)
				.font(.system(size: 11, weight: .medium))
				.padding(.leading, 5)
		}
		.background(Colors.background.suiColor.cornerRadius(12))
    }
}

#Preview {
	ProjectCellView(
		model: .init(
			id: UUID().uuidString,
			url: URL(string: "https://fps.cdnpk.net/images/home/subhome-ai.webp?w=649&h=649")!,
			name: "Tropical waterfall",
			date: "20 Jan 2025"
		)
	)
}
